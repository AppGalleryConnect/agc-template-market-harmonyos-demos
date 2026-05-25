import { minorsProtection } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { MinorsMode } from '../model/MinorsModel';
import { TCRouter } from '../comp/TCRouter';

const TAG: string = 'testTag'
/*
  未成年模式状态监听、获取类
 */
export class MinorsProtectionUtils {
  // 订阅者信息
  private static subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_MINORSMODE_ON,
      commonEventManager.Support.COMMON_EVENT_MINORSMODE_OFF]
  };
  private static subscriber: commonEventManager.CommonEventSubscriber | undefined;
  private static minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

  // 创建订阅者
  public static createSubscriber() {
    commonEventManager.createSubscriber(MinorsProtectionUtils.subscribeInfo)
      .then((commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
        // 这里获取到commonEventSubscriber对象需要暂存，用于后续事件回调。不可直接使用，否则会出现事件回调不生效的情况
        MinorsProtectionUtils.subscriber = commonEventSubscriber;
        // 订阅公共事件
        commonEventManager.subscribe(MinorsProtectionUtils.subscriber,
          (error: BusinessError, data: commonEventManager.CommonEventData) => {
            if (error) {
              hilog.error(0x0000, TAG, `Failed to subscribe. Code: ${error.code}, message: ${error.message}`);
            }
            if (data.event === commonEventManager.Support.COMMON_EVENT_MINORSMODE_ON) {
              // 订阅到开启事件，可以调用获取年龄段的接口，根据年龄段刷新内容展示，同时如开发者有缓存年龄段或未成年人模式开启状态，则需要刷新缓存
              MinorsProtectionUtils.minorsMode.isMinorsMode = true
            }
            if (data.event === commonEventManager.Support.COMMON_EVENT_MINORSMODE_OFF) {
              // 订阅到关闭事件，关闭当前应用的未成年人模式，刷新应用内容展示，取消年龄限制，如开发者有缓存未成年人模式开启状态，则需要刷新缓存
              MinorsProtectionUtils.minorsMode.isMinorsMode = false
            }
          });
      })
      .catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `Failed to subscribe. Code: ${error.code}, message: ${error.message}`);
      });
  }

  public static getMinorsMode(): boolean {
    if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
      try {
        if (minorsProtection.supportMinorsMode()) {
          const minorsProtectionInfo: minorsProtection.MinorsProtectionInfo =
            minorsProtection.getMinorsProtectionInfoSync();
          // 获取未成年人模式开启状态
          const minorsProtectionMode: boolean = minorsProtectionInfo.minorsProtectionMode;
          // 如开发者有频繁使用到未成年人模式开启状态，这里则需缓存未成年人模式开启状态
          hilog.info(0x0000, TAG,
            `Succeeded in getting minorsProtectionMode is: ${minorsProtectionMode.valueOf()}`);
          return minorsProtectionMode
        } else {
          hilog.info(0x0000, TAG,
            'The current device environment does not support the youth mode, please check the current device environment.');
          return false
        }
      } catch (error) {
        hilog.error(0x0000, TAG,
          `Failed to invoke supportMinorsMode or getMinorsProtectionInfoSync. errCode: ${error.code},
      errMessage: ${error.message}`);
        return false
      }
    } else {
      hilog.info(0x0000, TAG,
        'The current device does not support the invoking of the getMinorsProtectionInfoSync interface.');
      return false
    }
  }

  public static openMinorsMode(ctx: UIContext) {
    if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
      try {
        if (minorsProtection.supportMinorsMode()) {
          // 系统未开启未成年模式，开启系统的未成年模式
          minorsProtection.leadToTurnOnMinorsMode(ctx.getHostContext())
            .then(() => {
              // 接口调用完成，如需显示弹窗，请在此处处理
              TCRouter.pop();
            })
            .catch((error: BusinessError<Object>) => {
              hilog.error(0x0000, TAG,
                `Failed to leadToTurnOnMinorsMode. Code: ${error.code}, message: ${error.message}`);
            });
        } else {
          hilog.info(0x0000, TAG,
            'Youth Mode is not supported on this device. Please check your system settings or device compatibility.');
        }
      } catch (error) {
        hilog.error(0x0000, TAG,
          `Failed to invoke supportMinorsMode. errCode: ${error.code}, errMessage: ${error.message}`);
      }
    } else {
      hilog.info(0x0000, TAG,
        'The current device does not support the invoking of the leadToTurnOnMinorsMode interface.');
    }
  }

  public static closeMinorsMode(ctx: UIContext) {
    if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
      try {
        if (minorsProtection.supportMinorsMode()) {
          // 此示例为代码片段，实际需在自定义组件实例中使用，以获取UIContext对象作为函数入参
          minorsProtection.leadToTurnOffMinorsMode(ctx.getHostContext())
            .then(() => {
              // 接口调用完成，如需显示弹窗，请在此处处理
              TCRouter.pop();
            })
            .catch((error: BusinessError<Object>) => {
              hilog.error(0x0000, TAG,
                `Failed to leadToTurnOffMinorsMode. Code: ${error.code}, message: ${error.message}`);
            });
        } else {
          hilog.info(0x0000, TAG,
            'The current device environment does not support the youth mode, please check the current device environment.');
        }
      } catch (error) {
        hilog.error(0x0000, TAG,
          `Failed to invoke supportMinorsMode. errCode: ${error.code}, errMessage: ${error.message}`);
      }
    } else {
      hilog.info(0x0000, TAG,
        'The current device does not support the invoking of the leadToTurnOffMinorsMode interface.');
    }
  }
}