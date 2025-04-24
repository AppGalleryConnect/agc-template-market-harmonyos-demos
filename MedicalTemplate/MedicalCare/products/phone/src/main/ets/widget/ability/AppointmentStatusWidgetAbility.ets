import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { PreferenceUtil } from 'common';
import hilog from '@ohos.hilog';

const TAG: string = 'AppointmentStatusWidgetAbility';
const DOMAIN_NUMBER: number = 0xFF00;

export default class AppointmentStatusWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    hilog.info(DOMAIN_NUMBER, TAG, `[AppointmentStatusWidgetAbility] onAddForm formId: ${formId}`);
    if (!formId) {
      return formBindingData.createFormBindingData({
        text: 'onAddFormWithoutFormId'
      });
    }

    try {
      PreferenceUtil.getInstance(this.context).putToArray(this.getFormPreferenceKey(), formId)
    } catch (e) {
      hilog.error(DOMAIN_NUMBER, TAG, `[AppointmentStatusWidgetAbility] onAddForm error: ${e}`);
    }
    return formBindingData.createFormBindingData({});
  }

  onCastToNormalForm(formId: string) {
    hilog.info(DOMAIN_NUMBER, TAG, '[AppointmentStatusWidgetAbility] onCastToNormalForm');
    hilog.info(DOMAIN_NUMBER, TAG, formId);
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    hilog.info(DOMAIN_NUMBER, TAG, '[AppointmentStatusWidgetAbility] onUpdateForm');
    hilog.info(DOMAIN_NUMBER, TAG, formId);
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    hilog.info(DOMAIN_NUMBER, TAG, '[AppointmentStatusWidgetAbility] onFormEvent');
    hilog.info(DOMAIN_NUMBER, TAG, `${formId} - ${message}`);
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    hilog.info(DOMAIN_NUMBER, TAG, `[AppointmentStatusWidgetAbility] onRemoveForm ${formId}`);
    // Called to notify the form provider that a specified form has been destroyed.
    try {
      PreferenceUtil.getInstance(this.context).removeFromArray(this.getFormPreferenceKey(), formId)
    } catch (e) {
      hilog.error(DOMAIN_NUMBER, TAG, `[AppointmentStatusWidgetAbility] onRemoveForm error: ${e}`);
    }
  }

  onAcquireFormState(want: Want) {
    hilog.info(DOMAIN_NUMBER, TAG, '[AppointmentStatusWidgetAbility] onRemoveForm');
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  private getFormPreferenceKey() {
    return `appointment_status_widget_form_id`
  }
}