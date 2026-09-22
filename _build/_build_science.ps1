$ErrorActionPreference = 'Stop'

$src = 'D:\vektor-vits\_build\_src\links_utf8.html'
$out = 'D:\vektor-vits\science.html'

$lines = Get-Content -LiteralPath $src -Encoding UTF8

# ---- section ranges (1-based inclusive, verified against source) ----
$sections = @(
  @{ Key = 'brosh';  Start = 180;  End = 219  },
  @{ Key = 'paper';  Start = 222;  End = 1147 },
  @{ Key = 'patent'; Start = 1150; End = 1455 },
  @{ Key = 'diser';  Start = 1458; End = 1544 },
  @{ Key = 'conf';   Start = 1547; End = 2219 },
  @{ Key = 'other';  Start = 2222; End = 2435 }
)

function Get-SectionHtml {
  param([int]$Start, [int]$End, [string]$Key, [string]$Title)
  $text = ($lines[($Start - 1)..($End - 1)]) -join "`n"
  # remove HTML comments (including multi-line)
  $text = [regex]::Replace($text, '(?s)<!--.*?-->', '')
  # remove "Наверх" top-anchors
  $text = [regex]::Replace($text, '(?s)<a href="#TopOfThePage">.*?</a>', '')
  # turn the in-page anchor heading into our styled h2
  $text = [regex]::Replace($text, '(?s)<a name="' + [regex]::Escape($Key) + '">.*?</a>', '<h2 class="sec-title" id="' + $Key + '">' + $Title + '</h2>')
  # remove stray '. ' following the old anchor syntax, e.g. '</h2>.'
  $text = [regex]::Replace($text, '(?m)</h2>\s*\.\s*$', '</h2>')
  # strip legacy layout tags
  $text = $text -replace '<h3>', '' -replace '</h3>', ''
  $text = $text -replace '<br>', ''
  $text = [regex]::Replace($text, '<font[^>]*>', '')
  $text = $text -replace '</font>', ''
  # make relative PDF/HTM links absolute to the original host (quoted form)
  $text = $text -replace 'href="Documents/', 'href="https://vector-vita.narod.ru/Documents/'
  # and unquoted form: href=Documents/... (value ends at first whitespace/quote/'>')
  $text = [regex]::Replace($text, 'href=Documents/([^\s"''>]+)', 'href="https://vector-vita.narod.ru/Documents/$1"')
  # drop dead interactive wrappers from the original: <div id=navHeaderN onClick=shiftSubDiv(N)> ... </div>
  $text = [regex]::Replace($text, '<div\s+id="navHeader\d+"\s+onClick="shiftSubDiv\(\d+\)">', '')
  $text = $text -replace '</div>', ''
  $text = [regex]::Replace($text, '<ol\s+id="subDiv\d+"\s+style="display:block">', '<ol>')
  # fix a stray close-tag in the 2022 monograph item (СФНЦА РАН</a>, 2022. 277 c.)
  $text = [regex]::Replace($text, '</a>, 2022\. 277 c\.', ', 2022. 277 c.')
  # fix a stray close-tag after «Кубанского государственного аграрного университета</a>, 2018. №142.»
  $text = [regex]::Replace($text, '</a>,\s*2018\. №142\.', ', 2018. №142.')
  # fix a broken anchor from the source: href="http://www.cnyn.unam.mx/sinn2013/>SINN-2013"</a>
  $text = $text.Replace('<a href="http://www.cnyn.unam.mx/sinn2013/>SINN-2013"</a>', '<a href="http://www.cnyn.unam.mx/sinn2013/" title="cnyn.unam.mx">SINN-2013</a>')
  # trim stray whitespace inside href attribute values (URLs split across source lines)
  $text = [regex]::Replace($text, 'href="\s+', 'href="')
  $text = [regex]::Replace($text, '(href="[^"]*?)\s+"', '$1"')
  # drop whitespace-only lines
  $text = ($text -split "`r?`n" | Where-Object { $_.Trim() -ne '' }) -join "`n"
  return $text
}

# Extract section titles from the source anchors themselves (avoids Cyrillic literals)
foreach ($s in $sections) {
  $anchorLine = $lines[($s.Start - 1)]
  $m = [regex]::Match($anchorLine, '<a name="' + [regex]::Escape($s.Key) + '">(.*?)</a>')
  if ($m.Success) { $s.Title = $m.Groups[1].Value } else { $s.Title = $s.Key }
}

