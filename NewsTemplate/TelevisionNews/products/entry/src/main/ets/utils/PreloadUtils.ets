import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2 } from '@kit.ArkUI';
import { cloudFunction, cloudResPrefetch } from '@kit.CloudFoundationKit';
import { Constants, PreloadInfo, PreloadStatus } from 'lib_common';
import { AvModel } from 'lib_tv_apis';

const TAG = '[PreloadUtils]'

export class PreloadUtils {
  public static functionPreload() {
    try {
      cloudResPrefetch.getPrefetchResult(cloudResPrefetch.PrefetchMode.INSTALL_PREFETCH)
        .then((data: cloudResPrefetch.PrefetchResult) => {
          UtilLog.info(0x0000, TAG,
            `Succeeded in getting install prefetch data, result: ${JSON.stringify(data.result)}`);
          PreloadUtils.initPreload(data.result as Record<string, AvModel[]>);
        }).catch((err: BusinessError) => {
        UtilLog.error(0x0000, TAG,
          `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
        // 使用原有方式获取应用数据
        PreloadUtils.functionNormal();
      })
    } catch (e) {
      PreloadUtils.initPreload()
    }
  }

  public static functionNormal() {
    try {
      let promise = cloudFunction.call({
        name: 'television-preload',
        timeout: Constants.REQUEST_TIME_OUT,
        loadMode: cloudFunction.LoadMode.NORMAL,
      });
      promise.then((data: cloudFunction.FunctionResult) => {
        UtilLog.info(0x0000, TAG, 'call function successfully');
        PreloadUtils.initPreload(data.result as Record<string, AvModel[]>);
      }).catch((err: Error) => {
        UtilLog.error(0x0000, TAG, 'fail to call function: %{public}s', err.message);
        PreloadUtils.initPreload();
      });
    } catch (e) {
      UtilLog.error(0x0000, TAG, 'fail to call function.', e);
      PreloadUtils.initPreload();
    }
  }

  public static initPreload(result?: Record<string, AvModel[]>) {
    let preloadInfo: PreloadInfo = AppStorageV2.connect<PreloadInfo>(PreloadInfo, () => new PreloadInfo())!;
    if (result) {
      if (result.televisionList?.length) {
        preloadInfo.data = result.televisionList
        preloadInfo.status = PreloadStatus.SUCCESS
        return
      }
    }
    preloadInfo.status = PreloadStatus.FAILED
  }
}