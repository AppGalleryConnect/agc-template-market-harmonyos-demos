import {
  PreferenceUtil,
  HttpApi,
  BaseViewModel,
  ContextUtil,
  WidgetCardModel,
  KEY_CARD_INFO,
  Logger,
} from 'lib_foundation';

const TAG = '[WidgetCardVM]'

@ObservedV2
export class WidgetCardVM extends BaseViewModel {
  private static _instance: WidgetCardVM;
  private queryTimer: number | null = null;
  private readonly INTERVAL_TIME = 10 * 60 * 1000;

  public static get instance() {
    if (!WidgetCardVM._instance) {
      WidgetCardVM._instance = new WidgetCardVM();
    }
    return WidgetCardVM._instance;
  }

  // 定时查询物流状态
  startPolling() {
    if (this.queryTimer) {
      return;
    }

    this.queryTimer = setInterval(async () => {
      if (this.userInfoModel.isLogin) {
        try {
          const context = ContextUtil.globalContext;
          let formData = new WidgetCardModel();
          const orderData = await this.getLatestOrder();
          if (orderData) {
            formData.orderNo = orderData.orderNo;
            formData.senderCity = orderData.senderCity;
            formData.receiverCity = orderData.receiverCity;
            formData.logistics = orderData.logistics;
          }
          formData.isLogin = this.userInfoModel.isLogin;
          PreferenceUtil.getInstance(context).put(KEY_CARD_INFO, JSON.stringify(formData));
        } catch (error) {
          Logger.error(TAG, `Failed to get latest order: ${error}`);
        }
      }
    }, this.INTERVAL_TIME);
  }

  // 更新卡片信息
  async updateFormCardData(isUpDate: boolean = false) {
    const context = ContextUtil.globalContext;
    const data = PreferenceUtil.getCardDataArray(context);
    let formData = new WidgetCardModel();
    if (data) {
      formData = JSON.parse(data) as WidgetCardModel;
    }
    if (this.userInfoModel.isLogin) {
      const orderData = await this.getLatestOrder();
      if (orderData) {
        formData.orderNo = orderData.orderNo;
        formData.senderCity = orderData.senderCity;
        formData.receiverCity = orderData.receiverCity;
        formData.logistics = orderData.logistics;
      }
    }
    formData.isLogin = this.userInfoModel.isLogin;
    PreferenceUtil.getInstance(context).put(KEY_CARD_INFO, JSON.stringify(formData));
    Logger.info(TAG, `updateFormCardData formData: ${JSON.stringify(formData)}`);
    if (isUpDate) {
      PreferenceUtil.updateCard(formData as WidgetCardModel, context)
    }
  }

  // 查询最新一条快递信息
  public async getLatestOrder() {
    let formData: WidgetCardModel | undefined = undefined;
    const latestOrder = await HttpApi.queryLatestParcel()
    if (latestOrder.detail) {
      const detail = latestOrder.detail;
      const logistics = latestOrder?.logs?.[0];
      formData = new WidgetCardModel();
      formData.isLogin = true;
      formData.orderNo = detail.parcelNumber;
      formData.senderCity = detail.senderCity;
      formData.receiverCity = detail.receiverCity;
      if (logistics) {
        formData.logistics = logistics.description ?? '';
      }
      Logger.info(TAG, `getLatestOrder formData: ${JSON.stringify(formData)}`);
    }

    return formData;
  }
}
