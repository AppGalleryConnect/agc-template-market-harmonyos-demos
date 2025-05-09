import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';

export default class EntryFormAbility extends FormExtensionAbility {
  public onAddForm() {
    let formData = '';
    return formBindingData.createFormBindingData(formData);
  }

  public onAcquireFormState() {
    return formInfo.FormState.READY;
  }
}