import { UtilLog } from '@hw-agconnect/util-log';
import { http } from '@kit.NetworkKit';
import { fileIo } from '@kit.CoreFileKit';
import { preferences } from '@kit.ArkData';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { AvResponse, HomeServiceApi } from 'lib_tv_apis';
import { FormItemModel } from '../widget/common/Types';
import { FormCardData, FormDataClass } from '../type/Types';

const TAG = '[FormUtils]';

/**
 * 服务卡片工具类
 */
export class FormUtils {
  private static readonly fileName: string = 'tv_form_id_file';
  private static readonly formIdKey: string = 'tv_form_id_key';
  private static readonly formIdEventName: string = 'tv_form_id_event_name';
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
      UtilLog.error(TAG, 'addFormId fail, error: ' + JSON.stringify(e));
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
      UtilLog.error(TAG, 'delFormId fail, error: ' + JSON.stringify(e));
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
            UtilLog.error(TAG, 'Failed to publish form_id_event_name, error: ' + JSON.stringify(err));
          } else {
            UtilLog.info(TAG, 'Succeeded in publish form_id_event_name.');
          }
        },
      );
    } catch (e) {
      UtilLog.error(TAG, `commonEventManager.publish fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 订阅卡片创建/删除事件
   * @param ctx
   */
  public static async subscribeFormId(ctx: Context, source?: string) {
    UtilLog.info(TAG, 'subscribeFormId source:' + source)
    FormUtils.isSubscribed = true;
    let subscriber: commonEventManager.CommonEventSubscriber | undefined = undefined;
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [FormUtils.formIdEventName],
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
              UtilLog.info(TAG, 'Succeeded in creating subscribeFormId.');
            }
          });
        }
      });
    } catch (e) {
      UtilLog.error(TAG, `subscribe fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  /**
   * 查询卡片数据源
   * @returns
   */
  public static async queryFormData() {
    const list = await HomeServiceApi.queryFormNewsList() as AvResponse[];
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
        FormUtils.downloadFormImage(ctx, JSON.parse(formData.data).coverUrl, id)
        formProvider.updateForm(id, formBindingData.createFormBindingData(formData)).catch((e: BusinessError) => {
          UtilLog.error(TAG, 'updateForm fail, error: ' + JSON.stringify(e));
        });
      });
      UtilLog.info(TAG,
        `updateWidgets source: ${source}, list length: ${list.length}, list: ${JSON.stringify(list)}`);
    } catch (e) {
      UtilLog.error(TAG, `updateForm fail. Code: ${e.code}, message: ${e.message}`);
    }
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
      UtilLog.error(TAG, 'getSync fail, error: ' + JSON.stringify(e));
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
      UtilLog.error(TAG, 'getPreferencesSync fail, error: ' + JSON.stringify(e));
      return undefined;
    }
  }

  /**
   * 卡片默认列表数据
   * @returns
   */
  public static getDefaultFormData() {
    const data: FormItemModel[] = [
      new FormItemModel('television_2', '新闻卫视', false),
    ];
    return JSON.stringify(data);
  }

  /**
   * 下载网络图片到沙箱
   * 服务卡片展示图片
   * */
  public static async downloadFormImage(context: Context, netFile: string, formId: string) {
    let httpRequest = http.createHttp()
    let tempDir = context.getApplicationContext().tempDir;
    let fileName = 'file' + Date.now();
    let tmpFile = tempDir + '/' + fileName;
    let imgFile = undefined
    let imgMap: Record<string, number> = {};

    const data = await httpRequest.request(netFile)
    if (data?.responseCode === http.ResponseCode.OK) {
      try {
        let imgFile = fileIo.openSync(tmpFile, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        imgMap[fileName] = imgFile.fd;
        try {
          fileIo.write(imgFile.fd, data.result as ArrayBuffer).then((writeLen) => {
            UtilLog.info('write data to file succeed and size is:' + writeLen);
            try {
              let formData: FormDataClass = {
                imgName: fileName,
                formImages: imgMap,
              }
              const formInfo = formBindingData.createFormBindingData(formData)
              formProvider.updateForm(formId, formInfo).then(() => {
                UtilLog.info('FormAbility updateForm success.');
              }).catch((e: BusinessError) => {
                UtilLog.error(`FormAbility updateForm failed: 63 ${JSON.stringify(e)}`);
              });
            } catch (error) {
              UtilLog.error(`FormAbility updateForm failed: ${JSON.stringify(error)}`);
            }
          })
        } catch (err) {
          UtilLog.error('write data to file failed with error message: ' + err.message + ', error code: ' + err.code);
        }
      } catch (e) {
        UtilLog.error(`openSync failed: ${JSON.stringify(e as BusinessError)}`);
      } finally {
        fileIo.closeSync(imgFile);
      }
    } else {
      UtilLog.error(`ArkTSCard download task failed`);
      let param: Record<string, string> = {
        'text': '刷新失败',
      };
      const formInfo = (formBindingData.createFormBindingData(param))
      formProvider.updateForm(formId, formInfo);
    }
    httpRequest.destroy();
  }
}