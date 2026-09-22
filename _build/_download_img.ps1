$ErrorActionPreference = 'Continue'
$base = 'https://vector-vita.narod.ru'
$outRoot = 'D:\wexus music\vector-vita\img'
New-Item -ItemType Directory -Force -Path "$outRoot\awards", "$outRoot\appl", "$outRoot\EM" | Out-Null

$items = @(
  # [url, destination relative path]
  @("$base/logo1.jpg", "logo1.jpg"),
  @("$base/set_products.JPG", "set_products.JPG"),
  @("$base/argogel.jpg", "argogel.jpg"),
  @("$base/argokrem.jpg", "argokrem.jpg"),
  @("$base/powder.jpg", "powder.jpg"),
  @("$base/argovit.jpg", "argovit.jpg"),
  @("$base/Documents/pics/InnotechExpo2011thumb.jpg", "awards/InnotechExpo2011thumb.jpg"),
  @("$base/Documents/pics/BITSib2010thumb.jpg", "awards/BITSib2010thumb.jpg"),
  @("$base/Documents/pics/SibFair2008thumb.jpg", "awards/SibFair2008thumb.jpg"),
  @("$base/Documents/pics/SibFair2007thumb.jpg", "awards/SibFair2007thumb.jpg"),
  @("$base/Documents/pics/Argovit2001thumb.jpg", "awards/Argovit2001thumb.jpg"),
  @("$base/argovit25/images/logo1.jpg", "EM/../logo_bio.jpg"),
  @("$base/argovit25/images/EM/EM_ArgovitBio20.jpg", "EM/EM_ArgovitBio20.jpg"),
  @("$base/argovit25/images/EM/EM_ArgovitBio10.png", "EM/EM_ArgovitBio10.png"),
  @("$base/argovit25/images/EM/gis_ArgovitBio.png", "EM/gis_ArgovitBio.png"),
  @("$base/argovit25/images/EM/EM_ArgovitC100.png", "EM/EM_ArgovitC100.png"),
  @("$base/argovit25/images/EM/gis_ArgovitC.png", "EM/gis_ArgovitC.png"),
  @("$base/argovit25/images/EM/EM_ArgovitPVP1_100.png", "EM/EM_ArgovitPVP1_100.png"),
  @("$base/argovit25/images/EM/gis_ArgovitPVP1.png", "EM/gis_ArgovitPVP1.png"),
  @("$base/argovit25/images/EM/EM_ArgovitPVP2_50-1.jpg", "EM/EM_ArgovitPVP2_50-1.jpg"),
  @("$base/argovit25/images/EM/EM_ArgovitPVP2_50-2.jpg", "EM/EM_ArgovitPVP2_50-2.jpg"),
  @("$base/argovit25/images/EM/EM_ArgovitPVP3_100-1.png", "EM/EM_ArgovitPVP3_100-1.png"),
  @("$base/argovit25/images/EM/EM_ArgovitPVP3_100-2.png", "EM/EM_ArgovitPVP3_100-2.png")
)

foreach ($c in $items) {
  $url = $c[0]
  $rel = $c[1]
  $dest = Join-Path $outRoot $rel
  $destDir = Split-Path $dest -Parent
  New-Item -ItemType Directory -Force -Path $destDir | Out-Null
  curl.exe -L --fail --silent --show-error -o $dest $url 2>$null
}

# 10appl card + detail images
$applNames = @(
  '1.1.lor.jpg','1.2.tub.jpg','1.3.diab.jpg','1.4.onco.jpg','1.5.antibiotics.jpg',
  '2.1.mastit.jpg','2.2.bad.jpg','2.3.kishe.jpg','2.4.pets.jpg','2.5.rast.jpg',
  '1.01.lor.jpg','1.02.tub.jpg','1.03.diab.jpg','1.04.onco.jpg','1.05.antibiotics.jpg',
  '2.01.mastit.jpg','2.02.bad.jpg','2.03.kishe.jpg','2.04.pets.jpg','2.05.rast.jpg'
)
foreach ($n in $applNames) {
  $url = "$base/argovit25/images/10appl/$n"
  $dest = Join-Path "$outRoot\appl" $n
  curl.exe -L --fail --silent --show-error -o $dest $url 2>$null
}

# Report results
Get-ChildItem $outRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
  "{0,10}  {1}" -f $_.Length, ($_.FullName.Substring($outRoot.Length + 1))
}