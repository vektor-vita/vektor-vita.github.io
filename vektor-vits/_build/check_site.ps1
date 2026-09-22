$ErrorActionPreference = 'Stop'
$root = 'D:\vektor-vits'
$pages = @('index.html','products.html','argovit.html','applications.html','partners.html','science.html','contacts.html')
$issues = New-Object System.Collections.Generic.List[string]

foreach ($p in $pages) {
  $path = Join-Path $root $p
  if (-not (Test-Path -LiteralPath $path)) { $issues.Add("MISSING PAGE: $p"); continue }
  $text = [System.IO.File]::ReadAllText($path)

  if ($text -notmatch '<!DOCTYPE html>') { $issues.Add("$p : missing doctype") }
  if ($text -notmatch 'lang="ru"')      { $issues.Add("$p : missing lang=ru") }
  if ($text -notmatch 'css/style\.css') { $issues.Add("$p : missing css link") }
  if ($text -notmatch 'js/main\.js')    { $issues.Add("$p : missing js include") }
  if ($text -notmatch 'site-header')    { $issues.Add("$p : missing header") }
  if ($text -notmatch 'site-footer')    { $issues.Add("$p : missing footer") }
  if ($text -notmatch '</html>')        { $issues.Add("$p : missing </html>") }

  # local resources (css/js/img) must exist
  foreach ($m in [regex]::Matches($text, '(?:href|src)="((?:css|js|img)/[^"]+)"')) {
    $rel = $m.Groups[1].Value
    $full = Join-Path $root ($rel -replace '/', '\')
    if (-not (Test-Path -LiteralPath $full)) { $issues.Add("$p : MISSING RESOURCE $rel") }
  }

  # internal page links must exist
  foreach ($m in [regex]::Matches($text, 'href="([a-z]+\.html)(?:#([a-zA-Z0-9_-]+))?"')) {
    $target = $m.Groups[1].Value; $anchor = $m.Groups[2].Value
    $full = Join-Path $root $target
    if (-not (Test-Path -LiteralPath $full)) { $issues.Add("$p : BROKEN LINK to $target") }
    if ($anchor) {
      $ttext = [System.IO.File]::ReadAllText($full)
      if ($ttext -notmatch ('id="' + [regex]::Escape($anchor) + '"')) { $issues.Add("$p : anchor #$anchor not found in $target") }
    }
  }

  # same-page anchors
  foreach ($m in [regex]::Matches($text, 'href="#([a-zA-Z0-9_-]+)"')) {
    $a = $m.Groups[1].Value
    if ($text -notmatch ('id="' + [regex]::Escape($a) + '"') -and $text -notmatch ('name="' + [regex]::Escape($a) + '"')) {
      $issues.Add("$p : MISSING same-page anchor #$a")
    }
  }

  # PDF/HTM external resource links must point to original host or be absolute http(s)
  foreach ($m in [regex]::Matches($text, 'href="(https?://[^"]+\.(?:pdf|htm|html))"')) {
    $u = $m.Groups[1].Value
    if ($u -notmatch '^https?://') { $issues.Add("$p : non-absolute file link $u") }
  }
  # relative-looking external files
  foreach ($m in [regex]::Matches($text, 'href="((?!https?://|#|mailto:|tel:|fax:|css/|js/|img/|[a-z]+\.html)[^"]+\.(?:pdf|htm|html))"')) {
    $issues.Add("$p : RELATIVE file link $($m.Groups[1].Value)")
  }
}

$imgRoot = Join-Path $root 'img'
$imgCount = (Get-ChildItem -LiteralPath $imgRoot -Recurse -File | Measure-Object).Count
Write-Host "images on disk: $imgCount"

if ($issues.Count -eq 0) {
  Write-Host "=== ALL CHECKS PASSED ($($pages.Count) pages) ==="
} else {
  Write-Host "=== ISSUES: $($issues.Count) ==="
  $issues | ForEach-Object { Write-Host "  $_" }
}