
import { CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib'
import { Chapter, ExamService, EXAM_MANAGER_TYPE, ROUTE_PARAM , WRONG_COLLECT} from '@ohos_agcit/driver_license_exam_datasource'
import { promptAction } from '@kit.ArkUI';


@Builder
export function CollectionViewBuilder() {
  CollectionView()
}

@Entry
@ComponentV2
struct CollectionView {
  vm: CommonModel = CommonModel.instance;
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local chapterList:Chapter[] = this.examService.getChapterListByType(WRONG_COLLECT.WRONG);
  @Local typeStatus: WRONG_COLLECT = WRONG_COLLECT.WRONG;
  @Local totalCount: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.getTotalCount();
  }

  @Styles
  cardStyle() {
    .width(CommonConstants.FULL_WIDTH)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding(12)
  }

  toggleWrongOrCollect(type: WRONG_COLLECT) {
    this.typeStatus = type;
    this.getTotalCount();
    this.chapterList = this.examService.getChapterListByType(type);
  }

  getTotalCount() {
    if (this.typeStatus === WRONG_COLLECT.WRONG) {
      this.totalCount = this.examService.getErrorCount();
    } else {
      this.totalCount = this.examService.getCollectCount();
    }
  }

  @Builder
  toolBar() {
    Row() {
      Image($r('app.media.clear_btn'))
        .width(40)
        .height(40);
    }
    .width(50)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .margin({
      top: 10,
      right: '4%',
    })
    .onClick(() => {
      if (this.typeStatus === WRONG_COLLECT.WRONG) {
        this.examService.clearWrongQuestion()
      } else {
        this.examService.clearCollectQuestion();
      }
      this.toggleWrongOrCollect(this.typeStatus);
    })
  }

  build() {
    NavDestination(){
      Column({space:16}) {
        Row() {
          Text('错题本')
            .width(86)
            .height(36)
            .fontColor(this.typeStatus === WRONG_COLLECT.WRONG?Color.White:$r('sys.color.font_primary'))
            .fontSize(14)
            .backgroundColor(this.typeStatus === WRONG_COLLECT.WRONG?'#64BB5C':$r('sys.color.comp_background_secondary'))
            .borderRadius(16)
            .textAlign(TextAlign.Center)
            .maxFontScale(1)
            .margin({
              right:12
            })
            .onClick(() => {
              this.toggleWrongOrCollect(WRONG_COLLECT.WRONG)
            })
          Text('收藏题目')
            .width(86)
            .height(36)
            .fontColor(this.typeStatus === WRONG_COLLECT.COLLECT?Color.White:$r('sys.color.font_primary'))
            .fontSize(14)
            .backgroundColor(this.typeStatus === WRONG_COLLECT.COLLECT?'#64BB5C':$r('sys.color.comp_background_secondary'))
            .borderRadius(16)
            .textAlign(TextAlign.Center)
            .maxFontScale(1)
            .onClick(() => {
              this.toggleWrongOrCollect(WRONG_COLLECT.COLLECT)
            })
        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.Start)

        Column() {
          Text(this.typeStatus === WRONG_COLLECT.WRONG?'错题统计':'收藏统计')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .width(CommonConstants.FULL_WIDTH)
            .textAlign(TextAlign.Start)
            .maxFontScale(1)
            .margin({
              bottom:8
            })

          Column() {
            Row() {
              Text(this.typeStatus === WRONG_COLLECT.WRONG?'错题总数':'收藏总数')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .maxFontScale(1)

              Row() {
                Text(String(this.totalCount))
                  .fontSize(24)
                  .fontColor('#5BA854')
                  .fontWeight(FontWeight.Bold)
                  .maxFontScale(1)
                  .margin({
                    right:8
                  })

                Image($r('app.media.ic_right_arrow_lined'))
                  .width(16)
                  .height(16)
              }
            }
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              if (this.totalCount === 0) {
                this.getUIContext().getPromptAction().showToast({
                  message: this.typeStatus === WRONG_COLLECT.WRONG?'暂时没有错题':'暂时没有收藏的题目',
                  duration: 1500,
                })
                return;
              }
              const param:ROUTE_PARAM = {
                title: this.typeStatus === WRONG_COLLECT.WRONG?'错题':'收藏',
                type: this.typeStatus === WRONG_COLLECT.WRONG?EXAM_MANAGER_TYPE.error:EXAM_MANAGER_TYPE.collect
              }
              this.vm.navStack.pushPathByName('practiceView', param)
            })
          }
          .cardStyle()

        }
        .width(CommonConstants.FULL_WIDTH)

        Column() {
          Text(this.typeStatus === WRONG_COLLECT.WRONG?'错题分布':'收藏分布')
            .width(CommonConstants.FULL_WIDTH)
            .textAlign(TextAlign.Start)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .maxFontScale(1)
            .margin({
              bottom:8
            })

          if (this.chapterList.length > 0) {
            Column() {
              List() {
                ForEach(this.chapterList, (item: Chapter, index: number) => {
                  ListItem() {
                    Row() {
                      Row() {
                        Text(String(index + 1))
                          .width(16)
                          .height(16)
                          .margin({
                            right:8
                          })
                          .fontSize(10)
                          .fontColor(Color.White)
                          .borderRadius('50%')
                          .maxFontScale(1)
                          .backgroundColor(item.serialBgColor)
                          .textAlign(TextAlign.Center)

                        Text(item.title)
                          .fontSize(14)
                          .fontColor($r('sys.color.font_primary'))
                          .maxFontScale(1)
                      }

                      Row() {
                        Text(String(item.examManger.total))
                          .fontSize(14)
                          .fontColor($r('sys.color.font_secondary'))
                          .maxFontScale(1)
                          .margin({
                            right: 4
                          })
                        Image($r('app.media.ic_right_arrow_lined'))
                          .width(16)
                          .height(16)

                      }
                    }
                    .width(CommonConstants.FULL_WIDTH)
                    .justifyContent(FlexAlign.SpaceBetween)
                    .margin({
                      top:12,
                      bottom: 12
                    })
                    .onClick(() => {
                      const param:ROUTE_PARAM = {
                        title: item.title,
                        type: EXAM_MANAGER_TYPE.chapter_name,
                        wrongOrCollect: this.typeStatus,
                        keyword: item.title
                      }
                      this.vm.navStack.pushPathByName('practiceView', param)
                    })
                  }
                  .width(CommonConstants.FULL_WIDTH)
                }, (item:Chapter) => JSON.stringify(item))
              }
              .width(CommonConstants.FULL_WIDTH)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .divider({
                strokeWidth:1,
                color:$r('sys.color.comp_divider')
              })
            }
            .cardStyle()
          }

        }
        .width(CommonConstants.FULL_WIDTH)
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .padding({
        top:12,
        bottom:12,
        right: 16,
        left: 16
      })
    }
    .title('错题收藏')
    .menus(this.toolBar())
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
