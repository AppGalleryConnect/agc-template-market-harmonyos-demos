import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';
import { ChatContentSingleModel } from 'chat_base';
import { Params, POP_MENU_TYPE } from '../model/BubbleMsgModel';

export class PromptActionClass {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions = { alignment: DialogAlignment.TopStart, offset: { dx: 0, dy: 0 } }

  static setContext(context: UIContext) {
    PromptActionClass.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionClass.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionClass.options = options;
  }

  static openDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .openCustomDialog(PromptActionClass.contentNode, PromptActionClass.options)
    }
  }

  static closeDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .closeCustomDialog(PromptActionClass.contentNode)
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .updateCustomDialog(PromptActionClass.contentNode, options)
    }
  }

  //关闭气泡弹窗
  static closePop = () => {
  }
  //气泡菜单点击事件
  static menuClick = (_chatVM: ChatContentSingleModel, _type: POP_MENU_TYPE) => {
  }
  static getDeviceType: () => number = () => {
    return -1
  }
  static getVideoMutyStatus: () => boolean = () => {
    return false
  }

  static initBuilder(width: number | string, height: number | string, dx: number | string, dy: number | string,
    chatVM: ChatContentSingleModel, promptWrap:WrappedBuilder<Params[]>) {
    const contentNode: ComponentContent<Object> =
      new ComponentContent(PromptActionClass.ctx, promptWrap, new Params(width, height, chatVM));
    PromptActionClass.setContentNode(contentNode)

    const options: promptAction.BaseDialogOptions =
      {
        alignment: DialogAlignment.TopStart,
        offset: { dx: dx, dy: dy },
        maskColor: '#00000000',
        transition: TransitionEffect.IDENTITY,
        isModal: false,
        onWillAppear: () => {

        },
        onWillDisappear: () => {
          PromptActionClass.closePop()
        }
      }
    PromptActionClass.setOptions(options)
  }
}