import "dart:io";
import "package:yaml/yaml.dart";
import "package:intl/intl.dart";
import "package:thinkio_webtool/xlib.dart";

final DateFormat fmt = DateFormat("yyyy年MM月dd日");

extension type BlogTag._(String name){
  BlogTag(String tagName):
    this.name = BlogTag.validate(tagName);
  //ToDo: add static param of RegExp
  //               for tag format
  //      and make validate use the param
  //               as matcher
  static String validate(String input)
    => BlogTag._isREReady ? BlogTag.re.hasMatch(input) ? input : throw FormatException("") : input;
  static RegExp re = RegExp(r"^[a-z]$");
  static bool _isREReady = false;
}
enum PubKind {
  natives, markdown, wordpress
}
class PubKindP {
  static PubKind parse(String input) => switch(input.toLowerCase()){
    "native" || "natives" =>
      PubKind.natives,
    "markdown" || "md" =>
      PubKind.markdown,
    "wordpress" || "wp" =>
      PubKind.wordpress,
    _ => throw FormatException(""),
  }
  static PubKind? tryParse(String input){
    try {
      return PubKindP.parse(input);
    } catch (_) {
      return null;
    }
  }
}

class BlogRec implements Buildable<BlogRec> {
  final String title;
  final DateTime postedAt;
  final DateTime lastUpdatedAt;
  final String author;
  final List<BlogTag> tags;
  final PubKind pub;
  final Uri path;
  final Uri image;
  final String lead;
  
  static Uri defaultImage = Uri.parse("/image/thinking-img.jpg");
  
  BlogRec({required this.title, required DateTime postedAt, DateTime? lastUpdatedAt, required this.author, required this.pub, required this.path, Uri? image, Iterable<BlogTag>? tags, this.lead = ""}):
      this.postedAt = postedAt,
      this.lastUpdatedAt = lastUpdatedAt ?? postedAt,
      this.image = image ?? BlogRec.defaultImage,
      this.tags = tags?.toList() ?? <BlogTag>[];
  
  factory BlogRec.fromYaml(YamlMap yaml) {
    YamlKeyResult _ = yaml.hasKeys(requires: <String>["title", "postedAt", "author", "pub", "path"], optionals: <String>["lastUpdatedAt", "image", "tags", "lead"]);
    
    DateTime? luat = null;
    String? luatStr = yaml.valueAsOrNull<String>("lastUpdatedAt");
    if(luatStr != null){
      luat = DateTime.parse(luatStr);
    }
    
    Uri img = BlogRec.defaultImage;
    String? imgStr = yaml.valueAsOrNull<String>("image");
    if(imgStr != null){
      img = Uri.parse(imgStr);
    }
    
    List<BlogTag> tags = <BlogTag>[];
    YamlNode? rc = yaml.nodes["tags"];
    late Object? nv;
    if(rc != null && rc is YamlList){
      for(YamlNode n in rc.nodes){
        if(n is YamlScalar){
          nv = n.value;
          if(nv is String){
            tags.add(BlogTag(nv));
          }
        }
      }
    }
    
    return BlogRec(
      title: yaml.valueAs<String>("title"),
      postedAt: DateTime.parse(yaml.valueAs("postedAt")),
      lastUpdatedAt: luat,
      author: yaml.valueAs<String>("author"),
      pub: PubKindP.parse(yaml.valueAs<String>("pub")),
      path: casedUpdate<Uri>(
          Uri.parse(yaml.valueAs<String>("path")),
          (Uri u) => !u.hasAuthority,
          (Uri u) => u.replace(
            pathSegments: <String>["", "blog"]
              .followedBy(u.pathSegments.first == "" ? u.pathSegments.skip(1) : u.pathSegments)
            )
        ),
      image: img,
      tags: tags,
      lead: yaml.valueAsOrNull<String>("lead") ?? ""
    );
  }
  
  @override
  int compareTo(BlogRec other, {bool byName = false, bool asc = true}){
    final int base = byName ? this.title.compareTo(other.title) : this.postedAt.compareTo(other.postedAt);
    final int sign = asc ? 1 : -1;
    return sign * base;
  }
  
  @override
  String toString([int n = 0]){
    Iterable<String> details = pack(
        <String>[
          packInline(this.title, "h3"),
          packInline("${fmt.format(this.postedAt)} by ${this.author}", "p")
          ].followedBy(pack(
              this.lead.split("\n"),
              "p",
              asAttr(cls: <String>["blog-body"])
            )),
        "div",
        asAttr(cls: <String>["blogItem-details"])
      );
    Iterable<String> item = pack(
        packInline(
          "",
          "img",
          asAttr(attrs: <String, Object>{"src": this.image, "alt": this.title})
        ).asList()
        .followedBy(details),
        "div",
        asAttr(cls: <String>["blogsColumn-item"])
      );
    return indentMap(
        pack(
          pack(
            item,
            "a",
            asAttr(attrs: <String, Uri>{"href": this.path})
          ),
          "div",
          asAttr(id: "blogsColumn")
        ), n)
      .join("\n");
  }
}