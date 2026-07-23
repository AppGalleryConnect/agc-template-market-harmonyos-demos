import { AvModel } from 'lib_news_api'
import { NavHeaderBar } from 'lib_widget'
import { MediaController, AudioService } from 'module_audioplayer'
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
      .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .height(40)
      .enabled(this.vm.hasSubscribe)
      .onClick(() => {
        this.vm.cancelSubscribeAll()
      })
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '我的订阅',
        showBackBtn: true,
        isSubTitle: false,
        rightPartBuilder: () => {
          this.rightPartBuilder()
        },
      })
      SubscribeList({
        vm: this.vm,
        loading: this.vm.loadingModel.loading,
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
    .onShown(() => {
      if (this.vm.settingInfo.network.enableAudioSub) {
        AudioService.createSubWindow(this.getUIContext())
      } else {
        MediaController.pause()
      }
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}