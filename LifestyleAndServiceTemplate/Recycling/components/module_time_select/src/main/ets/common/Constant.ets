/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
export const WEEK_LABELS: ResourceStr[] = [
  $r('app.string.week_weekday'),
  $r('app.string.week_monday'),
  $r('app.string.week_tuesday'),
  $r('app.string.week_wednesday'),
  $r('app.string.week_thursday'),
  $r('app.string.week_friday'),
  $r('app.string.week_saturday'),
  $r('app.string.week_today'),
  $r('app.string.week_tomorrow'),
  $r('app.string.week_tomorrow_after_tomorrow'),
];


/**
 * 时间选项
 */
export interface TimeOptions {
  days?: number;
  startTime?: string;
  endTime?: string;
}

/**
 * 样式选项
 */
export interface StyleOptions {
  dayFg?: ResourceColor;
  dayFgSelected?: ResourceColor;
  timeBg?: ResourceColor;
  timeBgSelected?: ResourceColor;
  timeBorder?: ResourceColor;
  timeBorderSelected?: ResourceColor;
}

export const TIME_OPTIONS_DEFAULT: TimeOptions = {
  days: 7,
  startTime: '06:59:00',
  endTime: '19:30:00',
};

export const STYLE_OPTIONS_DEFAULT: StyleOptions = {
  dayFg: Color.Black,
  dayFgSelected: Color.Blue,
  timeBg: Color.White,
  timeBgSelected: Color.Blue,
  timeBorder: '#D9D9D9',
  timeBorderSelected: Color.Blue,
};