import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserInfo } from './UserInfo';
import { router } from '@kit.ArkUI';
import { SignInClass } from './SignInModel';


const KEY_REWARD_DATA = 'reward_ad_data';
const KEY_REWARD_STATUS = 'reward_ad_status';


export class RewardAdStatusHandler {
  // 用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
  private bookFinish: number = AppStorage.get('bookFinished') as number

  // 订阅方法，需要在每次展示广告前调用
  public registerPPSReceiver(item: SignInClass): void {
    if (this.subscriber) {
      this.unRegisterPPSReceiver();
    }
    // 订阅者信息
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['com.huawei.hms.pps.action.PPS_REWARD_STATUS_CHANGED'],
      // publisherBundleName被设置为"com.huawei.hms.adsservice",这意味着只有来自该包名的事件才会被订阅者接受和处理。
      // 如果没有明确声明publisherBundleName，那么订阅者可能会收到来自其它包名的伪造事件，从而导致安全性问题或误导。
      publisherBundleName: 'com.huawei.hms.adsservice'
    };
    // 创建订阅者回调
    try {
      commonEventManager.createSubscriber(subscribeInfo, (err: BusinessError, commonEventSubscriber:
        commonEventManager.CommonEventSubscriber) => {
        if (err) {
          hilog.error(0x0000, 'testTag', `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in creating subscriber');
        this.subscriber = commonEventSubscriber;
        // 订阅公共事件回调
        if (!this.subscriber) {
          hilog.warn(0x0000, 'testTag', 'Need create subscriber');
          return;
        }
        commonEventManager.subscribe(this.subscriber, (err: BusinessError, commonEventSubscriber:
          commonEventManager.CommonEventData) => {
          if (err) {
            hilog.error(0x0000, 'testTag', `Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
          } else {
            hilog.info(0x0000, 'testTag', 'Succeeded in subscribing data');
            const status: string = commonEventSubscriber?.parameters?.[KEY_REWARD_STATUS];
            switch (status) {
              case AdStatus.AD_OPEN:
                hilog.info(0x0000, 'testTag', 'Status is onAdOpen');
                break;
              case AdStatus.AD_CLICKED:
                hilog.info(0x0000, 'testTag', 'Status is onAdClick');
                break;
              case AdStatus.AD_CLOSED:
                hilog.info(0x0000, 'testTag', 'Status is onAdClose');
                this.unRegisterPPSReceiver();
                break;
              case AdStatus.AD_REWARDED:
                const rewardData: Record<string, string | number> =
                  commonEventSubscriber?.parameters?.[KEY_REWARD_DATA];
                const rewardType: string = rewardData?.rewardType as string;
                const rewardAmount: number = rewardData?.rewardAmount as number;
                item.isLookAD = true
                hilog.info(0x0000, 'testTag', `Status is onAdReward. Type is ${rewardType}, Amount is ${rewardAmount}`);
                break;
              case AdStatus.AD_VIDEO_START:
                hilog.info(0x0000, 'testTag', 'Status is onAdVideoStart');
                break;
              case AdStatus.AD_COMPLETED:
                hilog.info(0x0000, 'testTag', 'Status is onAdCompleted');
                try {
                  router.replaceUrl({ url: 'components/LookAD' })
                } catch (err) {
                }
                break;
              default:
                break;
            }
          }
        });
      });
    } catch (err) {
    }
  }


  // 取消订阅
  public unRegisterPPSReceiver(): void {
    commonEventManager.unsubscribe(this.subscriber, (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, 'testTag', `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
      } else {
        hilog.info(0x0000, 'testTag', 'Succeeded in unsubscribing');
        this.subscriber = null;
      }
    });
  }
}


enum AdStatus {
  AD_OPEN = 'onAdOpen',
  AD_CLICKED = 'onAdClick',
  AD_CLOSED = 'onAdClose',
  AD_REWARDED = 'onAdReward',
  AD_VIDEO_START = 'onVideoPlayBegin',
  AD_COMPLETED = 'onVideoPlayEnd'
}