import "dart:io";
import "package:yaml/yaml.dart";
import "package:intl/intl.dart";
import "package:thinkio_webtool/xlib.dart";

final DateFormat fmt = DateFormat("yyyy年MM月dd日", "ja-JP");

class BlogRec implements Buildable<BlogRec> {
  final String title;
  final DateTime postedAt;
  final DateTime lastUpdatedAt;
  final String author;
  final Uri path;
  final Uri image;
  final String lead;
  
  static Uri defaultImage = Uri.parse("");
  
  BlogRec({required this.title, required DateTime postedAt, DateTime? lastUpdatedAt, required this.author, required this.path, Uri? image, this.lead = ""}):
      this.postedAt = postedAt,
      this.lastUpdatedAt = lastUpdatedAt ?? postedAt
      this.image = image ?? BlogRec.defaultImage;
  
  factory BlogRec.fromYaml(YamlMap yaml) {}
  
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
          
              <img src="/image/thinking-img.jpg" alt="公式サイト完成">
              <div class="blogItem-details">
                <h3>thinking公式サイト完成！</h3>
                <p>2022年08月04日 by Sorakime</p>
                <p class="blog-body">どうも代表Sorakimeです。thinking公式サイトが完成して公開したということで、ブログ書いてみました。これが一つ目のブログの投稿ですね。このサイトではthinkingの特徴とかthinkingのプロジェクトの紹介から、それからブログではお知らせはもちろん、ちょっとしたメンバーによる日記みたいなのも書こうかなーと思ってます。</p>