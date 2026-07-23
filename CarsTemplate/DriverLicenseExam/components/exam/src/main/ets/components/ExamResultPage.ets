import { ExamController } from '../controller/ExamController';
import { ExamManager, ExamDetail, QuestionTypeEnum } from '../model/QuestionAnswerRecord';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib'

@Builder
export function ExamResultPageBuilder() {
  ExamResultPage();
}

@ComponentV2
export struct ExamResultPage {
  private examController: ExamController = ExamController.instance;
  vm: CommonModel = CommonModel.instance;
  @Local examManager: ExamManager | null = null;
  @Local currentIndex: number = 0;
  @Local selectedTab: number = 0; // 0: 单选, 1: 多选, 2: 判断
  @Local duration: number = 0; // 答题时长（分钟）
  @Local radioQuestions: Array<ExamDetail> = []; // 单选题
  @Local checkBoxQuestions: Array<ExamDetail> = []; // 多选题
  @Local judgeQuestions: Array<ExamDetail> = []; // 判断题
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  onReady(ctx: NavDestinationContext) {
    const param: ExamManager | undefined = ctx.pathInfo.param as ExamManager;
    if (param) {
      this.examManager = param;
      this.duration = 0;
      // 根据题目类型对题目进行分类
      this.examManager.examDetails.forEach((question) => {
        if (question.questionType === QuestionTypeEnum.RADIO) {
          this.radioQuestions.push(question);
        } else if (question.questionType === QuestionTypeEnum.CHECK_BOX) {
          this.checkBoxQuestions.push(question);
        } else if (question.questionType === QuestionTypeEnum.JUDGE) {
          this.judgeQuestions.push(question);
        }
      });
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.buildQuestionList();
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(false)
    .title('查看详情')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx: NavDestinationContext) => {
      this.onReady(ctx);
    })
    .onBackPressed(() => {
      this.vm.navStack.popToName('MainEntry', true);
      return true;
    })
  }

  @Builder
  buildTabBar() {
    Row() {
      this.buildTabItem('单选', 0);
      this.buildTabItem('多选', 1);
      this.buildTabItem('判断', 2);
    }
    .width('100%')
    .height(44)
    .padding(8)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      offsetX: 0,
      offsetY: 2,
      color: '#1A000000',
      fill: false,
    })
  }

  @Builder
  buildTabItem(text: string, index: number) {
    Text(text)
      .fontColor(this.selectedTab === index ? '#007DFF' : '#666666')
      .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Medium)
      .fontSize(15)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .height(32)
      .borderRadius(8)
      .backgroundColor(this.selectedTab === index ? 'rgba(0, 125, 255, 0.1)' : 'transparent')
      .onClick(() => {
        this.selectedTab = index;
      });
  }

  @Builder
  buildQuestionList() {
    List() {
      if (this.examManager) {
        ForEach(this.examManager.examDetails, (item: ExamDetail, index: number) => {
          ListItem() {
            this.buildQuestionCard(item, index);
          }
        }, (item: ExamDetail) => item.id.toString());
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  getCurrentQuestions(): Array<ExamDetail> {
    if (this.selectedTab === 0) {
      return this.radioQuestions;
    } else if (this.selectedTab === 1) {
      return this.checkBoxQuestions;
    } else {
      return this.judgeQuestions;
    }
  }

  @Builder
  buildQuestionCard(question: ExamDetail, index: number) {
    Column() {
      // 题目区域
      Row() {
        Text(`${index + 1}、${question.question}`)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .margin({ bottom: 12 });

      // 选项区域
      Column() {
        if (question.options) {
          this.option(question);
        }
      }
      .width('100%')
      .margin({ bottom: 12 });

      // 答案反馈区域
      Row() {
        Text(`答案：${this.getCorrectAnswer(question)}`)
          .fontSize(14)
          .fontColor('#52C41A')
          .margin({ right: 24 });
      }
      .width('100%')
      .padding({
        left: 12,
        right: 12,
        top: 6,
        bottom: 6
      })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(8)
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 12 });

      this.problemAnalysis(question);
    }
    .width('100%')
    .margin({ bottom: 12 });
  }

  @Builder
  problemAnalysis(item: ExamDetail) {
    Column({ space: 12 }) {
      this.analysisTitle('题目解析');
      Text(item.analysis)
        .fontSize(this.examController.getFg(this.examController.fontSize))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(this.examController.getFg(this.examController.fontSize + 4));
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding({
      top: 12,
      bottom: 12,
      left: '3%',
      right: '2%',
    });
  }

  @Builder
  analysisTitle(titleName: string) {
    Row() {
      Image($r('app.media.line'))
        .width(2)
        .height(12);

      Text(titleName)
        .fontSize(this.examController.getFg(this.examController.fontSize - 2))
        .fontColor($r('sys.color.font_primary'))
        .padding({
          left: '2%',
        });
    };
  }

  @Builder
  option(question: ExamDetail) {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      justifyContent: FlexAlign.Start
    }) {
      if (question.questionType === QuestionTypeEnum.CHECK_BOX) {
        ForEach(question.options, (option: string, optionIndex: number) => {
          Row({ space: 12 }) {
            Image(
              this.getCheckBoxClickImage(option, question.selected, question.answer))
              .width(this.examController.getFg(this.examController.fontSize + 6))
              .height(this.examController.getFg(this.examController.fontSize + 6))
              .objectFit(ImageFit.Contain);

            Text(String.fromCharCode(optionIndex + 65) + ': ')
              .fontSize(this.examController.getFg(this.examController.fontSize))
              .fontColor($r('sys.color.font_primary'));
            Text(option)
              .fontSize(this.examController.getFg(this.examController.fontSize))
              .fontColor($r('sys.color.font_primary'))
              .maxLines(10);
          }
          .width(this.vm.isLargeDevice ? 'auto' : '100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .padding({ right: 12 })
        }, (option: string) => option)

      } else {
        ForEach(question.options, (option: string, optionIndex: number) => {
          Row({ space: 12 }) {
            Image(
              this.getRadioImage(option, question.answer[0], question.selected[0] ? question.selected[0] : ''))
              .width(this.examController.getFg(this.examController.fontSize + 6))
              .height(this.examController.getFg(this.examController.fontSize + 6))
              .objectFit(ImageFit.Contain);
            Text(String.fromCharCode(optionIndex + 65) + ': ')
              .fontSize(this.examController.getFg(this.examController.fontSize))
              .fontColor($r('sys.color.font_primary'));
            Text(option)
              .fontSize(this.examController.getFg(this.examController.fontSize))
              .fontColor($r('sys.color.font_primary'))
              .maxLines(10);
          }
          .width(this.vm.isLargeDevice ? 'auto' : '100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .padding({ right: 12 })
        }, (option: string) => option);
      }
    }
    .width('100%')
  }

  /**
   * 获取单选题的图片
   * @param option
   * @param answer
   * @returns
   */
  getRadioImage(option: string, answer: string, select: string): ResourceStr {
    if (option === select && option !== answer) {
      return $r('app.media.error');
    }
    if (option !== select && option !== answer) {
      return $r('app.media.no_select');
    }
    return $r('app.media.correct');
  }

  /**
   * 多选-点击提交答案按钮时的图标展示
   * @param option 当前选项
   * @param selected 已选择
   * @param answer 答案
   * @returns 对应图标
   */
  getCheckBoxClickImage(option: string, selected: Array<string>, answer: Array<string>): ResourceStr {
    if (selected.includes(option) && answer.includes(option)) {
      return $r('app.media.correct');
    }
    if (selected.includes(option) && !answer.includes(option)) {
      return $r('app.media.error');
    }
    if (!selected.includes(option) && answer.includes(option)) {
      return $r('app.media.checkbox_select');
    }
    return $r('app.media.no_select');
  }

  /**
   * 将选项索引转换为字母
   * @param question 题目对象
   * @param isUserAnswer 是否为用户答案，默认为false（处理正确答案）
   * @returns ABCD格式的答案字符串
   */
  convertIndexToLetter(question: ExamDetail, isUserAnswer: boolean = false): string {
    const answerArray = isUserAnswer ? question.selected : question.answer;
    if (!answerArray?.length || !question.options) {
      return '-';
    }
    return answerArray
      .map(ans => {
        const index = question.options?.indexOf(ans);
        return index !== undefined && index >= 0 ? String.fromCharCode(index + 65) : '';
      })
      .filter(char => char !== '')
      .join('') || '-';
  }

  getCorrectAnswer(question: ExamDetail): string {
    return this.convertIndexToLetter(question);
  }

  getUserAnswer(question: ExamDetail): string {
    return this.convertIndexToLetter(question, true);
  }
}