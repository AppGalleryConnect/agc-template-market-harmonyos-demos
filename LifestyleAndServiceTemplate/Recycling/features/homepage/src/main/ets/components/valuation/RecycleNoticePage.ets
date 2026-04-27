import { ProtocolWebView } from 'common'
import { phoneRouterControl } from 'oh_router'
import { ProtocolData } from 'person'

@Builder
export function RecycleNoticePageBuilder() {
  RecycleNoticePage()
}

@ComponentV2
export struct RecycleNoticePage {
  build() {
    NavDestination() {
      Column() {
        ProtocolWebView({ content: ProtocolData.recycleProtocol })
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#ffffff')
    .hideToolBar(false)
    .padding({ top: 44 })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
