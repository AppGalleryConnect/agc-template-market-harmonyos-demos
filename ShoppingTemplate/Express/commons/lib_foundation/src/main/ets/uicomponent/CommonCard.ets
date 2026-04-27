@ComponentV2
export struct CommonCard {
  build() {
    Row() {
      Image($r('app.media.ic_vip'))
        .width(24)
        .height(24)
        .margin({ right: 4 })
      Text('开通会员')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#936900')
        .margin({ right: 12 })
      Text() {
        Span('可领')
          .fontColor('#936900')
        Span(' 788元 ')
          .fontColor('#0A59F7')
        Span('优惠礼包')
          .fontColor('#936900')
      }
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
    }
  }
}