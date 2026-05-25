import { Constants, FeedbackItem, FeedbackItemType, ReturnButton, FeedbackRecord, NavHeaderBar,
  BreakpointTypeEnum,
  BreakpointSystem,
  BreakpointStorage,
  FontModel} from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
export struct FeedbackRecordPage {
  @Local feedbackList: FeedbackItem[] = []
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local feedbackRecord: FeedbackRecord =
    AppStorageV2.connect(FeedbackRecord, 'feedbackRecord', () => new FeedbackRecord())!
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  async initData() {
    this.feedbackList = this.feedbackRecord.feedbackList
  }

  aboutToAppear(): void {
    this.initData()
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '反馈记录',
          hasBackButton: true,
          hasBgColor: true,
          isMainPage: false,
        })
        Scroll() {
          Column() {
            if (this.feedbackList.length === 0) {
              Column({ space: 16 }) {
                Image($r('app.media.NoRecord'))
                  .width(120)
                  .height(120)
                  .fillColor('#CCCCCC')

                Text('暂无反馈记录')
                  .fontSize(this.fontModel.getFg(16))
                  .fontColor($r('sys.color.font_secondary'))
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .height('90%')
            } else {
              ForEach(this.feedbackList, (item: FeedbackItemType) => {
                Column({ space: 12 }) {

                  Text('2025.06.06 周五 13:30:26')
                    .fontSize(this.fontModel.getFg(12))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))

                  Column() {
                    Text('问题描述')
                      .fontSize(this.fontModel.getFg(16))
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 12, bottom: 8 })

                    Text(item.description)
                      .fontSize(this.fontModel.getFg(12))
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width(Constants.FULL_SIZE)
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Text('问题截图')
                      .fontSize(this.fontModel.getFg(16))
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 12, bottom: 8 })
                    Scroll(){
                      Row() {
                        ForEach(item.stageImageUris, (itemUri: string, index: number) => {
                          Image(itemUri).width(80).height(80).margin({ right: 8 })
                        }, (item: string) => `${item}+${new Date().toString()}`)
                      }
                    }
                    .width('100%')
                    .scrollable(ScrollDirection.Horizontal)
                    .edgeEffect(EdgeEffect.Spring)
                    .scrollBar(BarState.Off)
                    .align(Alignment.Start)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width(Constants.FULL_SIZE)
                }
                .backgroundColor($r('sys.color.comp_background_primary'))
                .padding(12)
                .margin({ bottom: 12 })
                .width('100%')
                .borderRadius(16)
                .alignItems(HorizontalAlign.Start)
              }, (item: FeedbackItemType,index) => `${item.description}+${new Date().toString()}+${index}`)
            }
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)
          .backgroundColor($r('sys.color.background_secondary'))
          .padding({
            top: 12,
            left: 16,
            right: 16,
            bottom: 12
          })
        }
        .height('100%')
        .width('100%')
        .margin({ bottom: 100 })
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}


