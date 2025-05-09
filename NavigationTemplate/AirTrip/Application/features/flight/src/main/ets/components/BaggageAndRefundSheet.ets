

@ComponentV2
export struct BaggageAndRefundSheet {

  build() {
    Column() {
      Scroll() {
        Column({space: 8}) {
          Column({space: 8}) {
            Text('行李额').fontSize(16).fontWeight(FontWeight.Medium)
            Row() {
              Text('成人').fontSize(14)
                .alignSelf(ItemAlign.Stretch)
                .padding({left: 12, right: 12})
                .border({
                  width: {right: 1},
                  color: '#E5E5E5',
                  style: BorderStyle.Solid,
                })
              Column() {
                Text('免费手提行李额   5KG，1件，\n20*40*55CM')
                  .fontSize(14)
                  .padding(12)

                Divider().color('#E5E5E5').width('100%')

                Text('免费托运行李额   20KG，1件，\n40*60*100CM')
                  .fontSize(14)
                  .padding(12)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .border({
              width: 1,
              color: '#E5E5E5',
              style: BorderStyle.Solid,
              radius: 8
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          Column({space: 8}) {
            Text('退票手续费').fontSize(16).fontWeight(FontWeight.Medium)
            Row() {
              Text('成人').fontSize(14)
                .alignSelf(ItemAlign.Stretch)
                .padding({left: 12, right: 12})
                .border({
                  width: {right: 1},
                  color: '#E5E5E5',
                  style: BorderStyle.Solid,
                })
              Column() {
                Text('起飞前    48小时，免费')
                  .fontSize(14)
                  .fontColor($r('sys.color.ohos_id_color_primary'))
                  .padding(12)
                Divider().color('#E5E5E5').width('100%')
                Text('起飞前    24小时，128/人')
                  .fontSize(14)
                  .fontColor($r('sys.color.ohos_id_color_primary'))
                  .padding(12)
                Divider().color('#E5E5E5').width('100%')
                Text('起飞前    12小时，256/人')
                  .fontSize(14)
                  .fontColor($r('sys.color.ohos_id_color_primary'))
                  .padding(12)
                Divider().color('#E5E5E5').width('100%')
                Text('起飞前    4小时，384/人')
                  .fontSize(14)
                  .fontColor($r('sys.color.ohos_id_color_primary'))
                  .padding(12)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .border({
              width: 1,
              color: '#E5E5E5',
              style: BorderStyle.Solid,
              radius: 8
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          Column({space: 8}) {
            Text('签转条件').fontSize(16).fontWeight(FontWeight.Medium)
            Row() {
              Text('成人').fontSize(14)
                .alignSelf(ItemAlign.Stretch)
                .padding({left: 12, right: 12})
                .border({
                  width: {right: 1},
                  color: '#E5E5E5',
                  style: BorderStyle.Solid,
                })
              Column() {
                Text('允许')
                  .fontSize(14)
                  .padding(12)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .border({
              width: 1,
              color: '#E5E5E5',
              style: BorderStyle.Solid,
              radius: 8
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({space: 8}) {
            Text('备注').fontSize(16).fontWeight(FontWeight.Medium)
            Row() {
              Text('成人').fontSize(14)
                .alignSelf(ItemAlign.Stretch)
                .padding({left: 12, right: 12})
                .border({
                  width: {right: 1},
                  color: '#E5E5E5',
                  style: BorderStyle.Solid,
                })
              Text('以上为成人机票退改签费用标准，仅供\n参考，实际以航空公司收取为准')
                .fontSize(14)
                .padding(12)
            }
            .border({
              width: 1,
              color: '#E5E5E5',
              style: BorderStyle.Solid,
              radius: 8
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .height('calc(100% - 30vp)')
    .width('calc(100% - 32vp)')
  }
}