import "dart:convert";
import "dart:io";
import "package:yaml/yaml.dart";
import "package:thinkio_webtool/errors.dart";

abstract class Buildable<With> implements Comparable<With> {
  @override
  String toString([int n = 0]);
}

final LineSplitter ls = LineSplitter();
const HtmlEscape htmlEscape = HtmlEscape();

typedef PageFiles = ({Directory base, Iterable<String> data, Iterable<String> html, Iterable<String>? css});

T casedUpdate<T>(T input, bool Function(T) test, T Function(T) update, [T Function(T)? elseUpdate])
  => test(input) ? update(input) : (elseUpdate ?? ((T i) => i))(input);

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

String asAttr<V>({String? id, Iterable<String>? cls, Map<String, V>? attrs, bool useEscape = false}){
  String ids = attrOr("id", id, useEscape);
  String clss = attrOr("class", cls.doAs<String>((Iterable<String> it) => it.join(" "), ""), useEscape);
  Iterable<String> attrss = attrs?.entries.map<String>((MapEntry<String, V> me) => attrOr(me.key, me.value.toString(), useEscape)) ?? <String>[];
  return ids + (ids == "" ? "" : " ") + clss + (clss == "" ? "" : " ") + attrss.join(" ");
}

String attrOr<T>(String key, String? input, [bool useEscape = false])
  => input == null ? "" : key + "=" + input.doAsStr((String s) => quoted(useEscape ? htmlEscape.convert(s) : s, "\""), "");

extension ScalarWrapToList<E> on E {
  List<E> asList() => <E>[this];
}
extension DoAs<T> on T?{
  R doAs<R>(R Function(T) convert, R ifNull)
    => this == null ? ifNull : convert(this!);
  String doAsStr(String Function(T) convert, String ifNull)
    => this.doAs<String>(convert, ifNull);
}

String quoted(String content, String mark)
  => quotedA(content, mark, mark);
String quotedA(String content, String markS, String markE)
  => "$markS$content$markE";
String indent(String input, [int n = 1]) => "  " * n + input;

Iterable<String> indentMap(Iterable<String> lines, [int n = 1]) => lines.map<String>((String e) => indent(e, n));
List<String> indentMapL(Iterable<String> lines, [int n = 1]) => indentMapL(lines, n).toList();
String indentMapS(String src, [int n = 1]) => indentMap(src.split("\n"), n).join("\n");

Iterable<String> pack(Iterable<String> lines, String tag, [String? attrs]) {
  if(lines.isEmpty){
    return <String>[];
  }
  String attrx = attrs == null ? "" : " $attrs";
  return <String>["<$tag$attrx>"].followedBy(indentMap(lines)).followedBy(<String>["</$tag>"]);
}
String packInline(String line, String tag, [String? attrs]){
  String attrx = attrs == null ? "" : " $attrs";
  return line == "" ? "<$tag$attrx />" : "<$tag$attrx>$line</$tag>";
}
String wrap(String line, String tag, [String? attrs]){
  String attrx = attrs == null ? "" : " $attrs";
  return "<$tag$attrx>$line</$tag>";
}

List<String> packL(Iterable<String> lines, String tag, [String? attrs]) => pack(lines, tag, attrs).toList();

extension UriCD on Uri {
  Uri cd(Iterable<String> path)
    => this.replace(pathSegments: (this.pathSegments.isEmpty || this.pathSegments.last != "" ? this.pathSegments : this.pathSegments.take(this.pathSegments.length - 1)).followedBy(path));
}

extension FSCD on Directory {
  FSE cd<FSE extends FileSystemEntity>(Iterable<String> path){
    final Uri u = this.uri.cd(path);
    late final FileSystemEntity fse;
    if(FileSystemEntity.isFileSync(u.path)){
      fse = File.fromUri(u);
    }else if(FileSystemEntity.isDirectorySync(u.path)){
      fse = Directory.fromUri(u);
    }else{
      throw Error();
    }
    return fse as FSE;
  }
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
typedef YamlKeyResult = ({List<String> exists, List<String> chosen});
extension YamlMapExt on YamlMap {
  YamlKeyResult hasKeys({List<String> requires = const <String>[], List<String> optionals = const <String>[]}){
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
    return (exists: ret, chosen: <String>[]);
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
extension Role on String {
  String get nuked => this.split(" ").where((String s) => !(s.startsWith("(") && s.endsWith(")"))).join(" ");
}
extension RoleCollection on Iterable<String> {
  Iterable<String> get nuked => this.map<String>((String r) => r.nuked);
}