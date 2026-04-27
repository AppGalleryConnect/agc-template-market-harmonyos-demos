import { NewsQrCode } from '../model/Model'
import { SheetShowVM } from '../viewModel/SheetShowVM'

@ComponentV2
export struct Screenshot {
  @Local shareShowVM: SheetShowVM = SheetShowVM.instance

  handleQrCode() {
    let code:NewsQrCode = {
      articleId:this.shareShowVM.qrCodeInfo?.id,
      type:this.shareShowVM.qrCodeInfo?.type,
      authorId:this.shareShowVM.qrCodeInfo?.author?.authorId
    }
    return JSON.stringify(code)
  }

  build() {
    Column() {
      Column() {
        Image($r(this.shareShowVM.coverUrl)).height(143).width('100%')
          .visibility(this.shareShowVM.coverUrl ? Visibility.Visible : Visibility.None)
        Column() {
          Text(this.shareShowVM.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .maxLines(2)
            .textOverflow({overflow:TextOverflow.Ellipsis})
            .margin({ top: 12 })
          Row({ space: 8 }) {
            Text(this.shareShowVM.articleFrom)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
            Text(this.shareShowVM.createTime)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
          .margin({ top: '20%', bottom: 16 })
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 8, right: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(8)

      Row({ space: 8 }) {
        QRCode(this.handleQrCode()).width(64).height(64)
        Text('长按二维码查看详情')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .margin({ top: 12 })
      .justifyContent(FlexAlign.Start)
    }
    .id('Screenshot')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(8)
    .width(270)
    .height(this.shareShowVM.coverUrl ? 370 : 270)
    .padding(16)
  }
}