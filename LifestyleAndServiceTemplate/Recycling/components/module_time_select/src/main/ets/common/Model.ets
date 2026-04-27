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

import { CommonUtils } from './CommonUtils';
import { WEEK_LABELS } from './Constant';

/**
 * 日模型
 */
export class DayModel {
  date: Date;
  dateDesc: string;
  weekDesc: ResourceStr;

  constructor(date: Date, index: number) {
    this.date = date;
    this.dateDesc = `${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
    if (index === 0) {
      this.weekDesc = WEEK_LABELS[7];
    } else if (index === 1) {
      this.weekDesc = WEEK_LABELS[8];
    } else if (index === 2) {
      this.weekDesc = WEEK_LABELS[9];
    } else {
      this.weekDesc = WEEK_LABELS[date.getDay()];
    }
  }
}

/**
 * 时间模型
 */
export interface TimeModel {
  hour: number;
  minute: number;
  second: number;
}