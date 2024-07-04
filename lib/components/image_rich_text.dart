import 'package:flutter/material.dart';

/// 获取带有图片的textSpan列表 - 获取网络资源和本地资源 - 本地资源标记 [IMG:(assets/images/xxx.png]
List<InlineSpan> getTextSpanWithMixedImages(String text) {
  // 正则表达式匹配网络图片URL
  final urlRegex = RegExp(r'https?://\S+', multiLine: true, unicode: true);
  // 正则表达式匹配本地图片资源标记
  final imgRegex = RegExp(r'\[IMG:(.*?)\]', multiLine: true, unicode: true);
  List<InlineSpan> spans = [];
  int pos = 0;
  if (urlRegex.hasMatch(text)) {
    spans.addAll(urlRegex.allMatches(text).map((Match match) {
      print(match.group(0)!);
      WidgetSpan img = WidgetSpan(
        alignment: PlaceholderAlignment.middle, // 垂直居中
        child: Align(
          alignment: Alignment.center,
          child: Image.network(
            match.group(0)!,
            fit: BoxFit.scaleDown ,
            alignment: Alignment.center,
            errorBuilder:
                (BuildContext context, Object exception, StackTrace? stackTrace) {
              return Text(match.group(0)!);
            },
          ),
        )
      );
      pos = match.end;
      return match.start > pos
          ? TextSpan(
          children: [TextSpan(text: text.substring(pos, match.start)), img])
          : img;
    }));
    if(pos<text.length){
      spans.add(TextSpan(text: text.substring(pos)));
    }
  } else if (imgRegex.hasMatch(text)) {
    spans.addAll(imgRegex.allMatches(text).map((Match match) {
      WidgetSpan img = WidgetSpan(
        alignment: PlaceholderAlignment.middle, // 垂直居中
        child: Align(
          alignment: Alignment.center,
          child: Image.asset(
            match.group(0)!.replaceFirst("[IMG:", "").replaceFirst("]",""),
            fit: BoxFit.scaleDown ,
            alignment: Alignment.center,
          ),
        )
      );
      pos = match.end;
      return match.start > pos
          ? TextSpan(
              children: [TextSpan(text: text.substring(pos, match.start)), img])
          : img;
    }));
    if(pos<text.length){
      spans.add(TextSpan(text: text.substring(pos)));
    }
  } else {
    spans.add(TextSpan(text: text));
  }
  return spans;
}

class ImageRichText extends StatelessWidget {
  final String text;

  const ImageRichText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: getTextSpanWithMixedImages(text)),
    );
  }
}
