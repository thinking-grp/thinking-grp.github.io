import "dart:io";
import "package:thinkio_webtool/mprof.dart";
import "package:thinkio_webtool/blogind.dart";
import "package:thinkio_webtool/templater.dart";
import "package:thinkio_webtool/sitemap.dart";
import "package:thinkio_webtool/xlib.dart";


void generate_sitemap(Directory base, Iterable<String> data){
  String data = base.cd<File>(data).readAsStringSync();
  File out = base.cd<File>(<String>["sitemap.xml"]);
  genSitemap(out, data.construct(BlogRec.fromYaml, needSort: true, reverse: true));
}
void generate_member(PageFiles fin, File fout){
  final tlr = Templater(fin.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.construct<MemberProfile>("body", fin.data, MemberProfile.fromYaml, needSort: true, filterItem: (MemberProfile mp) => mp.current, n: 4);
  tlr.finate();
}
void generate_blog_index(PageFiles fin, File fout){
  final tlr = Templater(fin.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.construct<BlogRec>("articles", fin.data, BlogRec.fromYaml, needSort: true, limit: 5, reverse: true, n: 4);
  tlr.finate();
}
void generate_root_index(PageFiles fin, File fout){
  final tlr = Templater(fin.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.construct<BlogRec>("articles", fin.data, BlogRec.fromYaml, needSort: true, limit: 5, reverse: true, n: 4);
  tlr.finate();
}