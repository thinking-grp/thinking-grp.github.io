import "dart:io";
import "package:thinkio_webtool/xlib.dart";
import "package:thinkio_webtool/generate.dart";
import "package:thinkio_webtool/errors.dart";

const bool deploy = true;

void main() {
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  PageFiles pf_m = (
      base: Directory.fromUri(base),
      html: <String>["template", "member.thtm"],
      data: <String>["data", "member_profiles.yaml"],
      css: <String>["template", "member.css"]
    );
  Uri dout_m = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", deploy ? "member.html" : "member_generated.html"]).toList()); // /about/member_generated.html (dryrun), /about/member.html (deploy)
  File fout_m = File.fromUri(dout_m);
  
  PageFiles pf_b = (
      base: Directory.fromUri(base),
      html: <String>["template", "blog_index.thtm"],
      css: null,
      data: <String>["data", "blog_index.yaml"]
    );
  Uri dout_b = base.replace(pathSegments: base.pathSegments.followedBy(<String>["blog", deploy ? "index.html" : "index_generated.html"]).toList()); // /blog/index_generated.html (dryrun), /blog/index.html (deploy)
  File fout_b = File.fromUri(dout_b);
  
  try{
    generate_sitemap(pf_b.base, pf_b.data);
    generate_member(pf_m, fout_m);
    generate_blog_index(pf_b, fout_b);
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