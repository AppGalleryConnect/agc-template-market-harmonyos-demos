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
export class PracticeRecordModel {
  // 日期
  @Trace date: string = ''
  // 科目
  subject?: string
  // 练习时长
  @Trace practiceDuration?: string
  // 练习次数
  @Trace practiceCount?: string
  // 正确率
  @Trace correctRate?: string
  // 总题数
  @Trace totalCount?: string
  // 错题数
  @Trace wrongCount?: string
  // 练习数据
  practiceModels?: PracticeModel[]
}

export class PracticeModel {
  // 记录ID
  keyID: string = ''
  // 日期
  date: string = ''
  // 科目
  subject: string = ''
  // 练习时长
  practiceDuration: number = 0
  // 正确题数
  rightCount: number = 0
  // 题数
  topicCount: number = 0
}

// 练习记录
export const PRACTICE_RECORD_DATA: PracticeModel[] = [
  {
    keyID: '1',
    date: '2025-05-29',
    subject: '建筑工程经济',
    practiceDuration: 1 * 3600 + 5 * 60 + 38,
    rightCount: 3,
    topicCount: 7
  },
  {
    keyID: '2',
    date: '2025-05-29',
    subject: '建筑工程经济',
    practiceDuration: 1 * 3600 + 5 * 60 + 38,
    rightCount: 2,
    topicCount: 7
  },
  {
    keyID: '3',
    date: '2025-05-29',
    subject: '建筑工程管理与实务',
    practiceDuration: 1 * 3600 + 5 * 60 + 38,
    rightCount: 7,
    topicCount: 7
  },
  {
    keyID: '4',
    date: '2025-05-28',
    subject: '建筑工程经济',
    practiceDuration: 1 * 3600 + 13 * 60 + 41,
    rightCount: 6,
    topicCount: 7
  },
  {
    keyID: '5',
    date: '2025-05-27',
    subject: '建筑工程经济',
    practiceDuration: 1 * 3600 + 13 * 60 + 41,
    rightCount: 5,
    topicCount: 7
  },
  {
    keyID: '6',
    date: '2025-05-27',
    subject: '建筑工程经济',
    practiceDuration: 1 * 3600 + 13 * 60 + 41,
    rightCount: 3,
    topicCount: 7
  },
  {
    keyID: '7',
    date: '2025-05-25',
    subject: '建筑工程经济',
    practiceDuration: 1 * 3600 + 13 * 60 + 41,
    rightCount: 4,
    topicCount: 7
  },
  {
    keyID: '8',
    date: '2025-05-24',
    subject: '建筑工程经济',
    practiceDuration: 13 * 60 + 41,
    rightCount: 7,
    topicCount: 7
  },
  {
    keyID: '9',
    date: '2025-05-20',
    subject: '建筑工程经济',
    practiceDuration: 13 * 60 + 41,
    rightCount: 7,
    topicCount: 7
  },
  {
    keyID: '10',
    date: '2025-05-20',
    subject: '建筑工程管理与实务',
    practiceDuration: 13 * 60 + 41,
    rightCount: 5,
    topicCount: 7
  },
  {
    keyID: '11',
    date: '2025-05-10',
    subject: '建筑工程经济',
    practiceDuration: 15 * 3600 + 13 * 60 + 41,
    rightCount: 6,
    topicCount: 7
  }
]
