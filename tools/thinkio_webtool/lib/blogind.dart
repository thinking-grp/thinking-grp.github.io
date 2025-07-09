import "dart:io";
import "package:yaml/yaml.dart";
import "package:intl/intl.dart";
import "package:thinkio_webtool/xlib.dart";

final DateFormat fmt = DateFormat("yyyy年MM月dd日", "ja-JP");

extension type BlogTag._(String name){
  BlogTag(String tagName):
    this.name = BlogTag.validate(tagName);
  //ToDo: add static param of RegExp
  //               for tag format
  //      and make validate use the param
  //               as matcher
  static String validate(String input)
    => true;
}

class BlogRec implements Buildable<BlogRec> {
  final String title;
  final DateTime postedAt;
  final DateTime lastUpdatedAt;
  final String author;
  final List<BlogTag> tags;
  final Uri path;
  final Uri image;
  final String lead;
  
  static Uri defaultImage = Uri.parse("/image/thinking-img.jpg");
  
  BlogRec({required this.title, required DateTime postedAt, DateTime? lastUpdatedAt, required this.author, required this.path, Uri? image, Iterable<BlogTag>? tags, this.lead = ""}):
      this.postedAt = postedAt,
      this.lastUpdatedAt = lastUpdatedAt ?? postedAt,
      this.image = image ?? BlogRec.defaultImage,
      this.tags = tags?.toList() ?? <BlogTag>[];
  
  factory BlogRec.fromYaml(YamlMap yaml) {
    List<String> _ = yaml.hasKeys(requires: <String>["title", "postedAt", "author", "path"], optionals: <String>["lastUpdatedAt", "image", "tags", "lead"]);
  }
  
  @override
  int compareTo(BlogRec other, {bool byName = false, bool asc = true}){
    final int base = byName ? this.title.compareTo(other.title) : this.postedAt.compareTo(other.postedAt);
    final int sign = asc ? 1 : -1;
    return sign * base;
  }
  
  @override
  String toString([int n = 0]){
    => indentMap(
          pack(
            pack(
              pack(
                packInline(
                  null,
                  "img",
                  asAttr(attrs: <String, Object>{"src": this.image, "alt: this.title"})
                ).asList()
                .followedBy(pack(
                  <String>[
                    packInline(this.title, "h3"),
                    packInline("${fmt.format(this.postedAt)} by ${this.author}", "p")
                  ].followedBy(pack(
                    this.lead.split("\n"),
                    "p",
                    asAttr(cls: "blog-body"),
                    "div",
                    asAttr(cls: "blogItem-details")
                  )),
                  "div",
                  asAttr(cls: "blogsColumn-item">)
                ),
                "a",
                asAttr(attrs: <String, Uri>{"href": uri})
              ),
              "div",
              asAttr(id: "blogsColumn")
            ), n).join("\n");
  }
}