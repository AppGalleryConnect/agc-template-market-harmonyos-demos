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

import { DateTimeSolar } from './DateTimeSolar';

class DateTimeRangeClass {
  readonly dateTimeSolar: DateTimeSolar = new DateTimeSolar();

  public getSolar(): DateTimeSolar {
    return this.dateTimeSolar;
  }

  public getStartYear() {
    return this.dateTimeSolar.getStartSolarYear();
  }

  public setYearRange(startYear: number, endYear: number): void {
    this.dateTimeSolar.setYearRange(startYear, endYear);
  }

  public yearRange(): string[] {
    return this.dateTimeSolar.yearRange();
  }

  public monthRange(year: number): string[] {
    return this.dateTimeSolar.monthRange();
  }

  public dayRange(year: number, month: number): string[] {
    return this.dateTimeSolar.dayRange(year, month);
  }

  public hourRange(): string[] {
    return this.dateTimeSolar.hourRange();
  }

  public minutesRange(): string[] {
    return this.dateTimeSolar.minutesRange();
  }

  public secondsRange(): string[] {
    return this.dateTimeSolar.secondsRange();
  }
}

export const DATE_TIME_RANGE = new DateTimeRangeClass();