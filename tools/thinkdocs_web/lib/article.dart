import "package:yaml/yaml.dart";
import "package:web/web.dart";

import "package:thinkdocs_web/ext/gen.dart";
import "package:thinkdocs_web/ext/yaml.dart";
import "package:thinkdocs_web/ext/mark.dart";
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

  static Clearance fromLevel(int level){}
}


class ArticleMeta {
  final String title;
  final List<List<String>> categories;
  final Clearance access;
  final Clearance editable;
  final List<String> authors;
  final String version;
  DateTime createdAt;
  DateTime thisVerAt;
  DateTime latestVerAt;

  ArticleMeta({required this.title, });
  
  factory Meta.fromYaml(YamlMap yaml){
    
  }
}

extension MetaExt<M extends ArticleMeta> on M {
  ArticleMeta toMeta() => ArticleMeta(title: this.title);
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
  /// html source lines
  final HTMLElement html;
  
  BlogArticle(this.meta, this.html);
  
  factory BlogArticle.fromYaml(YamlList yaml){
    if (yaml.nodes.length < 2) {
    throw StateError("YAMLストリームには少なくとも2ドキュメント必要です");
    }
  
    final meta = ArticleMeta.fromYaml(
      yaml.nodes[0].nodeAs<YamlMap>());
  
    List<Node> nodes = document.parse(
      yaml.nodes[1].nodeAs<YamlScalar>().valueAs<String>());
  }
}

BlogArticle yfMark2Html(String yfMark)
  => BlogArticle.fromYaml(loadYamlStream(yfMark));