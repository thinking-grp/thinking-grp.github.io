import "dart:io";
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
  
  Templater construct<H extends Buildable>(String ident, Iterable<String> path, Iterable<H> Function(YamlList) fromYaml, {bool needSort = false, int n = 0, bool Function(H)? filterItem}){
    bool Function(H) filter = filterItem ?? ((H _) => true);
    String data = this.base.cd<File>(path).readAsStringSync();
    YamlNode yn = loadYamlNode(data);
    
    if(yn is YamlList){
    final List<H> hs = yn.nodes.map<H>((YamlNode ln){
        if(ln is YamlMap){
          return fromYaml(ln);
        }else{
          throw YamlSchemaViolationError(YamlMap, ln.runtimeType);
        }
      }).where((H h) => filter(h)).toList();
    if(needSort){
      hs.sort();
    }
    
    Iterable<String> resx = hs.map<String>((H mp) => mp.toString(n));
    this._internalHTML = this.internalHTML.replaceAll("{{$ident}}", resx.join("\n"));
    return this;
  }
  
  Templater inject(String ident, Iterable<String> path, [int n = 0]){
    String src = this.base.cd<File>(path).readAsStringSync();
    this._internalHTML = this.internalHTML.replaceAll("{{$ident}}", indentMapS(src, n));
    return this;
  }
  
  void finite(){
    if(!this.out.existsSync()){
      this.out.createSync();
    }
    this.out.writeAsStringSync(this._internalHTML);
  }
}

void generate(PageFiles fin, File fout){
  late String ret;
  String data = fin.data.readAsStringSync();
  String style = fin.css?.readAsStringSync() ?? "";
  String template = fin.html.readAsStringSync();
  YamlNode yn = loadYamlNode(data);

  if(yn is YamlList){
    final List<MemberProfile> mps = yn.nodes.map<MemberProfile>((YamlNode ln){
        if(ln is YamlMap){
          return MemberProfile.fromYaml(ln);
        }else{
          throw YamlSchemaViolationError(YamlMap, ln.runtimeType);
        }
      }).where((MemberProfile mp) => mp.current).toList();
    mps.sort();
    Iterable<String> resx = mps.map<String>((MemberProfile mp) => mp.toString(4));
    ret = template
      .replaceAll("{{css}}", style)
      .replaceAll("{{body}}", resx.join("\n"));
  }else{
    throw YamlSchemaViolationError(YamlList, yn.runtimeType);
  }

  fout.writeAsStringSync(ret);
}