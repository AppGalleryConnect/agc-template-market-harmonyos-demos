import { Constants, NavHeaderTitleBar } from 'lib_common'
import { AvModel } from 'lib_tv_apis'
import { SubscribeList } from '../components/SubscribeList'
import { SubscribeViewModel } from '../viewmodels/SubscribeVM'

@Builder
export function SubscribePageBuilder() {
  SubscribePage()
}

@ComponentV2
export struct SubscribePage {
  @Local vm: SubscribeViewModel = new SubscribeViewModel()

  @Builder
  rightPartBuilder() {
    Button('一键取消')
      .fontColor(this.vm.hasSubscribe ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .height(40)
      .enabled(this.vm.hasSubscribe)
      .onClick(() => {
        this.vm.cancelSubscribeAll()
      })
  }

  build() {
    NavDestination() {
      NavHeaderTitleBar({
        title: '我的订阅',
        fontSize: 20,
        needPadding: true,
      })
      Row() {
        Blank()
        this.rightPartBuilder()
      }
      .width(Constants.FULL_PERCENT)
      .margin({ top: 12, right: 12 })

      SubscribeList({
        vm: this.vm,
      })
    }
    .onReady(async () => {
      this.vm.init()
    })
    .onResult((result: AvModel) => {
      if (result) {
        this.vm.setSubscribe(result)
      }
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}