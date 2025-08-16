classPageNode._() PageNode {
  final List<String> path;
  
  PageNode._(this.path);
  PageNode.root(): this.path = <String>[""];
  PageNode child(String segment) => PageNode._(<String>[...(this.path), segment]);
  
  PageNode cd([List<String> segments = const <String>[]]) => this._cd(segments, false);
  PathNode _cd(Iterable<String> segments, bool isMiddle){
    if (segments.isEmpty) {
      return this;
    }
    if (!isMiddle && segments.first == "") {
      return PathNode._(segments.toList());
    }
    List<String> res = switch(segments.first) {
      "" || "." => this.path,
      ".." => this.path.take(this.path.length - 1),
      _ => this.path.followedBy(segments.take(1)),
    }.toList();
    return PathNode._(res)._cd(segments.skip(1), true);
  }
  
   PageNode get parent {
    if (path.length <= 1) return this;
    return PageNode._(path.take(path.length - 1).toList());
  }
  int get depth => path.length - 1;
  
  Uri get uri => Uri(pathSegments: this.path);
  String get absolutePath => this.uri.toString();
  String get relativePath => this.path.skip(1).join("/");
  Uri absoluteUri(Uri base) => base.replace(pathSegments: this.path);

  @override
  bool operator ==(Object other) =>
      other is PageNode && this._listEquals(this.path, other.path);
  @override
  int get hashCode => Object.hashAll(this.path);
  
  bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => this.absolutePath;
}