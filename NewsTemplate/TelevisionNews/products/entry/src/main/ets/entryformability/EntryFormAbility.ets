import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { FormUtils } from '../utils/FormUtils';
import { FormCardData } from '../type/Types';

const TAG: string = '[EntryFormAbility]';

export default class EntryFormAbility extends FormExtensionAbility {
  private formData: FormCardData = {
    data: FormUtils.getDefaultFormData(),
  };

  onAddForm(want: Want) {
    UtilLog.info(TAG, `onAddForm formId: ${this.formData}`);
    if (!FormUtils.isSubscribed) {
      FormUtils.subscribeFormId(this.context, TAG);
    }

    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    UtilLog.info(TAG, `onAddForm formId: ${formId}`);
    if (formId) {
      setTimeout(() => {
        FormUtils.addFormId(formId, this.context);
        FormUtils.publishFormId(formId, false);
      }, 300)
    }

    return formBindingData.createFormBindingData(this.formData);
  }

  onRemoveForm(formId: string) {
    UtilLog.info(TAG, `onRemoveForm, formId = ${formId}`);
    FormUtils.delFormId(formId, this.context);
    FormUtils.publishFormId(formId, true);
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }
}