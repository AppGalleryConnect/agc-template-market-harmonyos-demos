import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

export class CopyBoardUtil {
  private static _instance: CopyBoardUtil;

  public static get instance() {
    if (!CopyBoardUtil._instance) {
      CopyBoardUtil._instance = new CopyBoardUtil();
    }
    return CopyBoardUtil._instance;
  }

  // 复制内容
  public copy(text: string, from: string): void {
    // 创建纯文本内容
    try {
      let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      pasteboard.getSystemPasteboard().setData(pasteData).then(() => {
        promptAction.showToast({ message: `${from}已复制` })
      }).catch((err: BusinessError) => {
      });
    } catch (error) {
    }
  }
}