import "dart:io";
import "package:yaml/yaml.dart";

void main() {
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  Uri din = base.replace(pathSegments: base.pathSegments.followedBy(<String>["data", "member_profiles.yaml"]).toList()); // /data/member_profiles.yaml
  Uri dout = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", "member_generated.html"]).toList()); // /about/member_generated.html
  File f = File.fromUri(din);
  String data = f.readAsStringSync();
  YamlNode yn = loadYamlNode(data);
  if(yn is YamlList){
    final ret = yn.map((YamlNode ln){
        if(ln is YamlMap){
          
        }
      });
  }
}
