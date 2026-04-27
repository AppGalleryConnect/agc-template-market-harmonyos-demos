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
import { STYLE_OPTIONS_DEFAULT, TIME_OPTIONS_DEFAULT, TimeOptions, StyleOptions } from '../common/Constant';
import { DayModel } from '../common/Model';
import { TimeSelectVM } from '../viewmodel/TimeSelectVM';

@ComponentV2
export struct TimeSelect {
  @Param label: ResourceStr = '请选择';
  @Param timeOptions: TimeOptions = TIME_OPTIONS_DEFAULT;
  @Param styleOptions: StyleOptions = STYLE_OPTIONS_DEFAULT;
  @Param selectedTimestamp: number | null = null;
  @Event onTimeSelect: (dateTime: Date) => void = () => {
  };
  timeSelectVM: TimeSelectVM = new TimeSelectVM(this.timeOptions, this.styleOptions);

  private syncSelectedFromParam() {
    if (this.selectedTimestamp === null) {
      return;
    }
    const target = new Date(this.selectedTimestamp);
    let dayIndex = 0;
    for (let i = 0; i < this.timeSelectVM.dates.length; i++) {
      const d = this.timeSelectVM.dates[i].date;
      if (d.getFullYear() === target.getFullYear() && d.getMonth() === target.getMonth() &&
        d.getDate() === target.getDate()) {
        dayIndex = i;
        break;
      }
    }
    this.timeSelectVM._selectDateIndex = dayIndex;
    this.timeSelectVM.selectDateIndex = dayIndex;
    if (dayIndex === 0) {
      this.timeSelectVM.getTodayTimes();
    } else {
      this.timeSelectVM.getOtherDayTimes();
    }
    const hh = `${target.getHours() < 10 ? '0' : ''}${target.getHours()}`;
    const mm = `${target.getMinutes() < 10 ? '0' : ''}${target.getMinutes()}`;
    const timeStr = `${hh}:${mm}`;
    const idx = this.timeSelectVM.times.indexOf(timeStr);
    this.timeSelectVM._selectTimeIndex = idx;
    this.timeSelectVM.selectTimeIndex = idx;
  }

  @Builder
  SheetTimeSelect() {
    Column() {
      // 标题
      Row() {
        Row()
        Text('上门时间').fontSize(16).fontWeight(700).margin({ left: 8 })
        Image($r('app.media.ic_public_close_sheet')).width(15).height(15).onClick(() => {
          this.timeSelectVM.closeDateTimeSheet();
        })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)

      Scroll() {
        Row({ space: 4 }) {
          ForEach(this.timeSelectVM.dates, (v: DayModel, index) => {
            Column({ space: 2 }) {
              Text(v.weekDesc)
                .fontSize(12)
                .fontColor(this.timeSelectVM.dateFgColor(index))
                .fontWeight(this.timeSelectVM.dateFgWeight(index))
              Text(v.dateDesc)
                .fontSize(12)
                .fontColor(this.timeSelectVM.dateFgColor(index))
                .fontWeight(this.timeSelectVM.dateFgWeight(index))
            }
            .padding(10)
            .backgroundColor(this.timeSelectVM.dateBgColor(index))
            .borderRadius(4)
            .onClick(() => {
              this.timeSelectVM.onSelectDate(index);
            })
          }, (v: DayModel) => v.date.getTime().toString())
        }
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring)
      .padding({
        top: 10,
        bottom: 16,
      })

      if (this.timeSelectVM.times.length) {
        Grid(this.timeSelectVM.scroller) {
          ForEach(this.timeSelectVM.times, (v: string, index: number) => {
            GridItem() {
              Column({ space: 2 }) {
                Text(v).fontSize(14)
                  .fontColor(this.timeSelectVM.timeFgColor(index))

                if (!this.timeSelectVM.isTimeEnableSelect(index)) {
                  Text('约满').fontSize(10)
                }
              }
              .width('100%')
              .height(36)
              .justifyContent(FlexAlign.Center)
              .borderRadius(4)
              .backgroundColor(this.timeSelectVM.timeBgColor(index))
              .borderColor(this.timeSelectVM.timeBorderColor(index))
              .borderWidth(1)
              .enabled(this.timeSelectVM.isTimeEnableSelect(index))
              .opacity(this.timeSelectVM.isTimeEnableSelect(index) ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
              .onClick(() => {
                this.timeSelectVM.onClickTime(index);
              })
            }
          }, (day: string) => day)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(4)
        .rowsGap(10)
        .width('100%')
        .padding({
          bottom: 10,
        })
        .scrollBar(BarState.Off)
        .height(320)
      } else {
        Column({ space: 10 }) {
          Image($r('app.media.ic_empty')).width(56).height(47)
          Text('暂无时间').fontColor($r('app.color.common_grey')).fontSize(12)
        }
        .width('100%')
        .margin({ top: 60, bottom: 60 })
      }
      Row() {
        Text('确认')
          .width(304)
          .height(40)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .fontColor('#FFFFFF')
          .borderRadius(20)
          .backgroundColor('#FF4B4B')
          .onClick(() => {
            this.timeSelectVM.confirmSelectDateTime();
            const date = this.timeSelectVM.getSelectTime()
            if(date === null){
              this.getUIContext().getPromptAction().showToast({ message: '请选择时间' })
              return
            }
            this.timeSelectVM.closeDateTimeSheet();
            this.onTimeSelect(date);
          })
      }
      .width('100%')
      .margin({ bottom: 28 })
      .justifyContent(FlexAlign.Center)
    }
    .padding({ left: 16, right: 16 })
  }

  build() {
    Row() {
      Text(this.label).fontSize(14).fontColor('rgba(0,0,0,0.95)')

      Blank()
      Image($r('app.media.ic_public_arrow_right')).width(12).height(12)
    }
    .width('100%')
    .padding({ right: 28 })
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.syncSelectedFromParam();
      this.timeSelectVM.openDateTimeSheet();
    })
    .bindSheet($$this.timeSelectVM.showTimeSheet, this.SheetTimeSelect(),
      { detents: [530], preferType: SheetType.BOTTOM, showClose: false }
    )
  }
}
