import "dart:io";
import "package:yaml/yaml.dart";
import "package:thinkio_webtool/mprof.dart";
import "package:thinkio_webtool/errors.dart";
import "package:thinkio_webtool/xlib.dart";

void generate(PageFiles fin, File fout){
  late String ret;
  String data = fin.data.readAsStringSync();
  String style = fin?.css?.readAsStringSync() ?? "";
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