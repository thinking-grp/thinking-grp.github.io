import "dart:io";
import "package:thinkio_webtool/xlib.dart";
import "package:thinkio_webtool/generate.dart";
import "package:thinkio_webtool/errors.dart";

const bool deploy = true;

void main() {
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  PageFiles pf = (
      base: base,
      html: <String>["template", "member.thtm"],
      data: <String>["data", "member_profiles.yaml"],
      css: <String>["template", "member.css"]
    );
  Uri dout = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", deploy ? "member.html" : "member_generated.html"]).toList()); // /about/member_generated.html (dryrun), /about/member.html (deploy)

  File fout = File.fromUri(dout);
  
  try{
    generate(pf, fout);
  } on YamlSchemaViolationError catch(e, t) {
    print(e);
    print(t);
    exit(72);
  } on YamlMapHasNotRequiredKeysError catch(e, t) {
    print(e);
    print(t);
    exit(65);
  } on PathNotFoundException catch(e, t) {
    print(e);
    print(t);
    exit(45);
  } on FileSystemException catch(e, t) {
    print(e);
    print(t);
    exit(53);
  } catch(e, t) {
    print(e);
    print(t);
    exit(14);
  }
}