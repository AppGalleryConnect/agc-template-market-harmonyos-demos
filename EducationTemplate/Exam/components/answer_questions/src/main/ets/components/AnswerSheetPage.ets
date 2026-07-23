/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { window } from '@kit.ArkUI';
import { TopicItemModel } from '../viewModel/TopicItemModel';

@ComponentV2
export struct AnswerSheetPage {
  bottomHeight: number = 0;
  @Param close: () => void = () => {
  };
  @Param viewReport: () => void = () => {
  };
  @Param ques: TopicItemModel[] = [];
  @Param selectIndex: (index: number) => void = () => {
  };
  // 1练习模式 2答题模式
  @Param quesType: number = 1;
  // 练习时长
  @Param practiceDuration: number = 0;

  aboutToAppear(): void {
    try {
      // 获取导航条高度，手动进行避让
      window.getLastWindow(this.getUIContext()?.getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      });
    } catch (e) {
    }
  }

  build() {
    Column() {
      Column() {
        // 答题卡手势处理
        this.gestureHandleBuilder();
        // 答题卡标题
        this.titleBuilder();
        // 答题卡次标题
        this.subtitleBuilder();
        // 题目列表
        this.topicListBuilder();
      }
      .padding(20)
      .width('92%');
      Blank()
        .layoutWeight(1)
      // 查看报告
      this.viewReportBuilder();
    }
    .backgroundColor($r('app.color.answer_sheet_bg'))
    .borderRadius({
      topLeft: $r('sys.float.corner_radius_level16'),
      topRight: $r('sys.float.corner_radius_level16')
    })
    .width('100%')
    .height('100%');
  }

  // 答题卡手势处理
  @Builder
  gestureHandleBuilder() {
    Row() {
      Row()
        .width($r('app.float.vp_56'))
        .height($r('app.float.vp_5'))
        .backgroundColor($r('app.color.gesture_handle'))
        .borderRadius(3)
        .margin({ top: $r('app.float.vp_8') });
    }
    .justifyContent(FlexAlign.Center);
  }

  // 答题卡标题
  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.answer_sheet'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center);
      Image($r('app.media.close_btn'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(this.close)
        .id('close_button');
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .justifyContent(FlexAlign.SpaceBetween);
  }

  // 答题卡次标题
  @Builder
  subtitleBuilder() {
    Row() {
      Text($r('app.string.single_choice_topic'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'));
    }
    .width('100%')
    .margin({ top: $r('app.float.vp_5'), bottom: $r('app.float.vp_15') });
  }

  // 题目列表
  @Builder
  topicListBuilder() {
    Grid() {
      if (this.quesType === 1) {
        ForEach(this.ques, (item: TopicItemModel, index: number) => {
          GridItem() {
            Row() {
              Text(`${index + 1}`)
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Medium)
                .fontColor(item.showState === 0 ? $r('sys.color.font_primary') : $r('sys.color.font_on_primary'));
            }
            .width($r('app.float.vp_45'))
            .height($r('app.float.vp_45'))
            .backgroundColor(item.showState === 1 ? $r('sys.color.multi_color_08') :
              (item.showState === 2 ? $r('sys.color.multi_color_04') : $r('sys.color.comp_background_tertiary')))
            .borderRadius(40)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectIndex(index);
            });
          };
        }, (item: TopicItemModel, index: number) => item.keyID + index);
      } else if (this.quesType === 2) {
        ForEach(this.ques, (item: TopicItemModel, index: number) => {
          GridItem() {
            Row() {
              Text(`${index + 1}`)
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Medium)
                .fontColor(item.showState === 0 ? $r('sys.color.font_primary') : $r('sys.color.font_on_primary'));
            }
            .width($r('app.float.vp_45'))
            .height($r('app.float.vp_45'))
            .backgroundColor(item.isAnswer ? $r('app.color.view_report_btn') :
              $r('sys.color.comp_background_tertiary'))
            .borderRadius(40)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectIndex(index);
            });
          };
        }, (item: TopicItemModel, index: number) => item.keyID + index);

      }
    }
    .columnsTemplate('repeat(auto-stretch, 45)')
    .rowsGap($r('app.float.vp_16'))
    .columnsGap($r('app.float.vp_24'))
    .scrollBar(BarState.Off)
    .height(200);
  }

  // 查看报告
  @Builder
  viewReportBuilder() {
    Row() {
      Button(this.quesType === 1 ? '查看报告' : '交卷', { type: ButtonType.Capsule, stateEffect: true })
        .backgroundColor($r('app.color.view_report_btn'))
        .width('80%')
        .onClick(() => {
          this.viewReport();
        });
    }
    .width('100%')
    .height($r('app.float.vp_70'))
    .margin({ bottom: 16 })
    .justifyContent(FlexAlign.Center);
  }
}
