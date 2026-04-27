@ComponentV2
export struct HotelPolicyItem {
  @Param img: string = ''
  @Param title: string = '';
  @Param items: string[] = [];

  build() {
    Column({ space: 10 }) {
      // 标题
      Column() {
        Row() {
          Image($r(this.img)).width(14).height(14)
          Text(this.title).textTitleStyle()
        }.justifyContent(FlexAlign.Start).width('100%').alignItems(VerticalAlign.Top)
      }.margin({ top: 20 })

      // 内容项
      Column({ space: 8 }) {
        ForEach(this.items, (item: string) => {
          Column() {
            Text(item).textContentStyle()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start).margin({ left: 37 })
        },(item: string) => JSON.stringify(item))
      }
      .width('100%')
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function textTitleStyle() {
  .fontSize(14)
  .fontColor('#000000')
  .fontWeight(500)
  .margin({ left: 7, bottom: 10 })
}

@Extend(Text)
function textContentStyle() {
  .fontSize(12)
  .fontColor('#000000')
  .fontWeight(400)
}