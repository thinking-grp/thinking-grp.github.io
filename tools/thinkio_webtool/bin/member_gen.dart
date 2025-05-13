import "dart:io";
import "dart:convert";
import "package:yaml/yaml.dart";
import "package:color/color.dart";

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
  try{
    generate(fin, fout);
  } catch(e) {}
}

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
    final List<MemberProfile> mps = yn.map<MemberProfile>((YamlNode ln){
        if(ln is YamlMap){
          return MemberProfile.fromYaml(ln);
        }else{}
      }).where((MemberProfile mp) => mp.current).toList();
    mps.sort();
    Itreable<String> resx = mps.map<String>();
    ret = <String>[pre].followedBy(resx).followedBy(<String>[post]).join("\n");
  }else{}

  fout.writeSync(ret);
}

final LineSplitter _ls = LineSplitter();

class MemberProfile implements Comparable<MemberProfile>{
  final String name;
  final List<String> roles;
  final Color? color;
  final Uri? icon;
  final DateTime join;
  final String intro;
  final Uri? site;
  final String? github;
  final String? twitter;
  final String? youtube;
  final bool current;
  
  MemberProfile({required this.name, this.roles = const <String>[], this.color, this.icon, required this.join, this.intro = "", this.site, this.github, this.twitter, this.youtube, required this.current});
  factory MemberProfile.fromYaml(YamlMap yaml){}

  bool get isRepresentative() => this.roles.contains("代表");
  bool get isViceRepresentative() => this.roles.contains("副代表");
  bool get isPrevRepresentative() => this.roles.contains("前 代表");
  bool get isFormerRepresentative() => this.roles.contains("元 代表");
  bool get isExecutive() => this.roles.contains("運営") || this.isRepresentative || this.roles.isViceRepresentative;
  bool get isExecutivePlus() => this.isExecutive || this.isPrevRepresentative || this.isFormerRepresentative;

  @override
  int compareTo(MemberProfile other){
    if(this.isExecutivePlus != other.isExecutivePlus){
      return this.isExecutivePlus ? 1 : -1;
    }
    if(this.isExecutivePlus){
      if(this.isRepresentative){
        return 1;
      } else if(this.isViceRepresentative) {
        if(other.isRepresentative){
          return -1;
        } else if(other.isViceRepresentative){
          return 0;
        } else {
          return 1;
        }
      } else if(this.isPrevRepresentative) {
        if(other.isFormerRepresentative){
          return 1;
        } else {
          return -1;
        }
      } else if(this.isFormerRepresentative) {
        if(other.isFormerRepresentative) {
          return 0;
        } else {
          return -1;
        }
      } else {
        if(other.isRepresentative || other.isViceRepresentative){
          return -1;
        } else if(other.isPrevRepresentative || other.isFormerRepresentative) {
          return 1;
        } else {
          return 0;
        }
      }
    }
    return this.join.compareTo(other.join);
  }
  @override
  String toString(){
/*
        <div class="membersColumn">
          <div class="membersColumn-item" id="gasukaku">
            <div class="profilepic"></div>
            <div class="membersItem-details">
              <h3>Gasukaku
                <p class="role">代表</p>
              </h3>
              <div class="p">
                Gasukaku（ガスカク）です。
                <br>
                ちょっとしたホームページ作成、動画編集ならできます。
              </div>
              <div class="links">
                <a href="https://www.gasukaku.net/">WebSite</a>
                <a href="https://twitter.com/gasukaku">Twitter</a>
              </div>
            </div>
          </div>
        </div>
        <div class="membersColumn">
          <div class="membersColumn-item" id="xilletex">
            <div class="profilepic"></div>
            <div class="membersItem-details">
              <h3>佐藤 陽花　<small>(さとう はるか)</small>
                <p class="role">副代表</p>
              </h3>
              <div class="p">
                情報科学分野の研究者・技術者で、分散処理やコンピュータ言語、OS/CPUが専門です。DartやRustがメイン言語ですが、色々な言語に手だしています。
              </div>
              <div class="links">
                <a href="https://github.com/halka9000stg">GitHub</a>
                <a href="https://twitter.com/Distr_to_Yonder">Twitter</a>
                <a href="https://youtube.com/@Halka_ch">YouTube</a>
              </div>
            </div>
          </div>
        </div>
*/
    late String i;
    Itreable<String> roles = _pack(this.roles.isEmpty() ? <String>[]: <String>[this.roles.map<String>((String s){
        if(s.startsWith("前 ")  || s.startsWith("元 ")){
          i = s.split(" ");
          return "<small>${i.first}</small>${i.last}";
        } else {
          return s;
        }
}).join(", ")], "p", "class=\"role\"");
    Itreable<String> intro = _pack(_ls.convert(this.intro).eachInsert("<br>"), "div", "class=\"p\"");
    String? hpa = _toUrlStrA(this.site?.toString(), "", "WebSite", (_) => true);
    String? gha = _toUrlStrA(this.github, "https://github.com/", "GitHub");
    String? twa = _toUrlStrA(this.twitter, "https://twitter.com/@", "Twitter");
    String? yta = _toUrlStrA(this.youtube, "https://youtube.com/@", "YouTube", (String s) => s.startsWith("https://youtube.com/"));
  Itreable<String> links = _pack(<String?>[hpa, gha, twa, yta].whereType<String>(), "div", "class=\"links\"");
  }
}

String? _toUrlStrA(String? id, String base, String label, [bool Function(String)? test]){
  if(id == null){
    return null;
  }
  if(test != null){
    if(test(id)){
      return "<a href=\"$id\">$label</a>";
    }
  }
  return "<a href=\"$base$id\">$label</a>";
}
String _indent(String input, [int n = 1]) => "  " * n + input;
Itreable<String> _indentMap(Itreable<String> lines, [int n = 1]) => lines.map<String>((String e) => _indent(e, n));
List<String> _indentMapL(Itreable<String> lines, [int n = 1]) => _indentMapL(lines, n).toList();
Itreable<String> _pack(Itreable<String> lines, String tag, [String? attrs]) => lines.isEmpty() ? <String>[] : (<String>["<$tag${attrs == null ? "" : " $attrs"}>"].followedBy(_indentMap(lines)).followedBy(<String>["</$tag>"]));
List<String> _packL(Itreable<String> lines, String tag, [String? attrs]) => _pack(lines, tag, attrs).toList();

extension EachInsertExtension<E> on Iterable<E> {
  Iterable<E> eachInsert(E insertee) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return; // 空のとき

    yield iterator.current;
    while (iterator.moveNext()) {
      yield insertee;
      yield iterator.current;
    }
  }
}