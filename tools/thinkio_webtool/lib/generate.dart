import "dart:io";
import "dart:math" show min;
import "package:yaml/yaml.dart";
import "package:thinkio_webtool/mprof.dart";
import "package:thinkio_webtool/errors.dart";
import "package:thinkio_webtool/xlib.dart";


class Templater {
  final Directory base;
  final File out;
  final Iterable<String> templatePath;
  String _internalHTML = "";
  
  Templater(this.base, this.templatePath, this.out){
    this._internalHTML = this.base.cd<File>(this.templatePath).readAsStringSync();
  }
  
  Templater construct<H extends Buildable>(String ident, Iterable<String> path, H Function(YamlMap) fromYaml, {bool needSort = false, bool reverse = false, int? limit, int n = 0, bool Function(H)? filterItem}){
    bool Function(H) filter = filterItem ?? ((H _) => true);
    String data = this.base.cd<File>(path).readAsStringSync();
    YamlNode yn = loadYamlNode(data);
    
    if(yn is YamlList){
      List<H> hs = yn.nodes.map<H>((YamlNode ln){
          if(ln is YamlMap){
            return fromYaml(ln);
          }else{
            throw YamlSchemaViolationError(YamlMap, ln.runtimeType);
          }
        }).where((H h) => filter(h)).toList();
      if(needSort){
        hs.sort();
      }
      if (reverse) {
        hs = hs.reversed.toList();
      }
      if (limit != null) {
        hs = hs.take(min<int>(limit, hs.length)).toList();
      }
      Iterable<String> resx = hs.map<String>((H mp) => mp.toString(n));
      this._replace(ident, resx.join("\n"));
      return this;
    }else{
      throw YamlSchemaViolationError(YamlList, yn.runtimeType);
    }
  }
  
  Templater inject(String ident, Iterable<String> path, [int n = 0]){
    String src = this.base.cd<File>(path).readAsStringSync();
    this._replace(ident, indentMapS(src, n));
    return this;
  }
  
  void finate(){
    if(!this.out.existsSync()){
      this.out.createSync();
    }
    this.out.writeAsStringSync(this._internalHTML);
  }
  void _replace(String ident, String dataString){
    this._internalHTML = this._internalHTML.replaceAll(Templater.identOn(ident), dataString);
  }
  static RegExp identOn(String ident)
    => RegExp(r"\s*(?<!\\){{" + ident + "}}");
}

void generate(PageFiles fin, File fout){
  final tlr = Templater(fin.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.construct<MemberProfile>("body", fin.data, MemberProfile.fromYaml, needSort: true, filterItem: (MemberProfile mp) => mp.current, n: 4);
  tlr.finate();
}