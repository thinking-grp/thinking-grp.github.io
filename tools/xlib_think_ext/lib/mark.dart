import "package:markdown/markdown.dart" as m;
import "package:web/web.dart" as w;

w.HTMLElement markdownToHtmlDOM(String markdown, m.Document doc)
  => renderToHtmlDOM(doc.parse(markdown));

w.HTMLElement renderToHtmlDOM(List<m.Node> nodes){}