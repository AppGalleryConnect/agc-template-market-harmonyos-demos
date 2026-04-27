/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the ""License"");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ""AS IS"" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

export enum DateIndex {
  YEAR = 0,
  MONTH = 1,
  DAY = 2,
  HOURS = 3,
  MINUTES = 4,
  SECOND = 5,
}

export enum TimeFormat {
  NONE = 0,
  HOUR = 1,
  MINUTES = 2,
  SECOND = 3,
}

export interface DateTimePickerOption {
  isLoop?: boolean
  timeFormat?: TimeFormat
}

export interface DateTimePickerStyle {
  backgroundColor?: ResourceColor
  borderColor?: ResourceColor | EdgeColors | LocalizedEdgeColors
  borderWidth?: Length | EdgeWidths | LocalizedEdgeWidths
  borderRadius?: Length | BorderRadiuses | LocalizedBorderRadiuses
  margin?: Margin | Length | LocalizedMargin
}

export interface DateTimePickerData {
  startYear: number // 日期时间选择器开始日期
  endYear: number // 日期时间选择器结束日期
  selectedDate?: Date // 默认选中日期
  resultCb: Callback<Date> // 当前选中的日期时间回调
}

export interface DateTimePickerParam {
  data: DateTimePickerData
  option?: DateTimePickerOption
  style?: DateTimePickerStyle
}