import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { ExamDetail, ExamManager } from '../model/QuestionAnswerRecord';
import { SelectComponent } from './SelectComponent';
import { CustomContentDialog } from '@kit.ArkUI';
import { ExamController } from '../controller/ExamController';
import { JSON } from '@kit.ArkTS';

// 设置 和 模拟考试时按返回键时打开弹窗
let examController: ExamController = ExamController.instance;

@Entry
@ComponentV2
export struct Exam {
  @Param @Require appPathStack: NavPathStack;
  @Param @Require examManager: ExamManager;
  // 记录模拟考试分数回调, 用于计算模拟考试平均分
  @Param mockExamCall: (score: number) => void = (score: number) => {
  };
  // 退出考试时同步答题数据到全局题库（仅模拟考试需要）
  @Param syncExamData: () => void = () => {
  };
  // 监听monitor中isShowMockExamDialog的变化
  private examController: ExamController = ExamController.instance;
  // 显示剩余时间
  @Local remainTime: number = 0;
  // 是否显示答题卡
  @Local isShowProblemListSheet: boolean = false;
  // 记录当前是第几题
  @Local currentIndex: number = 0;
  // 是否显示未答完题提醒弹窗
  @Local isShowIncompleteSubmitDialog: boolean = false;
  // 模拟考试-暂停考试/继续考试
  @Local isStop: boolean = false;
  // 控制计时器是否运行
  @Local isTimerRunning: boolean = true;
  // 定时器引用
  private timer: number = -1;
  // 仅渲染当前题附近页面，降低超大题库切换开销
  private readonly renderWindowSize: number = 2;
  vm: CommonModel = CommonModel.instance;

  @Monitor('examController.isShowMockExamDialog')
  mockExamDialogChange() {
    if (examController.isShowMockExamDialog) {
      examController.isShowMockExamDialog = false;
      this.isStop = true;
      this.examExitDialog.open();
    }
  }

  aboutToAppear(): void {
    this.currentIndex = this.examManager.currentQuestionId + 1;

    if (this.examManager.timeLimit !== 0) {
      this.remainTime = this.examManager.timeLimit * 60;
      this.timer = setInterval(() => {
        if (this.isTimerRunning && !this.isStop) {
          if (this.remainTime >= 1) {
            this.remainTime--;
          } else {
            this.isTimerRunning = false;
            this.isStop = true;
            this.examSubmitDialog.open();
          }
        }
      }, 1000); // 1秒触发一次
    }
  }

  // 如果想退出考试重新进入后将已做题回显，去掉这个方法
  aboutToDisappear(): void {
    this.syncExamData();
    this.examManager.clearSelectedOption();
  }

