import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { Logger } from 'lib_common';
import { FormUtils } from '../common/FormUtils';
import { FormCardData } from '../common/Types';

const TAG: string = '[PhoneFormAbility]';

export default class PhoneFormAbility extends FormExtensionAbility {
  private formData: FormCardData = {
    data: FormUtils.getDefaultFormData(),
  };

  onAddForm(want: Want) {
    Logger.setLogConfig();
    if (!FormUtils.isSubscribed) {
      FormUtils.subscribeFormId(this.context, TAG);
    }

    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    Logger.info(TAG, `onAddForm formId: ${formId}`);
    if (formId) {
      FormUtils.addFormId(formId, this.context);
      FormUtils.publishFormId(formId, false);
    }

    return formBindingData.createFormBindingData(this.formData);
  }

  onRemoveForm(formId: string) {
    Logger.info(TAG, `onRemoveForm, formId = ${formId}`);
    FormUtils.delFormId(formId, this.context);
    FormUtils.publishFormId(formId, true);
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }
}