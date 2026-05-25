import { display } from '@kit.ArkUI';
import { mediaquery, UIContext } from '@kit.ArkUI';
import {window} from '@kit.ArkUI'
import { Logger } from 'external_interactions';

@ComponentV2
export struct qrCodeDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  @Local widPercent: number = 1
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  computeWid(){
    let displayClass: display.Display | null = null;
    displayClass = display.getDefaultDisplaySync();
    let totalWid = this.getUIContext().px2vp(displayClass.width);
    let wid = ((totalWid - 328) / 2) / totalWid;
    this.widPercent = Math.floor(wid * 100);
  }
  async aboutToAppear() {
    try {
      let myWindow = await window.getLastWindow(this.getUIContext().getHostContext()!)
      myWindow.on('windowSizeChange', () => {
        this.computeWid()
      })
    } catch (e) {
      Logger.error('[qrCodeDialog]', `Failed to get last window. error: ${JSON.stringify(e)}`)
    }
    this.computeWid()
  }
  build() {
    NavDestination(){
      Stack(){
        Column() {
          Row() {
            Text('会员码')
              .fontSize(18)
              .margin({ top: 26 })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          Row() {
            Image($r('app.media.qrCode'))
              .width(200)
              .margin({ top: 38 })
              .backgroundColor(Color.Black)
              .height(200)
          }
        }
        .width(328)
        .height(328)
        .border({ radius: 20 })
        .backgroundColor(Color.White)
        .position({x: this.widPercent+ '%', y: '28%'})
      }
      .width('100%')
      .height('100%')
      .onClick(()=>{
        this.pathStack.pop()
      })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
    })
    .backgroundColor('rgba(0,0,0,0.2)')
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}