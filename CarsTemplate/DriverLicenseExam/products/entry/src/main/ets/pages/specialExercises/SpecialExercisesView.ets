import { CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib'
import { CLASSIFY_DATA, CLASSIFY_BY_TYPE, DATA_BY_QUESTION_TYPE, EXAM_MANAGER_TYPE, ExamService, QuestionType,
  ROUTE_PARAM } from '@ohos_agcit/driver_license_exam_datasource'
import { promptAction } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';

@Builder
export function specialExercisesViewBuilder() {
  SpecialExercisesView()
}

@ComponentV2
struct SpecialExercisesView {
  vm: CommonModel = CommonModel.instance;
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;
  @Local totalCount: number = 0;
  @Local chapterCount: number = 0;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.setQuestionCount();
    this.chapterCount = this.examService.getChapterList().length;
  }

  setQuestionCount() {
    CLASSIFY_DATA.forEach((item: QuestionType) => {
      switch (item.type) {
        case EXAM_MANAGER_TYPE.easy:
          item.quantity = this.examService.getEasyQuestionCount();
          break;
        case EXAM_MANAGER_TYPE.simple:
          item.quantity = this.examService.getSimpleQuestionCount();
          break;
        case EXAM_MANAGER_TYPE.normal:
          item.quantity = this.examService.getMiddleQuestionCount();
          break;
        case EXAM_MANAGER_TYPE.mistake:
          item.quantity = this.examService.getMistakeQuestionCount();
          break;
        case EXAM_MANAGER_TYPE.difficult:
          item.quantity = this.examService.getHardQuestionCount();
          break;
      }
    })

    DATA_BY_QUESTION_TYPE.forEach((item: QuestionType) => {
      switch (item.type) {
        case EXAM_MANAGER_TYPE.single:
          item.quantity = this.examService.getRadioQuestionCount();
          break;
        case EXAM_MANAGER_TYPE.judging:
          item.quantity = this.examService.getJudgeQuestionCount();
          break;
      }
    })
    this.totalCount = this.examService.getTotalCount();
  }

  @Styles
  cardStyle() {
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding(12)
  }
  @Builder
  classifyQuestion(classifyTitle: Resource, number: number, type: EXAM_MANAGER_TYPE) {
    Row() {
      Text(classifyTitle)
        .fontSize(12)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxFontScale(1)
      Row() {
        Text(String(number))
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .maxFontScale(1)
        Image($r('app.media.ic_right_arrow_lined'))
          .height(12)
          .width(12)
      }
    }
    .width(94)
    .height(40)
    .backgroundColor($r('sys.color.comp_background_secondary'))
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({
      left:12,
      right: 8
    })
    .margin({
      right:12,
      top:12
    })
    .onClick(() => {
      if(number === 0) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.no_question'),
          duration: 1500,
        });
      } else {
        const param:ROUTE_PARAM = {
          title:classifyTitle,
          type: type
        }
        this.vm.navStack.pushPathByName('practiceView', param)
      }
    })
  }
  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          Row() {
            Row() {
              Image($r('app.media.list'))
                .width(16)
                .height(16)
                .margin({
                  right: 8
                })
              Text($r('app.string.exercises_by_chapter'))
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxFontScale(1)
            }

            Row() {
              Text(`共${this.chapterCount}章`)
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
                .maxFontScale(1)
                .margin({
                  right: 8
                })
              Image($r('app.media.ic_right_arrow_lined'))
                .height(12)
                .width(12)
            }
          }
          .height(44)
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .cardStyle()
          .onClick(() => {
            this.vm.navStack.pushPathByName('chapterListView', true);

          })

          Row() {
            Row() {
              Image($r('app.media.random'))
                .width(16)
                .height(16)
                .margin({
                  right: 8
                })
              Text($r('app.string.exercises_by_random'))
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxFontScale(1)
            }

            Row() {
              Text(String(this.totalCount))
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
                .maxFontScale(1)
                .margin({
                  right: 8
                })
              Image($r('app.media.ic_right_arrow_lined'))
                .height(12)
                .width(12)
            }
          }
          .height(44)
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .cardStyle()
          .onClick(() => {
            const param: ROUTE_PARAM = {
              title: '随机练习',
              type: EXAM_MANAGER_TYPE.random
            }
            this.vm.navStack.pushPathByName('practiceView', param)
          })

          Column() {
            Text($r('app.string.by_degree_of_difficulty'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxFontScale(1)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(CLASSIFY_DATA, (item: CLASSIFY_BY_TYPE) => {
                this.classifyQuestion(item.name, item.quantity, item.type)
              }, (item: CLASSIFY_BY_TYPE) => {
                try {
                  return JSON.stringify(item.name)
                } catch (err) {
                  return ''
                }
              })
            }
          }
          .width(CommonConstants.FULL_WIDTH)
          .alignItems(HorizontalAlign.Start)
          .cardStyle()

          Column() {
            Text($r('app.string.by_question_type'))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxFontScale(1)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(DATA_BY_QUESTION_TYPE, (item: CLASSIFY_BY_TYPE) => {
                this.classifyQuestion(item.name, item.quantity, item.type)
              }, (item: CLASSIFY_BY_TYPE) => {
                try {
                  return JSON.stringify(item.name)
                } catch (err) {
                  return ''
                }
              })
            }
          }
          .width(CommonConstants.FULL_WIDTH)
          .alignItems(HorizontalAlign.Start)
          .cardStyle()
        }
        .padding({
          top: 20,
          left: 16,
          right: 16,
          bottom: 20
        })
      }
      .scrollBar(BarState.Off)
    }
    .title('专项练习')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
  }
}
