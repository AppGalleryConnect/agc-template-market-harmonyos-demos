import { PatientViewModel } from 'patient'
import { UserViewModel } from 'personal'
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi'
import { ConfirmDialogUtil, LoadingDialogUtil } from 'common'

@ComponentV2
export struct MyPage {
  @Param userViewModel: UserViewModel = UserViewModel.getInstance()

  aboutToAppear(): void {
    this.userViewModel.getUserInfo()
  }

  @Builder
  MyPageItem(icon: ResourceStr, title: string, routerName?: string, onClick?: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .margin({
          right: 12
        })
      Text(title)
        .fontSize(14)
      Blank()
      Image($r('app.media.ic_chevron_right'))
        .width(14)
        .height(14)
        .fillColor($r('sys.color.ohos_id_color_primary'))
    }
    .width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .padding({
      top: 16,
      bottom: 16,
      left: 22,
      right: 22
    })
    .onClick(() => {
      if (routerName) {
        this.userViewModel.toPage(routerName)
      } else if (onClick) {
        onClick()
      }
    })
  }

  build() {
    Column() {
      Text('我的')
        .height($r('sys.float.titlebar_default_height'))
        .fontSize($r('sys.float.ohos_id_text_size_dialog_tittle'))
        .fontWeight(800)
        .width('100%')
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .textAlign(TextAlign.Start)
        .padding({
          left: 18
        })

      Row({ space: 18 }) {
        Image(this.userViewModel.userModel.userHeadImg)
          .alt($r('app.media.ic_profile'))
          .borderRadius(50)
          .width(44)
          .height(44)

        Column({ space: 5 }) {
          Text(this.userViewModel.getUserName())
            .fontSize(18)
            .fontWeight(500)

          Text(this.userViewModel.getUserPhone())
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Stack() {
          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
              label: '绑定手机号',
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .fontSize(12)
                  .fontWeight(500)
                  .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
                  .height(36)
                  .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onGetPhoneNumber((err, data) => {
                this.userViewModel.onGetPhoneNumber(err, data)
              })
          }).onClick(() => {
            LoadingDialogUtil.openLoadingDialog()
          }).visibility(!this.userViewModel.userModel.isPhoneAssociated ? Visibility.Visible : Visibility.None)

          Button('解绑手机号')
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .height(36)
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .visibility(this.userViewModel.userModel.isPhoneAssociated ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              ConfirmDialogUtil.showConfirmDialog({
                title: '解绑手机号',
                content: '确定要解绑手机号吗？',
                onConfirm: () => {
                  this.userViewModel.unbindPhone()
                }
              })
            })
        }
      }
      .width('100%')
      .align(Alignment.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
      .padding({
        left: 24,
        right: 24,
        top: 19,
        bottom: 16
      })
      .onClick(() => {
        this.userViewModel.toPersonalPage()
      })

      List() {
        ListItem() {
          this.MyPageItem($r('app.media.ic_patient_management'), '就诊人管理', undefined, () => {
            PatientViewModel.getInstance().toPatientEditListPage()
          })
        }

        ListItem() {
          this.MyPageItem($r('app.media.ic_appointment'), '挂号记录', 'AppointmentOrderListPage')
        }

        ListItem() {
          this.MyPageItem($r('app.media.ic_report'), '报告查询', 'ReportQueryPage')
        }
      }
      .width('100%')
      .height('100%')
      .margin({ top: 8 })
      .divider({
        strokeWidth: 0.5,
        color: $r('sys.color.ohos_id_color_list_separator')
      })
    }
    .height('100%')
  }
}

