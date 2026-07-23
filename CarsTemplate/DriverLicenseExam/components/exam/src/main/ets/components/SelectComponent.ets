import { ExamController } from '../controller/ExamController';
import { ExamDetail, QuestionTypeEnum } from '../model/QuestionAnswerRecord';
import { JSON } from '@kit.ArkTS';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';


@ComponentV2
export struct SelectComponent {
  private examController: ExamController = ExamController.instance;
  private vm: CommonModel = CommonModel.instance;
  // 是否显示答案/解析/视频讲解等
  @Local showAnswer: boolean = false;
  // 答案索引
  @Local ansIndexList: Array<number> = [];
  // 已选择的选项索引
  @Local selectIndexList: Array<number> = [];
  @Param @Require item: ExamDetail;
  @Param @Require changeCorrectNum: (isAdd: boolean) => void;
  @Param @Require changeErrorNum: (isAdd: boolean) => void;
  @Local checkBoxImage: boolean = false;

  @Monitor('examController.renderView')
  renderViewChange(){
    // 不显示答案，解析等
    if (this.showAnswer) {
      this.showAnswer = false;
    }
    this.ansIndexList = [];
    this.selectIndexList = [];
  }

  // 如果想退出考试重新进入后将已做题回显，打开这个方法
  // aboutToAppear(): void {
  //   // 已经答过的题数据回显
  //   if (this.isReDisplay) {
  //     for (let i = 0; i < this.item.options.length; i++) {
  //       if (this.item.selected.includes(this.item.options[i])) {
  //         this.selectIndexList.push(i)
  //       }
  //       if (this.item.answer.includes(this.item.options[i])) {
  //         this.ansIndexList.push(i);
  //       }
  //     }
  //   }
  // }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        // 问题类型
        this.questionType();
        // 问题
        this.question();
        // 选项
        this.option()

