import "package:web/web.dart";
import "package:thinkdocs_web/"

Future<void> main() async {
  Uri su = Uri.parse(window.location.href);
  if(su.hasQuery){
    Map<String, String> su_qps = su.queryParameters;
    String? art_tgt = su_qps["a"];
    String? art_ver = su_qps["v"];
    String? art_date = su_qps["at"];
    if(art_tgt != null){
      await showArticle(art_tgt, base: su.origin, date: art_date, ver: art_ver);
    }else{
      await showIndex();
    }
  }else{
    await showIndex();
  }
}