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
  } on YamlSchemaViolationError catch(e) {
    print(e);
  } on YamlMapHasNotRequiredKeysError catch(e) {
    print(e);
  }
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
    final List<MemberProfile> mps = yn.nodes.map<MemberProfile>((YamlNode ln){
        if(ln is YamlMap){
          return MemberProfile.fromYaml(ln);
        }else{
          throw YamlSchemaViolationError();
        }
      }).where((MemberProfile mp) => mp.current).toList();
    mps.sort();
    Iterable<String> resx = mps.map<String>((MemberProfile mp) => mp.toString(4));
    ret = <String>[pre].followedBy(resx).followedBy(<String>[post]).join("\n");
  }else{
    throw YamlSchemaViolationError();
  }

  fout.writeAsStringSync(ret);
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
  factory MemberProfile.fromYaml(YamlMap yaml){
     List<String> _ = yaml.hasKeys(requires: <String>["name", "join", "current"], optionals: <String>["roles", "color", "icon", "intro", "site", "github", "twitter", "youtube"]);

    List<String> roles = <String>[];
    YamlNode rc = yam
nodesl["roles"];
    late Object? nv;
    if(rc is YamlList){
      for(YamlNode n in rc.nodes){
        if(n is YamlScalar){
          nv = n.value;
          if(nv is String){
            roles.add(nv);
          }
        }
      }
    }

    Color? col = null;
    String? cs = yaml.valueAs<String?>("color");
    if(cs is String){
      col = Color.hex(cs);
    }

    Uri? icon = null;
    String? ics = yaml.valueAs<String?>("icon");
    if(ics is String){
      if(ics == "/"){
      } else if (ics.startsWith("/")) {
        icon = Uri.tryParse("https://www.thinking-grp.org/image/icon$ics");
      } else {
        icon = Uri.tryParse(ics);
      }
      
    }

    Uri? site = null;
    String? ss = yaml.valueAs<String?>("site");
    if(ss is String){
      site = Uri.tryParse(ss);
    }

    return MemberProfile(
      name: yaml.valueAs<String>("name"),
      roles: roles, color: col, icon: icon,
      join: yaml.valueAs<DateTime>("join"),
      intro: yaml.valueAs<String?>("intro") ?? "",
      site: site,
      github: yaml.valueAs<String?>("github"),
      twitter: yaml.valueAs<String?>("twitter"),
      youtube: yaml.valueAs<String?>("youtube"),
      current: yaml.valueAs<bool>("current"));
  }

  bool get isRepresentative => this.roles.contains("代表");
  bool get isViceRepresentative => this.roles.contains("副代表");
  bool get isPrevRepresentative => this.roles.contains("前 代表");
  bool get isFormerRepresentative => this.roles.contains("元 代表");
  bool get isExecutive => this.roles.contains("運営") || this.isRepresentative || this.isViceRepresentative;
  bool get isExecutivePlus => this.isExecutive || this.isPrevRepresentative || this.isFormerRepresentative;

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
  String toString([int n = 0]){
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

    String profPic = "<div class=\"profilepic\"></div>";

    String baseName = this.name.replaceAllMapped(RegExp("(\([^)]*\))"), (Match m) => "<small>${m[1]}</small>").replaceAllMapped(RegExp("( (か|または|又は|もしくは|若しくは|あるいは|或いは|or) )"), (Match m) => "<small>${m[1]}</small>");

    late List<String> i;
    String? roles = this.roles.isEmpty ? null : _wrap(this.roles.map<String>((String s){
        if(s.startsWith("前 ")  || s.startsWith("元 ")){
          i = s.split(" ");
          return "<small>${i.first}</small>${i.last}";
        } else {
          return s;
        }
}).join(", "), "p", "class=\"role\"");

    List<String> name = (roles == null) ? <String>["<h3>$baseName</h3>"] : <String>["<h3>$baseName", _indent(roles), "</h3>"];

    Iterable<String> intro = _pack(_ls.convert(this.intro).eachInsert("<br>"), "div", "class=\"p\"");

    String? hpa = _toUrlStrA(this.site?.toString(), "", "WebSite", (_) => true);
    String? gha = _toUrlStrA(this.github, "https://github.com/", "GitHub");
    String? twa = _toUrlStrA(this.twitter, "https://twitter.com/@", "Twitter");
    String? yta = _toUrlStrA(this.youtube, "https://youtube.com/@", "YouTube", (String s) => s.startsWith("https://youtube.com/"));
  Iterable<String> links = _pack(<String?>[hpa, gha, twa, yta].whereType<String>(), "div", "class=\"links\"");

    Iterable<String> details = _pack(name.followedBy(intro).followedBy(links), "div", "class=\"membersItem-details\"");

    Iterable<String> column = _pack(_pack(<String>[profPic].followedBy(details), "div", "class=\"membersItem-details\""), "div", "class=\"membersColumn\"");

    return _indentMap(column, n).join("\n");
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
Iterable<String> _indentMap(Iterable<String> lines, [int n = 1]) => lines.map<String>((String e) => _indent(e, n));
List<String> _indentMapL(Iterable<String> lines, [int n = 1]) => _indentMapL(lines, n).toList();
Iterable<String> _pack(Iterable<String> lines, String tag, [String? attrs]) {
  if(lines.isEmpty){
    return <String>[];
  }
  String attrx = attrs == null ? "" : " $attrs";
  return <String>["<$tag$attrx>"].followedBy(_indentMap(lines)).followedBy(<String>["</$tag>"]);
}
List<String> _packL(Iterable<String> lines, String tag, [String? attrs]) => _pack(lines, tag, attrs).toList();
String _wrap(String line, String tag, [String? attrs]){
  String attrx = attrs == null ? "" : " $attrs";
  return "<$tag$attrx>$line</$tag>";
}

extension EachInsertExtension<E> on Iterable<E> {
  Iterable<E> eachInsert(E insertee) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;

    yield iterator.current;
    while (iterator.moveNext()) {
      yield insertee;
      yield iterator.current;
    }
  }
}

extension YamlMapExt on YamlMap {
  List<String> hasKeys({List<String> requires = const <String>[], List<String> optionals = const <String>[]}){
    List<String> ret = <String>[];
    if(requires.every((String k) => this.containsKey(k))){
      ret.addAll(requires);
    } else {
      throw YamlMapHasNotRequiredKeysError();
    }
    for(String k in optionals){
      if(this.containsKey(k)){
        ret.add(k);
      }
    }
    return ret;
  }
  T valueAs<T>(String key) {
    YamlNode n = this.nodes[key];
    if(n is YamlScalar){
      Object? v = n.value;
      if(v is T){
        return v as T;
      } else {
        throw YamlSchemaViolationError();
      }
    }
    if(n is T){
      return n as T;
    } else {
      throw YamlSchemaViolationError();
    }
  }
}

class YamlSchemaViolationError extends Error {}
class YamlMapHasNotRequiredKeysError extends Error {}