import { ComponentContent } from '@kit.ArkUI';
import { VEPromptAction } from 'video_common';

/**
 * 健康数据输入弹框
 */
export class VELoading {
  static uiContext: UIContext | undefined;
  private constructor() {
  }

  static show(message?: string) {
    VELoading.close();
    if (VEPromptAction.contentNode === undefined) {
      if (VELoading.uiContext) {
        let contentNode = new ComponentContent(VELoading.uiContext, wrapBuilder(buildLoading), message ?? '');
        VEPromptAction.uiContext = VELoading.uiContext;
        VEPromptAction.contentNode = contentNode;
        VEPromptAction.options = {
          alignment: DialogAlignment.Center,
          maskRect: {
            x: '40%',
            y: '45%',
            width: '20%',
            height: '10%'
          },
          maskColor: Color.Transparent,
          autoCancel: false,
          onWillDismiss: (_reason: DismissDialogAction) => {
            VELoading.close();
            return true;
          }
        };
        VEPromptAction.openDialog();
      }
    }
  }

  static close() {
    VEPromptAction.closeDialog();
  }
}

@Builder
function buildLoading(message: string) {
  Column() {
    LoadingProgress()
      .color($r('sys.color.icon_secondary'))
      .width(40)
      .height(40)

    if (message.length > 0) {
      Text(message)
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
  }.width(message.length > 0 ? 74 : 60)
  .height(message.length > 0 ? 74 : 60)
  .backgroundColor(Color.Gray)
  .borderRadius(6)
  .padding(6)
}