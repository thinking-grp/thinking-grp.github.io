import "dart:io";
import "package:thinkio_webtool/xlib.dart";
import "package:thinkio_webtool/generate.dart";
import "package:thinkio_webtool/errors.dart";

const bool deploy = true;

void main() {
  print("main()");
  print("curr: Uri");
  Uri curr = Platform.script;  // /tools/thinkio_webtool/bin/member_gen.dart
  print(curr.pathSegments);
  print("base: Uri");
  Uri base = curr.replace(pathSegments: curr.pathSegments.take(curr.pathSegments.length - 4).toList()); // /
  print(base.pathSegments);
  PageFiles pf_m = (
      html: <String>["template", "member.thtm"],
      css: <String>["template", "member.css"]
    );
  Uri dout_m = base.replace(pathSegments: base.pathSegments.followedBy(<String>["about", deploy ? "member.html" : "member_generated.html"]).toList()); // /about/member_generated.html (dryrun), /about/member.html (deploy)
  File fout_m = File.fromUri(dout_m);
  
  PageFiles pf_b = (
      html: <String>["template", "blog_index.thtm"],
      css: null,
    );
  Uri dout_b = base.replace(pathSegments: base.pathSegments.followedBy(<String>["blog", deploy ? "index.html" : "index_generated.html"]).toList()); // /blog/index_generated.html (dryrun), /blog/index.html (deploy)
  File fout_b = File.fromUri(dout_b);
  
  try{
    final ld = LoadedData(
        base: Directory.fromUri(base),
        blogPath: <String>["data", "blog_index.yaml"],
        memberPath: <String>["data", "member_profiles.yaml"]
      );
    
    generate_sitemap(ld);
    generate_member(ld, pf_m, fout_m);
    generate_blog_index(ld, pf_b, fout_b);
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