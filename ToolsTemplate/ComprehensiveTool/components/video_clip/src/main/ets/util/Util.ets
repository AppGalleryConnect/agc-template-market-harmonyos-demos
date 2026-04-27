import { UtilLog } from '@hw-agconnect/util-log';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';

export class Util {
  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(uiContext: UIContext, url: string): string {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('mockImage://')[1];
      const prefixUrl: string = '';
      return `${prefixUrl}${resourceName}`;
    }
    // resources下的资源通过resourceImage://xxx表达
    if (url.startsWith('resourceImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = uiContext.getHostContext()!.resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        UtilLog.error(0xff00, 'Template', `get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return url;
  };

  /**
   * 获取视频资产
   * @param uri
   * @param context
   * @returns
   */
  static async getVideoAsset(uri: string, context: Context) {
    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | null = null;
    try {
      phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    } catch (e) {
      UtilLog.error(`getPhotoAccessHelper failed with error ${e}`)
    }

    // 创建查询条件（通过URI定位视频）
    const predicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('uri', uri);

    // 配置查询字段（仅获取文件大小）
    const fetchOption: photoAccessHelper.FetchOptions = {
      predicates: predicates,
      fetchColumns: [photoAccessHelper.PhotoKeys.SIZE, photoAccessHelper.PhotoKeys.DURATION],
    };

    // 执行查询
    const result = await phAccessHelper?.getAssets(fetchOption);
    const videoAsset = await result?.getFirstObject();
    return videoAsset
  }
}