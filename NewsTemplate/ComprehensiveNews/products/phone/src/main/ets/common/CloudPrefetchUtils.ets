import { BusinessError } from '@kit.BasicServicesKit';
import { cloudResPrefetch } from '@kit.CloudFoundationKit';
import { CloudRecommendListResult, Logger } from 'lib_common';
import { HomeServiceApi, RequestListData } from 'lib_news_api';

const TAG = '[CloudPrefetchUtils]'

/**
 * 预加载工具类
 */
export class CloudPrefetchUtils {
  /**
   * 获取安装预加载数据
   * 预加载指南：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/cloudfoundation-prefetch-overview
   */
  public static functionPreload() {
    try {
      cloudResPrefetch.getPrefetchResult(cloudResPrefetch.PrefetchMode.INSTALL_PREFETCH)
        .then((data: cloudResPrefetch.PrefetchResult) => {
          let result: RequestListData[] =
            (data.result as CloudRecommendListResult<RequestListData[]>).recommendList as RequestListData[];
          AppStorage.setOrCreate('recommendList', result);
          Logger.info(TAG,
            `Succeeded in getting install prefetch data, result: ${JSON.stringify(data.result)}`);
        }).catch(async (err: BusinessError) => {
        Logger.error(TAG, `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
        // 使用原有方式获取应用数据
        let recommendList = await HomeServiceApi.queryHomeRecommendList('recommend');
        AppStorage.setOrCreate('recommendList', recommendList);
      });
    } catch (err) {
      Logger.error(TAG, `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
    }
  }
}