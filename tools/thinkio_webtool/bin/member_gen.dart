import "dart:io";
import "package:yaml/yaml.dart";

void main() {
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  Uri din = base.replace(pathSegments: base.pathSegments.followedBy(<String>["data", "member_profiles.yaml"]).toList()); // /data/member_profiles.yaml
  Uri dout = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", "member_generated.html"]).toList()); // /about/member_generated.html

  File fin = File.fromUri(din);
  File fout = File.fromUri(dout);
  if(!fout.existsSync()){
    fout.createSync();
  }

  late String ret;
  String data = fin.readAsStringSync();
  YamlNode yn = loadYamlNode(data);

  if(yn is YamlList){
    final retx = yn.map((YamlNode ln){
        if(ln is YamlMap){
          
        }
      });
  }

  fout.writeSync(ret);
}
