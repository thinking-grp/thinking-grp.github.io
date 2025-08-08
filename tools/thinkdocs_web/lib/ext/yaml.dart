import "package:yaml/yaml.dart";

extension YamlNodeCasting on YamlNode {
  YN nodeAs<YN extends YamlNode>() {
    if (this is YN) {
      return this as YN;
    } else {
      throw StateError("YamlNode is not of expected type $YN: $this");
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
}