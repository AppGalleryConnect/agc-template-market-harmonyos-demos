import { pasteboard } from '@kit.BasicServicesKit';
import { FileBaseInfo } from 'cloud_file_base';
import { ShareDetailRowViewInfoViewModel } from '../viewmodel/ShareDetailRowViewInfoViewModel';

@ComponentV2
export struct CopyView {
  @Event shareAction: () => void = () => {
  }
  @Param @Require fileInfo: FileBaseInfo
  @Param @Require shareExtureInfoVM: ShareDetailRowViewInfoViewModel

  @Local isSetUseFullTime: boolean = false
  @Param subTitle: string = ''
  @Param title: string = ''
  @Param change: boolean = false

  build() {
    Row() {
      Column({ space: 3 }) {
        Text(this.subTitle)
          .font({
            size: $r('sys.float.Body_S'),
          })
          .height(13)
          .textAlign(TextAlign.Center)
          .fontColor($r('sys.color.font_tertiary'))

        Text(this.title)
          .textAlign(TextAlign.Center)
          .height(18)
          .fontColor('#B2000000')
          .font({
            size: $r('sys.float.Body_L'),
            weight: FontWeight.Medium
          })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('复制')
        .textAlign(TextAlign.End)
        .font({ size: $r('sys.float.Body_M'), })
        .height(15)
        .fontColor('#FF2FAFFF')
        .onClick(() => {
          copyPastBoard(this.getUIContext(), this.title, '提取码复制成功！')
        })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(60)
  }
}

export async function copyPastBoard(context: UIContext, content: string, tipString: string) {
  try {
    let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
    // 获取系统剪贴板将数据写入
    let systemPasteboard = pasteboard.getSystemPasteboard();
    await systemPasteboard.setData(data);
    showToast(context, tipString)
  } catch (e) {
  }
}

function showToast(uiContext: UIContext, message: string) {
  uiContext.getPromptAction().showToast({
    textColor: $r('sys.color.font_on_primary'),
    message: message,
    duration: 2000,
    backgroundColor: '#CC202C3B',
    bottom: 136 + 24,
    backgroundBlurStyle: BlurStyle.NONE
  })
}