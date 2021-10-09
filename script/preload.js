document.getElementsByTagName('head')[0].innerHTML=`
${document.getElementsByTagName('head')[0].innerHTML}
<link rel="stylesheet" href="/style/main.css">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width,initial-scale=1">
<script src="https://unpkg.com/jquery@3.6.0/dist/jquery.min.js"></script>
`

window.onload=()=>{
  document.body.innerHTML=`
  <header>
    <div>
      <a href="/"></a>
      <a href="/member.html">メンバー</a>
      <a href="/article/">記事</a>
    </div>
  </header>
  ${document.body.innerHTML}
  <footer>
    <small>Copyright &copy; 2021 thinking All rights reserved.</small>
  </footer>
  `
}
