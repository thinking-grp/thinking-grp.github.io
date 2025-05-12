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
      

  late String ret;
  String data = fin.readAsStringSync();
  YamlNode yn = loadYamlNode(data);

  if(yn is YamlList){
    final List<MemberProfile> = yn.map<MemberProfile>((YamlNode ln){
        if(ln is YamlMap){
          return MemberProfile.fromYaml(ln);
        }else{}
      });
  }else{}

  fout.writeSync(ret);
}
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

  @override
  int compareTo(MemberProfile other){}
  @override
  String toString(){}
}