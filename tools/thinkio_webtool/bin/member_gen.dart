import "dart:io";
import "package:thinkio_webtool/xlib.dart";
import "package:thinkio_webtool/generate.dart";
import "package:thinkio_webtool/errors.dart";

const bool deploy = true;

void main() {
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  Uri din = base.replace(pathSegments: base.pathSegments.followedBy(<String>["data", "member_profiles.yaml"]).toList()); // /data/member_profiles.yaml
  Uri tin = base.replace(pathSegments: base.pathSegments.followedBy(<String>["template", "member.thtm"]).toList()); // /template/member.thtm
  Uri sin = base.replace(pathSegments: base.pathSegments.followedBy(<String>["template", "member_profiles.css"]).toList()); // /template/member.css
  Uri dout = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", deploy ? "member.html" : "member_generated.html"]).toList()); // /about/member_generated.html (dryrun), /about/member.html (deploy)

  File find = File.fromUri(din);
  File fint = File.fromUri(tin);
  File fins = File.fromUri(sin);
  File fout = File.fromUri(dout);
  if(!fout.existsSync()){
    fout.createSync();
  }
  try{
    generate((data: find, html: fint, css: fins), fout);
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