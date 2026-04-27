import { commonEventManager } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const KEY_REWARD_DATA = 'reward_ad_data';
const KEY_REWARD_STATUS = 'reward_ad_status';

const TAG = '[RewardAdStatusHandler]'

@ObservedV2
export class RewardAdStatusHandler {
  // 广告状态
  @Trace status: string = '';
  private static _instance: RewardAdStatusHandler;
  // 用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;

  public static get instance() {
    if (RewardAdStatusHandler._instance) {
      return RewardAdStatusHandler._instance;
    }
    RewardAdStatusHandler._instance = new RewardAdStatusHandler();
    return RewardAdStatusHandler._instance;
  }

  // 订阅方法，需要在每次展示广告前调用
  public registerPPSReceiver(): void {
    if (this.subscriber) {
      this.unRegisterPPSReceiver();
    }
    // 订阅者信息
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['com.huawei.hms.pps.action.PPS_REWARD_STATUS_CHANGED'],
      // publisherBundleName被设置为"com.huawei.hms.adsservice"，表示只有来自该包名的事件才会被订阅者接收和处理。
      // 如果没有明确声明publisherBundleName，那么订阅者可能会收到来自其它包名的伪造事件，从而导致安全性问题或误导。
      publisherBundleName: 'com.huawei.hms.adsservice',
    };
    // 创建订阅者回调
    try {
      commonEventManager.createSubscriber(subscribeInfo, (err: BusinessError, commonEventSubscriber:
        commonEventManager.CommonEventSubscriber) => {
        if (err) {
          UtilLog.error(TAG, `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        UtilLog.info(TAG, 'Succeeded in creating subscriber');
        this.subscriber = commonEventSubscriber;
        // 订阅公共事件回调
        commonEventManager.subscribe(this.subscriber, (err: BusinessError, commonEventSubscriber:
          commonEventManager.CommonEventData) => {
          if (err) {
            UtilLog.error(TAG, `Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
          } else {
            UtilLog.info(TAG, 'Succeeded in subscribing data');
            const status: string = commonEventSubscriber?.parameters?.[KEY_REWARD_STATUS];
            this.status = status;
            switch (status) {
              case 'onAdOpen':
                UtilLog.info(TAG, 'Status is onAdOpen');
                break;
              case 'onAdClick':
                UtilLog.info(TAG, 'Status is onAdClick');
                break;
              case 'onAdClose':
                UtilLog.info(TAG, 'Status is onAdClose');
                this.unRegisterPPSReceiver();
                break;
              case 'onAdReward':
                const rewardData: Record<string, string | number> =
                  commonEventSubscriber?.parameters?.[KEY_REWARD_DATA];
                const rewardType: string = rewardData?.rewardType as string;
                const rewardAmount: number = rewardData?.rewardAmount as number;
                UtilLog.info(TAG, `Status is onAdReward. Type is ${rewardType}, Amount is ${rewardAmount}`);
                break;
              case 'onVideoPlayBegin':
                UtilLog.info(TAG, 'Status is onVideoPlayBegin');
                break;
              case 'onVideoPlayEnd':
                UtilLog.info(TAG, 'Status is onVideoPlayEnd');
                break;
              default:
                break;
            }
          }
        });
      });
    } catch (e) {
      UtilLog.error(TAG, `subscribe fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  // 取消订阅
  public unRegisterPPSReceiver(): void {
    commonEventManager.unsubscribe(this.subscriber, (err: BusinessError) => {
      if (err) {
        UtilLog.error(TAG, `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
      } else {
        UtilLog.error(TAG, 'Succeeded in unsubscribing');
        this.subscriber = null;
      }
    });
  }
}