  build() {
    Column() {
      // 模拟考试-展示剩余时间
      this.showRemainTime();

      Swiper(examController.swiperController) {
        ForEach(this.examManager.examDetails, (item: ExamDetail, examIndex: number) => {
          Column({ space: 12 }) {
            if (this.shouldRenderQuestion(examIndex)) {
              SelectComponent({
                item: item,
                // 如果想退出考试重新进入后将已做题回显，打开这个参数
                // isReDisplay: item.selected.length !== 0,
                changeCorrectNum: (isAdd: boolean) => {
                  isAdd ? this.examManager.correctNumber++ : this.examManager.correctNumber--;
                },
                changeErrorNum: (isAdd: boolean) => {
                  isAdd ? this.examManager.errorNumber++ : this.examManager.errorNumber--;
                },
              });
            } else {
              Blank()
                .width('100%')
                .height('100%');
            }
          };
        }, (item: ExamDetail, index: number) => {
          try {
            return JSON.stringify(index);
          } catch (err) {
            return '';
          }
        });
      }
      .index(this.examManager.currentQuestionId)
      .height('100%')
      .autoPlay(false)
      .loop(false)
      .indicator(false)
      .onChange((targetIndex: number) => {
        this.examManager.currentQuestionId = targetIndex;
        this.currentIndex = targetIndex + 1;
      })
      .padding({
        top: 12,
        bottom: this.examManager.timeLimit === 0 ? 92 : 92 + 48,
      });

      this.bottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'));
  }

  private shouldRenderQuestion(index: number): boolean {
    const current = this.currentIndex - 1;
    return Math.abs(index - current) <= this.renderWindowSize;
  }

  @Builder
  showRemainTime() {
    Row({ space: 12 }) {
      Image($r('app.media.clock'))
        .width(24)
        .height(24);

      Text('剩余时间')
        .fontSize(12)
        .fontColor('#64BB5C');

      Text(this.convertToTime(this.remainTime))
        .fontSize(16)
        .fontColor('#64BB5C');
    }
    .height(48)
    .visibility(this.examManager.timeLimit === 0 ? Visibility.None : Visibility.Visible);
  }

  // 答题卡-点击显示清除数据弹窗
  clearRecordsController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '温馨提示',
      contentBuilder: () => {
        this.clearRecords();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            this.examManager.clearRecords();
            examController.swiperController.changeIndex(this.examManager.currentQuestionId);
            this.examController.renderView = !this.examController.renderView;
            this.isShowProblemListSheet = !this.isShowProblemListSheet;
          },
        },
      ],
    }),
  });
  examExitDialog: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.examExitBuilder();
    },
    autoCancel: false,
  });
  examIncompleteSubmitDialog: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.examIncompleteSubmitBuilder();
    },
    autoCancel: false,
  });

  @Builder
  examExitBuilder() {
    Column() {
      Text('考试尚未结束')
        .dialogTitleStyle()
        .maxFontScale(1)

      Blank().height(12)

      Text('是否确认立即退出考试?')
        .dialogInfoStyle()
        .maxFontScale(1)

      Blank().height(28)

      Row() {
        Text('继续考试')
          .dialogChooseStyle()
          .fontColor('#64BB5C')
          .maxFontScale(1)
          .onClick(() => {
            this.examExitDialog.close();
            this.isStop = false;
          });
        Column() {
          Column() {
          }
          .height(24)
          .width(1)
          .backgroundColor('rgba(0,0,0,0.05)')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width(8)
        .height('100%')

        Text('确认退出')
          .dialogChooseStyle()
          .fontColor($r('sys.color.font_secondary'))
          .maxFontScale(1)
          .onClick(() => {
            this.examExitDialog.close();
            this.appPathStack.pop();
          });
      }
      .width(296)
      .height(40)

      Blank()
    }
    .width(328)
    .height(164)
  }

  @Builder
  examIncompleteSubmitBuilder() {
    Column() {
      Text('温馨提示')
        .maxFontScale(1)
        .dialogTitleStyle()
        .fontColor($r('sys.color.font_primary'))

      Blank().height(12)

      Text('您还有未答完的题目，是否确认交卷?')
        .dialogInfoStyle()
        .maxFontScale(1)

      Blank().height(28)

      Row() {
        Text('继续答题')
          .dialogChooseStyle()
          .fontColor('#64BB5C')
          .maxFontScale(1)
          .onClick(() => {
            this.examIncompleteSubmitDialog.close();
            this.isStop = false;
          });
        Column() {
          Column() {
          }
          .height(24)
          .width(1)
          .backgroundColor('rgba(0,0,0,0.05)')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width(8)
        .height('100%')

        Text('确认交卷')
          .dialogChooseStyle()
          .fontColor($r('sys.color.font_secondary'))
          .maxFontScale(1)
          .onClick(() => {
            this.examIncompleteSubmitDialog.close();
            this.examSubmitDialog.open();
          });
      }
      .width(296)
      .height(40)

      Blank()
    }
    .width(328)
    .height(164)
  }

  examSubmitDialog: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.submitExamBuilder();
    },
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
    },
  });

  @Builder
  submitExamBuilder() {
    Column() {
      Text(this.calcExamScore() ? '成绩合格' : '成绩不合格')
        .maxFontScale(1)
        .dialogTitleStyle()

      Blank().height(12)

      Text('未答题数: ' + (this.examManager.total - this.examManager.correctNumber - this.examManager.errorNumber) +
        '           ' + '考试成绩: ' + this.examManager.correctNumber + '分')
        .dialogInfoStyle()
        .maxFontScale(1)

      Blank().height(28)

      Row() {
        Text('重新考试')
          .dialogChooseStyle()
          .fontColor('#64BB5C')
          .maxFontScale(1)
          .onClick(() => {
            this.isStop = false;
            this.isTimerRunning = true;
            if (this.timer !== -1) {
              clearInterval(this.timer);
            }
            this.timer = setInterval(() => {
              if (this.isTimerRunning && !this.isStop) {
                if (this.remainTime >= 1) {
                  this.remainTime--;
                } else {
                  this.isTimerRunning = false;
                  this.isStop = true;
                  this.examSubmitDialog.open();
                }
              }
            }, 1000);
            this.examSubmitDialog.close();

            this.examManager.clearRecords();
            this.examController.renderView = !this.examController.renderView;
            examController.swiperController.changeIndex(0);
            this.remainTime = this.examManager.timeLimit * 60;
          });
        Column() {
          Column() {
          }
          .height(24)
          .width(1)
          .backgroundColor('rgba(0,0,0,0.05)')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width(8)
        .height('100%')

        Text('查看详情')
          .dialogChooseStyle()
          .fontColor($r('sys.color.font_secondary'))
          .maxFontScale(1)
          .onClick(() => {
            if (this.timer !== -1) {
              clearInterval(this.timer);
            }
            this.isStop = false;
            this.examSubmitDialog.close();
            this.mockExamCall(this.examManager.correctNumber);
            this.appPathStack.pushPathByName(
              'examResultPage',
              this.examManager,
            );
          });
      }
      .width(296)
      .height(40)

      Blank()
    }
    .width(328)
    .height(164);
  }

  // 模拟考试-计算考试成绩是否合格
  calcExamScore(): boolean {
    return this.examManager.total * 0.9 <= this.examManager.correctNumber;
  }

  /**
   * 底部栏视图（正确与错误数量，答题卡入口，是否收藏）
   */
  @Builder
  bottomBar() {
    Row() {
      Image($r('app.media.correct'))
        .width(16)
        .height(16)
        .margin({
          right: '1%',
        })

      Text(String(this.examManager.correctNumber))
        .maxFontScale(1)

      Image($r('app.media.error'))
        .width(16)
        .height(16)
        .margin({
          left: '3%',
          right: '1%',
        })

      Text(String(this.examManager.errorNumber))
        .maxFontScale(1)
        .margin({
          right: '7%',
        });

      Row() {
        Image($r('app.media.exam_list'))
          .width(16)
          .height(16)
          .margin({
            right: '1%',
          })
          .fillColor($r('sys.color.icon_primary'));
        Text(`${this.currentIndex}/${this.examManager.total}`)
          .maxFontScale(1)
      }
      .onClick(() => {
        this.isShowProblemListSheet = !this.isShowProblemListSheet;
      })
      .bindSheet($$this.isShowProblemListSheet, this.showProblemListSheet(), {
        height: '70%',
        width: this.vm.isLargeDevice ? '61%' : '100%',
        preferType: SheetType.CENTER,
        title: { title: '答题卡' },
        backgroundColor: $r('sys.color.comp_background_primary'),
      });

      Blank();

      Row() {
        Image(this.examManager.examDetails.length > 0 && this.examManager.examDetails[this.currentIndex-1].isCollect ?
          $r('app.media.has_been_marked') :
          $r('app.media.not_marked'))
          .width(24)
          .height(24)
          .margin({
            right: '1%',
          })

        Text('收藏')
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'))
          .maxFontScale(1)
      }
      .onClick(() => {
        const detail = this.examManager.examDetails[this.currentIndex - 1];
        if (detail) {
          detail.isCollect = !detail.isCollect;
        }
      });

      Row() {
        Image($r('app.media.bell'))
          .width(16)
          .height(16)
          .fillColor($r('sys.color.background_primary'));
        Text('交卷')
          .fontColor(Color.White)
          .fontSize(12)
          .maxFontScale(1)
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#64BB5C')
      .borderRadius(8)
      .width(76)
      .height(28)
      .margin({
        left: '3%',
        top: -3,
      })
      .onClick(() => {
        this.isStop = true;
        const answeredCount = this.examManager.correctNumber + this.examManager.errorNumber;
        if (answeredCount < this.examManager.total) {
          this.examIncompleteSubmitDialog.open();
        } else {
          this.examSubmitDialog.open();
        }
      })
      .visibility(this.examManager.timeLimit === 0 ? Visibility.None : Visibility.Visible);
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height(76)
    .alignItems(VerticalAlign.Top)
    .padding({
      top: 16,
      left: '4%',
      right: '4%',
    })
    .position({
      bottom: 0,
    });
  }

  /**
   * 答题卡视图
   */
  @Builder
  showProblemListSheet() {
    Column() {
      Grid() {
        ForEach(this.examManager.examDetails, (item: ExamDetail, index: number) => {
          GridItem() {
            Stack() {
              Row() {
              }
              .width('100%')
              .width(40)
              .height(40)
              .borderRadius(20)
              .backgroundColor(this.getBgColorByIsCorrect(item.isCorrect));

              Text(String(index + 1))
                .fontColor(item.isCorrect === undefined ? $r('sys.color.font_primary') : Color.White);
            };
          }
          .onClick(() => {
            try {
              this.currentIndex = index + 1;
              this.examManager.currentQuestionId = index;
              examController.swiperController.changeIndex(index);
              this.isShowProblemListSheet = !this.isShowProblemListSheet;
            } catch (err) {
            }
          });
        }, (item: ExamDetail) => {
          try {
            return JSON.stringify(item.isCorrect);
          } catch (err) {
            return '';
          }
        });
      }
      .rowsGap(16)
      .columnsTemplate('repeat(auto-stretch, 69)')
      .height('75%')
      .scrollBar(BarState.Off)

      Blank('15%')

      Button('清空记录')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#64BB5C')
        .height(40)
        .width('78%')
        .margin({
          top: 40,
          bottom: 30,
        })
        .onClick(() => {
          this.clearRecordsController.open();
        });
    }
    .padding({
      left: '2%',
      right: '2%',
    })
    .height('100%')
    .width('100%');
  }

  /**
   * 答题卡-显示对、错和未答题的背景色
   * @param isCorrect
   * @returns
   */
  getBgColorByIsCorrect(isCorrect: boolean | undefined): ResourceColor {
    if (isCorrect === undefined) {
      return $r('sys.color.comp_background_tertiary');
    }
    return isCorrect ? '#64BB5C' : ' #E84026';
  }

  /**
   * 清除记录弹窗视图
   */
  @Builder
  clearRecords() {
    Row() {
      Text('确定要清空当前操作记录吗')
        .fontColor($r('sys.color.font_primary'));
    }
    .justifyContent(FlexAlign.Center)
    .width('100%');
  }

  /**
   * 时间转换-将剩余秒数转换为 mm:ss
   * @param time
   * @returns
   */
  convertToTime(time: number): string {
    let minute: number = Math.floor(time / 60);
    let second: number = time % 60;
    return (minute < 10 ? '0' + minute : minute + '') + ':' + (second < 10 ? '0' + second : second) + '';
  }
}

@Extend(Text)
function dialogTitleStyle() {
  .fontSize(20)
  .fontColor('#E84026')
  .fontWeight(FontWeight.Bold)
  .width('100%')
  .textAlign(TextAlign.Center)
  .width(280)
  .height(56)
}

@Extend(Text)
function dialogInfoStyle() {
  .fontSize(16)
  .fontWeight(FontWeight.Regular)
  .width('100%')
  .textAlign(TextAlign.Center)
  .height(21)
}

@Extend(Text)
function dialogChooseStyle() {
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .width(144)
  .height('100%')
  .textAlign(TextAlign.Center)
}

@Builder
export function showSettingSheet() {
  Column({ space: 20 }) {
    Row() {
      Text('答对自动下一题')
        .fontSize(16)
        .maxFontScale(1)
        .fontColor($r('sys.color.font_primary'));
      Blank();
      Toggle({ type: ToggleType.Switch, isOn: examController.showNext })
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .onChange((isOn: boolean) => {
          if (isOn) {
            examController.showNext = true;
            return;
          }
          examController.showNext = false;
        });
    }
    .width('100%')
    .padding({
      top: 5,
    });

    Row() {
      Text('字体大小')
        .fontSize(10)
        .maxFontScale(1)
        .fontColor($r('sys.color.font_primary'));
      Blank();
      Row() {
        Slider({
          value: examController.fontSize,
          min: 14, //滑动最小值
          max: 22, //滑动最大值
          step: 2, //步长
          style: SliderStyle.OutSet,
        })
          .stepColor($r('sys.color.font_secondary'))
          .trackColor($r('sys.color.comp_background_secondary'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .showSteps(true)
          .blockStyle({ type: SliderBlockType.IMAGE, image: $r('app.media.font_setting') })
          .blockSize({ width: 16, height: 16 })
          .onChange((value: number, mode: SliderChangeMode) => {
            examController.fontSize = value;
          });
      }
      .width('70%');

      Blank();

      Text('字体大小')
        .fontSize(16)
        .maxFontScale(1)
        .fontColor($r('sys.color.font_primary'));
    }
    .width('100%');
  }
  .height('100%')
  .padding({
    left: 20,
    right: 20
  })
  .backgroundColor($r('sys.color.comp_background_primary'))
}
