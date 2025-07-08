import "dart:convert";
import "dart:io" show File;
import "package:yaml/yaml.dart";
import "package:thinkio_webtool/errors.dart";

final LineSplitter ls = LineSplitter();
typedef PageFiles = ({File data, File html, File? css});

String? toUrlStrA(String? id, String base, String label, String? followIconPath, [bool Function(String)? test]){
  String followIcon = followIconPath != null ? "<img src=\"$followIconPath\" alt=\"logo of $label\">" : "";
  if(id == null){
    return null;
  }
  if(test != null){
    if(test(id)){
      return "<a href=\"$base$id\">$followIcon $label</a>";
    }
  }
  return "<a href=\"$base$id\">$followIcon $label</a>";
}
String indent(String input, [int n = 1]) => "  " * n + input;
Iterable<String> indentMap(Iterable<String> lines, [int n = 1]) => lines.map<String>((String e) => indent(e, n));
List<String> indentMapL(Iterable<String> lines, [int n = 1]) => indentMapL(lines, n).toList();
Iterable<String> pack(Iterable<String> lines, String tag, [String? attrs]) {
  if(lines.isEmpty){
    return <String>[];
  }
  String attrx = attrs == null ? "" : " $attrs";
  return <String>["<$tag$attrx>"].followedBy(indentMap(lines)).followedBy(<String>["</$tag>"]);
}
List<String> packL(Iterable<String> lines, String tag, [String? attrs]) => pack(lines, tag, attrs).toList();
String wrap(String line, String tag, [String? attrs]){
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
      throw YamlMapHasNotRequiredKeysError(requires.where((String e) => !this.containsKey(e)).toList());
    }
    for(String k in optionals){
      if(this.containsKey(k)){
        ret.add(k);
      }
    }
    return ret;
  }
  T valueAs<T>(String key) {
    YamlNode n = this.nodes[key]!;
    if(n is YamlScalar){
      Object? v = n.value;
      if(v is T){
        return v as T;
      } else {
        throw YamlSchemaViolationError(T, v.runtimeType);
      }
    }
    if(n is T){
      return n as T;
    } else {
      throw YamlSchemaViolationError(T, n.runtimeType);
    }
  }
  T? valueAsOrNull<T>(String key) {
    YamlNode? n = this.nodes[key];
    if(n == null){
      return null;
    }
    if(n is YamlScalar){
      Object? v = n.value;
      if(v == null){
        return null;
      }
      if(v is T){
        return v as T;
      } else {
        throw YamlSchemaViolationError(T, v.runtimeType);
      }
    }
    if(n is T){
      return n as T;
    } else {
      throw YamlSchemaViolationError(T, n.runtimeType);
    }
  }
}