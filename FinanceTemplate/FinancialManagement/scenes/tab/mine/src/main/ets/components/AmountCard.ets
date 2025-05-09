import { FormatUtil, RouterMap } from 'commonlib'
import { MinePageVM } from '../viewModels/MinePageVM'

@ComponentV2
export struct AmountCard {
  vm: MinePageVM = MinePageVM.instance
  @Local handlePopup: boolean = false

  @Builder
  serviceBuilder(text: string, icon: Resource, url: RouterMap) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .margin({ bottom: 8 })
      Text(text)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .onClick(() => {
      if (this.vm.isLogin) {
        FormatUtil.jumpToNext(url)
      } else {
        FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
      }
    })
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text('总市值(元)')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ right: 4 })
          Image(this.vm.showMoney ? $r('app.media.ic_open_eye') : $r('app.media.ic_eye_closed'))
            .width(16)
            .height(16)
            .onClick(() => {
              this.vm.showMoney = !this.vm.showMoney
            })
        }
        .margin({ bottom: 8 })

        Text(!this.vm.isLogin ? '--' : this.vm.showMoney ? this.vm.userAccount?.positionAmount + '' : '****')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 16 })

        Row() {
          Text('累计收益(元)')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ right: 4 })
          Image($r('app.media.ic_tip'))
            .width(16)
            .height(16)
            .onClick(() => {
              this.handlePopup = !this.handlePopup
            })
            .bindPopup(this.handlePopup, {
              // PopupOptions类型气泡的内容
              builder: this.popupBuilder,
              placement: Placement.Top,
              enableArrow: true,
              targetSpace: '15vp',
              onStateChange: (e) => {
                console.info(JSON.stringify(e.isVisible))
                if (!e.isVisible) {
                  this.handlePopup = false
                }
              }
            })
        }
        .margin({ bottom: 2 })

        Text(!this.vm.isLogin ? '--' : this.vm.showMoney ? this.vm.userAccount?.accumulatedEarnings + '' : '****')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .margin({ bottom: 17 })

      Divider().color($r('sys.color.comp_divider')).margin({ bottom: 15 })

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        this.serviceBuilder('查自选', $r('app.media.ic_self_selection'), RouterMap.MY_REGULAR_CHOICE)
        this.serviceBuilder('查交易', $r('app.media.ic_transaction'), RouterMap.TRANSACTION_RECORD_LIST)
        this.serviceBuilder('查定投', $r('app.media.ic_dollar_cost'), RouterMap.MY_REGULAR_INVESTMENT)
        this.serviceBuilder('其他', $r('app.media.ic_other'), RouterMap.OTHER)
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
    .padding({
      top: 24,
      bottom: 16,
      left: 16,
      right: 16
    })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  popupBuilder() {
    Row({ space: 2 }) {
      Text('现金宝每日计算收益，累计收益是指现金宝账户每日收益的总和。')
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .width(200)
    .padding(8)
  }
}