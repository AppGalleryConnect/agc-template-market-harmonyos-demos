import { RouterMap, RouterUtils } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { FeedbackTrigger } from '../FeedbackTrigger'

@ComponentV2
struct FeedbackPage {
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '意见反馈'
        })
        Column({ space: 12 }) {
          FeedbackTrigger() {
            Row({ space: 8 }) {
              Text('反馈问题')
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
              Image($r('app.media.ic_right'))
                .width($r('app.float.arrow_right_w'))
                .draggable(false)
            }
            .width('100%')
            .padding({
              left: 12,
              right: 12,
              top: 16,
              bottom: 16
            })
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
          }

          Row({ space: 8 }) {
            Text('反馈记录')
              .fontSize(16)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
            Image($r('app.media.ic_right'))
              .width($r('app.float.arrow_right_w'))
              .draggable(false)
          }
          .width('100%')
          .padding({
            left: 12,
            right: 12,
            top: 16,
            bottom: 16
          })
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onClick(()=>{
            RouterUtils.pushPathByName(RouterMap.FEEDBACK_HISTORY_PAGE)
          })
        }
        .margin({ top: 8 })
        .padding({
          left: 16, right: 16
        })
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)

  }
}

@Builder
export function buildFeedbackPage(): void {
  FeedbackPage()
}