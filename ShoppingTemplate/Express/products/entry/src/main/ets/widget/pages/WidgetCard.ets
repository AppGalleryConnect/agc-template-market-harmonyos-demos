import { IOrder } from 'lib_foundation';

@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('productList') productList: IOrder[] = []
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';

  build() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.startIcon'))
            .width(20)
            .height(20)
            .margin({ right: 8 })
          Text('物流信息')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }
        .margin({ bottom: 12 })

        ForEach(this.productList, (item: IOrder) => {
          Row() {
            Text() {
              Span(item.sendAddress.city)
              Span('-')
              Span(item.getAddress.city)
            }
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          }
          .margin({ bottom: 12 })

          Text('正在发往' + item.getAddress.city)
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ bottom: 17 })
          Button('查询进度')
            .width(126)
            .controlSize(ControlSize.SMALL)
            .backgroundColor(Color.White)
            .fontSize($r('sys.float.Body_M'))
            .fontColor('#317AF7')
            .fontWeight(FontWeight.Regular)
            .onClick(() => {
              postCardAction(this, {
                action: this.actionType,
                abilityName: this.abilityName,
                params: {
                  id: item.id,
                },
              });
            });
        }, (item: IOrder) => JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向
        repeating: true, // 渐变颜色是否重复
        colors: [[0xEFF5FF, 0.0], [0xEFF5FF, 0.24], [0x8BAFF0, 1]], // 数组末尾元素占比小于1时满足重复着色效果
      })
    }
    .height('100%')
  }
}