import { privacyManager } from '@kit.AppGalleryKit';
import { BusinessError, commonEventManager, deviceInfo } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[AppPrivacyUtil]';

@ObservedV2
export class AppPrivacyUtil {
  // todo 配置是否允许展示首页，默认展示
  public readonly CONFIG_SHOW_HOME: boolean = true;
  // 隐私弹框场景下，用户点击同意，会发送此事件。
  private readonly EVENT_ID = 'usual.event.PRIVACY_STATE_CHANGED';
  // 订阅者信息, 用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  private subscriber: commonEventManager.CommonEventSubscriber | undefined = undefined;
  // 事件列表
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [this.EVENT_ID],
  };
  private productMode = deviceInfo.productModel;
  // 协议签署标识
  @Trace public agreeFlag: boolean = false;
  private static _instance: AppPrivacyUtil;

  constructor() {
    this.agreeFlag = this.queryAppPrivacyResult();
    // 适配模拟器
    if (this.productMode === 'emulator') {
      this.agreeFlag = true;
    }
    UtilLog.info(TAG, 'Succeeded in set agreeFlag = ' + this.agreeFlag);
  }

  /**
   * 获取实例
   * @returns
   */
  public static get instance() {
    if (AppPrivacyUtil._instance) {
      return AppPrivacyUtil._instance;
    }
    AppPrivacyUtil._instance = new AppPrivacyUtil();
    return AppPrivacyUtil._instance;
  }

  /**
   * 查询隐私签署状态
   * @returns
   */
  public queryAppPrivacyResult(): boolean {
    try {
      const appPrivacyResults: privacyManager.AppPrivacyResult[] = privacyManager.getAppPrivacyResult();
      UtilLog.info(TAG, 'Succeeded in getting AppPrivacyResult= ' + JSON.stringify(appPrivacyResults));
      if (appPrivacyResults.length) {
        return appPrivacyResults.every(v => v.result === privacyManager.AppPrivacyResultType.FULL_MODE_AGREED);
      }
      // todo 兼容本地调试和云调试，协议列表为空时，作同意处理
      return true;
    } catch (error) {
      UtilLog.error(TAG,
        'GetAppPrivacyResultPublic exception code: ' + error.code + ', exception message: ' + error.message);
      // todo 兼容本地调试和云调试，获取协议出现异常，作同意处理
      return true;
    }
  }

  /**
   * 订阅隐私弹框签署结果
   * @param callback
   */
  public subscribe(callback?: (agreeFlag: boolean) => void) {
    // 创建订阅者
    commonEventManager.createSubscriber(this.subscribeInfo).then((commonEventSubscriber) => {
      this.subscriber = commonEventSubscriber;
      // 订阅公共事件
      try {
        commonEventManager.subscribe(this.subscriber, (err, data) => {
          if (err) {
            UtilLog.error(TAG, `subscribe failed, code is ${err?.code}, message is ${err?.message}`);
            return;
          }
          const result = JSON.parse(data?.data ?? '{}')?.resultType as number;
          // 更新协议签署标识
          this.agreeFlag = result === 1;
          // 回调签署结果
          if (callback) {
            callback(this.agreeFlag);
          }
          UtilLog.info(TAG, 'Succeeded in subscribe privacy result, set agreeFlag = ' + this.agreeFlag);
        });
      } catch (error) {
        UtilLog.error(TAG,
          'init createSubscriber failed, exception code: ' + error.code + ', exception message: ' + error.message);
      }
    }).catch((err:BusinessError)=>{
      UtilLog.error(TAG, `create subscriber failed, code is ${err?.code}, message is ${err?.message}`);
    });
  }

  /**
   * 取消订阅隐私弹框签署结果
   */
  public unSubscribe() {
    if (this.subscriber) {
      commonEventManager.unsubscribe(this.subscriber);
    }
  }
}