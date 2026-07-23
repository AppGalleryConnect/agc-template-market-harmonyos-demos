import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FormCardData, FormItemModel } from '../models/Model';


const DOMAIN = 0x00FF;
const TAG = '[FormUtils]';

/**
 * 服务卡片工具类
 */
export class FormUtils {
  private static readonly fileName: string = 'form_id_file';
  private static readonly formIdKey: string = 'form_id_key';
  private static readonly formDataKey: string = 'form_data_key';
  public static isSubscribed: boolean = false;

  /**
   * 检查并清理已过期的卡片数据，更新卡片UI
   * 如果当前时间已超过卡片数据的预约时间，则从首选项中删除该条数据并刷新卡片
   * @param ctx 上下文
   */
  public static async checkAndCleanExpiredFormData(ctx: Context) {
    try {
      const list = FormUtils.getFormData(ctx);
      if (!list || list.length === 0) {
        return;
      }
      const now = Date.now();
      let needUpdate = false;
      for (let i = list.length - 1; i >= 0; i--) {
        const item = list[i];
        if (item.appointTimeRaw > 0 && now >= item.appointTimeRaw) {
          hilog.info(DOMAIN, TAG, `checkAndCleanExpiredFormData remove expired order: ${item.orderId}`);
          list.splice(i, 1);
          needUpdate = true;
        }
      }
      if (needUpdate) {
        const store = FormUtils.getStore(ctx);
        if (store) {
          store.putSync(FormUtils.formDataKey, list);
          await store.flush();
          hilog.info(DOMAIN, TAG, 'checkAndCleanExpiredFormData saved, remaining count: ' + list.length);
        }
        FormUtils.updateWidgets(ctx, 'checkAndCleanExpiredFormData');
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'checkAndCleanExpiredFormData fail, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 更新卡片UI内容
   */
  public static async updateWidgets(ctx: Context, source?: string) {
    const formData = FormUtils.queryFormDataFromLocal(ctx);
    const list = FormUtils.getFormIds(ctx);
    try {
      list.forEach((id) => {
        formProvider.updateForm(id, formBindingData.createFormBindingData(formData)).catch((e: BusinessError) => {
          hilog.error(DOMAIN, TAG, 'updateForm fail, error: ' + JSON.stringify(e));
        });
      });
      hilog.info(DOMAIN, TAG,
        `updateWidgets source: ${source}, list length: ${list.length}, list: ${JSON.stringify(list)}`);
    } catch (e) {
      hilog.error(DOMAIN, TAG, `updateForm fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 创建卡片
   * @param formId
   * @param ctx
   */
  public static async addFormId(formId: string, ctx: Context) {
    try {
      const list = FormUtils.getFormIds(ctx);
      if (!list.some((id) => id === formId)) {
        list.push(formId);
        const store = FormUtils.getStore(ctx);
        if (store) {
          store.putSync(FormUtils.formIdKey, list);
          await store.flush();
        }
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'addFormId fail, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 删除卡片
   * @param formId
   * @param ctx
   */
  public static async delFormId(formId: string, ctx: Context) {
    try {
      const list = FormUtils.getFormIds(ctx);
      const index = list.findIndex((id) => id === formId);
      if (index !== -1) {
        list.splice(index, 1);
        const store = FormUtils.getStore(ctx);
        if (store) {
          store.putSync(FormUtils.formIdKey, list);
          await store.flush();
        }
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'delFormId fail, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 从本地持久化存储读取卡片数据（只返回预约时间最近的一条）
   * @param ctx 上下文
   * @returns JSON字符串
   */
  public static queryFormDataFromLocal(ctx: Context) {
    let resp = '';
    try {
      const list = FormUtils.getFormData(ctx);
      if (!list || list.length === 0) {
        resp = JSON.stringify(new FormItemModel('', '', '', '', '', false));
      } else {
        // 按预约时间排序。获取最近的一条
        const sortedList = list.sort((a, b) => a.appointTime.localeCompare(b.appointTime));
        resp = JSON.stringify(sortedList[0]);
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'queryFormDataFromLocal fail, error: ' + JSON.stringify(e));
      resp = JSON.stringify(new FormItemModel('', '', '', '', '', false));
    }
    const formData: FormCardData = {
      data: resp,
    };

    return formData;
  }

  /**
   * 获取卡片id列表
   * @param ctx
   * @returns
   */
  public static getFormIds(ctx: Context) {
    try {
      const store = FormUtils.getStore(ctx);
      if (store) {
        return store.getSync(FormUtils.formIdKey, []) as string[];
      }
      return [];
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'getSync fail, error: ' + JSON.stringify(e));
      return [];
    }
  }

  /**
   * 获取卡片数据列表
   * @param ctx
   * @returns
   */
  public static getFormData(ctx: Context) {
    try {
      const store = FormUtils.getStore(ctx);
      if (store) {
        return store.getSync(FormUtils.formDataKey, []) as FormItemModel[];
      }
      return [];
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'getSync fail, error: ' + JSON.stringify(e));
      return [];
    }
  }

  /**
   * 获取持久化
   * @param ctx
   * @returns
   */
  private static getStore(ctx: Context) {
    try {
      const dataPreferences = preferences.getPreferencesSync(ctx, { name: FormUtils.fileName });
      // 获取Preferences实例后，订阅进程间数据变更事件
      dataPreferences.on('multiProcessChange', () => {
        // 调用removePreferencesFromCache从缓存中移除指定的Preferences实例
        preferences.removePreferencesFromCacheSync(ctx, { name: FormUtils.fileName });
      });
      return dataPreferences;
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'getPreferencesSync fail, error: ' + JSON.stringify(e));
      return undefined;
    }
  }
}