import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { SafeJson, WindowUtil } from 'lib_foundation';

const TAG: string = '[PointsUtil]';

export class PointsUtil {
  public static copyText(text: string) {
    try {
      const pasteboardData = pasteboard.createData(
        pasteboard.MIMETYPE_TEXT_PLAIN,
        text
      );
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard
        .setData(pasteboardData)
        .then(() => {
          WindowUtil.toast('复制成功!');
        })
        .catch((err: BusinessError) => {
          WindowUtil.toast('复制失败!');
          SafeJson.jsonStringify(err);
        });
    } catch (err) {
      WindowUtil.toast('复制失败!');
      SafeJson.jsonStringify(err);
    }
  }
}
