import "dart:io";
import "package:thinkio_webtool/mprof.dart";
import "package:thinkio_webtool/templater.dart";
import "package:thinkio_webtool/xlib.dart";


void generate_member(PageFiles fin, File fout){
  final tlr = Templater(fin.base, fin.html, fout);
  if(fin.css != null){
    tlr.inject("css", fin.css!, 3);
  }
  tlr.construct<MemberProfile>("body", fin.data, MemberProfile.fromYaml, needSort: true, filterItem: (MemberProfile mp) => mp.current, n: 4);
  tlr.finate();
}