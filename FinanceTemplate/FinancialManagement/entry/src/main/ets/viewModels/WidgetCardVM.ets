import { https } from 'network';
import { Logger, PreferenceUtil } from 'commonlib';
import { formBindingData, formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';
import commonEventManager from '@ohos.commonEventManager';
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp';


const TAG: string = 'WidgetCardVM';

class FormData {
  hasData: boolean = false;
  productList: IProductItem[] = []
}

@ObservedV2
export class WidgetCardVM {
  eventType: string = 'createCard';
  private formDataInfo: FormData | undefined = undefined;
  private static _instance: WidgetCardVM;

  public static get instance() {
    if (!WidgetCardVM._instance) {
      WidgetCardVM._instance = new WidgetCardVM();
    }
    return WidgetCardVM._instance;
  }


  public async getLatestOrder() {
    const res = await https.getMyRegularChoiceList(1);
    if (res.code === 0) {
      const productListData: IProductItem[] = res.data.slice(0, 2)
      this.formDataInfo = {
        hasData: true,
        productList: productListData
      };
      PreferenceUtil.getInstance().put('formDataInfo', this.formDataInfo);
    }
  }

  public async updateFormInfo() {
    try {
      if (!this.formDataInfo) {
        return;
      }
      this.updateFormData(this.formDataInfo);
    } catch (e) {
      Logger.error(`updateFormInfo failed. Cause: ${JSON.stringify(e)}`);
    }
  }

  public getFormIdArray() {
    return PreferenceUtil.getInstance().get(this.getFormPreferenceKey()) as Array<string>;
  }

  public createFormData(data: FormData): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(data);
  }

  public updateFormData(data: FormData, formId?: string) {
    if (!this.getFormIdArray()) {
      return;
    }
    let formInfo = this.createFormData(data);

    let formIdArray: Array<string> = this.getFormIdArray();
    for (let id of formIdArray) {
      if (formId && id !== formId) {
        continue;
      }
      formProvider.updateForm(id, formInfo).then(() => {
        Logger.info(`updateForm success. ${JSON.stringify(data)}`);
      }).catch((error: BusinessError) => {
        Logger.info(`Operation updateForm failed. Cause: ${JSON.stringify(error)}`);
      });
    }
  }

  // 发布公共事件跨进程传递卡片id
  public publishFormId(data: string) {
    commonEventManager.publish(this.eventType, { data, subscriberPermissions: [] }, (err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
      } else {
        Logger.info(TAG, 'Succeeded in publishing common event.');
      }
    });
  }

  // 订阅获取卡片id
  public subscribeFormId() {
    let subscriber: commonEventManager.CommonEventSubscriber;
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [this.eventType],
      publisherPermission: ''
    };
    commonEventManager.createSubscriber(subscribeInfo, (err, data) => {
      if (err) {
        Logger.error(`Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
        return;
      }
      Logger.info('Succeeded in creating subscriber1.');
      subscriber = data;
      // 订阅公共事件回调
      commonEventManager.subscribe(subscriber, (err, data) => {
        if (err) {
          Logger.error(`Failed to subscribe common event. Code is ${err.code}, message is ${err.message}`);
          return;
        } else {
          PreferenceUtil.getInstance().putToArray(this.getFormPreferenceKey(), data.data as string);
        }
      });
    });
  }

  private getFormPreferenceKey() {
    return 'order_status_widget_form_id';
  }
}
