import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ChatUtil } from '../utils/ChatUtil';
import { ChatBaseRow } from './ChatBaseRow';

/**
 * 自定义消息（纯文本、表情、超链接等）
 */
@ComponentV2
export struct ChatTextRow {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require keyId: string;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local strArr: string[] = [];
  @Local urlArr: string[] = [];

  aboutToAppear(): void {
    this.resetKeyId();
  }

  @Monitor('keyId')
  resetKeyId() {
    let content = this.chatVM.textElem;
    ChatUtil.splitUrls(content, (array: string[][]) => {
      this.strArr = array[0];
      this.urlArr = array[1];
    });
  }

  @Builder
  render() {
    Text() {
      ForEach(this.strArr, (str: string, index: number) => {
        Span(str);
        if (this.urlArr.length > index) {
          Span(this.urlArr[index])
            .fontColor(this.chatVM.isOwner ? Color.White : '#0A59F7')
            .decoration({ type: TextDecorationType.Underline, color: this.chatVM.isOwner ? Color.White : '#0A59F7' })
            .onClick(() => {
              let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
              ChatUtil.openUrlToWeb(context, this.urlArr[index]);
            })
        }
      }, (str: string, index: number) => str + index);
    }
    .fontSize($r('sys.float.Body_M'))
    .fontWeight(FontWeight.Regular)
    .fontColor(this.chatVM.isOwner ? Color.White : Color.Black)
    .lineHeight($r('app.float.vp_20'))
    .maxLines(-1)
    .constraintSize({
      minWidth: $r('app.float.vp_14'),
      maxWidth: this.CustomChatMaxWidth,
      minHeight: $r('app.float.vp_20'),
      maxHeight: Infinity
    })
  }

  build() {
    ChatBaseRow({
      childBuilder: () => {
        this.render();
      },
      chatVM: this.chatVM,
      onChatAvatarClick: this.onChatAvatarClick
    })
  }

  @Computed
  get CustomChatMaxWidth() {
    let uiContext = this.getUIContext();
    let widthBreakpoint: WidthBreakpoint = uiContext.getWindowWidthBreakpoint()
    let tempSingle = this.chatBreakpoint.getColumnWidth(uiContext);
    let tempTotal = 0;

    if (widthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
      // 非阔折叠的直板设备,折叠屏折叠态，阔折叠的直板设备
      tempTotal = tempSingle * 4 + 36;
    } else if (widthBreakpoint === WidthBreakpoint.WIDTH_MD) {
      // 折叠屏展开态
      tempTotal = tempSingle * 5 + 48;
    } else {
      tempTotal = tempSingle * 4 + 36;
    }
    //头像 36 + 头像和消息间隙 8 + 白色切角背景12
    return tempTotal - 56;
  }
}