import { cloudFunction } from '@kit.CloudFoundationKit';
import { CourseInfo, StoreConfig, StoreInfo } from '../types/Index';
import { Logger } from './Logger';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG = 'PreloadUtil';

interface BaseRet {
  code: number;
  msg: string;
}

interface PreloadResp {
  ret: BaseRet;
  result: StoreConfig;
}

@ObservedV2
export class PreloadResultModel implements StoreConfig {
  @Trace storeInfo: StoreInfo | undefined;
  @Trace courseList: CourseInfo[] = [];
  @Trace banners: ResourceStr[] = [];
}

@ObservedV2
export class PreloadUtil {
  private static _preloadResult: PreloadResultModel =
    PersistenceV2.connect(PreloadResultModel, 'preloadResult', () => new PreloadResultModel())!;

  public static async preload() {
    if (!canIUse('SystemCapability.DeviceCloudGateway.CloudFoundation')) {
      Logger.info(TAG, 'this device cannot use preload service.');
      return;
    }
    let promise = cloudFunction.call({
      name: 'course',
      timeout: 3000, // 获取缓存数据的超时时间
      loadMode: cloudFunction.LoadMode.PRELOAD, // 获取缓存数据必须设置为PRELOAD
    });
    await promise
      .then((funcResult) => {
        const res = funcResult.result as PreloadResp;
        if (res.ret.code === 0) {
          PreloadUtil._preloadResult.banners = res.result.banners ?? [];
          PreloadUtil._preloadResult.courseList = res.result.courseList ?? [];
          PreloadUtil._preloadResult.storeInfo = res.result.storeInfo ?? undefined;
        }
      })
      .catch((err: Error) => {
        Logger.error(TAG, 'fail to get preload cache', err.message);
      });
  }

  public static getPreloadResult(): StoreConfig {
    return PreloadUtil._preloadResult;
  }
}