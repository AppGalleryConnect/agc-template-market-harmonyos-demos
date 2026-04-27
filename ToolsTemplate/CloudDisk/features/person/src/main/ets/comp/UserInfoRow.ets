import { baseToast } from 'base_apis'
import { GlobalContext } from 'common'
import { DownLoadNetworkPriceViewModel } from '../viewmodel/DownLoadNetworkPriceViewModel'

/**
 * @usage: 用于用户信息设置行展示场景。提供标题、副标题、右侧内容和开关按钮的横向布局，
 * 适用于设置页面的各种配置项。关键数据结构：leftTitle（左侧标题字符串或资源）、subTitle（副标题字符串）、
 * rightContent（右侧内容字符串）、isSwitch（是否显示开关布尔值）、isOpen（开关状态布尔值）、
 * rightOnClick（右侧点击回调函数）、switchButton（开关切换回调函数，参数为开关状态）。
 * 包含if逻辑：根据isSwitch判断显示开关或右箭头，根据isOpen判断开关状态，
 * 开启开关时显示确认对话框。
 * @layout: 横向布局。左侧为标题列（标题和副标题垂直排列，左对齐），中间为空白区域，
 * 右侧为内容文字（右对齐，最多120宽度）和开关或箭头图标。整体高度60，垂直居中对齐。
 * @constraints: leftTitle左侧标题不能为空，isSwitch为true时switchButton回调函数必须正确处理开关状态
 * @isGen: true
 * @fileType: component
 * @zhName: 用户信息行组件
 */
@ComponentV2
export struct UserInfoRow {
  @Param leftTitle: string | Resource = ''
  @Param subTitle: string = ''
  @Param rightContent: string = ''
  @Event rightOnClick: () => void
  @Event switchButton: (isOn: boolean) => void
  @Param isSwitch: boolean = false
  @Local isOpen: boolean = new DownLoadNetworkPriceViewModel().getDownLoadNetworkPrice()

  aboutToAppear(): void {
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.leftTitle)
          .font({
            size: 15,
            weight: 500
          })
          .fontColor($r('app.color.dark_color_444444'))
          .height(18)
        if (this.subTitle) {
          Text(this.subTitle).height(19).fontWeight(400).fontSize(14).fontColor($r('sys.color.font_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Text(this.rightContent)
        .height(15)
        .textAlign(TextAlign.End)
        .width(120)
        .fontSize(13)
        .fontWeight(400)
        .fontColor($r('app.color.gray_color_9DA3AA'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.isSwitch) {
        Column() {
          Toggle({
            type: ToggleType.Switch,
            isOn: this.isOpen
          })
        }
        .hitTestBehavior(HitTestMode.Block)
        .onClick(() => {
          if (this.isOpen) {
            this.isOpen = false
            if (this.switchButton) {
              this.switchButton(this.isOpen)
            }
          } else {
            GlobalContext.getUIContext().showAlertDialog({
              title: $r('app.string.phone_network_title'),
              message: $r('app.string.phone_network_message'),
              autoCancel: false,
              alignment: DialogAlignment.Center,
              showInSubWindow: true,
              isModal: true,
              buttonDirection: DialogButtonDirection.HORIZONTAL,
              buttons: [
                {
                  value: $r('app.string.cancel'),
                  action: () => {
                  }
                },
                {
                  value: $r('app.string.sure'),
                  action: () => {
                    this.isOpen = true
                    baseToast.hide()
                    if (this.switchButton) {
                      this.switchButton(this.isOpen)
                    }
                  }
                }
              ]
            })
          }
        })
      } else {
        Image($r('app.media.iconRight'))
          .size({ width: 20, height: 20 })
      }
    }
    .onClick(() => {
      if (this.rightOnClick) {
        this.rightOnClick()
      }
    })
    .size({ width: '100%', height: 60 })
    .padding({ left: 16, right: 16 })
  }
}
