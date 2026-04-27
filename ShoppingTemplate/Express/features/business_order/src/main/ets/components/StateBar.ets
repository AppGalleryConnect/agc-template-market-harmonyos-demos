import { OrderStatus, OrderType } from 'lib_foundation'
import { QueryPageVM } from '../viewModels/QueryPageVM'

@ComponentV2
export struct StateBar {
  vm: QueryPageVM = QueryPageVM.instance
  controller: TextInputController = new TextInputController()

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Button(`寄件${this.vm.sendCount}`)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.selectedIndex === 0 ? Color.White : $r('sys.color.font_primary'))
        .backgroundColor(this.vm.selectedIndex === 0 ? '#0A59F7' : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.selectedIndex = 0
          this.vm.type = OrderType.SEND
          this.vm.status = OrderStatus.SUCCESS
          if (this.vm.userInfoModel.isLogin) {
            this.vm.getOrderList()
          }
        })
      Button(`收件${this.vm.getCount}`)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.selectedIndex === 1 ? Color.White : $r('sys.color.font_primary'))
        .backgroundColor(this.vm.selectedIndex === 1 ? '#0A59F7' : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.selectedIndex = 1
          this.vm.type = OrderType.RECEIVE
          this.vm.status = OrderStatus.SUCCESS
          if (this.vm.userInfoModel.isLogin) {
            this.vm.getOrderList()
          }
        })
      Button(`待支付${this.vm.pendingCount}`)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.selectedIndex === 2 ? Color.White : $r('sys.color.font_primary'))
        .backgroundColor(this.vm.selectedIndex === 2 ? '#0A59F7' : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.selectedIndex = 2
          this.vm.type = OrderType.ALL
          this.vm.status = OrderStatus.DO_ING
          if (this.vm.userInfoModel.isLogin) {
            this.vm.getOrderList()
          }
        })
      Select(this.vm.selectData)
        .value('筛选')
        .font({ size: $r('sys.float.Body_L'), weight: 500 })
        .fontColor($r('sys.color.font_primary'))
        .selectedOptionFont({ size: $r('sys.float.Body_L'), weight: 400 })
        .optionFont({ size: $r('sys.float.Body_L'), weight: 400 })
        .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
        .optionWidth(200)
        .optionHeight(300)
        .onSelect((index: number, value: string) => {
          this.vm.selectedExpressStatus = value
          if (this.vm.userInfoModel.isLogin) {
            this.vm.getOrderList()
          }
        })
    }
    .width('100%')
    .margin({ bottom: 18 })
  }
}