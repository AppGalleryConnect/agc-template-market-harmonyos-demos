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
import { CommonUtils } from '../common/CommonUtils';
import { STYLE_OPTIONS_DEFAULT, TIME_OPTIONS_DEFAULT, TimeOptions, StyleOptions } from '../common/Constant';
import { DayModel } from '../common/Model';
import { TimeUtils } from '../common/TimeUtils';

@ObservedV2
export class TimeSelectVM {
  @Trace dates: DayModel[] = [];
  @Trace times: string[] = [];
  @Trace selectDateIndex: number = 0;
  @Trace selectTimeIndex: number = -1;
  @Trace _selectDateIndex: number = 0;
  @Trace _selectTimeIndex: number = -1;
  @Trace showTimeSheet: boolean = false;
  @Trace selectTime: boolean = false;
  scroller: Scroller = new Scroller();
  timeOptions: TimeOptions = TIME_OPTIONS_DEFAULT;
  styleOptions: StyleOptions = STYLE_OPTIONS_DEFAULT;

  constructor(timeOptions: TimeOptions, styleOptions: StyleOptions) {
    CommonUtils.assign(this.timeOptions, timeOptions);
    CommonUtils.assign(this.styleOptions, styleOptions);
    this.dates = TimeUtils.getDays(this.timeOptions.days);
    this.getTodayTimes();
  }

  getTodayTimes() {
    const today = new Date();
    const startTime = today.getTime();
    const _endTime = TimeUtils.handleTimeSplit(this.timeOptions.endTime!);
    today.setHours(_endTime.hour, _endTime.minute, _endTime.second);
    const endTime = today.getTime();
    this.times = TimeUtils.getAllowTimes(startTime, endTime);
  }

  getOtherDayTimes() {
    const date = new Date();
    const _startTime = TimeUtils.handleTimeSplit(this.timeOptions.startTime!);
    date.setHours(_startTime.hour, _startTime.minute, _startTime.second);
    const startTime = date.getTime();

    const _endTime = TimeUtils.handleTimeSplit(this.timeOptions.endTime!);
    date.setHours(_endTime.hour, _endTime.minute, _endTime.second);
    const endTime = date.getTime();
    this.times = TimeUtils.getAllowTimes(startTime, endTime);
  }

  getSelectTime() {
    try {
      const selectedDate = this.dates[this.selectDateIndex].date;
      const selectTime = this.times[this.selectTimeIndex].split(':').map(v => Number(v));
      selectedDate.setHours(selectTime[0]);
      selectedDate.setMinutes(selectTime[1]);
      selectedDate.setSeconds(0);
      return selectedDate;
    } catch (e) {
      return null;
    }
  }

  onSelectDate(index: number) {
    if (this._selectDateIndex === index) {
      return;
    }
    this._selectDateIndex = index;
    this.onRefreshDay();
    this._selectTimeIndex = -1;
  }

  onRefreshDay() {
    if (this._selectDateIndex === 0) {
      this.getTodayTimes();
    } else {
      this.getOtherDayTimes();
    }
  }

  onClickTime(index: number) {
    this._selectTimeIndex = index;
  }

  openDateTimeSheet() {
    this._selectDateIndex = this.selectDateIndex;
    this._selectTimeIndex = this.selectTimeIndex;
    this.showTimeSheet = true;
  }

  closeDateTimeSheet() {
    this.showTimeSheet = false;
  }

  confirmSelectDateTime() {
    this.selectDateIndex = this._selectDateIndex;
    this.selectTimeIndex = this._selectTimeIndex;
    if (this.selectTimeIndex === -1) {
      this.closeDateTimeSheet();
      this.selectTime = false;
      return;
    }
    this.closeDateTimeSheet();
    this.selectTime = true;
  }

  isTimeEnableSelect(index: number) {
    return index > 6;
  }

  dateFgColor(index: number) {
    return this._selectDateIndex === index ? this.styleOptions.dayFgSelected : this.styleOptions.dayFg;
  }

  dateFgWeight(index: number) {
    return this._selectDateIndex === index ? 400 : 400;
  }

  dateBgColor(index: number) {
    return this._selectDateIndex === index ? $r('sys.color.background_emphasize') : Color.White;
  }

  timeBgColor(index: number) {
    // 选中场景
    if (this._selectTimeIndex === index) {
      return this.styleOptions.timeBgSelected;
    }

    if (!this.isTimeEnableSelect(index)) {
      return this.styleOptions.timeBgDisabled;
    }

    return this.styleOptions.timeBg;
  }

  timeBorderWidth(index: number) {
    // 选中场景
    if (this._selectTimeIndex === index) {
      return 2;
    }

    return 1;
  }

  timeBorderColor(index: number) {
    // 选中场景
    if (this._selectTimeIndex === index) {
      return this.styleOptions.timeBorderSelected;
    }

    return this.styleOptions.timeBorder;
  }
}
