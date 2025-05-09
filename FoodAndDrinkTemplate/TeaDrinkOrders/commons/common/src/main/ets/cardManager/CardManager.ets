import { formBindingData, formProvider } from '@kit.FormKit';
import { PreferenceUtil } from '../utils/PreferenceUtil';
import { BusinessError } from '@kit.BasicServicesKit';

export class FormDataClass {
  storeName: ResourceStr = ''
  orderState: boolean = false
  orderId: string = ''
  storeType: number = 0
  orderPickNum: string = ''
  makingNum: number = 0
  makingWaitMin: number = 0
  deliveryTime: string = ''
  distance: string = ''
}

export class CardManager {
  private static instance: CardManager = new CardManager()

  static get(): CardManager {
    return CardManager.instance
  }

  static KEY_CARD_ID = 'card_id'
  static KEY_CARD_INFO = 'card_info'

  public getFormIdArray() {
    return PreferenceUtil.getInstance().get(CardManager.KEY_CARD_ID) as Array<string>
  }

  public createFormData(data: FormDataClass): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(data);
  }

  async updateCard(formData: FormDataClass, formId?: string) {

    if (!this.getFormIdArray()) {
      return
    }
    if (!formData) {
      formData = new FormDataClass()
    }
    let formInfo = this.createFormData(formData);

    let formIdArray: Array<string> = this.getFormIdArray()
    for (let id of formIdArray) {
      if (formId && id !== formId) {
        continue
      }
      formProvider.updateForm(id, formInfo).then(() => {
        console.info(`updateForm success. ${JSON.stringify(formData)}`)
      }).catch((error: BusinessError) => {
        console.info(`Operation updateForm failed. Cause: ${JSON.stringify(error)}`);
      })
    }
  }
}