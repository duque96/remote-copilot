import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:remote_copilot_app/ui/components/animated_text_sheen.dart';

class CopilotMarkdownView extends StatelessWidget {
  const CopilotMarkdownView({
    required this.data,
    this.foregroundColor,
    this.maxHeight,
    this.subdued = false,
    this.sheen = false,
    super.key,
  });

  final String data;
  final Color? foregroundColor;
  final double? maxHeight;
  final bool subdued;
  final bool sheen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedForeground = foregroundColor ?? colorScheme.onSurface;
    final textColor = subdued ? resolvedForeground.withValues(alpha: 0.8) : resolvedForeground;
    final codeBlockBackground = colorScheme.brightness == Brightness.dark ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerLow;
    final codeBlockBorderColor = colorScheme.outlineVariant;
    final tableHeaderColor = colorScheme.brightness == Brightness.dark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow;

    final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: TextStyle(color: textColor, height: 1.45, fontSize: subdued ? 13 : 15),
      code: TextStyle(color: textColor, backgroundColor: codeBlockBackground, fontFamily: 'monospace'),
      codeblockDecoration: BoxDecoration(color: codeBlockBackground, borderRadius: BorderRadius.circular(12)),
      blockquote: TextStyle(color: textColor.withValues(alpha: 0.82), height: 1.45),
      listBullet: TextStyle(color: textColor),
      h1: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      h2: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      h3: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableScrollbarThumbVisibility: true,
      tableBorder: TableBorder.all(color: codeBlockBorderColor, borderRadius: BorderRadius.circular(12)),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      tableHeadCellsDecoration: BoxDecoration(color: tableHeaderColor),
    );

    final markdown = MarkdownBody(
      data: data,
      shrinkWrap: true,
      selectable: true,
      builders: {'pre': _ScrollablePreBuilder(foregroundColor: textColor, backgroundColor: codeBlockBackground)},
      styleSheet: markdownStyle,
    );

    final content = sheen ? AnimatedTextSheen(enabled: true, baseColor: textColor, child: markdown) : markdown;

    if (maxHeight == null) {
      return content;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight!),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: content,
        ),
      ),
    );
  }
}

class _ScrollablePreBuilder extends MarkdownElementBuilder {
  _ScrollablePreBuilder({required this.foregroundColor, required this.backgroundColor});

  final Color foregroundColor;
  final Color backgroundColor;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    final code = element.textContent;
    final rawLanguage = _extractLanguage(element);
    final language = _normalizeLanguage(rawLanguage);
    final textStyle = (preferredStyle ?? parentStyle ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
      color: foregroundColor,
      fontFamily: 'monospace',
      height: 1.45,
      fontSize: 13,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rawLanguage case final headerLanguage?)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(
                headerLanguage.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.55),
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(12, rawLanguage == null ? 12 : 8, 12, 12),
            child: HighlightView(code, language: language, padding: EdgeInsets.zero, textStyle: textStyle),
          ),
        ],
      ),
    );
  }

  String? _extractLanguage(md.Element element) {
    String? className;

    for (final child in element.children ?? const <md.Node>[]) {
      if (child is md.Element) {
        className = child.attributes['class'];
        break;
      }
    }

    if (className == null || className.isEmpty) {
      return null;
    }

    for (final token in className.split(' ')) {
      if (token.startsWith('language-') && token.length > 'language-'.length) {
        return token.substring('language-'.length);
      }
    }

    return null;
  }

  String? _normalizeLanguage(String? language) {
    if (language == null) {
      return null;
    }

    const aliases = {
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'py': 'python',
      'kt': 'kotlin',
      'rs': 'rust',
      'yml': 'yaml',
      'sh': 'bash',
      'shell': 'bash',
      'cs': 'csharp',
    };

    return aliases[language.trim().toLowerCase()] ?? language.trim().toLowerCase();
  }
}