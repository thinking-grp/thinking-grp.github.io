function article(markdown){
  document.getElementsByTagName('head')[0].innerHTML=`
  ${document.getElementsByTagName('head')[0].innerHTML}
  <link rel="stylesheet" href="/style/article.css">`
  let html=marked(markdown);
  document.getElementsByTagName('div')[0].innerHTML=`
  <div>
    <h1 style="font-weight: 200">
      ${document.getElementsByTagName('title')[0].innerText.substring(0, 
        document.getElementsByTagName('title')[0].innerText.indexOf('-')-1)}
    </h1>
    <article>${html}</article>
  </div>`
}