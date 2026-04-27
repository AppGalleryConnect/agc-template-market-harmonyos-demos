import { HeaderView, UserInfo } from 'common'
import { phoneRouterControl } from 'oh_router'
import { SpaceViews } from './SpaceViews'
import { VIPView } from './VIPView'

@ComponentV2
export struct TopView {
  @Param @Require userInfo :UserInfo
  build() {
    Column() {
      HeaderView({
        title: '个人空间',
        clickBackBtn: () => {
          phoneRouterControl.popPage()
        }
      })
        .margin({ top: 24 })

      SpaceViews({userInfo : this.userInfo})
        .margin({ top: 200 })

      VIPView()
        .margin({ top: 12 })
    }
  }
}