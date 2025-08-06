import "package:web/web.dart";

Future<void> main() async {
  Uri su = Uri.parse(window.location.href);
  if(su.hasQuery){
    Map<String, String> su_qps = su.queryParameters;
    String? art_tgt = su_qps["a"];
    if(art_tgt != null){
      await showArticle(art_tgt, base: su.origin);
    }else{
      await showIndex();
    }
  }else{
    await showIndex();
  }
}