import "dart:io";
import "package:sitemap/sitemap.dart";
import "package:thinkio_webtool/blogind.dart";
import "package:thinkio_webtool/pagenode.dart";

void genSitemap(File out, Iterable<BlogRec> blogs) {
  final sm = Sitemap();
  
  final index = PageNode.root();
  final PageNode about = index.child("about");
  final PageNode member = about.child("member.html");
  final PageNode project = index.child("project");
  final PageNode thinkerAI = project.child("thinkerAI");
  final PageNode thinkfont = project.child("thinkfont");
  final PageNode thinkingsns = project.child("thinkingsns");
  final PageNode thinkos = project.child("thinkos");
  final PageNode blog = index.child("blog");
  
  final Map<PageNode, num> staticPages = <PageNode, num>{
    index: 0.6,
    about: 0.6,
    member: 0.8,
    project: 0.4,
    thinkerAI: 0.6,
    thinkfont: 0.3,
    thinkingsns: 0.75,
    thinkos: 0.75,
    blog: 0.8,
  };
  final num blogPriority = 0.95;
  
  sm.entries.addAll(
      staticPages.entries.map<SitemapEntry>((MapEntry<PageNode, num> e) => visit(e.key.path, e.value))
    );
  sm.entries.addAll(
      blogs
        .where((BlogRec br) => !br.path.hasAuthority)
        .map<SitemapEntry>((BlogRec br) => visit(br.path.pathSegments, blogPriority))
  );
  
  if (!out.existsSync()) {
    out.createSync(recursive: true);
  }
  out.writeAsStringSync(sm.generate());
}

SitemapEntry visit(Iterable<String> path, num priority) {
  final base = Uri.parse("https://www.thinking-grp.org/");
  final Iterable<String> ps = path.first == "" ? path.skip(1) : path;
  final Uri fu = Uri(pathSegments: ps.last.contains(".") ? ps : ps.followedBy(<String>["index.html"]));
  final Uri loc = base.replace(pathSegments: ps);
  final f = File.fromUri(fu);
  final sme = SitemapEntry();
  
  sme.location = loc.toString();
  sme.lastModified = f.lastModifiedSync();
  sme.changeFrequency = "weekly";
  sme.priority = priority;
  
  return sme;
}