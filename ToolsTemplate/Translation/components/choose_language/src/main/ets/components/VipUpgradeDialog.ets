import { VipDialogConstants } from '../constants/LanguageConstants';

/**
 * @usage: VIP升级提示弹窗组件，用于提示用户升级VIP以解锁高级语言。支持显示/隐藏控制、升级和关闭回调。
 * 主要数据结构包括visible（显示状态）、onClose（关闭回调）、onUpgrade（升级回调）。
 * 包含if逻辑判断弹窗显示。
 * @layout: 组件采用Column垂直布局，整体为全屏遮罩层。弹窗内容Column包含VIP图标Image、提示文字Text、解锁按钮Button。
 * 底部为关闭按钮Row（白色X图标）。弹窗背景为渐变色。
 * @constraints: 无
 * @isGen: true
 * @fileType: component
 * @zhName: VIP升级提示弹窗组件
 * @image: screenshot/translate/VipUpgradeDialog.jpg
 */
@ComponentV2
export struct VipUpgradeDialog {
  @Require @Param visible: boolean = false;
  @Param onClose?: () => void = undefined;
  @Param onUpgrade?: () => void = undefined;

  aboutToAppear(): void {
  }

  build() {
    if (this.visible) {
      // 全屏遮罩层
      Column() {
        // 弹窗内容区域
        Column() {
          //VIP图标
          Image($r('app.media.vip_logos'))
            .width(VipDialogConstants.VIP_ICON_WIDTH)
            .height(VipDialogConstants.VIP_ICON_HEIGHT)
            .margin({ top: VipDialogConstants.VIP_ICON_TOP_MARGIN })

          // 提示文字
          Text(VipDialogConstants.UPGRADE_TEXT)
            .fontSize(VipDialogConstants.TEXT_FONT_SIZE)
            .fontColor(VipDialogConstants.TEXT_COLOR)
            .fontWeight(700)
            .margin({
              top: VipDialogConstants.TEXT_TOP_MARGIN,
              bottom: VipDialogConstants.TEXT_BOTTOM_MARGIN
            })

          // 去解锁按钮
          Button(VipDialogConstants.UNLOCK_BUTTON_TEXT)
            .width(250)
            .height(VipDialogConstants.BUTTON_HEIGHT)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor(VipDialogConstants.BUTTON_BG_COLOR)
            .borderRadius(VipDialogConstants.BUTTON_BORDER_RADIUS)
            .onClick(() => {
              this.handleUpgrade();
            })
        }
        .width(VipDialogConstants.DIALOG_WIDTH)
        .padding({
          left: VipDialogConstants.DIALOG_HORIZONTAL_PADDING,
          right: VipDialogConstants.DIALOG_HORIZONTAL_PADDING,
          top: 0,
          bottom: VipDialogConstants.DIALOG_BOTTOM_PADDING
        })
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [
            [VipDialogConstants.BG_GRADIENT_END, 0.0],
            [VipDialogConstants.BG_GRADIENT_END, 0.7],
            [VipDialogConstants.BG_GRADIENT_START, 1.0]
          ]
        })
        .borderRadius(VipDialogConstants.DIALOG_BORDER_RADIUS)

        // 关闭按钮
        Row() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(16)
            .fontColor([Color.White])
        }
        .width(30)
        .height(30)
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .backgroundColor('rgba(255, 255, 255, 0.4)')
        .margin({ top: 24 })
        .onClick(() => {
          if (this.onClose) {
            this.onClose();
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(VipDialogConstants.MASK_BG_COLOR)
      .justifyContent(FlexAlign.Center)
      .onAppear(() => {
      })
    }
  }

  private handleUpgrade(): void {
    if (this.onUpgrade) {
      this.onUpgrade();
    }
  }
}
