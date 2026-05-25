import { ExamService, Chapter, EXAM_MANAGER_TYPE, ROUTE_PARAM } from '@ohos_agcit/driver_license_exam_datasource'
import { CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib'

@Builder
export function ChapterListViewBuilder() {
  ChapterListView()
}

@ComponentV2
struct ChapterListView {
  vm: CommonModel = CommonModel.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local chapterList:Chapter[] = this.examService.getChapterList();
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      List() {
        ForEach(this.chapterList, (item: Chapter, index: number) => {
          ListItem() {
            Column() {
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
                  .backgroundColor(item.serialBgColor)
                  .textAlign(TextAlign.Center)
                  .maxFontScale(1)

                Text(item.title)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                  .maxFontScale(1)
              }
              .width(CommonConstants.FULL_WIDTH)
              .margin({
                bottom:6
              })

              Row() {
                Row() {
                  Progress({
                    value: item.examManger.correctNumber,
                    total: item.examManger.total,
                    type: ProgressType.Linear
                  })
                    .width(88)
                    .height(24)
                    .color($r('sys.color.comp_background_emphasize'))
                  Text(`${item.examManger.correctNumber}/${item.examManger.total}`)
                    .fontSize(10)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({
                      left: 8,
                      right: 16
                    })
                    .maxFontScale(1)
                  Text(`正确率 ${item.calAccuracyRate()}%`)
                    .fontSize(10)
                    .fontColor($r('sys.color.font_secondary'))
                    .maxFontScale(1)
                }
                .layoutWeight(1)


                Text('前往练习')
                  .width(76)
                  .height(28)
                  .backgroundColor('#64BB5C')
                  .fontColor(Color.White)
                  .fontSize(12)
                  .borderRadius(8)
                  .textAlign(TextAlign.Center)
                  .maxFontScale(1)
                  .onClick(() => {
                    const param:ROUTE_PARAM = {
                      title: item.title,
                      type: EXAM_MANAGER_TYPE.chapter_name,
                      keyword: item.title
                    }
                    this.vm.navStack.pushPathByName('practiceView', param)
                  })
              }
              .padding({
                left:24
              })
              .width(CommonConstants.FULL_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .layoutWeight(1)
            .width(CommonConstants.FULL_WIDTH)
            .margin({
              bottom: 12,
              top:12
            })
          }
          .width(CommonConstants.FULL_WIDTH)
        }, (item:Chapter) => JSON.stringify(item))
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding({
        top:12,
        left: 16,
        right: 16
      })
      .divider({
        strokeWidth:1,
        color:$r('sys.color.comp_divider')
      })
      .scrollBar(BarState.Off)
    }
    .title('章节练习')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
  }
}
