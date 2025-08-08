import "package:markdown/markdown.dart";

/// thinkdocs markdown syntax and extension fravors
class ThinkMark {
  final List<BlockSyntax> blocks = <BlockSyntax>[];
  final List<InlineSyntax> inlines = <InlineSyntax>[];
  final ExtensionSet exts = ExtensionSet(
    ExtensionSet.gitHubFlavored.blockSyntaxes.followedBy(<BlockSyntax>[]),ExtensionSet.gitHubFlavored.inlineSyntaxes.followedBy(<InlineSyntax>[])
    );
    final Resolver linkResolver = (String name, [String? title]){}
    final Resolver imageResolver = (String name, [String? title]){}
  
}

final ThinkMark thinkMark = ThinkMark();

String _styleTextPattern = r"\[]{}";

class StyleTextSyntax extends InlineSyntax {
  StyleTextSyntax(): super(_styleTextPattern);
  
  @override
  bool onMatch(InlineParser parser, Match match){
    
  }
}

final Document document = Document(
    blockSyntaxes: thinkMark.blocks,
    inlineSyntaxes: thinkMark.inlines,
    extensionSet: thinkMark.exts,
    linkResolver: thinkMark.linkResolver,
    imageLinkResolver: thinkMark.imageResolver,
    encodeHtml: true,
    withDefaultBlockSyntaxes: true,
    withDefaultInlineSyntaxes: true,
  );