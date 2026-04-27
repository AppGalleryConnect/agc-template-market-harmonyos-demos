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
import { STYLE_OPTIONS_DEFAULT, StyleOptions, TIME_OPTIONS_DEFAULT, TimeOptions } from '../common/Constant';
import { DayModel } from '../common/Model';
import { TimeSelectVM } from '../viewmodel/TimeSelectVM';

@ComponentV2
export struct TimeSelect {
  @Param breakpoint: string = '';
  @Param label: ResourceStr = '请选择';
  @Param timeOptions: TimeOptions = TIME_OPTIONS_DEFAULT;
  @Param styleOptions: StyleOptions = STYLE_OPTIONS_DEFAULT;
  @BuilderParam promptBuilder: () => void = this.ItemBuilder;
  timeSelectVM: TimeSelectVM = new TimeSelectVM(this.timeOptions, this.styleOptions);
  @Event onTimeSelect: (dateTime: Date | null) => void = () => {
  };
  @Local currentAdd: string | undefined = ''

  @Builder
  SheetTimeSelect() {
    Column({ space: 12 }) {
      Scroll() {
        Row() {
          ForEach(this.timeSelectVM.dates, (v: DayModel, index) => {
            Column() {
              Text(v.weekDesc)
                .fontSize(12)
                .fontColor(this.timeSelectVM.dateFgColor(index))
                .fontWeight(this.timeSelectVM.dateFgWeight(index))
              Text(v.dateDesc)
                .fontSize(12)
                .fontColor(this.timeSelectVM.dateFgColor(index))
                .fontWeight(this.timeSelectVM.dateFgWeight(index))
            }
            .justifyContent(FlexAlign.Center)
            .height(40)
            .width(40)
            .backgroundColor(this.timeSelectVM.dateBgColor(index))
            .borderRadius(8)
            .onClick(() => {
              this.timeSelectVM.onSelectDate(index);
            })
          }, (v: DayModel) => v.date.getTime().toString())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .margin({ top: 12 })
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring)

      if (this.timeSelectVM.times.length) {
        Grid(this.timeSelectVM.scroller) {
          ForEach(this.timeSelectVM.times, (v: string, index: number) => {
            GridItem() {
              Column({ space: 2 }) {
                Text(v).fontSize(14)
                  .fontColor(this.timeSelectVM.isTimeEnableSelect(index) ? $r('sys.color.font_primary') :
                    $r('sys.color.font_tertiary'))
                if (!this.timeSelectVM.isTimeEnableSelect(index)) {
                  Text('约满').fontSize(10).fontColor($r('sys.color.font_tertiary'))
                }
              }
              .width('100%')
              .height(36)
              .justifyContent(FlexAlign.Center)
              .borderRadius(8)
              .backgroundColor(this.timeSelectVM.timeBgColor(index))
              .borderColor(this.timeSelectVM.timeBorderColor(index))
              .borderWidth(this.timeSelectVM.timeBorderWidth(index))
              .enabled(this.timeSelectVM.isTimeEnableSelect(index))
              .onClick(() => {
                this.timeSelectVM.onClickTime(index);
              })
            }
          }, (day: string, index: number) => day + index)
        }
        .layoutWeight(1)
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(4)
        .rowsGap(8)
        .width('100%')
        .scrollBar(BarState.Off)
      } else {
        Column({ space: 12 }) {
          Image($r('app.media.ic_empty')).width(56).height(47)
          Text('暂无时间').fontColor($r('app.color.common_grey')).fontSize(12)
        }
        .layoutWeight(1)
        .width('100%')
        .margin({ top: 60, bottom: 60 })
      }

      Row() {
        Button('确定')
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .height(40)
          .backgroundColor($r('app.color.common_theme_color'))
          .onClick(() => {
            this.timeSelectVM.confirmSelectDateTime();
            this.currentAdd = CommonUtils.formatDateTime(this.timeSelectVM.getSelectTime()?.getTime());
            this.onTimeSelect(this.timeSelectVM.getSelectTime());
          })
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .padding({ left: 16, right: 16, bottom: this.breakpoint === 'sm' ? 40 : 16 })
  }

  build() {
    Row() {
      this.promptBuilder()
    }
    .onClick(() => {
      this.timeSelectVM.openDateTimeSheet();
      this.timeSelectVM.onRefreshDay();
    })
    .bindSheet($$this.timeSelectVM.showTimeSheet, this.SheetTimeSelect(), {
      showClose: true,
      title: { title: '上门时间' },
      preferType: this.breakpoint === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
      height: SheetSize.MEDIUM,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
    })
  }

  @Builder
  ItemBuilder() {
    Row() {
      SymbolGlyph($r('sys.symbol.clock_fill'))
        .fontSize(24)
        .fontColor([$r('sys.color.icon_secondary')])
        .margin({ right: 8 })

      if (!this.timeSelectVM.selectTime) {
        Text('请选择您希望的上门时间')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(21)
          .layoutWeight(1)
      } else {
        Text(this.currentAdd)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(21)
          .layoutWeight(1)
      }
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.icon_secondary')])
        .fontSize(24)
        .margin({ left: 8 })
    }
  }
}