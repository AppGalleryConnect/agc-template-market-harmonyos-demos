import { Params } from '../model/BubbleMsgModel'
import { BubbleMsgComponent } from './BubbleMsgComponent'

@Builder
function promptDialogBuilder(params: Params) {
  Column() {
    BubbleMsgComponent({
      chatVM: params.chatVM
    })
  }
  .width(params.width).height(params.height)
}

export const promptWrap = wrapBuilder(promptDialogBuilder)