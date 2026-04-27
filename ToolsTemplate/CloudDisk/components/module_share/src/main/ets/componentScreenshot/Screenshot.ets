import dayjs from 'dayjs'
import { NewsQrCode, ShareOptions } from '../model/Model'

@ComponentV2
export struct Screenshot {
  @Require @Param qrCodeInfo: ShareOptions

  handleQrCode() {
    let code: NewsQrCode = {
      articleId: this.qrCodeInfo?.id,
      type: this.qrCodeInfo?.type,
    }
    return JSON.stringify(code)
  }

  build() {
    Column() {
      Column() {
        Column() {
          Stack() {
            Image(this.qrCodeInfo.coverUrl).width('100%').borderRadius(8).clip(true)
            Image($r('app.media.play')).width(43).height(43)
          }.visibility(this.qrCodeInfo.coverUrl && this.qrCodeInfo.isVideo ? Visibility.Visible : Visibility.None)

          Image(this.qrCodeInfo.coverUrl).height(143).width('100%')
            .visibility(this.qrCodeInfo.coverUrl && !this.qrCodeInfo.isVideo ? Visibility.Visible : Visibility.None)
        }

        Column() {
          Text(this.qrCodeInfo.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .maxLines(2)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 12 })
          Row({ space: 8 }) {
            Text(this.qrCodeInfo.articleFrom)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
            Text(dayjs(this.qrCodeInfo.createTime).format('YYYY-MM-DD hh:mm'))
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
    .id(this.qrCodeInfo.id)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(8)
    .width(270)
    .height(this.qrCodeInfo.coverUrl ? 370 : 270)
    .padding(16)
  }
}