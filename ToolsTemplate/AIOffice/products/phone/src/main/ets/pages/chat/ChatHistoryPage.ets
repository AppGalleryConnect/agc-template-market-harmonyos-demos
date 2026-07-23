import { RouterUtils } from 'lib_common';
import { CopilotHistory } from '../../components/CopilotHistory';
import { NavHeaderBar } from '../../widget/NavHeaderBar';

@Builder
export function ChatHistoryPageBuilder() {
  ChatHistoryPage()
}

@ComponentV2
export struct ChatHistoryPage {
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '历史对话'
        })
        CopilotHistory({
          storeId: 'Chat',
          onClickEvent: (threadId) => {
            RouterUtils.pop(threadId);
          }
        }).padding({ left: 16, right: 16, bottom: 16 })
          .layoutWeight(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
    }.hideTitleBar(true)
  }
}