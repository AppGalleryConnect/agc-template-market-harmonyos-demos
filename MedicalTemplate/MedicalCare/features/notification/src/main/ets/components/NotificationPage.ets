import { CommonWebPageParam } from 'common';
import { NotificationViewModel } from '../viewmodel/NotificationViewModel';

@ComponentV2
export struct NotificationPage {
  @Local viewModel: NotificationViewModel = new NotificationViewModel()

  build() {
    Column() {
      Text('消息')
        .height($r('sys.float.titlebar_default_height'))
        .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
        .fontWeight(800)
        .width('100%')
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .textAlign(TextAlign.Start)
        .padding({
          left: 18
        })
      Column({ space: 8 }) {
        List() {
          ListItem() {
            this.notificationItem('医院动态', $r('app.media.ic_notification_hospital'), () => {
              this.viewModel.toPage('CommonWebPage', {
                src: 'https://developer.huawei.com/',
                title: '医院动态'
              } as CommonWebPageParam)
            })
          }

          ListItem() {
            this.notificationItem('我的消息', $r('app.media.ic_notification_my'), () => {
              this.viewModel.toPage('MyNotificationPage')
            })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .divider({
          strokeWidth: 0.5,
          color: $r('sys.color.ohos_id_color_list_separator')
        })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .padding({ top: 8 })
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  notificationItem(title: string, icon: ResourceStr, onClick: () => void) {
    Row({ space: 13 }) {
      Image(icon)
        .width(28)
        .height(28)

      Text(title)
        .fontSize(14)
        .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
    }
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
    .onClick(onClick)
  }
}
