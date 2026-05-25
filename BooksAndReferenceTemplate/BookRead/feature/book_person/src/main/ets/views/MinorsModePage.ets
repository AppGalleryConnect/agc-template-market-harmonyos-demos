import { AppStorageV2 } from '@kit.ArkUI';
import {
  Constants,
  FontModel,
  MinorsMode,
  MinorsProtectionUtils,
  NavHeaderBar,
  TCRouter
} from 'common';
import { fp2pxUtil } from 'base_common';

const minorsMode: MinorsMode =
  AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

@ComponentV2
export struct MinorsModePage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight')!;
  @Local isSelected: boolean = true
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title:'',
          hasBackButton: true,
          hasBgColor: false,
          isMainPage: false,
        })
        Column() {
          Column() {
            Image($r('app.media.ic_minors'))
              .size({ width: 48, height: 48 })
            Text(minorsMode.isMinorsMode ? '青少年模式已开启' : '青少年模式未开启')
              .fontWeight(700)
              .fontSize(this.fontModel.getFg(24))
              .margin({ top: 16 })
              .textAlign(TextAlign.Center)
            Text('未成年人模式下将为孩子展示适龄内容，帮助未成年人健康使用设备。该模式下部分功能将受限使用，请监护人主动设置。')
              .fontWeight(400)
              .fontSize(this.fontModel.getFg(14))
              .margin({ top: 16 })
              .textAlign(TextAlign.Center)
          }

          Blank()
          Column() {
            Row() {
              Checkbox()
                .selectedColor($r('app.color.slider_selected_color'))
                .width(20)
                .height(20)
                .select($$this.isSelected)
              Text() {
                Span('阅读并同意')
                Span('《未成年人个人信息保护规则》')
                  .fontColor($r('app.color.font_overdue'))
                  .onClick(() => {
                    TCRouter.push(Constants.PRIVACY_POLICY_ROUTE)
                  })
              }
              .fontSize(fp2pxUtil(12))
              .fontWeight(400)
              .margin({ left: 12 })
            }
            .constraintSize({
              maxWidth: 448
            })
            .width('100%')
            .margin({ bottom: 12 })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            Button(minorsMode.isMinorsMode ? '关闭青少年模式' : '开启青少年模式')
              .fontSize(fp2pxUtil(16))
              .width('100%')
              .constraintSize({
                maxWidth: 448
              })
              .backgroundColor($r('app.color.slider_selected_color'))
              .onClick(() => {
                if (!this.isSelected) {
                  this.getUIContext().getPromptAction().showToast({
                    message: '请阅读并同意《未成年人个人信息保护规则》',
                    duration: 2000
                  })
                } else {
                  if (minorsMode.isMinorsMode) {
                    MinorsProtectionUtils.closeMinorsMode(this.getUIContext())
                  } else {
                    MinorsProtectionUtils.openMinorsMode(this.getUIContext())
                  }
                }
              })
          }
        }
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16
        })
        .margin({ top: 40 })
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({ bottom: 36 })
  }
}