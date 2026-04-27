/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

export interface SlicedText {
  text: string;
  isHighlight: boolean;
}

export class StringUtil {
  public static isBlank(input: string): boolean {
    if (!!input) {
      return input.trim().length === 0;
    }
    return true;
  }

  public static getSlicedText(text: string, keyWord: string, isIgnoredCase?: boolean): SlicedText[] {
    if (!keyWord || !text) {
      return [];
    }
    let slicedText: SlicedText[] = [];
    let inputKeyWord: string;
    let inputText: string;
    if (isIgnoredCase) {
      inputKeyWord = keyWord.toUpperCase();
      inputText = text.toUpperCase();
    } else {
      inputKeyWord = keyWord;
      inputText = text;
    }
    let curIndex = 0;
    let keyWordIndex = inputText.indexOf(inputKeyWord, curIndex);
    while (keyWordIndex >= 0) {
      if (keyWordIndex > curIndex) {
        slicedText.push({
          text: text.slice(curIndex, keyWordIndex),
          isHighlight: false
        });
      }
      slicedText.push({
        text: text.slice(keyWordIndex, keyWordIndex + inputKeyWord.length),
        isHighlight: true
      });
      curIndex = keyWordIndex + inputKeyWord.length;
      keyWordIndex = inputText.indexOf(inputKeyWord, curIndex);
    }
    if (curIndex < inputText.length) {
      slicedText.push({
        text: text.slice(curIndex, inputText.length),
        isHighlight: false
      });
    }
    return slicedText;
  }
}