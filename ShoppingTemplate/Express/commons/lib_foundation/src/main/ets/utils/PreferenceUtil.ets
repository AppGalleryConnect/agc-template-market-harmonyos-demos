import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { Logger } from './Logger';
import { ContextUtil } from './ContextUtil';
import { KEY_CARD_ID, KEY_CARD_INFO } from '../common/Constant';
import { CardInfo, WidgetCardModel } from '../model/CommonModel';

const TAG = '[PreferenceUtil]'

export class PreferenceUtil {
  private static preferenceRecord: Map<string, PreferenceUtil> = new Map();
  private dataPreferences: preferences.Preferences | null = null;

  private constructor(context: Context, fileName: string) {
    try {
      preferences.removePreferencesFromCacheSync(context, fileName)
    } catch (e) {
      Logger.error(`PreferenceUtil removePreferencesFromCacheSync failed`, e)
    }
    this.dataPreferences = preferences.getPreferencesSync(context, { name: fileName })
    Logger.info(TAG, `PreferenceUtil: ${fileName} init: ${this.dataPreferences != null}`)
  }

  public static getInstance(context: Context, fileName: string = 'default') {
    if (PreferenceUtil.preferenceRecord.has(fileName)) {
      PreferenceUtil.preferenceRecord.delete(fileName)
    }
    let preferenceUtil: PreferenceUtil = new PreferenceUtil(context, fileName);
    PreferenceUtil.preferenceRecord.set(fileName, preferenceUtil)
    return preferenceUtil
  }

  public put(key: string, value: object | string | boolean) {
    if (!this.dataPreferences) {
      Logger.info(TAG, 'dataPreferences is null');
    }
    try {
      this.dataPreferences?.putSync(key, value);
      this.dataPreferences?.flush();
      Logger.info(TAG, ` put: ${key} = ${JSON.stringify(value)}`);
    } catch (e) {
      Logger.error(TAG, `put error: ${JSON.stringify(e)}`);
    }
  }

  public get(key: string, defaultValue?: object | string | boolean) {
    try {
      let data = this.dataPreferences?.getSync(key, defaultValue);
      Logger.info(TAG, `PreferenceUtil: get: ${key} = ${JSON.stringify(data)}`);
      return data;
    } catch (e) {
      Logger.error(TAG, `PreferenceUtil: get error: ${JSON.stringify(e)}`);
      return defaultValue;
    }
  }

  public putToArray(key: string, value: string) {
    if (!this.dataPreferences) {
      Logger.error(TAG, `dataPreferences is null`)
    }
    let array: Array<string> = this.get(key) as Array<string> || [];
    if (array.indexOf(value) !== -1) {
      return;
    }
    array.push(value);
    Logger.info(TAG, `put value is ${value}`)
    this.put(key, array);
  }

  public static getCardInfoArray(context?: Context): Array<string> {
    let ctx = context || ContextUtil.globalContext;
    try {
      preferences.removePreferencesFromCacheSync(ctx, { name: 'default' })
      return PreferenceUtil.getInstance(ctx!).get(KEY_CARD_ID) as Array<string>
    } catch (e) {
      Logger.error(TAG, `updateCard failed. getCardInfoArray error. ${e}`)
      return []
    }
  }

  public static getCardDataArray(context?: Context): string {
    let ctx = context || ContextUtil.globalContext;
    try {
      preferences.removePreferencesFromCacheSync(ctx, { name: 'default' })
      return PreferenceUtil.getInstance(ctx!).get(KEY_CARD_INFO) as string
    } catch (e) {
      Logger.error(TAG, `updateCard failed. getCardInfoArray error. ${e}`)
      return ''
    }
  }

  public static removeCard(formId: string, context: Context) {
    let cardIdArray = PreferenceUtil.getCardInfoArray(context);
    Logger.info(TAG, `cardIdArray : ${JSON.stringify(cardIdArray)}`);
    if (!formId || !cardIdArray.length) {
      return
    }
    let cardInfoArr: string[] = cardIdArray;
    let card = cardInfoArr.find(item => {
      let cardInfo: CardInfo = JSON.parse(item || '{}') as CardInfo
      return cardInfo.formId === formId
    })
    Logger.info(TAG, `removeCard start. formId:${formId}, cardInfo:${card}`)
    if (!PreferenceUtil.getInstance(context).dataPreferences) {
      Logger.info(TAG, `PreferenceUtil: dataPreferences is null`)
    }
    let array: string[] = PreferenceUtil.getCardInfoArray(context) as string[] || [];
    const value = card || '';
    Logger.info(TAG, `PreferenceUtil: remove card value: ${value}}`)
    array.splice(array.indexOf(value), 1)
    PreferenceUtil.getInstance(context).put(KEY_CARD_ID, array)
  }

  public static async updateCard(formData: WidgetCardModel, context?: Context, formId?: string) {
    Logger.info(TAG, `updateCard start. formData:${JSON.stringify(formData)}, formId:${formId}`)
    let cardIdArray: Array<string> = PreferenceUtil.getCardInfoArray(context) as Array<string> || [];
    if (!cardIdArray?.length) {
      Logger.info(TAG, `updateCard failed. formId is empty. ${JSON.stringify(cardIdArray)}`)
      return
    }
    Logger.info(TAG, `formId:${JSON.stringify(cardIdArray)}`)
    if (!formData) {
      formData = new WidgetCardModel()
    }
    let cardInfoArr: Array<string> = cardIdArray;
    let formDimension = formData.formDimension
    for (let cardInfoStr of cardInfoArr) {
      let cardInfo: CardInfo = JSON.parse(cardInfoStr || '{}') as CardInfo
      // formId不存在不同步 2.有formId为刷新场景，过滤预约卡片  3。根据尺寸定向同步卡片
      if (!cardInfo.formId || (formId && cardInfo.formId !== formId) ||
        (formDimension && cardInfo.formDimension !== formDimension)) {
        continue
      }
      formData.formDimension = cardInfo.formDimension
      formProvider.updateForm(cardInfo.formId, formBindingData.createFormBindingData(formData)).then(() => {
        Logger.info(TAG, `updateForm success. formData:${JSON.stringify(formData)},formId:${cardInfo.formId}`)
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Operation updateForm failed. formData: ${JSON.stringify(formData)},
        formId:${cardInfo.formId}. Cause: ${JSON.stringify(error)}`);
      })
    }
  }
}