        if (this.showAnswer) {
          Column({ space: 12 }) {
            this.answer();
            this.problemAnalysis();
            this.videoAnalysis();
          };
        }
      }
      .padding({
        left: '4%',
        right: '4%',
      })
    }
    .scrollBar(BarState.Off);
  }

  @Builder
  questionType(){
    Row() {
      Text(getQuestionType(this.item.questionType))
        .fontSize(this.examController.getFg(this.examController.fontSize - 2))
        .fontColor(Color.White);
    }
    .width(this.examController.getFg(this.examController.fontSize + 62))
    .height(this.examController.getFg(this.examController.fontSize + 14))
    .justifyContent(FlexAlign.Center)
    .borderRadius(8)
    .backgroundColor($r('app.color.bt_bg_color'))
    .alignSelf(ItemAlign.Start);
  }

  @Builder
  question(){
    Text(this.item.question)
      .fontSize(this.examController.getFg(this.examController.fontSize))
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .lineHeight(this.examController.getFg(this.examController.fontSize + 6))
      .alignSelf(ItemAlign.Start)
      .padding({
        bottom: 15,
      });

    if (this.item.questionImage !== '') {
      Image($r(this.item.questionImage))
        .width('90%')
        .height(150);
    }
  }

  @Builder
  option(){
    if (this.item.questionType === QuestionTypeEnum.CHECK_BOX) {
      ForEach(this.item.options, (option: string, optionIndex: number) => {
        Row({ space: 12 }) {
          Image(this.checkBoxImage ?
            this.showAnswer ? getCheckBoxClickImage(option, this.item.selected, this.item.answer) :
            getCheckBoxUnClickImage(option, this.item.selected) :
          getCheckBoxUnClickImage(option, this.item.selected))
            .width(this.examController.getFg(this.examController.fontSize + 6))
            .height(this.examController.getFg(this.examController.fontSize + 6));

          Text(String.fromCharCode(optionIndex + 65) + ': ')
            .fontSize(this.examController.getFg(this.examController.fontSize))
            .fontColor($r('sys.color.font_primary'));
          Text(option)
            .fontSize(this.examController.getFg(this.examController.fontSize))
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .maxLines(10);
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.Start)
        .onClick(() => {
          if (this.showAnswer) {
            return;
          }
          this.checkBoxImage = !this.checkBoxImage;

          let index = this.selectIndexList.indexOf(optionIndex);
          if (index === -1) {
            this.selectIndexList.push(optionIndex);
            this.item.selected.push(option);
          } else {
            this.selectIndexList.splice(index, 1);
            this.item.selected.splice(this.item.selected.indexOf(option), 1);
          }
        })
      }, (option: string) => option)

      Button('提交答案')
        .backgroundColor(this.item.selected.length > 1 ? ' #64BB5C ' : $r('app.color.default_submit_answer'))
        .height(40)
        .width('86%')
        .margin({
          top: 14,
        })
        .onClick(() => {
          if (this.item.selected.length > 1) {
            this.checkBoxImage = true;
            this.showAnswer = true;

            for (let item of this.item.options) {
              let index = this.item.answer.indexOf(item);
              if (index !== -1) {
                this.ansIndexList.push(index);
              }
            }
            this.verifyIsCorrect();
          }
        })
        .visibility(this.showAnswer ? Visibility.None : Visibility.Visible);

    } else {
      ForEach(this.item.options, (option: string, optionIndex: number) => {
        ListItem() {
          Row({ space: 12 }) {
            Image(this.showAnswer ?
            this.getRadioImage(option, this.item.answer[0]) :
            $r('app.media.no_select'))
              .width(this.examController.getFg(this.examController.fontSize + 6))
              .height(this.examController.getFg(this.examController.fontSize + 6));
          Text(String.fromCharCode(optionIndex + 65) + ': ')
            .fontSize(this.examController.getFg(this.examController.fontSize))
            .fontColor($r('sys.color.font_primary'));
          Text(option)
            .fontSize(this.examController.getFg(this.examController.fontSize))
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .maxLines(10);
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Start)
          .onClick(() => {
            this.showAnswer = true;
            if (this.item.selected.length !== 0) {
              return;
            }
            this.selectIndexList[0] = optionIndex;
            this.item.selected.push(option);

            for (let i = 0; i < this.item.options.length; i++) {
              if (this.item.answer.includes(this.item.options[i])) {
                this.ansIndexList.push(i);
              }
            }
            this.verifyIsCorrect();
          });
        };
      }, (option: string) => option);
    }
  }

  @Builder
  answer() {
    Column() {
      Text() {
        Span('答案: ')
          .fontColor($r('sys.color.font_primary'));
        Span(this.ansIndexList.sort().map(i => String.fromCharCode(i + 65)).join(''))
          .fontColor('#64BB5C')
          .fontWeight(FontWeight.Bold);

        if (this.item.isCorrect === false) {
          Span('    您的选择: ')
            .fontColor($r('sys.color.font_primary'));
          Span(this.selectIndexList.sort().map(i => String.fromCharCode(i + 65)).join(''))
            .fontColor('#E84026')
            .fontWeight(FontWeight.Bold);
        }
      }
      .fontSize(this.examController.getFg(this.examController.fontSize - 2))
      .lineHeight(this.examController.getFg(this.examController.fontSize + 6))
      .width('100%');
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .padding({
      left: 12,
      right: 12,
      top: 6,
      bottom: 6,
    });
  }

  @Builder
  problemAnalysis() {
    Column({ space: 12 }) {
      this.analysisTitle('题目解析');
      Text(this.item.analysis)
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
  videoAnalysis() {
    Column({ space: 12 }) {
      this.analysisTitle('视频讲题');

      Video({
        src: this.item.videoExplainUrl,
      })
        .width('100%')
        .height(this.vm.isLargeDevice ? 313 : 160)
        .borderRadius(8);
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 12,
      bottom: 12,
      left: '3%',
      right: '3%',
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

  /**
   * 获取单选题的图片
   * @param option
   * @param answer
   * @returns
   */
  getRadioImage(option: string, answer: string): ResourceStr {
    let select: string = this.item.selected[0] ? this.item.selected[0] : '';
    if (option === select && option !== answer) {
      return $r('app.media.error');
    }
    if (option !== select && option !== answer) {
      return $r('app.media.no_select');
    }
    return $r('app.media.correct');
  }

  /**
   * 判断选择是否正确
   * @returns
   */
  verifyIsCorrect() {
    if (this.selectIndexList.length !== this.ansIndexList.length) {
      this.changeCorrectAndErrorNum(false, this.item.isCorrect);
      this.item.isCorrect = false;
      return;
    }

    this.selectIndexList.sort();
    this.ansIndexList.sort();
    for (let i = 0; i < this.ansIndexList.length; i++) {
      if (this.selectIndexList[i] !== this.ansIndexList[i]) {
        this.changeCorrectAndErrorNum(false, this.item.isCorrect);
        this.item.isCorrect = false;
        return;
      }
    }

    this.changeCorrectAndErrorNum(true, this.item.isCorrect);
    this.item.isCorrect = true;
    if (this.examController.showNext) {
      this.examController.swiperController.showNext()
    }
  }

  /**
   * 更新 ExamManager 中 correctNumer 和 errorNumer 的值
   * @param result 本次结果
   * @param isCorrect 现在 ExamDetail 中的值
   */
  changeCorrectAndErrorNum(result: boolean, isCorrect: boolean| undefined) {
    // 值为undefined，之前没有被选择，更改数量
    if (isCorrect === undefined) {
      result ? this.changeCorrectNum(true) : this.changeErrorNum(true);
      return;
    }
    // 前一次为 true，这次仍然为 true，数量不变，这次为false，正确数量-1，错误数量=1
    if (isCorrect) {
      if (result) {
        return;
      }
      this.changeCorrectNum(false);
      this.changeErrorNum(true);
      return;
    }

    if (result) {
      this.changeCorrectNum(true);
      this.changeErrorNum(false);
      return;
    }
  }
}
/**
 * 多选-未点击提交答案按钮时的图标展示
 * @param option 当前选项
 * @param selected 已选择的选项集合
 * @returns 对应图标
 */
function getCheckBoxUnClickImage(option: string, selected: Array<string>): ResourceStr {
  if (selected.includes(option)) {
    return $r('app.media.checkbox_select');
  }
  return $r('app.media.no_select');
}

/**
 * 多选-点击提交答案按钮时的图标展示
 * @param option 当前选项
 * @param selected 已选择
 * @param answer 答案
 * @returns 对应图标
 */
function getCheckBoxClickImage(option: string, selected: Array<string>, answer: Array<string>): ResourceStr {
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
 * 获取问题类型
 * @param questionType
 * @returns
 */
export function getQuestionType(questionType: QuestionTypeEnum): string {
  if (questionType === QuestionTypeEnum.RADIO) {
    return '单选';
  }
  if (questionType === QuestionTypeEnum.CHECK_BOX) {
    return '多选';
  }
  if (questionType === QuestionTypeEnum.JUDGE) {
    return '判断';
  }
  return '';
}
