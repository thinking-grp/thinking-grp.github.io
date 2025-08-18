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
}

void generate_sitemap(LoadedData ld){
  print("generate:generate_sitemap()");
  Uri u = ld.base.uri;
  File out = File.fromUri(u.cd(<String>["sitemap.xml"]));
  genSitemap(u, out, ld.blogsAll);
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