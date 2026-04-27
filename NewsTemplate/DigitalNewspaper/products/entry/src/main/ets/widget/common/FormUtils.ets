import { preferences } from '@kit.ArkData';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NewsArticle, queryNewsList } from 'lib_foundation';
import { FormCardData, FormItemModel } from './Types';

const DOMAIN = 0x00FF;
const TAG = '[FormUtils]';

/**
 * 服务卡片工具类
 */
export class FormUtils {
  private static readonly fileName: string = 'form_id_file';
  private static readonly formIdKey: string = 'form_id_key';
  private static readonly formIdEventName: string = 'form_id_event_name';
  public static isSubscribed: boolean = false;

  /**
   * 创建卡片
   * @param formId
   * @param cxt
   */
  public static async addFormId(formId: string, cxt: Context) {
    try {
      const list = FormUtils.getFormIds(cxt);
      if (!list.some((id) => id === formId)) {
        list.push(formId);
        const store = FormUtils.getStore(cxt);
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
   * @param cxt
   */
  public static async delFormId(formId: string, cxt: Context) {
    try {
      const list = FormUtils.getFormIds(cxt);
      const index = list.findIndex((id) => id === formId);
      if (index !== -1) {
        list.splice(index, 1);
        const store = FormUtils.getStore(cxt);
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
   * 发布卡片创建/删除事件
   * @param formId
   * @param isDelete
   */
  public static publishFormId(formId: string, isDelete: boolean) {
    try {
      commonEventManager.publish(
        FormUtils.formIdEventName,
        { data: formId, parameters: { isDelete } },
        (err: BusinessError) => {
          if (err) {
            hilog.error(DOMAIN, TAG, 'Failed to publish form_id_event_name, error: ' + JSON.stringify(err));
          } else {
            hilog.info(DOMAIN, TAG, 'Succeeded in publish form_id_event_name.');
          }
        },
      );
    } catch (e) {
      hilog.error(DOMAIN, TAG, `commonEventManager.publish fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 订阅卡片创建/删除事件
   * @param ctx
   */
  public static async subscribeFormId(ctx: Context, source?: string) {
    hilog.info(DOMAIN, TAG, 'subscribeFormId source:' + source)
    FormUtils.isSubscribed = true;
    let subscriber: commonEventManager.CommonEventSubscriber | undefined = undefined;
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [FormUtils.formIdEventName],
      publisherPermission: '',
    };
    try {
      commonEventManager.createSubscriber(subscribeInfo, (_err1, data1) => {
        if (data1) {
          subscriber = data1;
          commonEventManager.subscribe(subscriber, async (_err2, data2) => {
            if (data2) {
              if (data2.parameters?.isDelete) {
                FormUtils.delFormId(data2.data as string, ctx);
              } else {
                FormUtils.addFormId(data2.data as string, ctx);
                FormUtils.updateWidgets(ctx, source);
              }
              hilog.info(DOMAIN, TAG, 'Succeeded in creating subscribeFormId.');
            }
          });
        }
      });
    } catch (e) {
      hilog.error(DOMAIN, TAG, `subscribe fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 查询卡片数据源
   * @returns
   */
  public static async queryFormData() {
    const list: NewsArticle = await queryNewsList();
    return JSON.stringify(list);
  }

  /**
   * 更新卡片UI内容
   */
  public static async updateWidgets(ctx: Context, source?: string) {
    const resp = await FormUtils.queryFormData();
    const formData: FormCardData = {
      data: resp,
    };
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
   * 更新卡片UI内容
   */
  public static async updateWidget(formId: string) {
    const resp = await FormUtils.queryFormData();
    const formData: FormCardData = {
      data: resp,
    };

    formProvider.updateForm(formId, formBindingData.createFormBindingData(formData)).then(() => {
      hilog.info(DOMAIN, TAG, 'FormAbility updateForm success.');
    }).catch((e: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'Operation updateForm failed, error: ' + JSON.stringify(e));
    });

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
   * 获取持久化
   * @param ctx
   * @returns
   */
  private static getStore(ctx: Context) {
    try {
      return preferences.getPreferencesSync(ctx, { name: FormUtils.fileName });
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'getPreferencesSync fail, error: ' + JSON.stringify(e));
      return undefined;
    }
  }

  /**
   * 卡片默认列表数据
   * @returns
   */
  public static getDefaultFormData() {
    const data: FormItemModel =
      new FormItemModel('article_digital_1', '人工智能助力教育公平：偏远地区学生迎来优质教育资源', 1751089800000);
    return JSON.stringify(data);
  }
}