import { Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { AppLinkingRouter } from '../model/AppLinkingModel';
import { Logger } from '@hw-agconnect/ui-base';

const TAG = '[WantUtils]';

const SOURCE_FORM_CARD: string = 'FormCard';
/**
 * 应用want处理工具类
 */
export class WantUtils {

  public static handleAppLinkingWant(want: Want) {
    /**
     * 处理want中获取传入的链接信息
     * 例如传入的url为：https://linking.xiaobingtang.cn/BookRead?id=1
     */
    const uri = want?.uri;
    if (uri) {
      try {
        const urlObject = url.URL.parseURL(uri);
        const bookId = urlObject.params.get('id');
        if (urlObject.pathname.includes('BookRead') && bookId) {
          const appLinkRouter: AppLinkingRouter =
            AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
          appLinkRouter.id = new Date().getTime();
          appLinkRouter.bookId = bookId;
        }
        Logger.info(TAG, `Success to handle applinking want. pathname: ${urlObject.pathname}, bookId: ${bookId}`)
      } catch (e) {
        Logger.error(TAG, `Failed to handle applinking want. uri: ${uri}, Code: ${e.code}, message: ${e.message}`);
      }
    }
  }
}