$head = @'
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Наука: брошюры, статьи, патенты, диссертации — НПЦ «Вектор-Вита»</title>
  <meta name="description" content="Научная база ООО НПЦ «Вектор-Вита»: монография «Серебро в медицине», более 150 научных статей (Web of Science, Scopus, РИНЦ), более 50 патентов России и Мексики, диссертации, материалы конференций и публикации СМИ о серебросодержащих препаратах.">
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="brand" href="index.html" aria-label="На главную">
      <img src="img/logo1.jpg" alt="Логотип НПЦ Вектор-Вита">
      <span class="brand-name">ООО НПЦ «Вектор-Вита»
        <small>Кластерное серебро</small></span>
    </a>
    <button class="nav-toggle" aria-label="Меню" aria-expanded="false">☰</button>
    <nav class="main-nav">
      <ul>
        <li><a href="index.html">Главная</a></li>
        <li><a href="products.html">Продукция</a></li>
        <li><a href="argovit.html">Арговит</a></li>
        <li><a href="applications.html">Применения</a></li>
        <li><a href="partners.html">Партнёры</a></li>
        <li><a href="science.html">Наука</a></li>
        <li><a href="contacts.html">Контакты</a></li>
      </ul>
    </nav>
  </div>
</header>

<main>
  <section class="hero">
    <div class="wrap">
      <p class="breadcrumb">Главная / Наука</p>
      <h1>Наука, статьи, патенты</h1>
      <p class="subtitle">Брошюры и монографии, научные статьи (Web of Science, Scopus, РИНЦ), патенты России и Мексики, диссертации, материалы научно-практических конференций и публикации в СМИ — результаты изучения и применения препаратов серебра НПЦ «Вектор-Вита».</p>
    </div>
  </section>

  <section class="section">
    <div class="wrap">
      <div class="toc">
        <a href="#brosh">Брошюры, монография</a>
        <a href="#paper">Научные статьи</a>
        <a href="#patent">Патенты</a>
        <a href="#diser">Диссертации</a>
        <a href="#conf">Конференции, презентации</a>
        <a href="#other">СМИ</a>
      </div>
'@

$covidBlock = @'
      <h2 class="sec-title" style="margin-top:40px" id="covid">Наши разработки для профилактики COVID-19</h2>
      <div class="covid-box">
        <h3>Средство для полоскания горла на основе Арговита-С</h3>
        <p>В трёх следующих (мексиканских) статьях в качестве средства для полоскания горла применялся разбавленный Арговит-С — производимая нами субстанция биосеребра. В двух последующих статьях систематизирован этот опыт.</p>
        <ul class="ref-list">
          <li>Статья (на испанском) <a href="https://newsweekespanol.com/2020/06/prueban-con-exito-en-el-hospital-general-de-tijuana-un-producto-que-previene-el-covid-19/" title="newsweekespanol.com">Prueban con éxito en el Hospital General de Tijuana un producto que previene el COVID-19</a> (Продукт, предотвращающий COVID-19, успешно прошёл испытания в Главной больнице Тихуаны) в журнале «Newsweek», 17 июня 2020 г.</li>
          <li>Статья (на испанском) <a href="https://www.elsoldetijuana.com.mx/local/ofrecen-proteccion-extra-a-personal-de-salud-que-combate-covid-19-5378378.html" title="elsoldetijuana.com.mx">Ofrecen protección extra a personal de salud que combate Covid-19</a> (Предложение дополнительной защиты медицинскому персоналу, сражающемуся с COVID-19) в журнале «El Sol de Tijuana», 17 июня 2020 г.</li>
          <li>Статья (на испанском) <a href="https://www.elimparcial.com/estilos/Crean-en-Tijuana-enjuague-bucal-que-aseguran-previene-infeccion-por-Covid-19-20200618-0104.html" title="elimparcial.com">Crean en Tijuana enjuague bucal que, aseguran, previene infección por Covid-19</a> (В Тихуане создают жидкость для полоскания рта, которая, как уверяют, предотвращает заражение Covid-19) в журнале «El Imparcial», 18 июня 2020 г.</li>
          <li>Бурмистров В.А., Богданчикова Н.Е., Гюсан А.О., Ураскулова Б.Б., Альманса-Рейес О., Альварадо-Вера М., Пласенсия-Лопес И., Пестряков А.Н., Рачковская Л.Н., Летягин А.Ю. <a href="https://elibrary.ru/item.asp?id=47108282" title="elibrary.ru">Перспективы использования препаратов наноструктурированного серебра для борьбы с инфекционными заболеваниями, включая COVID-19.</a> Сибирский научный медицинский журнал. 2021. Т.41. №5. С.4-15. DOI: <a href="https://doi.org/10.18699/SSMJ20210501" title="doi">10.18699/SSMJ20210501</a></li>
          <li>Almanza-Reyes H., Moreno S., Plascencia-López I., Alvarado-Vera M., Patrón-Romero L., Borrego B., Reyes-Escamilla A., Valencia-Manzo D., Brun A., Pestryakov A., Bogdanchikova N. <a href="https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0256401" title="journals.plos.org">Evaluation of silver nanoparticles for the prevention of SARS-CoV-2 infection in health workers: <i>In vitro</i> and <i>in vivo</i>.</a> (2021) PLoS ONE 16(8): e0256401. DOI: <a href="https://doi.org/10.1371/journal.pone.0256401" title="doi">10.1371/journal.pone.0256401</a></li>
        </ul>
      </div>
