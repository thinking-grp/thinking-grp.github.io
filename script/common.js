window.onload = () => {
  document.head.innerHTML += `<meta name="viewport" content="width=device-width, initial-scale=1">`
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
      <p><a href="/wallpaper">壁紙ダウンロード</a></p>
    </div>
    <div class="footerColumn">
      <p><a href="/about/dept/" class="footer-bigger">部署一覧</a></p>
      <p><a href="/project/thinkfont/">thinkFont</a></p>
      <p><a href="/project/thinkos/">thinkOS</a></p>
      <p><a href="/project/thinkerAI/">thinkerAI</a></p>
      <p><a href="/about/dept/web/">Web開発</a></p>
      <p><a href="/about/dept/material/">素材等作成</a></p>
    </div>
    <div class="footerColumn">
      <p><a href="/project/" class="footer-bigger">プロジェクト一覧</a></p>
      <p><a href="/project/thinkfont">thinkFont</a></p>
      <p><a href="/project/thinkos">thinkOS</a></p>
      <p><a href="/project/thinkerAI/">thinkerAI</a></p>
      <p><a href="https://mncrp.github.io/">monochrome Project.</a></p>
    </div>
    <div class="footerColumn">
      <p><a href="/agreement">プライバシーポリシーと利用規約</a></p>
      <div class="year-s">
        <p>&copy; &#160;<div>2022-</div><div id="year"></div></p>
      </div>
      <p>thinking All rights reserved.</p>
    </div>
  </footer>
  `;
//2020-OOOO year
  date = new Date();
  year = date.getFullYear();
  document.getElementById("year").innerHTML = year;

  window.addEventListener('scroll', () => {
    let scrollTop = document.documentElement.scrollTop;
    let sliderHeight = document.getElementById('slider').getBoundingClientRect().height;
    if (scrollTop >= sliderHeight - 60) {
      document.getElementsByTagName('header')[0].style.height = '40px';
    } else {
      document.getElementsByTagName('header')[0].style.height = '60px';
    }
  });
}
