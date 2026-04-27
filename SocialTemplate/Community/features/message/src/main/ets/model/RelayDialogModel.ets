import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ChatContentSingleModel, ChatConversationType } from 'chat_window';
import { CMChatGroupInfo } from 'instant_messaging';
import { SearchContactModel } from '../viewmodel/SearchContactModel';

export class RelayDialogModel {
  title: string = '发送给'
  type: number = ChatConversationType.CHAT_GROUP //发送目标类型，是个人还是群组
  groupInfoVM?: CMChatGroupInfo
  contactVM?: SearchContactModel
  chatVM: ChatContentSingleModel = new ChatContentSingleModel()
  ctx?: UIContext
  contentNode?: ComponentContent<Object>
  options: promptAction.BaseDialogOptions =
    {
      alignment: DialogAlignment.Bottom,
      maskColor: '#80000000',
      transition: TransitionEffect.IDENTITY,
      isModal: true
    }
  cancelCallBack?: () => void
  sureCallBack?: () => void

  initDialog(ctx: UIContext, contentNode: ComponentContent<Object>) {
    this.ctx = ctx
    this.contentNode = contentNode
  }

  openDialog() {
    if (this.contentNode !== null) {
      this.ctx?.getPromptAction()
        .openCustomDialog(this.contentNode, this.options)
    }
  }

  closeDialog() {
    if (this.contentNode !== null) {
      this.ctx?.getPromptAction()
        .closeCustomDialog(this.contentNode)
    }
  }
}