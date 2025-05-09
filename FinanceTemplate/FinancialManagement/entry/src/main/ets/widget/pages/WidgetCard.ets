import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp';

@Entry
@Component
struct WidgetCard {
  readonly ACTION_TYPE: string = 'router';
  readonly ABILITY_NAME: string = 'EntryAbility';
  @LocalStorageProp('productList') productList: IProductItem[] = []

  dateAsCustom(date: Date): string {
    const month = String(date.getMonth() + 1);
    const day = String(date.getDate());
    return `${month}月${day}日`;
  }

  build() {
    Column() {
      Text('我的理财自选')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })
      Text(this.dateAsCustom(new Date()) + '更新')
        .fontSize(10)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 9 })
      ForEach(this.productList, (productItem: IProductItem) => {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Row() {
              Text(productItem.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .margin({ right: 4 })

            Row() {
              Text(productItem.title)
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor('#C15F2F')
            }
            .height(14)
            .padding({ left: 4, right: 4 })
            .borderWidth(1)
            .borderColor('#C15F2F')
            .borderRadius(4)
          }
          .width('75%')

          Column() {
            Text(productItem.annualizedRate + '%')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor('#C15F2F')
            Text(productItem.annualizedCycle)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('25%')
          .alignItems(HorizontalAlign.End)
        }
        .margin({ bottom: 17 })
        .onClick(() => {
          postCardAction(this, {
            action: this.ACTION_TYPE,
            abilityName: this.ABILITY_NAME,
            params: {
              id: productItem.id,
            }
          });
        })
      }, (item: IProductItem[]) => JSON.stringify(item))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })

  }
}