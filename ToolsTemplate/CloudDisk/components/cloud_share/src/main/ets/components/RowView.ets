import { pasteboard } from '@kit.BasicServicesKit';
import { FileBaseInfo } from 'cloud_file_base';
import { ShareDetailRowViewInfoViewModel } from '../viewmodel/ShareDetailRowViewInfoViewModel';

@ComponentV2
export struct RowView {
  @Param @Require fileInfo: FileBaseInfo
  @Param @Require shareExtureInfoVM: ShareDetailRowViewInfoViewModel
  @Event shareAction: () => void = () => {
  }
  @Param change: boolean = false
  @Local isSetUseFullTime: boolean = false
  @Param subTitle: string = ''
  @Param title: string = ''

  build() {
    Row() {
      Column({ space: 3 }) {
        Text(this.subTitle)

          .font({ size: $r('sys.float.Body_S'), })
          .height(13)
          .fontColor($r('sys.color.font_tertiary'))
          .textAlign(TextAlign.Center)

        Text(this.shareExtureInfoVM.usefullTime ? this.shareExtureInfoVM.usefullTime : this.title)
          .height(18)
          .fontColor('#B2000000')
          .textAlign(TextAlign.Center)
          .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('修改')
        .textAlign(TextAlign.End)
        .font({
          size: $r('sys.float.Body_M'),
        })
        .fontColor('#FF2FAFFF')
        .height(15)
        .onClick(() => {
          this.shareAction()
        })
    }
    .height(60)
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}

export async function copyPastBoard(curContext: UIContext, curText: string, tipString: string) {
  try {
    let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, curText);
    // 获取系统剪贴板
    let systemPasteboard = pasteboard.getSystemPasteboard();
    // 将数据写入剪贴板
    await systemPasteboard.setData(data);
    showToast(curContext, tipString)
  } catch (e) {
  }
}

function showToast(uiContext: UIContext, message: string) {
  uiContext.getPromptAction().showToast({
    backgroundColor: '#CC202C3B',
    bottom: 136 + 24,
    backgroundBlurStyle: BlurStyle.NONE,
    message: message,
    duration: 2000,
    textColor: $r('sys.color.font_on_primary')
  })
}