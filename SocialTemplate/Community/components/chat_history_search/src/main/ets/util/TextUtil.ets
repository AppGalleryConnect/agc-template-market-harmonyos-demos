import { MeasureText } from '@kit.ArkUI'

// 精准匹配常见 Emoji，完全排除中文字符
const EMOJI_REGEX =
  /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F170}-\u{1F19A}\u{1F004}\u{1F0CF}\u{1F18E}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{200D}\u{20E3}\u{FE0F}\u{1F170}-\u{1F19A}]/gu;

export class TextUtil {
  static getShortText(text: string, constraintWidth: number, fontSize: Resource, maxLines: number, lineHeight: Resource,
    suffix: string, lastSpan: string, textIndent = 0) {
    let textTemp = TextUtil.processStrWithEmoji(text);
    let textSize = MeasureText.measureTextSize({
      textContent: textTemp,
      fontSize: fontSize,
      constraintWidth: constraintWidth,
      maxLines: maxLines,
      lineHeight: lineHeight,
      textIndent: textIndent
    });
    let needHeight = textSize.height;
    if (needHeight === undefined) {
      return '';
    }
    //二分法查找
    let leftCursor = 0;
    let rightCursor = text.length;
    let cursor = Math.floor(text.length / 2);
    let tempText = '';
    while (true) {
      tempText = TextUtil.safeSliceString(text, 0, cursor) + suffix + lastSpan;
      const tempSize = MeasureText.measureTextSize({
        textContent: TextUtil.processStrWithEmoji(tempText),
        fontSize: fontSize,
        constraintWidth: constraintWidth,
        lineHeight: lineHeight,
        textIndent: textIndent
      });
      const currentHeight = tempSize.height;
      if (currentHeight === undefined) {
        return '';
      }
      if (currentHeight > needHeight) {
        rightCursor = cursor;
        cursor = leftCursor + Math.floor((rightCursor - leftCursor) / 2)
      } else { //小于等于
        leftCursor = cursor;
        cursor += Math.floor((rightCursor - cursor) / 2)
      }
      if (Math.abs(rightCursor - leftCursor) <= 1) { //找到了
        break;
      }
    }
    return TextUtil.safeSliceString(text, 0, cursor, false) + suffix;
  }

  static safeSliceString(str: string, start: number, end: number,
    includeTruncatedEmoji: boolean = true): string {
    const normalizedStart = TextUtil.normalizeIndex(start, str.length);
    const normalizedEnd = TextUtil.normalizeIndex(end, str.length);
    if (normalizedStart >= normalizedEnd) {
      return '';
    }
    const emojiRegex = /[\p{Emoji}\u200d\uFE0F]/gu;
    const emojiRanges: Array<number[]> = [];
    let match: RegExpExecArray | null;
    emojiRegex.lastIndex = 0; // 重置正则缓存
    while ((match = emojiRegex.exec(str))) {
      emojiRanges.push([match.index, emojiRegex.lastIndex]);
    }
    let safeEnd = normalizedEnd;
    let truncatedEmojiRange: number[] | null = null;
    for (const range of emojiRanges) {
      if (range[0] >= normalizedStart && range[0] < normalizedEnd && range[1] > normalizedEnd) {
        truncatedEmojiRange = range;
        break;
      }
    }
    if (truncatedEmojiRange) {
      if (includeTruncatedEmoji) {
        safeEnd = truncatedEmojiRange[1];
      } else {
        safeEnd = truncatedEmojiRange[0];
      }
    }
    for (const range of emojiRanges) {
      if (range[0] >= normalizedStart && range[0] < normalizedEnd && range[1] > normalizedEnd) {
        safeEnd = range[1];
        break;
      }
    }
    safeEnd = Math.min(Math.max(safeEnd, normalizedStart), str.length);
    return str.slice(normalizedStart, safeEnd);
  }

  static normalizeIndex(index: number, length: number): number {
    if (index < 0) {
      return Math.max(length + index, 0);
    }
    return Math.min(index, length);
  }

  static getNeedProcess(text: string, constraintWidth: number, fontSize: Resource, maxLines: number,
    lineHeight: Resource,
    suffix: string = '', lastSpan: string = '') {
    text = TextUtil.processStrWithEmoji(text);
    let newText = text + suffix + lastSpan;
    let textSize = MeasureText.measureTextSize({
      textContent: newText,
      fontSize: fontSize,
      constraintWidth: constraintWidth,
      lineHeight: lineHeight
    });
    let realHeight = textSize.height;
    let needSize = MeasureText.measureTextSize({
      textContent: newText,
      fontSize: fontSize,
      constraintWidth: constraintWidth,
      maxLines: maxLines,
      lineHeight: lineHeight
    });
    let needHeight = needSize.height;
    if (realHeight === undefined || needHeight === undefined) {
      return false;
    }
    return (realHeight > needHeight ? true : false);
  }

  /**
   * 处理字符串：移除Emoji + 补充对应数量的“正”字
   * @param originalStr 原始字符串（含Emoji）
   * @returns 处理后的字符串、Emoji数量
   */
  public static processStrWithEmoji(originalStr: string): string {
    const emojiList = originalStr.match(EMOJI_REGEX) || [];
    const emojiCount = emojiList.length;
    const strWithoutEmoji = originalStr.replace(EMOJI_REGEX, '');
    const supplementStr = '正'.repeat(emojiCount * 1.3);
    const processedStr = strWithoutEmoji + supplementStr;

    return processedStr;
  }
}