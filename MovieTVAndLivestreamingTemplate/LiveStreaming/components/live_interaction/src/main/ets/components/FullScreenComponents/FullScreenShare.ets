@ComponentV2
export struct FullScreenShare {

  @Event setHide: () => void
  @Event openSharePost: () => void
  @Event goBack: () => void
  @Event closeAll: () => void

  build() {
    Row() {
      Column()
        .height('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.closeAll()
        })
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .margin({ left: 24 })
            .onClick(() => {
              this.setHide()
            })
          Text('分享到')
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .fontColor('#fff')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(56)
        .margin({ top: 22 })
        Row() {
          Column() {
            Image($r('app.media.wechat'))
              .width(48)
              .height(48)
              .borderRadius(8)
            Text('微信')
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(400)
              .margin({ top: 8 })
          }
          .width(68)
          .height(88)
          .margin({ left: 24, right: 9 })
          Column() {
            Image($r('app.media.friend_circle'))
              .width(48)
              .height(48)
              .borderRadius(8)
            Text('朋友圈')
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(400)
              .margin({ top: 8 })
          }
          .width(68)
          .height(88)
          .margin({ right: 9 })
          Column() {
            Image($r('app.media.qq'))
              .width(48)
              .height(48)
              .borderRadius(8)
            Text('QQ')
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(400)
              .margin({ top: 8 })
          }
          .width(68)
          .height(88)
        }
        .width('100%')
        .height(88)
        .margin({ top: 8 })
        Row() {
          Column() {
            Image($r('app.media.create_post_white'))
              .width(48)
              .height(48)
              .borderRadius(8)
            Text('生成海报')
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(400)
              .margin({ top: 8 })
          }
          .width(68)
          .height(88)
          .margin({ left: 24, right: 9 })
          .onClick(() => {
            this.openSharePost()
          })
          Column() {
            Image($r('app.media.copy_link_white'))
              .width(48)
              .height(48)
              .borderRadius(8)
            Text('复制链接')
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(400)
              .margin({ top: 8 })
          }
          .width(68)
          .height(88)
          .margin({ right: 9 })
          Column() {
            Image($r('app.media.system_share_white'))
              .width(48)
              .height(48)
              .borderRadius(8)
            Text('系统分享')
              .height(16)
              .fontSize(12)
              .fontColor('#fff')
              .fontWeight(400)
              .margin({ top: 8 })
          }
          .width(68)
          .height(88)
        }
        .width('100%')
        .height(88)
        .margin({ top: 16 })
      }
      .width(368)
      .height('100%')
      .backgroundColor($r('app.color.normal_font_color'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }
    .width('100%')
    .height('100%')
  }
}