import { BarVM, HeaderView, TValueType } from 'common'
import { phoneRouterControl } from 'oh_router'
import { CurrentDeviceViewModel } from '../viewmodel/CurrentDeviceViewModel'
import { AlertDialog } from '@kit.ArkUI';
import deviceInfo from '@ohos.deviceInfo';

@Builder
export function EquipmentPageBuilder(paramData: TValueType) {
  EquipmentPage({ currentDeviceData: paramData as EquipmentPageParam })
}

/**
 * @usage: 用于展示设备详情页面。提供单个设备的详细信息展示和删除设备功能。
 * 关键数据结构包括EquipmentPageParam（设备页面参数，包含paramdata设备数据和cancelEquipmentAction删除回调）、
 * CurrentDeviceViewModel（当前设备视图模型）、marketNameInfo（当前手机名称）、osFullName（当前手机版本号）。
 * 包含if逻辑：根据设备名称和系统版本判断是否为当前设备，当前设备无法删除并显示提示"当前设备无法删除，请删除其他设备"。
 * @layout: 页面采用NavDestination布局。顶部是HeaderView导航栏（标题"设备"和返回按钮，上边距20vp），
 * 主体Column（宽度90%、左对齐）包含设备名称Text（字号20、加粗、灰色#B2000000、右边距10vp）、
 * 设备系统Text（字号12、灰色#9DA3AA、上边距10vp）、验证通过时间Text（字号12、灰色#9DA3AA、上边距10vp），
 * 底部是"移除设备"Button（宽度100%、高度5.5%、底部边距130vp）。点击按钮弹出AlertDialog确认对话框（标题"确定移除吗?"、
 * 内容"移除操作后，该设备验证状态将失效"、取消和确定按钮）。
 * @constraints: 当前设备名称和系统版本从deviceInfo获取不可修改；当前设备无法删除的判断逻辑固定；
 * 删除设备需要弹出确认对话框；删除成功后调用cancelEquipmentAction回调并返回上一页；
 * 删除失败时显示Toast提示"当前设备无法删除，请删除其他设备"。
 * @isGen: true
 * @fileType: page
 * @zhName: 设备详情页面
 * @component: HeaderView
 */
@ComponentV2
struct EquipmentPage {
  @Param @Require currentDeviceData: EquipmentPageParam
  //获取手机名称
  @Local marketNameInfo: string = deviceInfo.marketName
  //获取手机版本号
  @Local osFullName: string = deviceInfo.osFullName

  build() {
    NavDestination() {
      HeaderView({
        title: $r('app.string.device'),
        clickBackBtn: () => {
          phoneRouterControl.popPage();
        }
      })
        .margin({ top: 20 })
      Column() {
        Text(this.currentDeviceData.paramData.currentDeviceName)
          .fontColor($r('app.color.dark_color_B2000000'))
          .fontSize(20)
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 10 })
        Text('设备系统： ' + this.currentDeviceData.paramData.currentDeviceEquipmentSystem)
          .fontSize(12)
          .fontColor($r('app.color.dark_color_9DA3AA'))
          .margin({ top: 10 })
          .textAlign(TextAlign.Start)
        Text('验证通过时间： ' + this.currentDeviceData.paramData.currentDeviceTime)
          .fontSize(12)
          .fontColor($r('app.color.dark_color_9DA3AA'))
          .margin({ top: 10 })
          .textAlign(TextAlign.Start)
        Blank()
        Button($r('app.string.delete_device'))
          .width('100%')
          .height('5.5%')
          .backgroundColor($r('app.color.blue_color_2FAFFF'))
          .margin({ bottom: 130 })
          .onClick(() => {
            this.dialogController.open()
          })
      }
      .width('90%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '确定移除吗?',
      content: '移除操作后，该设备验证状态将失效',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogController.close()
        }
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          if (this.currentDeviceData.paramData.currentDeviceName === this.marketNameInfo &&
            this.currentDeviceData.paramData.currentDeviceEquipmentSystem === this.osFullName) {
            showToast(this.getUIContext(), '当前设备无法删除，请删除其他设备')
          } else {
            this.currentDeviceData.cancelEquipmentAction()
            phoneRouterControl.popPage()
          }
          this.dialogController.close()
        }
      },
    })
  });
}

function showToast(uiContext: UIContext, message: string) {
  uiContext.getPromptAction().showToast({
    message: message,
    duration: 2000,
    textColor: $r('sys.color.font_on_primary'),
    backgroundColor: $r('app.color.dark_color_CC202C3B'),
    bottom: 136 + px2vp(BarVM.instance.aiBarHeight.value),
    backgroundBlurStyle: BlurStyle.NONE
  })
}

export interface EquipmentPageParam {
  paramData: CurrentDeviceViewModel,
  cancelEquipmentAction: () => void
}
