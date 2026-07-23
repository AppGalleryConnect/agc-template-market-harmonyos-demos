/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@ObservedV2
class TopicItemModel {
  // 类型
  type: string
  // 标题
  title: string
  // 题目ID
  keyID: string
  // 题目选项列表
  @Trace ques: AnswerItem[] = []
  // 解析
  parse: string = ''
  // 题目答案列表
  rightQues: string[]
  // 选中的答案列表
  selectQues: string[]
  // 0原始状态 1错误 2正确
  showState: number = 0
  // 是否已经答过
  @Trace isAnswer: boolean = false

  constructor(keyID: string, type: string, title: string, ques: AnswerItem[], rightQues: string[],
    selectQues: string[], isAnswer: boolean, parse: string) {
    this.type = type;
    this.title = title;
    this.keyID = keyID;
    this.ques = ques;
    this.rightQues = rightQues;
    this.selectQues = selectQues
    this.isAnswer = isAnswer
    this.parse = parse
  }
}

@ObservedV2
class AnswerItem {
  // 选项标题
  ansTitle: string
  // 选项ID
  ansID: string
  ans: string
  // 是否选中
  @Trace isSelect: boolean
  // 0原始状态 1错误状态 2正确状态
  @Trace showState: number = 0

  constructor(ansTitle: string, ansID: string, ans: string, isSelect: boolean, showState: number) {
    this.ansTitle = ansTitle;
    this.ansID = ansID;
    this.ans = ans;
    this.isSelect = isSelect;
    this.showState = showState;
  }
}

@ObservedV2
class SearchHistory {
  // 用 @Trace 标记数组属性，使其变化可被追踪
  @Trace public historyList: string[] = [];
}

export { AnswerItem, TopicItemModel, SearchHistory }