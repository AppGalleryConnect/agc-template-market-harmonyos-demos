import { GiftModel } from '../../models/GiftGroup';
import { deviceInfo } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct Gifts {
  @Require @Param giftData: Array<GiftModel>
  @Local selectedId: number = 0;
  @Event onBack: () => void
  @Event onPay: Function = (item: GiftModel) => {
  }

  @Builder
  giftItem(item: GiftModel) {
    if (this.selectedId !== item.id) {
      Column() {
        Image(item.icon)
          .width(48)
          .height(48)
          .margin({
            top: 12,
            left: 14,
            right: 14,
            bottom: 4
          })

        Text(item.name)
          .width(60)
          .height(15)
          .fontSize(12)
          .fontWeight(400)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: 2 })

        Text(`${item.price}虚拟币`)
          .width(60)
          .height(14)
          .fontSize(10)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: 12 })
      }
      .height(108)
      .width(76)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.selectedId = item.id
      })
    } else {
      Column() {
        Image(item.icon)
          .width(48)
          .height(48)
          .margin({
            top: 12,
            left: 14,
            right: 14,
            bottom: 4
          })

        Text(`${item.price}虚拟币`)
          .width(60)
          .height(14)
          .fontSize(10)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)

        Button('赠送')
          .width(76)
          .height(28)
          .backgroundColor('#E84026')
          .fontWeight(700)
          .margin('6px 26px')
          .type(ButtonType.Normal)
          .borderRadius({
            topLeft: 0,
            topRight: 0,
            bottomLeft: 8,
            bottomRight: 8
          })
          .onClick(() => {
            this.onPay(item)
          })
      }
      .borderRadius(8)
      .height(108)
      .width(76)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
  }

  build() {
    Column() {
      Row() {
        Text('礼物')
          .fontSize(20)
          .fontWeight(700)
          .lineHeight(27)
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .size({ width: 40, height: 40 })
        .onClick(() => {
          this.onBack()
        })
      }
      .width('95%')
      .height(56)
      .margin({ top: 8 })
      .justifyContent(FlexAlign.SpaceBetween)

      Grid() {
        ForEach(this.giftData, (item: GiftModel) => {
          GridItem() {
            this.giftItem(item)
          }
        }, (item: GiftModel) => item.id.toString())
      }
      .height('100%')
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .scrollBar(BarState.Off)
    }
  }
}

