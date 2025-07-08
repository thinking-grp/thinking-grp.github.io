import "dart:io";
import "package:yaml/yaml.dart";
import "package:thinkio_webtool/xlib.dart";

class BlogRec implements Buildable<BlogRec> {
  final String title;
  final DateTime postedAt;
  final DateTime lastUpdatedAt;
  final String author;
  final Uri path;
  final String lead;
  
  BlogRec({required this.title, required DateTime postedAt, DateTime? lastUpdatedAt, required this.author, required this.path, this.lead = ""}):
      this.postedAt = postedAt,
      this.lastUpdatedAt = lastUpdatedAt ?? postedAt;
  
  factory BlogRec.fromYaml(YamlMap yaml) {}
  
  @override
  int compareTo(BlogRec other, {bool byName = false, bool asc = true}){
    final int base = byName ? this.title.compareTo(other.title) : this.postedAt.compareTo(other.postedAt);
    final int sign = asc ? 1 : -1;
    return sign * base;
  }
  
  @override
  String toString([int n = 0]){}
}