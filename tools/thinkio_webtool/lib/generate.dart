import "dart:io";
import "package:yaml/yaml.dart" show YamlMap;
import "package:thinkio_webtool/mprof.dart";
import "package:thinkio_webtool/blogind.dart";
import "package:thinkio_webtool/templater.dart";
import "package:thinkio_webtool/sitemap.dart";
import "package:thinkio_webtool/xlib.dart";

class LoadedData {
  final Directory base;
  final Iterable<BlogRec> blogsAll;
  final Iterable<MemberProfile> members;
  
  LoadedData({required Directory base, required Iterable<String> blogPath, required Iterable<String> memberPath}):
    this.base = base,
    this.blogsAll = LoadedData.load<BlogRec>(base, blogPath, BlogRec.fromYaml, needSort: true, reverse: true),
    this.members = LoadedData.load<MemberProfile>(base, memberPath, MemberProfile.fromYaml, needSort: true, filterItem: (MemberProfile mp) => mp.current);
  
  Iterable<BlogRec> blogsLimit(int count)
    => this.blogsAll.take(count);
  
  static Iterable<H> load<H extends Buildable>(Directory base, Iterable<String> dataPath, H Function(YamlMap) fromYaml, {bool needSort = false, bool reverse = false, int? limit, bool Function(H)? filterItem})
    => base.cd<File>(dataPath).readAsStringSync().construct<H>(fromYaml, needSort: needSort, reverse: reverse, limit: limit, filterItem: filterItem);
}

void generate_sitemap(LoadedData ld){
  print("generate:generate_sitemap()");
  Uri u = ld.base.uri;
  File out = File.fromUri(u.cd(<String>["sitemap.xml"]));
  genSitemap(u, out, ld.blogsAll);
}
void generate_member(LoadedData ld, PageFiles fin, File fout){
  final tlr = Templater(ld.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.constructWith<MemberProfile>("body", ld.members, n: 4);
  tlr.finate();
}
void generate_blog_index(LoadedData ld, PageFiles fin, File fout){
  final tlr = Templater(ld.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.constructWith<BlogRec>("articles", ld.blogsAll, n: 4);
  tlr.finate();
}
void generate_root_index(LoadedData ld, PageFiles fin, File fout){
  final tlr = Templater(ld.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.constructWith<BlogRec>("articles", ld.blogsLimit(5), n: 4);
  tlr.finate();
}