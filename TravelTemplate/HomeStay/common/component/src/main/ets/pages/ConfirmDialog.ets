import { consult } from 'util';

@CustomDialog
export struct ConfirmDialog {
  controller?: CustomDialogController
  call: () => void = () => {
  }
  phone: string = ''

  build() {
    Column({ space: 16 }) {
      Text(this.phone)
        .fontColor('#007DFF')
        .fontWeight(500)
        .fontSize(18)
        .width('100%')
        .textAlign(TextAlign.Center)

      Row({ space: 120 }) {
        Text('呼叫').fontWeight(500).fontColor('#007DFF').onClick(() => {
          consult(this.phone);
          this.controller?.close()
        })
        Text('取消').fontWeight(500).onClick(() => {
          this.controller?.close()
        })
      }.width('100%').justifyContent(FlexAlign.Center)
    }.size({ width: '80%', height: 120 }).justifyContent(FlexAlign.Center).backgroundColor(Color.White).borderRadius(16)
  }
}