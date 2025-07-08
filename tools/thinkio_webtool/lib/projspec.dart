import "dart:io";
import "package:yaml/yaml.dart";
import "package:markdown/markdown.dart";
import "package:thinkio_webtool/xlib.dart";

class ProjectSpec implements Comparable<ProjectSpec> {

  ProjectSpec();
  
  factory ProjectSpec.fromYaml(YamlMap yaml) {}
  
  @override
  int compareTo(ProjectSpec other){
    return 0;
  }
  
  @override
  String toString([int n = 0]){}
}