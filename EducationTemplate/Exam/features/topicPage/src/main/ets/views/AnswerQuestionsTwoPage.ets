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

import { AlertDialog, AppStorageV2 } from '@kit.ArkUI';
import { TestReportModel } from './TestReportPage';
import { Logger, RouterMap, RouterModule, BreakpointModel } from 'commonlib';
import { AnswerItem, AnswerSheetDialog, QUESTION_DATA, TopicItemModel } from 'answer_questions';

@ComponentV2
export struct AnswerQuestionsTwoPage {
  offsetX: number = 0;
  positionX: number = 0;
  panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });
  ques: TopicItemModel[] = [];
  textTimerController: TextTimerController = new TextTimerController();
  timerCount: number = 30 * 60 * 1000;
  practiceDuration: number = 0;
  @Local currentIndex: number = 0;
  @Local currentModel?: TopicItemModel;
  @Local format: string = 'HH:mm:ss';
  @Local isShowAnswerSheet: boolean = false;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 退出页面弹框
  backPageDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '温馨提示',
      content: '您还有题目没有作答是否直接交卷结束考试！',
      secondaryButton: {
        value: '继续考试',
        action: () => {
        }
      },
      primaryButton: {
        value: '结束考试',
        fontColor: $r('sys.color.font_tertiary'),
        action: () => {
          RouterModule.pop();
        },
      },
    }),
  });
  // 交卷弹框
  submitExamDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '交卷',
      content: '请确认是否完成答卷要提交试卷？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          // 跳转测评结果页面
          let testReport: TestReportModel = new TestReportModel();
          testReport.ques = this.ques;
          testReport.quesType = 2;
          testReport.practiceDuration = this.practiceDuration;
          RouterModule.replace({ url: RouterMap.EXAM_RESULT_PAGE, param: testReport });
        }
      },
    }),
  });

  aboutToAppear(): void {
    this.currentIndex = 0;
    this.initCurrentModel();
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      // 倒计时
      this.countdownBuilder();
      // 作答面板
      this.answerPanelBuilder();
      // 底部操作
      this.bottomOperationBuilder();
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 作答面板
   */
  @Builder
  answerPanelBuilder() {
    Scroll() {
      Column() {
        // 题目
        this.questionBuilder();
        Blank();
      }
      .gesture( // 左右滑动触发该手势事件
        PanGesture(this.panOption)
          .onActionUpdate((event: GestureEvent) => {
            if (event) {
              this.offsetX = this.positionX + event.offsetX;
            }
          })
          .onActionStart(() => {
          })
          .onActionEnd(() => {
            this.onActionEnd();
          })
      )
      .width('100%')
      .height('100%');
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1);
  }

  /**
   * 底部操作
   */
  @Builder
  bottomOperationBuilder() {
    Row() {
      // 答题卡
      this.answerSheetBuilder();
      Blank()
        .layoutWeight(1);
      Row({ space: 12 }) {
        // 上一题
        this.preQuestionBuilder();
        // 下一题/交卷
        this.nextQuestionBuilder();
      }
      .justifyContent(FlexAlign.End)
      .margin({ right: $r('app.float.vp_16') });
    }
    .width('100%')
    .height($r('app.float.vp_48'))
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetY: -10
    });
  }

  /**
   * 下一题/交卷
   */
  @Builder
  nextQuestionBuilder() {
    Button(this.currentIndex === this.ques.length - 1 ? $r('app.string.submit_exam') :
      $r('app.string.next_question'),
      { type: ButtonType.Normal, stateEffect: true })
      .backgroundColor($r('app.color.view_report_btn'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_on_primary'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .width(this.breakpointModel.currentBreakpoint === 'sm' ? 112 : 240)
      .height($r('app.float.vp_40'))
      .onClick(() => {
        if (this.currentIndex >= this.ques.length - 1) {
          // 打开交卷弹框
          this.submitExamDialogController.open();
        } else {
          this.currentIndex += 1;
          this.currentIndex = Math.min(this.currentIndex, this.ques.length - 1);
          this.currentModel = this.ques[this.currentIndex];
        }
      });
  }

  /**
   * 上一题
   */
  @Builder
  preQuestionBuilder() {
    Button($r('app.string.pre_question'), { type: ButtonType.Normal, stateEffect: true })
      .backgroundColor(this.currentIndex === 0 ? $r('sys.color.comp_background_tertiary') :
        $r('app.color.view_report_btn'))
      .stateEffect(this.currentIndex === 0 ? false : true)
      .fontColor(this.currentIndex === 0 ? $r('app.color.view_report_btn') : $r('sys.color.font_on_primary'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .height($r('app.float.vp_40'))
      .width(this.breakpointModel.currentBreakpoint === 'sm' ? 112 : 240)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .onClick(() => {
        if (this.currentIndex === 0) {
        } else {
          this.currentIndex -= 1;
          this.currentIndex = Math.max(this.currentIndex, 0);
          this.currentModel = this.ques[this.currentIndex];
        }
      });
  }

  /**
   * 答题卡
   */
  @Builder
  answerSheetBuilder() {
    Column() {
      Image($r('app.media.icon_answer_sheet'))
        .width($r('app.float.vp_26'))
        .height($r('app.float.vp_26'));
      Text($r('app.string.answer_sheet'))
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.icon_primary'))
        .margin({ top: $r('app.float.vp_2') });
    }
    .width($r('app.float.vp_38'))
    .height($r('app.float.vp_48'))
    .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .bindSheet($$this.isShowAnswerSheet, this.answerSheet(), {
      height: 560,
      backgroundColor: $r('sys.color.background_secondary'),
      showClose: false,
    })
    .onClick(() => {
      this.isShowAnswerSheet = true;
    });
  }

  /**
   * 题目
   */
  @Builder
  questionBuilder() {
    Column() {
      // 题目类型
      this.questionTypeBuilder();

      Text(`${this.currentIndex + 1}` + '、' + this.currentModel!.title)
        .width('100%')
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: $r('app.float.vp_15') });
      Column() {
        ForEach(this.currentModel!.ques, (item: AnswerItem) => {
          Row() {
            Image(item.isSelect ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
              .height($r('app.float.vp_20'))
              .width($r('app.float.vp_20'));

            Text(`${item.ans}` + '：' + `${item.ansTitle}`)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: $r('app.float.vp_14') });
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Top)
          .margin({ top: $r('app.float.vp_16') })
          .padding({ right: $r('app.float.vp_12') })
          .onClick(() => {
            this.answerEvent(item);
          });
        }, (item: AnswerItem, index: number) => item.ansID + index);
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%');
    }
    .width('92%');
  }

  /**
   * 题目类型
   */
  @Builder
  questionTypeBuilder() {
    Row() {
      Text($r('app.string.single_choice'))
        .width($r('app.float.vp_72'))
        .height($r('app.float.vp_28'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_on_primary'))
        .textAlign(TextAlign.Center)
        .backgroundColor('#4B5CC4')
        .borderRadius($r('app.float.vp_8'));
    }
    .width('100%')
    .margin($r('app.float.vp_12'));

  }

  /**
   * 倒计时
   */
  @Builder
  countdownBuilder() {
    Row() {
      Image($r('app.media.ic_public_alarm_clock'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'));
      Text($r('app.string.time_remaining'))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.multi_color_09'))
        .margin({ left: $r('app.float.vp_12') });
      TextTimer({ isCountDown: true, count: this.timerCount, controller: this.textTimerController })
        .format(this.format)
        .fontColor($r('sys.color.multi_color_09'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: $r('app.float.vp_4') })
        .onTimer((_utc: number, elapsedTime: number) => {
          this.practiceDuration = elapsedTime;
        })
        .onAppear(() => {
          this.textTimerController.start();
        });
    }
    .height($r('app.float.vp_48'));

    Divider().color($r('sys.color.comp_divider'));
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      Row() {
        Row() {
          // 返回图标
          Image($r('app.media.ic_back'))
            .height($r('app.float.vp_40'))
            .width($r('app.float.vp_40'))
            .borderRadius($r('app.float.vp_20'))
            .onClick(() => {
              // back
              this.backPageDialogController.open();
            });
        }
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .borderRadius($r('app.float.vp_40'));

        Text($r('app.string.answer_questions'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: $r('app.float.vp_8') });
      };
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .height($r('app.float.vp_56'))
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);

    Divider().color($r('sys.color.comp_divider'));
  }

  @Builder
  answerSheet() {
    AnswerSheetDialog({
      practiceDuration: this.practiceDuration,
      textTimerController: this.textTimerController,
      quesType: 2,
      ques: this.ques,
      selectIndex: (index) => {
        this.onSelectIndex(index);
        this.isShowAnswerSheet = false;
      },
      viewReport: () => {
        // 关闭答题卡弹框
        this.isShowAnswerSheet = false;
        this.viewReport();
      },
      close: () => {
        this.isShowAnswerSheet = false;
      }
    });
  }

  onActionEnd() {
    if (this.offsetX > this.positionX) {
      Logger.info('右滑');
      this.currentIndex -= 1;
      this.currentIndex = Math.max(this.currentIndex, 0);
    } else {
      Logger.info('左滑');
      this.currentIndex += 1;
      this.currentIndex = Math.min(this.currentIndex, this.ques.length - 1);
    }
    this.currentModel = this.ques[this.currentIndex];
    this.positionX = this.offsetX;
  }

  /**
   * 数据初始化
   */
  initCurrentModel() {
    for (let index = 0; index < QUESTION_DATA.length; index++) {
      let obj = QUESTION_DATA[index];
      let topicItem: TopicItemModel = new TopicItemModel('001', '1', '行业模板规范可以可以从以下哪个渠道获取？',
        [new AnswerItem('对', '', 'A', false, 0), new AnswerItem('错', '', 'B', false, 0),
          new AnswerItem('以上都对', '', 'C', false, 0), new AnswerItem('以上都错', '', 'D', false, 0)],
        ['A'], [], false, '', '');
      topicItem.title = obj.title;
      topicItem.type = obj.type;
      topicItem.rightQues = obj.rightQues;
      topicItem.isAnswer = obj.isAnswer;
      topicItem.keyID = obj.keyID;
      topicItem.parse = obj.parse;
      let ans: AnswerItem[] = [];
      for (let index = 0; index < obj.ques.length; index++) {
        let objItem = obj.ques[index];
        let it: AnswerItem = new AnswerItem('', '', 'B', false, 0);
        it.ansTitle = objItem.ansTitle;
        it.ans = objItem.ans;
        it.ansID = objItem.ansID;
        it.isSelect = objItem.isSelect;
        it.showState = objItem.state;
        ans.push(it);
      }
      topicItem.ques = ans;
      this.ques.push(topicItem);
    }
    this.currentModel = this.ques[0];
  }

  /**
   * 答题逻辑处理
   */
  answerEvent(item: AnswerItem) {
    // 单选类型
    this.currentModel!.isAnswer = true;
    this.currentModel?.selectQues.splice(0);
    this.currentModel?.selectQues.push(item.ans);
    for (let index = 0; index < this.currentModel!.ques.length; index++) {
      let element = this.currentModel!.ques[index];
      if (element.ans === item.ans) {
        element.isSelect = true;
      } else {
        element.isSelect = false;
      }
    }
  }

  onSelectIndex(index: number) {
    this.currentIndex = index;
    this.currentModel = this.ques[this.currentIndex];
  }

  viewReport() {
    // 打开交卷弹框
    this.submitExamDialogController.open();
  }
}

@Builder
export function AnswerQuestionsTwoBuilder() {
  AnswerQuestionsTwoPage();
}
