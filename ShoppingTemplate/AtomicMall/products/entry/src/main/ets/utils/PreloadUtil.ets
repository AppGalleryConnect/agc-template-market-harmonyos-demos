import { BusinessError } from '@kit.BasicServicesKit';
import { cloudResPrefetch } from '@kit.CloudFoundationKit';
import { HomeApis, HomeConfigResp } from 'lib_network';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

const TAG: string = '[PreloadUtil]';

export class PreloadUtil {
  /**
   * 获取安装预加载数据
   * 预加载指南：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/cloudfoundation-prefetch-overview
   */
  public static async getPreloadData(): Promise<HomeConfigResp | undefined> {
    let res: HomeConfigResp | undefined = undefined;
    try {
      await cloudResPrefetch.getPrefetchResult(cloudResPrefetch.PrefetchMode.INSTALL_PREFETCH)
        .then((data: cloudResPrefetch.PrefetchResult) => {
          res = data.result as HomeConfigResp;
          Logger.info(TAG,
            `Succeeded in getting install prefetch data, result: ${JSON.stringify(data.result)}`);
        }).catch(async (err: BusinessError) => {
          Logger.error(TAG, `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
        });
    } catch (err) {
      Logger.error(TAG, `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
    }
    if (!res) {
      // 使用原有方式获取应用数据
      res = await HomeApis.getHomeConfig();
    }
    return res;
  }
}