import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { FormCardModel } from '../models/FormCardModel';

export default class PhoneFormAbility extends FormExtensionAbility {
  onAddForm() {
    const formData: FormCardModel = {
      newsId: '1',
      newsTitle: 'AI重塑社交媒体：智能互动与内容推荐开启未来传播新时代',
    };
    return formBindingData.createFormBindingData(formData);
  }

  onAcquireFormState() {
    return formInfo.FormState.READY;
  }
}