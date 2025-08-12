import "package:yaml/yaml.dart";
import "package:web/web.dart";

import "package:xlib_think_ext/gen.dart";
import "package:xlib_think_ext/yaml.dart";
import "package:xlib_think_ext/mark.dart";
import "package:thinkdocs_web/markdown.dart";

enum Clearance implements Comparable<Clearance> {
  all(0),
  member(1),
  executive(5),
  representative(7);
  // 0 all
  // 1 member
  // 2 team che
  // 3 division che
  // 4 depart che
  // 5 exec
  // 6 repr & vice-repr
  // 7 repr only

  final int level;
  // byte representation width
  final int width = 1;
  
  const Clearance(this.level);
  
  @override
  int compareTo(Clearance other) => this.level.compareTo(other.level);
  
  bool operator <(Clearance other) => this.level < other.level;
  
  static Clearance min(Clearance a, Clearance b) => switch(a.compareTo(b)){
    > 0 => b,
    _ => a
  }
  static Clearance max(Clearance a, Clearance b) => switch(a.compareTo(b)){
    > 0 => a,
    _ => b
  }
  
  static Clearance parse(String value): switch(value.toLowerCase()){
      "exec" => Clearance.parse("executive"),
      "repr" => Clearance.parse("representative"),
      _ => catchOf<Clearance, IterableElementError>(
        tryDo: () => Clearance.values
          .firstWhere((Clearance c) => c.name == value.toLowerCase()),
        catchDo: (_){
          throw FormatException("");
        }),
  };

  static Clearance? tryParse(String name)
    => catchOf<Clearance?, FormatException>(
      tryDo: () => Clearance.parse(name),
      catchDo: (_) => null);

  static Clearance fromLevel(int level){
    if (level < 0 || 7 < level) {
      throw RangeError("");
    }
    Iterable<Clearance> cand = Clearance.values.where((Clearance c) => c.level level);
    if (cand.isEmpty) {
      throw FormatException("");
    } else if (cand.length != 1) {
      throw FormatException("");
    } else {
      return cand.single;
    }
  }
}

class Capability {
  final Clearance read;
  final Clearance write;
  final Clearance exec;
  
  Capability(Clearance read, Clearance write, [Clearance exec]):
    this.read = read,
    this.write = write,
    this.exec = exec ?? (read.compareTo(write) < 0 ? read : write);
  
  bool canRead(Clearance cap) => cap.compareTo(this.read) >= 0;
  bool canWrite(Clearance cap) => this.canRead(cap) && cap.compareTo(this.write) >= 0;
  bool canExec(Clearance cap) => this.canWrite(cap) && cap.compareTo(this.exec) >= 0;
}
class ArticleMeta {
  /// [required] title of the article
  final String title;
  /// [optional] categories
  final List<List<String>> categories;
  /// [optional] clearance level to read the article
  final Clearance access;
  /// [optional] clearance level to edit the article
  final Clearance editable;
  /// [required] author or authors of the article
  final List<String> authors;
  /// [required] hash-id of this version
  final String version;
  /// [required] created datetime of first version
  DateTime createdAt;
  /// [required] updated datetime of this version
  DateTime thisVerAt;
  /// [optional] updated datetime of latest version
  DateTime latestVerAt;

  ArticleMeta({
    required this.title,
    List<List<String>>? categories,
    this.access = Clearance.all,
    this.editable = Clearance.all,
    required this.authors,
    required this.version,
    required this.createdAt,
    required DateTime thisVerAt,
    DateTime? latestVerAt}):
    this.categories = categories ?? <List<String>>[],
    this.thisVerAt = thisVerAt,
    this.latestVerAt = latestVerAt ?? thisVerAt;
  
  /// construct from YAML data
  factory ArticleMeta.fromYaml(YamlMap yaml){
    return ArticleMeta(
      title: yaml.valueAs<String>(),
      categories: ,
      access: ,
      editable: ,
      authors: ,
      version: ,
      createdAt: ,
      thisVerAt: ,
      latestVerAt: l
    )
  }
  
  /// bandle clearances to `Capability`
  Capability get clearances => Capability(access, editable);
}

extension MetaExt<M extends ArticleMeta> on M {
  /// convert to ArticleMeta
  ArticleMeta toMeta() => this as ArticleMeta;
}

class BlogArticle implements ArticleMeta {
  @override
  final String title;
  @override
  final List<List<String>> categories;
  @override
  final Clearance access;
  @override
  final Clearance editable;
  @override
  final List<String> authors;
  @override
  final String version;
  @override
  final DateTime createdAt;
  @override
  final DateTime thisVerAt;
  @override
  final DateTime latestVerAt;
  /** html elements or source lines
   * witch type choose for use?
   * - `HTMLElement` (for Front with `pkg:web`)
   * - `List<String>` (for Server in native)
   * - `type` (for Jaspr with `pkg:jaspr`)
   * - `type` (for Server with `pkg:html`)
   */
  final HTMLElement html;
  
  BlogArticle({
    required this.title,
    List<List<String>>? categories,
    this.access = Clearance.all,
    this.editable = Clearance.all,
    required this.authors,
    required this.version,
    required this.createdAt,
    required DateTime thisVerAt,
    DateTime? latestVerAt,
    required this.html
  }):
    this.categories = categories ?? <List<String>>[],
    this.thisVerAt = thisVerAt,
    this.latestVerAt = latestVerAt ?? thisVerAt;
  
  BlogArticle.withMeta(ArticleMeta meta, this.html):
    this.title = meta.title,
    this.categories = meta.categories,
    this.access = meta.access,
    this.editable = meta.editable,
    this.authors = meta.authors,
    this.version = meta.version,
    this.createdAt = meta.createdAt,
    this.thisVerAt = meta.thisVerAt,
    this.latestVerAt = meta.latestVerAt;
    
  factory BlogArticle.fromYaml(YamlList yaml){
    if (yaml.nodes.length < 2) {
    throw FormatException("YAML stream of YAML-compatible YAML-frontmatter Markdown needs least 2 documents in a data.");
    }
  
    final meta = ArticleMeta.fromYaml(
      yaml.nodes[0].nodeAs<YamlMap>());
  
    List<Node> nodes = document.parse(
      yaml.nodes[1].valueAs<String>());
    // 
    
    return BlogArticle.withMeta(meta, );
  }
}

BlogArticle yfMark2Html(String yfMark)
  => BlogArticle.fromYaml(loadYamlStream(yfMark));