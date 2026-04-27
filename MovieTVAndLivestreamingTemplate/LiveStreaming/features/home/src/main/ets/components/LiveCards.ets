import { getMedia } from '@agctemplate/resources'
import { LiveCardModel } from '@agctemplate/widgets'
import { deviceInfo } from '@kit.BasicServicesKit'

@ComponentV2
export struct BigCard {
  @Param @Require liveData: LiveCardModel

  build() {
    Column() {
      Stack() {
        Image(this.liveData.cover)
          .width('100%')
          .height('71%')
          .borderRadius({ topLeft: 8, topRight: 8 })

        if (this.liveData.status === '2') {
          Image(getMedia('app.media.start_soon'))
            .height(16)
            .position({ right: 4, top: 4 })
        }
      }

      Column() {
        Row() {
          Text(this.liveData.title)
            .fontSize(16)
            .fontWeight(400)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({
              left: 12,
              right: 12,
              top: 6,
              bottom: 4
            })
        }
        .width('100%')

        Row() {
          Image(getMedia('app.media.watcher'))
            .width(16)
            .fillColor($r('sys.color.font_secondary'))
            .margin({ left: 13, right: 4, bottom: 9 })
          if (this.liveData.watching >= 10000) {
            Text(`${(this.liveData.watching / 10000).toFixed(1)}万`)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ right: 4, bottom: 9 })
          } else {
            Text(this.liveData.watching.toString())
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ right: 4, bottom: 9 })
          }
        }
        .width('100%')
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('29%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .width(deviceInfo.deviceType === 'tablet'?362:244)
    .height(deviceInfo.deviceType === 'tablet'?262:194)
  }
}


@ComponentV2
export struct CommonCard {
  @Param @Require liveData: LiveCardModel

  build() {
    Column() {
      Stack() {
        Image(this.liveData.cover)
          .width(160)
          .height(90)
          .borderRadius({ topLeft: 8, topRight: 8 })

        if (this.liveData.status === '1') {
          Image(getMedia('app.media.streaming'))
            .height(16)
            .position({ left: 4, top: 4 })
        }

        Row() {
          Image(getMedia('app.media.watcher'))
            .width(12)
            .margin({
              left: 4,
              right: 3,
              bottom: 4,
              top: 4
            })
            .fillColor('#fff')
          if (this.liveData.watching >= 10000) {
            Text(`${(this.liveData.watching / 10000).toFixed(1)}w`)
              .fontSize(8)
              .fontWeight(400)
              .fontColor('#fff')
              .margin({ top: 5, bottom: 5 })
          } else {
            Text(this.liveData.watching.toString())
              .fontSize(8)
              .fontWeight(400)
              .fontColor('#fff')
              .margin({ top: 5, bottom: 5 })
          }

          Row() {
            Text(this.liveData.category)
              .fontSize(8)
              .fontWeight(400)
              .fontColor('#fff')
              .textAlign(TextAlign.End)
              .margin({ top: 6, bottom: 4, right: 4 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)

        }
        .width(160)
        .height(20)
        .backgroundColor($r('sys.color.mask_fourth'))
        .position({ top: 70 })
      }

      Row() {
        Image(this.liveData.avatar)
          .width(28)
          .borderRadius(14)
          .margin('6px 4px')

        Column() {
          Row() {
            Text(this.liveData.title)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize(12)
              .fontWeight(400)
              .textAlign(TextAlign.Start)
              .fontColor($r('sys.color.font_primary'))
          }
          .width(120)
          .height(16)
          .margin({ top: 4, right: 4, bottom: 2 })

          Row() {
            Text(this.liveData.streamer)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontWeight(500)
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width(120)
          .height(14)
          .margin({ right: 4, bottom: 4 })
        }

      }
      .width(160)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .width(160)
    .height(130)
  }
}