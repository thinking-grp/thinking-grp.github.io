class YamlSchemaViolationError extends Error {
  final Type requiredType;
  final Type actualType;

  YamlSchemaViolationError(this.requiredType, this.actualType);

  @override
  String toString() => "YamlSchemaViolationError\nThe type of value violates supposed schema\nrequired: ${this.requiredType}\nactual: ${this.actualType}\n";

}
class YamlMapHasNotRequiredKeysError extends Error {
  final List<String> missings;

  YamlMapHasNotRequiredKeysError(this.missings);

  @override
  String toString() => "YamlMapHasNotRequiredKeysError\nThe map hasn't required keys\nmissings: ${this.missings}\n";
}