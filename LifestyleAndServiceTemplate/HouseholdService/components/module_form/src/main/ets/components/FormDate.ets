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

import { CommonUtils } from '../common/Utils';

@ComponentV2
export struct FormDate {
  @Once @Param date: Date | null = null;
  @Event onDateSelected: (date: Date) => void;
  @Local showDatePickerSheet: boolean = false;
  private _tempDate: Date | null = null;

  @Computed
  get dateText() {
    if (!this.date) {
      return '请选择';
    }
    return CommonUtils.formatDate(this.date.getTime());
  }

  @Computed
  get dateColor() {
    if (!this.date) {
      return $r('app.color.common_grey');
    }
    return $r('sys.color.font_primary');
  }

  @Builder
  datePickerSheet() {
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.ic_public_close_sheet')).width(40).height(40).onClick(() => {
          this.showDatePickerSheet = false;
        })
        Text('生日').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_public_confirm_sheet')).width(40).height(40).onClick(() => {
          this.date = this._tempDate ?? new Date();
          this.showDatePickerSheet = false;
          this.onDateSelected(this.date);
        })
      }
      .width('100%')
      .height(56)

      DatePicker({ selected: this.date, start: new Date('1900-1-1'), end: new Date() })
        .onDateChange((date: Date) => {
          this._tempDate = date;
        })
    }
    .padding({ left: 16, right: 16, bottom: 28 })
  }

  build() {
    Row({ space: 6 }) {
      Text(this.dateText)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.dateColor)
      Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
    }
    .focusOnTouch(true)
    .onClick(() => {
      this.showDatePickerSheet = true;
    })
    .bindSheet($$this.showDatePickerSheet, this.datePickerSheet(), {
      height: SheetSize.FIT_CONTENT,
      showClose: false,
    })
  }
}
