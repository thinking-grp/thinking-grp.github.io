window.onload = () => {
  document.getElementsByTagName('head')[0].innerHTML = `
  ${document.getElementsByTagName('head')[0].innerHTML}
  <link rel="stylesheet" href="/style/main.css">
  `
  document.body.innerHTML = `
  <header>
    <div>
      <a href="/" id="header-icon"></a>
      <div id="header-buttons">
        <a href="/about/">About</a>
        <a href="/project/">Project</a>
        <a href="/blog/">Blog</a>
      </div>
    </div>
  </header>
  ${document.body.innerHTML}
  <footer>
    <div class="footerColumn">
      <p><a href="/about/">私たちについて</a></p>
      <p><a href="/blog/">ブログ</a></p>
      <p><a href="/sitemap">サイトマップ</a></p>
      <p><a href="/contact">お問い合わせ</a></p>
      <p><a href="/join">応募する</a></p>
    </div>
    <div class="footerColumn">
      <p><a href="/about/dept/" class="footer-bigger">部署一覧</a></p>
      <p><a href="/project/thinkfont/">thinkFont</a></p>
      <p><a href="/project/thinkos/">thinkOS</a></p>
      <p><a href="/about/dept/web/">Web開発</a></p>
      <p><a href="/about/dept/material/">素材等作成</a></p>
    </div>
    <div class="footerColumn">
      <p><a href="/project/" class="footer-bigger">プロジェクト一覧</a></p>
      <p><a href="/project/thinkfont">thinkFont</a></p>
      <p><a href="/project/thinkos">thinkOS</a></p>
      <p><a href="https://sorakime.github.io/mncr/">monochrome Project.</a></p>
    </div>
    <div class="footerColumn">
      <p><a href="/agreement">プライバシーポリシーと利用規約</a></p>
      <p>Copyright &copy; 2022 thinking All rights reserved.</p>
    </div>
  </footer>
  `
  window.addEventListener('scroll', () => {
    let scrollTop = document.documentElement.scrollTop;
    let sliderHeight = document.getElementById('slider').getBoundingClientRect().height;
    if (scrollTop >= sliderHeight - 60) {
      document.getElementsByTagName('header')[0].style.height = '40px';
    } else {
      document.getElementsByTagName('header')[0].style.height = '60px';
    }
  })
}
