import { NotificationType } from '../constant/Constant'
import { NotificationModel } from '../model/NotificationModel'
import { NotificationViewModel } from '../viewmodel/NotificationViewModel'
import { CommonEmptyView, CommonNavDestination, UISkeleton } from 'common'

@Builder
export function MyNotificationPageBuilder(name: string, param: Object) {
  CommonNavDestination({ title: '我的消息', contentPadding: {} }) {
    MyNotificationPage()
  }
}

@ComponentV2
export struct MyNotificationPage {
  @Local viewModel: NotificationViewModel = new NotificationViewModel()

  aboutToAppear(): void {
    this.viewModel.loadNotificationList()
  }

  build() {
    if (this.viewModel.isLoading) {
      Stack() {
        UISkeleton({
          loading: this.viewModel.isLoading,
          options: [1, { margin: { bottom: 16 } }, 1, { margin: { bottom: 16 } }, 1, { margin: { bottom: 16 } }]
        })
      }
      .width('100%')
      .height('100%')
      .padding(16)
    } else {
      List({ space: 16 }) {
        if (!this.viewModel.notificationList.length) {
          CommonEmptyView()
        }
        ForEach(this.viewModel.notificationList, (item: NotificationModel, index) => {
          this.notificationCard(index, item.title, item.content, item.time, item.type)
        }, (item: NotificationModel) => item.id.toString())
      }
      .padding(16)
    }
  }

  @Builder
  notificationCard(index:
    number, title:
    string, content:
    string, time:
    string, type:
    number
  ) {
    Column({ space: 8 }) {
      Text(time)
        .fontSize(12)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))

      Column({ space: 12 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(500)
          .width('100%')
          .textAlign(TextAlign.Start)

        Divider()
          .strokeWidth(0.5)
          .color($r('sys.color.ohos_id_color_subheading_separator'))

        Text(content)
          .width('100%')
          .fontSize(12)
          .textAlign(TextAlign.Start)

        if (type !== NotificationType.NOTIFICATION_NORMAL) {
          Flex({ direction: FlexDirection.RowReverse, justifyContent: FlexAlign.Start }) {
            Button('查看详情')
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .fontSize(14)
              .height(28)
              .onClick(() => {
                this.viewModel.toNotificationDetail(index)
              })
          }
        }
      }
      .padding(16)
      .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
      .borderRadius(8)
    }

  }
}