import { Constants, GetMyCarResp } from 'common/Index'
import { promptAction } from '@kit.ArkUI'
import { MustGoodsController } from '../models/MustGoodsController'

@Component
export struct MyCarComp {
  @StorageProp('buyCarMoney') buyCarMoney: number = 0
  @StorageProp('myCar') @Watch('carChange') myCar: GetMyCarResp = new GetMyCarResp()
  @StorageProp('isRest') isRest: boolean = false
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController
  @Consume('orderId') @Watch('change') orderId: string
  @Link showCarList: boolean
  @State buttonStr: Resource = $r('app.string.place_order')

  aboutToAppear(): void {
    this.change()
  }

  carChange() {
    this.mustGoodsCtrl.cleanCar()
    this.myCar.res?.forEach(item => {
      if (item.isMust === Constants.GOODS_MUST) {
        this.mustGoodsCtrl.addIsMust(Number(item.num))
      }
    })
    this.mustGoodsCtrl.change()
  }

  change() {
    if (this.isRest) {
      this.buttonStr = $r('app.string.store_rest')
    } else if (this.orderId) {
      this.buttonStr = $r('app.string.add_good')
    } else {
      this.buttonStr = $r('app.string.place_order')
    }
  }

  build() {
    Row() {
      Row() {
        Badge({
          count: this.myCar.res?.length ?? 0,
          style: { fontSize: 10, badgeSize: 16 },
        }) {
          Image($r('app.media.buy_car')).width(36)
        }

        Text() {
          Span($r('app.string.total_price'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Span($r('app.string.currency_symbol'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.multi_color_09'))
          Span(`${Number(this.myCar.money)}`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.multi_color_09'))
            .fontWeight(FontWeight.Medium)
        }.margin({ left: 16 })

      }.layoutWeight(1).onClick(() => {
        this.showCarList = !this.showCarList
      })


      Button(this.buttonStr)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.multi_color_09'))
        .padding({
          left: 11,
          right: 11,
          top: 6,
          bottom: 6,
        })
        .onClick(() => {
          if (this.isRest) {
            promptAction.showToast({ message: $r('app.string.store_rest') })
          } else if (!this.myCar.res?.length) {
            promptAction.showToast({ message: $r('app.string.need_goods') })
          } else if (this.mustGoodsCtrl.isNeedMustGoods) {
            this.mustGoodsCtrl.clickSubmit()
            this.mustGoodsCtrl.goMustGoods()
            promptAction.showToast({ message: $r('app.string.need_must_goods') })
          } else {
            this.showCarList = false
            this.mustGoodsCtrl.clickSubmit()
            this.pageStack.pushPath({ name: 'ConfirmOrderPage' })
          }
        })
    }
    .width(Constants.FULL_SIZE)
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .shadow({
      radius: 4,
      color: '#0D000000',
      offsetX: 0,
      offsetY: -4,
    })
  }
}