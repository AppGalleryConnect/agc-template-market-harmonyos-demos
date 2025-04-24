import { scanBarcode, scanCore } from '@kit.ScanKit';

@ComponentV2
export struct AddButtonView {
  @Require @Param pathStack: NavPathStack = new NavPathStack()

  @Builder BuildScanAddButton() {
    Column() {
      Image($r('app.media.scan'))
        .size({ width: 44, height: 44 })
      Text('扫码添加').fontSize(12).margin({top: 6})
    }
    .onClick(() => {
      scanBarcode.startScanForResult(getContext(this), {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: true,
        enableAlbum: true
      }).then((result: scanBarcode.ScanResult) => {
        this.pathStack.pushPathByName('AddInstructionPage', result.originalValue)
      })
    })
  }

  @Builder BuildManualAddButton() {
    Column() {
      Image($r('app.media.manual'))
        .size({ width: 44, height: 44 })
      Text('手动添加').fontSize(12).margin({top: 6})
    }
    .onClick(() => {
      this.pathStack.pushPathByName('ManualAddPage', null)
    })
  }

  build() {
    Row() {
      this.BuildScanAddButton()
      this.BuildManualAddButton()
    }
    .justifyContent(FlexAlign.SpaceAround)
    .width('90%')
    .height(100)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}