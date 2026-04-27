import { fileUri } from '@kit.CoreFileKit'
import { ChatInputComponentViewModel } from 'chat_input'
import { RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { BackgroundImageViewPageBuilder } from '../view/BackgroundImageView'
import { CustomActionSheet } from '../view/DialogPage'
import { MessageChatModel } from '../viewmodel/MessageChatModel'

/**
 * 设置聊天背景
 */
export class ChatBackgroundSkillUtil {
  messageChatModel?: MessageChatModel

  /**
   * 设置聊天背景功能方法
   */
  chatBackgroundSkill(context: Context, uIContext: UIContext) {
    this.messageChatModel = new MessageChatModel(uIContext)
    CustomActionSheet.show({
      title: '选择图片',
      sheets: [
        {
          title: '预置背景',
          action: () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.BACK_GROUND_IMAGE_VIEW,
              builder: wrapBuilder(BackgroundImageViewPageBuilder)
            })
          }
        },
        {
          title: '从手机相册选择',
          action: () => {
            let chatInputComponentViewModel: ChatInputComponentViewModel = new ChatInputComponentViewModel()
            chatInputComponentViewModel.selectPhoto(context).then(async (result: string) => {
              //获取图片类中的内容
              const sendContent = await chatInputComponentViewModel.getImageInfo(result)
              let fileUriObject = new fileUri.FileUri(sendContent.pictureUrl);
              //将沙箱里面的URL转换成image组件可以识别的URL
              if (this.messageChatModel) {
                this.messageChatModel.userInfo.chatBgImage = fileUriObject.toString()
              }
            })
          }
        }
      ],
      confirm: {
        value: '取消',
        action: () => {

        }
      },
      cancel: () => {

      }
    })
  }
}