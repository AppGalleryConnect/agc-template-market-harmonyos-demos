import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { Logger, PreferenceUtil } from 'module_base';
import { WidgetCardVM } from '../viewmodels/WidgetCardVM';

const vm: WidgetCardVM = WidgetCardVM.instance

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    Logger.info(`[WidgetAbility] onAddForm formId: ${formId}`);
    if (!formId) {
      return formBindingData.createFormBindingData({
        text: 'onAddFormWithoutFormId',
      });
    }
    try {
      PreferenceUtil.getInstance(this.context).putToArray(this.getFormPreferenceKey(), formId);
      vm.publishFormId(formId)
    } catch (e) {
      Logger.error(`[WidgetAbility] onAddForm error: ${e}`);
    }
    if (PreferenceUtil.getInstance(this.context).get('formDataInfo')) {
      PreferenceUtil.getInstance(this.context).get(this.getFormPreferenceKey())
      const formDataInfo = PreferenceUtil.getInstance().get('formDataInfo') as object;
      return formBindingData.createFormBindingData(formDataInfo);
    } else {
      return formBindingData.createFormBindingData({});
    }
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    try {
      PreferenceUtil.getInstance(this.context).removeFromArray(this.getFormPreferenceKey(), formId);
    } catch (e) {
      Logger.error(`[WidgetAbility] onRemoveForm error: ${e}`);
    }
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  private getFormPreferenceKey() {
    return 'order_status_widget_form_id';
  }
};