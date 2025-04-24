import { scanBarcode, scanCore } from '@kit.ScanKit'
import { StorageUtil } from 'utils'

@ComponentV2
export struct AddEntryView {
  @Require @Param pathStack: NavPathStack = new NavPathStack()
  @Param px: number = 24

  scan() {
    scanBarcode.startScanForResult(getContext(this), {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    }).then((result: scanBarcode.ScanResult) => {
      this.pathStack.pushPathByName('AddInstructionPage', result.originalValue)
    })
  }

  @Builder
  AddMenu() {
    Column() {
      Text('添加设备')
        .height(40)
        .onClick(() => {
          if (StorageUtil.exists('isLogin')) {
            this.pathStack.pushPathByName('AddDevicePage', null);
          } else {
            this.pathStack.pushPathByName('QuickLoginPage', null);
          }
        })
      Divider().height(10).width('80%').color('#ccc')
      Text('扫一扫')
        .height(40)
        .onClick(() => {
          if (StorageUtil.exists('isLogin')) {
            this.scan()
          } else {
            this.pathStack.pushPathByName('QuickLoginPage', null);
          }
        })
    }
    .width(100)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Row() {
      Image($r('app.media.plus'))
        .size({ width: this.px, height: this.px })
        .bindMenu(this.AddMenu)
    }
  }
}