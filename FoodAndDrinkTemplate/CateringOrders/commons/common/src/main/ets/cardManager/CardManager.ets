import dataPreferences from '@ohos.data.preferences';
import { formBindingData, formProvider } from '@kit.FormKit';
import EntryContext from './EntryContext';

export class FormDataClass {
  storeName: ResourceStr = ''
  orderState: boolean = false
  orderId: string = ''
  storeType: string = ''
  storeTable: string = ''
  orderPickNum: string = ''
}

export class CardManager {
  private static instance: CardManager = new CardManager()

  static get(): CardManager {
    return CardManager.instance
  }

  static KEY_CARD_ID = 'card_id'
  static KEY_CARD_INFO = 'card_info'

  saveCardId(context: Context, formId: string) {
    dataPreferences.removePreferencesFromCacheSync(context, { name: CardManager.KEY_CARD_ID })
    let pref = dataPreferences.getPreferencesSync(context, { name: CardManager.KEY_CARD_ID });
    pref.putSync(CardManager.KEY_CARD_ID, formId)
    pref.flush()
  }

  clearCardId(context: Context) {
    dataPreferences.removePreferencesFromCacheSync(context, { name: CardManager.KEY_CARD_ID })
    let pref = dataPreferences.getPreferencesSync(context, { name: CardManager.KEY_CARD_ID });
    pref.putSync(CardManager.KEY_CARD_ID, '')
    pref.flush()
  }

  getFormId(context: Context): string {
    dataPreferences.removePreferencesFromCacheSync(context, { name: CardManager.KEY_CARD_ID })
    let pref = dataPreferences.getPreferencesSync(context, { name: CardManager.KEY_CARD_ID });
    let cardId = pref.getSync(CardManager.KEY_CARD_ID, '') as string
    return cardId
  }

  async updateCard(context?: Context, formId?: string, formData?: FormDataClass) {
    // 主动触发卡片刷新
    if (!context) {
      context = EntryContext.getContext() as Context
    }
    if (!formId) {
      formId = this.getFormId(context)
    }
    if (!formData) {
      formData = new FormDataClass()
    }
    formProvider.updateForm(formId, formBindingData.createFormBindingData(formData))
  }
}