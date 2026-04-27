import { FeedbackItemType } from '@agctemplate/feed_back'
import { PreferConstant, PreferenceUtil } from '@agctemplate/utils'
import { BarVM } from '@agctemplate/widgets'
import { Header } from '../component/Header'

import { NavDestinationModifier } from '@kit.ArkUI'

@ComponentV2
export struct FeedbackRecordPage {
  @Local feedbackList: FeedbackItemType[] = []
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier()

  /**
   * 数据初始化
   */
  initData() {
    let feedbackList: FeedbackItemType[] =
      PreferenceUtil.getInstance(this.getUIContext().getHostContext())
        .get(PreferConstant.FEEDBACK_RECORD, []) as FeedbackItemType[]
    this.feedbackList = feedbackList
  }

  aboutToAppear(): void {
    this.initData()
  }

  build() {
    NavDestination() {
      Column() {
        Header({ title: '反馈记录' })
        Column() {
          if (this.feedbackList.length > 0) {
            List() {
              ForEach(this.feedbackList, (item: FeedbackItemType) => {
                ListItem() {
                  Column() {
                    Text(item.time)
                      .fontSize(14)
                      .fontWeight(400)
                      .lineHeight(19)
                      .fontColor($r('sys.color.font_primary'))
                    Text('问题描述')
                      .fontSize(14)
                      .fontWeight(400)
                      .lineHeight(19)
                      .fontColor($r('sys.color.font_secondary'))
                      .margin({ top: 12, bottom: 8 })
                    Text(item.description)
                      .fontSize(16)
                      .fontWeight(400)
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(21)
                      .margin({ bottom: 12 })
                    GridRow({
                      columns: {
                        sm: 3, // 在sm断点时为3列
                        md: 5, // 在md断点时为5列
                      },
                      gutter: {
                        x: 8, // 列间距
                        y: 8, // 行间距
                      },
                    }) {
                      ForEach(item.stageImageUris, (item1: string, index: number) => {
                        GridCol() {
                          Image(item1)
                            .width(96)
                            .height(96)
                            .borderRadius(16)
                        }
                      }, (item1: string, index: number) => item1 + index)
                    }
                    .width('100%')
                  }
                  .backgroundColor($r('sys.color.comp_background_primary'))
                  .padding(12)
                  .margin({ bottom: 12 })
                  .width('100%')
                  .borderRadius(16)
                  .alignItems(HorizontalAlign.Start)
                }
              }, (item: FeedbackItemType) => JSON.stringify(item))
            }
            .margin({ bottom: 30 })
            .scrollBar(BarState.Off)
          } else {
            // 没有数据 显示空
            Column() {
              Text('您还没有提交反馈记录')
                .width('100%')
                .height('100%')
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
            }.width('100%').height(120)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 12
        })
        .height('100%')
        .width('100%')
        .backgroundColor($r('sys.color.background_secondary'))

      }
      .height('100%').width('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
    .attributeModifier(this.navDestinationModifier)
  }
}

@Builder
export function FeedbackRecordPageBuilder() {
  FeedbackRecordPage()
}

