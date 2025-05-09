import { FormatUtil, RouterMap } from 'commonlib'
import { ProductInfoVM } from '../../viewModels/ProductInfoVM'
import { emitter } from '@kit.BasicServicesKit'

@ComponentV2
export struct PurchaseBar {
  vm: ProductInfoVM = ProductInfoVM.instance

  build() {
    Column() {
      Row() {
        Text(`剩余可购买额度${this.vm.productInfo ? this.vm.productInfo.remainingPurchaseAmount : 0}元`)
          .fontColor(Color.Orange)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(32)
      .backgroundColor('#FDF0E8')

      Flex({ alignItems: ItemAlign.Center }) {
        Column() {
          Image(!this.vm.isSelected ? $r('app.media.ic_add') : $r('app.media.ic_cancel'))
            .width(24)
            .height(24)
          Text(!this.vm.isSelected ? '加自选' : '取消自选')
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
        }
        .width(60)
        .flexShrink(1)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 16 })
        .onClick(() => {
          if (this.vm.isSelected) {
            this.vm.isSelected = false
            if (this.vm.productInfo) {
              if (this.vm.isLogin) {
                this.vm.deleteProductFromCart(this.vm.productInfo.id)
              } else {
                FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
              }
            }
          } else {
            this.vm.isSelected = true
            if (this.vm.productInfo) {
              if (this.vm.isLogin) {
                this.vm.addProductToCart(this.vm.productInfo.id)
                emitter.emit('refreshCard');
              } else {
                FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
              }
            }
          }
        })

        Row() {
          Row() {
            Text('定投')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#E4480C')
          }
          .width('50%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(228,72,12,0.05)')
          .padding({
            top: 10,
            bottom: 9,
            left: 22,
            right: 21
          })
          .borderRadius({ topLeft: 20, bottomLeft: 20 })
          .onClick(() => {
            if (this.vm.isLogin) {
              FormatUtil.jumpToNext(RouterMap.PURCHASE, { id: this.vm.productInfo?.id, isPurchase: false })
            } else {
              FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
            }
          })

          Row() {
            Text('购买')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .width('50%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#E4480C')
          .padding({
            top: 10,
            bottom: 9,
            left: 21,
            right: 22
          })
          .borderRadius({ topRight: 20, bottomRight: 20 })
          .onClick(() => {
            if (this.vm.isLogin) {
              FormatUtil.jumpToNext(RouterMap.PURCHASE, { id: this.vm.productInfo?.id, isPurchase: true })
            } else {
              FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
            }
          })
        }
        .flexGrow(1)
      }
      .height(56)
      .padding({
        left: 16,
        right: 16
      })
      .margin({ bottom: 28 })

    }
    .width('100%')
    .height(106)
    .backgroundColor(Color.White)
    .position({ bottom: 0 })
    .translate({ x: 0, y: 28 })
  }
}