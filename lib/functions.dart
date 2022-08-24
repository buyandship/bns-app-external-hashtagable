import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/widgets/hashtag_text.dart';

import 'detector/detector.dart';

/// Check if the text has hashTags
bool hasHashTags(String value, {bool allowEmoji = false}) {
  final decoratedTextColor = Colors.blue;
  final detector = Detector(
    textStyle: TextStyle(),
    decoratedStyle: TextStyle(color: decoratedTextColor),
    allowEmoji: allowEmoji,
  );
  final result = detector.getDetections(value);
  final detections = result.where((detection) => detection.style!.color == decoratedTextColor).toList();
  return detections.isNotEmpty;
}

/// Extract hashTags from the text
List<String> extractHashTags(String value, {bool allowEmoji = false}) {
  final decoratedTextColor = Colors.blue;
  final detector = Detector(
    textStyle: TextStyle(),
    decoratedStyle: TextStyle(color: decoratedTextColor),
    allowEmoji: allowEmoji,
  );
  final detections = detector.getDetections(value);
  final taggedDetections = detections.where((detection) => detection.style!.color == decoratedTextColor).toList();
  final result = taggedDetections.map((decoration) {
    final text = decoration.range.textInside(value);
    return text.trim();
  }).toList();
  return result;
}

/// Returns textSpan with decorated tagged text
///
/// Used in [HashTagText]
TextSpan getHashTagTextSpan({
  required TextStyle decoratedStyle,
  required TextStyle basicStyle,
  required String source,
  Function(String)? onTap,
  bool decorateAtSign = false,
  bool allowEmoji = false,
}) {
  final decorations = Detector(
    decoratedStyle: decoratedStyle,
    textStyle: basicStyle,
    decorateAtSign: decorateAtSign,
    allowEmoji: allowEmoji,
  ).getDetections(source);
  if (decorations.isEmpty) {
    return TextSpan(text: source, style: basicStyle);
  } else {
    decorations.sort();
    final span = decorations
        .asMap()
        .map(
          (index, item) {
            final recognizer = TapGestureRecognizer()
              ..onTap = () {
                final decoration = decorations[index];
                if (decoration.style == decoratedStyle) {
                  onTap!(decoration.range.textInside(source).trim());
                }
              };
            return MapEntry(
              index,
              TextSpan(
                style: item.style,
                text: item.range.textInside(source),
                recognizer: (onTap == null) ? null : recognizer,
              ),
            );
          },
        )
        .values
        .toList();

    return TextSpan(children: span);
  }
}
