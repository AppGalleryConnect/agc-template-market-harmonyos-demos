/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { PlayConstants } from '../player/common/constants/PlayConstants';

export class DateFormatUtil {
  /**
   * Seconds converted to HH:mm:ss.
   *
   * @param seconds Maximum video duration (seconds).
   * @return Time after conversion.
   */
  static secondToTime(seconds: number): string {
    let hourUnit = PlayConstants.TIME_UNIT * PlayConstants.TIME_UNIT;
    let hour = Math.floor(seconds / hourUnit);
    let minute = Math.floor((seconds - hour * hourUnit) / PlayConstants.TIME_UNIT);
    let second = seconds - hour * hourUnit - minute * PlayConstants.TIME_UNIT;
    if (hour > 0) {
      return `${DateFormatUtil.padding(hour.toString())}${':'}
        ${DateFormatUtil.padding(minute.toString())}${':'}${DateFormatUtil.padding(second.toString())}`;
    }
    if (minute > 0) {
      return `${DateFormatUtil.padding(minute.toString())}${':'}${DateFormatUtil.padding(second.toString())}`;
    } else {
      return `${PlayConstants.INITIAL_TIME_UNIT}${':'}${DateFormatUtil.padding(second.toString())}`;
    }
  }

  /**
   * Zero padding, 2 bits.
   *
   * @param num Number to be converted.
   * @return Result after zero padding.
   */
  static padding(num: string): string {
    let length = PlayConstants.PADDING_LENGTH;
    for (let len = (num.toString()).length; len < length; len = num.length) {
      num = `${PlayConstants.PADDING_STR}${num}`;
    }
    return num;
  }
}