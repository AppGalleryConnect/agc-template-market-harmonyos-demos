import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { Logger, PreferenceUtil } from 'commonlib';
import { WidgetCardVM } from '../viewModels/WidgetCardVM';

const vm: WidgetCardVM = WidgetCardVM.instance

export default class EntryFormAbility extends FormExtensionAbility {
  public onAddForm(want: Want) {
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

  public onCastToNormalForm(formId: string) {

  }

  public onUpdateForm(formId: string) {
  }

  public onFormEvent(formId: string, message: string) {

  }

  public onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    Logger.info(`[WidgetAbility] onRemoveForm ${formId}`);
    // Called to notify the form provider that a specified form has been destroyed.
    try {
      PreferenceUtil.getInstance(this.context).removeFromArray(this.getFormPreferenceKey(), formId);
    } catch (e) {
      Logger.error(`[WidgetAbility] onRemoveForm error: ${e}`);
    }
  }

  public onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }

  private getFormPreferenceKey() {
    return 'order_status_widget_form_id';
  }
}
