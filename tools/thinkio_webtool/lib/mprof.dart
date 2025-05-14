import "dart:io";
import "package:yaml/yaml.dart";
import "package:color/color.dart";
import "./xlib.dart";

class MemberProfile implements Comparable<MemberProfile>{
  final String id;
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

  static Uri defaultIcon = Uri.parse("https://www.thinking-grp.org/image/noimage.jpg");

  MemberProfile({required this.id, required this.name, this.roles = const <String>[], this.color, this.icon, required this.join, this.intro = "", this.site, this.github, this.twitter, this.youtube, required this.current});
  factory MemberProfile.fromYaml(YamlMap yaml){
     List<String> _ = yaml.hasKeys(requires: <String>["id", "name", "join", "current"], optionals: <String>["roles", "color", "icon", "intro", "site", "github", "twitter", "youtube"]);

    List<String> roles = <String>[];
    YamlNode? rc = yaml.nodes["roles"];
    late Object? nv;
    if(rc != null && rc is YamlList){
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
    String? cs = yaml.valueAsOrNull<String>("color");
    if(cs != null){
      col = Color.hex(cs);
    }
    print("${yaml.valueAs<String>("name")}\nvalue color: $cs\nparsed color: #$col\n");

    Uri? icon = null;
    String? ics = yaml.valueAsOrNull<String>("icon");
    if(ics is String){
      if(ics == "/"){
      } else if (ics.startsWith("/")) {
        icon = Uri.tryParse("https://www.thinking-grp.org/image/icon$ics");
      } else {
        icon = Uri.tryParse(ics);
      }

    }

    Uri? site = null;
    String? ss = yaml.valueAsOrNull<String>("site");
    if(ss is String){
      site = Uri.tryParse(ss);
    }

    DateTime dt = DateTime.parse(yaml.valueAs<String>("join"));

    return MemberProfile(
      id: yaml.valueAs<String>("id"),
      name: yaml.valueAs<String>("name"),
      roles: roles, color: col, icon: icon,
      join: dt,
      intro: yaml.valueAsOrNull<String>("intro") ?? "",
      site: site,
      github: yaml.valueAsOrNull<String>("github"),
      twitter: yaml.valueAsOrNull<String>("twitter"),
      youtube: yaml.valueAsOrNull<String>("youtube"),
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
      return this.isExecutivePlus ? -1 : 1;
    }
    if(this.isExecutivePlus){
      if(this.isRepresentative){
        return -1;
      } else if(this.isViceRepresentative) {
        if(other.isRepresentative){
          return 1;
        } else if(other.isViceRepresentative){
          return 0;
        } else {
          return -1;
        }
      } else if(this.isPrevRepresentative) {
        if(other.isFormerRepresentative){
          return -1;
        } else {
          return 1;
        }
      } else if(this.isFormerRepresentative) {
        if(other.isFormerRepresentative) {
          return 0;
        } else {
          return 1;
        }
      } else {
        if(other.isRepresentative || other.isViceRepresentative){
          return 1;
        } else if(other.isPrevRepresentative || other.isFormerRepresentative) {
          return -1;
        } else {
          return 0;
        }
      }
    }
    return this.join.compareTo(other.join);
  }
  @override
  String toString([int n = 0]){
    Iterable<String> profPic = _pack(_pack(<String>["<img src=\"${(this.icon ?? MemberProfile.defaultIcon).toString()}\" />"], "div", "class=\"icon-wrap\" style=\"border-color: #${(this.color ?? Color.hex("#b8b8b8")).toHexColor()};\""), "div", "class=\"profilepic\"");

    String baseName = this.name.replaceAllMapped(RegExp(r"(\([^)]*\))"), (Match m) => "<small>${m[1]}</small>").replaceAllMapped(RegExp(r"( (か|または|又は|もしくは|若しくは|あるいは|或いは|or) )"), (Match m) => "<small>${m[1]}</small>");

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

    Iterable<String> column = _pack(_pack(profPic.followedBy(details), "div", "class=\"membersColumn-item\" id=\"${this.id}\""), "div", "class=\"membersColumn\"");

    return _indentMap(column, n).join("\n");
  }
}