import { Constants, Reduction, SheetHeaderComp, StoreSet } from 'common/Index'

@Component
export struct ShopDiscountComp {
  @Consume('showShopDiscount') showShopDiscount: boolean
  @Consume('storeSet') storeSet: StoreSet
  @Consume('reductionList') reductionList: Array<Reduction>

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
      }.width(Constants.FULL_SIZE).height(Constants.FULL_SIZE).backgroundColor($r('sys.color.mask_fourth'))
      .onClick(() => {
        this.showShopDiscount = false
      })

      Column() {
        SheetHeaderComp({
          title: $r('app.string.shop_discount_title'), close: () => {
            this.showShopDiscount = false
          },
        })

        List({ space: 12 }) {
          ListItem() {
            Row() {
              Image($r('app.media.notice')).width(16)
              Text($r('app.string.new_user_discount', this.storeSet.xyhMoney))
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }

          ForEach(this.reductionList, (reduction: Reduction) => {
            ListItem() {
              Row() {
                Image($r('app.media.notice')).width(16)
                Text(reduction.name)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_secondary'))
                  .margin({ left: 8 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }.padding({ top: 3, bottom: 3 }).layoutWeight(1)
            }
          }, (reduction: Reduction) => JSON.stringify(reduction))
        }
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .padding(12)
        .margin({ top: 8 })
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius({ topLeft: 12, topRight: 12 })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width(Constants.FULL_SIZE)
      .height(328)
      .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, top: 8 })
      .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
      .borderRadius({ topLeft: 32, topRight: 32 })
      .clip(true)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
    }
  }
}