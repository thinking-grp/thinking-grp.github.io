import "package:yaml/yaml.dart";

extension YamlNodeCasting on YamlNode {
  YN nodeAs<YN extends YamlNode>() {
    if (this is YN) {
      return this as YN;
    } else {
      throw StateError("YamlNode is not of expected type $YN: $this");
    }
  }
  V valueAs<V>() => this.nodeAs<YamlScalar>().valueAs<V>();
}
typedef YamlKeyResult = ({List<String> exists, List<String> chosen});
extension YamlMapExt on YamlMap {
  YamlKeyResult hasKeys({List<String> requires = const <String>[], List<String> optionals = const <String>[], Map<String, String> alternates = const <String, String>{}}){
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

extension YamlValueCasting on YamlScalar {
  V valueAs<V>() {
    Object? o = this.value;
    if (o is V) {
      return o as V;
    } else {
      throw StateError("Value is not of expected type $V: $o");
    }
  }
  V? valueAsOrNull<V>(){
    try {
      this.valueAs<V>();
    } on StateError catch (_) {
      return null;
    } 
  }
}

