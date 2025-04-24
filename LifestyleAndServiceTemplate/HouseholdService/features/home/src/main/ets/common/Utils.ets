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

import { CommonUtils } from 'utils';
import { DayModel } from './Model';

export class HomeUtils {
  /**
   * 获取从当天开始的一周
   * @returns
   */
  static get7Days(): DayModel[] {
    const total = 7;
    const today = new Date();
    let todayDate = today.getDate();
    const days: DayModel[] = [...new Array(total)].map((item: number, index: number) => {
      const temp = new Date(today);
      const curDate = temp.setDate(todayDate);
      todayDate++;
      return new DayModel(new Date(curDate), index);
    });
    return days;
  };

  /**
   * 获取对应日期可以选择的时间
   * @param startTime
   * @param endTime
   * @returns
   */
  static getAllowTimes(startTime: number, endTime: number): string[] {
    const date = new Date(startTime);
    date.setSeconds(0);
    let hours = date.getHours();
    let minutes = date.getMinutes();

    if (minutes < 30) {
      date.setMinutes(30);
    } else {
      date.setHours(hours + 1);
      date.setMinutes(0);
    }

    const times: string[] = [];
    while (date.getTime() <= endTime) {
      times.push(`${CommonUtils.padZero(date.getHours())}:${CommonUtils.padZero(date.getMinutes())}`);
      date.setMinutes(date.getMinutes() + 30);
    }

    return times;
  };
}

