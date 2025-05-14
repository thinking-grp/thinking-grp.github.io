import "dart:io";
import "package:thinkio_webtool/generate.dart";
import "package:thinkio_webtool/errors.dart";

const bool deploy = true;

void main() {
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  Uri din = base.replace(pathSegments: base.pathSegments.followedBy(<String>["data", "member_profiles.yaml"]).toList()); // /data/member_profiles.yaml
  Uri dout = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", deploy ? "member.html" : "member_generated.html"]).toList()); // /about/member_generated.html (dryrun), /about/member.html (deploy)

  File fin = File.fromUri(din);
  File fout = File.fromUri(dout);
  if(!fout.existsSync()){
    fout.createSync();
  }
  try{
    generate(fin, fout);
  } on YamlSchemaViolationError catch(e, t) {
    print(e);
    print(t);

  } on YamlMapHasNotRequiredKeysError catch(e, t) {
    print(e);
    print(t);

  } catch(e, t) {
    print(e);
    print(t);
  }
}