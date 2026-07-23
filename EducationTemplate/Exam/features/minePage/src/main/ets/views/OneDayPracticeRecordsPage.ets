/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { HashSet } from '@kit.ArkTS';
import {
  BreakpointType, Logger, PracticeModel, PracticeRecordModel, RouterMap, RouterModule
} from 'commonlib';
import { MineVM } from '../viewModel/MineVM';

const TAG = 'OneDayPracticeRecordsPage';

/**
 * 某一天练习记录页面
 */
@ComponentV2
export struct OneDayPracticeRecordsPage {
  practiceRecord: PracticeRecordModel = new PracticeRecordModel();
  practiceRecordModels: PracticeRecordModel[] = [];
  mineVM: MineVM = MineVM.instance;

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
    this.practiceRecord = RouterModule.getNavParam({ url: RouterMap.DAY_PRACTICE_DETAILS_PAGE })!;
    // 初始化数据
    this.initData();
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Divider().color($r('sys.color.comp_divider'));
      Column() {
        // 练习次数
        this.subTitleBuilder();
        // 练习明细
        this.practiceDetailsBuilder();
      }
      .width('100%')
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
    }
    .width('100%')
    .height('100%');
  }

  /**
   * 练习记录
   */
  @Builder
  practiceDetailsBuilder() {
    List({ space: 8 }) {
      ForEach(this.practiceRecordModels,
        (record: PracticeRecordModel) => {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.icon_true_questions'))
                  .width($r('app.float.vp_32'))
                  .height($r('app.float.vp_32'));
                Text(record.subject)
                  .fontSize($r('sys.float.Subtitle_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ left: $r('app.float.vp_8') });
              }
              .width('100%');

              Row() {
                Column() {
                  Text(record.practiceDuration ?? '-')
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium);
                  Text($r('app.string.practice_duration'))
                    .margin({ top: $r('app.float.vp_4') })
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Caption_L'));
                }
                .height($r('app.float.vp_56'))
                .width($r('app.float.vp_70'))
                .backgroundColor($r('sys.color.background_primary'))
                .borderRadius(12)
                .justifyContent(FlexAlign.Center);

                Column() {
                  Text(record.totalCount ?? '-')
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'));
                  Text('总题数')
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: $r('app.float.vp_4') });
                }
                .width($r('app.float.vp_70'))
                .height($r('app.float.vp_56'))
                .justifyContent(FlexAlign.Center)
                .backgroundColor($r('sys.color.background_primary'))
                .borderRadius(12);

                Column() {
                  Text(record.wrongCount ?? '-')
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'));
                  Text('错误')
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: $r('app.float.vp_4') });
                }
                .width($r('app.float.vp_70'))
                .height($r('app.float.vp_56'))
                .justifyContent(FlexAlign.Center)
                .backgroundColor($r('sys.color.background_primary'))
                .borderRadius(12);

                Column() {
                  Text(record.correctRate ?? '-')
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'));
                  Text($r('app.string.correct_rate'))
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: $r('app.float.vp_4') });
                }
                .width($r('app.float.vp_70'))
                .height($r('app.float.vp_56'))
                .justifyContent(FlexAlign.Center)
                .backgroundColor($r('sys.color.background_primary'))
                .borderRadius(12);
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ top: $r('app.float.vp_8') });
            }
            .width('100%')
            .height($r('app.float.vp_120'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius($r('app.float.vp_16'))
            .padding($r('app.float.vp_12'));
          };
        }, (item: PracticeRecordModel, index: number) => item.date + index);
    }
    .height('82%')
    .width('100%')
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
  }

  /**
   * 练习次数
   */
  @Builder
  subTitleBuilder() {
    Row() {
      Text($r('app.string.practice_count'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') });
      Text(`${this.practiceRecord.practiceCount}次`)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.time_btn'))
        .margin({ left: $r('app.float.vp_4') });
    }
    .width('100%');
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .width($r('app.float.vp_40'))
            .height($r('app.float.vp_40'))
            .borderRadius($r('app.float.vp_20'))
            .onClick(() => {
              RouterModule.pop();
            });
        }
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .borderRadius($r('app.float.vp_20'));

        Text(this.practiceRecord.date)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: $r('app.float.vp_8') });
        Text($r('app.string.practice_records'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
      };
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
  }

  /**
   * 初始化数据
   */
  initData() {
    try {
      let practiceModels: PracticeModel[] = this.practiceRecord.practiceModels!;
      let subjectSet: HashSet<string> = new HashSet();
      practiceModels.forEach((item: PracticeModel) => {
        subjectSet.add(item.subject);
      });
      subjectSet.forEach((subject: string) => {
        let record: PracticeRecordModel = new PracticeRecordModel();
        record.subject = subject;
        let practiceDuration: number = 0;
        let rightCount: number = 0;
        let topicCount: number = 0;
        let practiceCount: number = 0;
        practiceModels.forEach((item: PracticeModel) => {
          if (subject === item.subject) {
            practiceDuration += item.practiceDuration;
            rightCount += item.rightCount;
            topicCount += item.topicCount;
            practiceCount++;
          }
        });
        if (practiceCount > 0) {
          let h = Math.floor(practiceDuration / 3600) < 10 ? '0' + Math.floor(practiceDuration / 3600) :
            Math.floor(practiceDuration / 3600);
          let m = Math.floor(practiceDuration % 3600 / 60) < 10 ? '0' + Math.floor(practiceDuration % 3600 / 60) :
            Math.floor(practiceDuration % 3600 / 60);
          let s = (practiceDuration % 60) < 10 ? '0' + (practiceDuration % 60) : (practiceDuration % 60);
          record.practiceDuration = h + ':' + m + ':' + s;
          record.practiceCount = practiceCount.toString();
          record.correctRate = (rightCount / topicCount * 100).toFixed(2) + '%';
          record.wrongCount = (topicCount - rightCount).toString();
          record.totalCount = topicCount.toString();
        }
        this.practiceRecordModels.push(record);
      });
    }catch (e) {
    }
  }
}

@Builder
export function OneDayPracticeRecordsBuilder() {
  OneDayPracticeRecordsPage();
}