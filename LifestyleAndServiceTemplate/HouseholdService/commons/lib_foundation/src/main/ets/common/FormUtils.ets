import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { CommonUtils } from 'module_base';
import { IFullOrderInfo } from '../model/IResponse';
import { FormCardData, FormItemModel } from '../model/ObserveModel';

const DOMAIN = 0x00FF;
const TAG = '[FormUtils]';

export class FormUtils {
  private static readonly fileName: string = 'form_id_file';
  private static readonly formIdKey: string = 'form_id_key';
  private static readonly formDataKey: string = 'form_data_key';
  public static isSubscribed: boolean = false;

  private static getStore(ctx: Context) {
    try {
      const dataPreferences = preferences.getPreferencesSync(ctx, { name: FormUtils.fileName });
      dataPreferences.on('multiProcessChange', () => {
        preferences.removePreferencesFromCacheSync(ctx, { name: FormUtils.fileName });
      });
      return dataPreferences;
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'getPreferencesSync fail, error: ' + JSON.stringify(e));
      return undefined;
    }
  }

  static getFormIds(ctx: Context): string[] {
    try {
      const store = FormUtils.getStore(ctx);
      return store ? store.getSync(FormUtils.formIdKey, []) as string[] : [];
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'getFormIds fail, error: ' + JSON.stringify(e));
      return [];
    }
  }

  static getFormData(ctx: Context): FormItemModel[] {
    try {
      const store = FormUtils.getStore(ctx);
      return store ? store.getSync(FormUtils.formDataKey, []) as FormItemModel[] : [];
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'getFormData fail, error: ' + JSON.stringify(e));
      return [];
    }
  }

  static queryFormDataFromLocal(ctx: Context): FormCardData {
    let resp = '';
    try {
      const list = FormUtils.getFormData(ctx);
      if (!list || list.length === 0) {
        resp = JSON.stringify(new FormItemModel('', '', '', '', '', false));
      } else {
        const sortedList = list.sort((a, b) => a.appointTime.localeCompare(b.appointTime));
        resp = JSON.stringify(sortedList[0]);
      }
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'queryFormDataFromLocal fail, error: ' + JSON.stringify(e));
      resp = JSON.stringify(new FormItemModel('', '', '', '', '', false));
    }
    return { data: resp };
  }

  static async addFormData(orderInfo: IFullOrderInfo, ctx: Context) {
    try {
      const list = FormUtils.getFormData(ctx);
      if (list.some((item) => item.orderId === orderInfo.orderId)) {
        return;
      }
      list.push(new FormItemModel(
        orderInfo.id, orderInfo.orderId, orderInfo.title,
        CommonUtils.formatDate(orderInfo.appointTime), orderInfo.addressName, true, orderInfo.appointTime,
      ));
      const store = FormUtils.getStore(ctx);
      if (store) {
        store.putSync(FormUtils.formDataKey, list);
        await store.flush();
        UtilLog.info(DOMAIN, TAG, 'addFormData success, orderId: ' + orderInfo.orderId);
      }
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'addFormData fail, error: ' + JSON.stringify(e));
    }
  }

  static async removeFormData(orderId: string, ctx: Context) {
    try {
      const list = FormUtils.getFormData(ctx);
      const index = list.findIndex((item) => item.orderId === orderId);
      if (index === -1) {
        return;
      }
      list.splice(index, 1);
      const store = FormUtils.getStore(ctx);
      if (store) {
        store.putSync(FormUtils.formDataKey, list);
        await store.flush();
        UtilLog.info(DOMAIN, TAG, 'removeFormData success, orderId: ' + orderId);
      }
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'removeFormData fail, error: ' + JSON.stringify(e));
    }
  }

  static async checkAndCleanExpiredFormData(ctx: Context) {
    try {
      const list = FormUtils.getFormData(ctx);
      if (!list || list.length === 0) {
        return;
      }
      const now = Date.now();
      let needUpdate = false;
      for (let i = list.length - 1; i >= 0; i--) {
        if (list[i].appointTimeRaw > 0 && now >= list[i].appointTimeRaw) {
          UtilLog.info(DOMAIN, TAG, `checkAndCleanExpiredFormData remove expired order: ${list[i].orderId}`);
          list.splice(i, 1);
          needUpdate = true;
        }
      }
      if (!needUpdate) {
        return;
      }
      const store = FormUtils.getStore(ctx);
      if (store) {
        store.putSync(FormUtils.formDataKey, list);
        await store.flush();
        UtilLog.info(DOMAIN, TAG, 'checkAndCleanExpiredFormData saved, remaining count: ' + list.length);
      }
      FormUtils.updateWidgets(ctx, 'checkAndCleanExpiredFormData');
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'checkAndCleanExpiredFormData fail, error: ' + JSON.stringify(e));
    }
  }

  static async updateWidgets(ctx: Context, source?: string) {
    const formData = FormUtils.queryFormDataFromLocal(ctx);
    const formIds = FormUtils.getFormIds(ctx);
    try {
      formIds.forEach((id) => {
        formProvider.updateForm(id, formBindingData.createFormBindingData(formData)).catch((e: BusinessError) => {
          UtilLog.error(DOMAIN, TAG, 'updateForm fail, error: ' + JSON.stringify(e));
        });
      });
      UtilLog.info(DOMAIN, TAG,
        `updateWidgets source: ${source}, list length: ${formIds.length}, list: ${JSON.stringify(formIds)}`);
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, `updateForm fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  static async clearAllFormData(ctx: Context) {
    try {
      const store = FormUtils.getStore(ctx);
      if (store) {
        store.putSync(FormUtils.formDataKey, []);
        await store.flush();
        FormUtils.updateWidgets(ctx, 'clearAllFormData');
      }
    } catch (e) {
      UtilLog.error(DOMAIN, TAG, 'clearAllFormData fail, error: ' + JSON.stringify(e));
    }
  }
}