'@

$footer = @'
    </div>
  </section>
</main>

<footer class="site-footer">
  <div class="wrap">
    <div>
      <h4>ООО НПЦ «Вектор-Вита»</h4>
      <p style="margin:0 0 10px">Разработка и производство препаратов на основе кластерного серебра для косметологии, медицины и ветеринарии.</p>
      <p style="margin:0">630098, Новосибирск-98, а/я 55<br>Директор: Илья Васильевич Бурмистров</p>
    </div>
    <div>
      <h4>Разделы</h4>
      <ul>
        <li><a href="products.html">Продукция</a></li>
        <li><a href="argovit.html">Биосеребро Арговит</a></li>
        <li><a href="applications.html">Примеры использования</a></li>
        <li><a href="partners.html">Сотрудничество</a></li>
        <li><a href="science.html">Статьи, патенты, диссертации</a></li>
      </ul>
    </div>
    <div>
      <h4>Контакты</h4>
      <ul>
        <li><a href="mailto:vector-vita.spc@ya.ru">vector-vita.spc@ya.ru</a></li>
        <li><a href="mailto:vector-vita@mail.ru">vector-vita@mail.ru</a></li>
        <li>тел. (383) 239-25-30</li>
        <li>тел./факс (383) 345-30-65</li>
        <li><a href="tel:+79833102530">+7 983 310 25 30</a></li>
      </ul>
    </div>
  </div>
  <div class="footer-bottom">© ООО НПЦ «Вектор-Вита». Сайт — современная версия vector-vita.narod.ru</div>
</footer>

<button class="to-top" aria-label="Наверх">↑</button>
<script src="js/main.js"></script>
</body>
</html>
'@

$sectionsHtml = foreach ($s in $sections) {
  Get-SectionHtml -Start $s.Start -End $s.End -Key $s.Key -Title $s.Title
}

$html = $head + "`n" + $covidBlock + "`n" + ($sectionsHtml -join "`n") + "`n" + $footer

[System.IO.File]::WriteAllText($out, $html, (New-Object System.Text.UTF8Encoding($false)))

# ---- validation ----
Write-Host "science.html written: $((Get-Item -LiteralPath $out).Length) bytes"

foreach ($s in $sections) {
  $block = Get-SectionHtml -Start $s.Start -End $s.End -Key $s.Key -Title $s.Title
  $openA   = ([regex]::Matches($block, '<a(\s|>)')).Count
  $closeA  = ([regex]::Matches($block, '</a>')).Count
  $openOl  = ([regex]::Matches($block, '<ol')).Count
  $closeOl = ([regex]::Matches($block, '</ol>')).Count
  $openUl  = ([regex]::Matches($block, '<ul')).Count
  $closeUl = ([regex]::Matches($block, '</ul>')).Count
  Write-Host ("  {0,-8} a:{1}/{2}  ol:{3}/{4}  ul:{5}/{6}  len:{7}" -f $s.Key, $openA, $closeA, $openOl, $closeOl, $openUl, $closeUl, $block.Length)
}