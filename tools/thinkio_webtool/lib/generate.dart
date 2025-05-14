import "dart:io";
import "package:yaml/yaml.dart";
import "package:thinkio_webtool/mprof.dart";
import "package:thinkio_webtool/errors.dart";

void generate(File fin, File fout){
   String pre = """<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Members - thinking</title>
    <link rel="stylesheet" href="/style/main.css">
    <link rel="stylesheet" href="/style/member.css">
    <link rel="icon" href="https://www.thinking-grp.org/image/logo/favicon.ico" type="image/x-icon">
    <script src="/script/common.js"></script>
<style>
.membersColumn-item{
  display: flex;
  min-height: 7em;
}
.profilepic {
  width: 5em;
  padding: 19px 7px 7px;
  overflow-x: hidden;
  flex-shrink: 0;
}
.profilepic .icon-wrap {
  position: relative;
  width: 80%;
  aspect-ratio: 1;
  border: 2px solid;
  background: light-gray;
  border-radius: 50%;
  margin: 3px;
  padding: 0px;
}
.profilepic .icon-wrap img {
  position: absolute;
  margin: 1px;
  top: 2px;
  left: 2px;
  width: calc(100% - 6px);
  height: calc(100% - 6px);
  clip-path: circle(50%);
}
</style>
  </head>
  <body>
    <div id="slider" class="slider-general">
      <h2>メンバー一覧</h2>
      <h3>私たちのクリエイティブなメンバーを紹介します。</h3>
    </div>
    <main class="fadeIn">
      <div id="members">
        <h2>Members</h2>""";
  String post = """</div>
    </main>
  </body>
</html>""";

  late String ret;
  String data = fin.readAsStringSync();
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
    ret = <String>[pre].followedBy(resx).followedBy(<String>[post]).join("\n");
  }else{
    throw YamlSchemaViolationError(YamlList, yn.runtimeType);
  }

  fout.writeAsStringSync(ret);
}