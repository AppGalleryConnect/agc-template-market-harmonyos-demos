import { ConfirmOrderRouter, Constants, MyCarModel, RouterMap } from 'common/Index'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { Decimal } from '@kit.ArkTS'

@ComponentV2
export struct MyCarComp {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Param @Require isRest: Boolean
  @Param @Require showCarList: Boolean
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel) as MyCarModel
  @Event changeCarPanel: (value: boolean) => void = (value) => {
  };

  @Computed
  get myCar() {
    return this.myCarModel.myCar
  }

  @Computed
  get carBtnName() {
    if (this.isRest) {
      return $r('app.string.store_rest')
    } else {
      return $r('app.string.place_order')
    }
  }

  @Computed
  get totalMoney() {
    let totalMoney: number = 0
    this.myCarModel.carCheck.forEach(item => {
      let carGoodInfo = this.myCarModel.myCar.carGoods?.find(carGood=> carGood.id === item)
      if (carGoodInfo) {
        totalMoney = new Decimal(carGoodInfo.money).mul(carGoodInfo.num).add(totalMoney).toNumber()
      }
    })
    return totalMoney
  }

  build() {
    Row() {
      Row() {
        Badge({
          count: this.myCarModel.carCheck.length ?? 0,
          style: { fontSize: 10, badgeSize: 14 },
        }) {
          Image($r('app.media.ic_buy_car')).width(36)
        }

        Text() {
          Span($r('app.string.total_price'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(22)
          Span($r('app.string.currency_symbol'))
            .fontSize(8)
            .fontWeight(FontWeight.Medium)
            .fontColor('#486602')
            .lineHeight(14)
          Span(`${Number(this.totalMoney)}`)
            .fontSize(16)
            .fontColor('#486602')
            .lineHeight(20)
            .fontWeight(FontWeight.Bold)
        }.margin({ left: 16 })

      }.layoutWeight(1).onClick(() => {
        this.changeCarPanel(!this.showCarList)
      })


      Button(this.carBtnName)
        .height(32)
        .fontSize(14)
        .fontColor($r('sys.color.white'))
        .backgroundColor($r('app.color.mainColor'))
        .padding({
          left: 11,
          right: 11,
          top: 6,
          bottom: 6,
        })
        .onClick(() => {
          if (this.isRest) {
            promptAction.showToast({ message: $r('app.string.store_rest') })
          } else if (!this.myCar.carGoods?.length || !this.myCarModel.carCheck.length) {
            promptAction.showToast({ message: $r('app.string.need_goods') })
          } else {
            let carGoodsSelect = this.myCar.carGoods
            if (this.myCarModel.carCheck?.length) {
              carGoodsSelect = this.myCar.carGoods.filter(item => this.myCarModel.carCheck?.includes(item.id))
            }
            if (!carGoodsSelect.length) {
              promptAction.showToast({ message: $r('app.string.car_empty_toast') })
              return
            }
            // 下单后收起购物车列表
            this.changeCarPanel(false)
            this.pageStack.pushPathByName(RouterMap.CONFIRM_ORDER_PAGE,
              { carGoods: carGoodsSelect } as ConfirmOrderRouter)
          }
        })
    }
    .width(Constants.FULL_SIZE)
    .height(48)
    .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .shadow({
      radius: 4,
      color: '#0D000000',
      offsetX: 0,
      offsetY: -4,
    })
  }
}