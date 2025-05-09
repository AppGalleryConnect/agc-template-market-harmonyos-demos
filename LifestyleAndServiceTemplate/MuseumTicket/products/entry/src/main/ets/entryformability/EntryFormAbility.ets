import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { Logger, PreferenceUtil } from 'commonlib';
import {WidgetCardVM} from '../viewmodels/WidgetCardVM'

const TAG: string = 'EntryFormAbility';
const vm:WidgetCardVM = WidgetCardVM.instance

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    Logger.info(TAG, `[WidgetAbility] onAddForm formId: ${formId}`);
    if (!formId) {
      return formBindingData.createFormBindingData({
        text: 'onAddFormWithoutFormId',
      });
    }
    try {
      PreferenceUtil.getInstance(this.context).putToArray(this.getFormPreferenceKey(), formId);
      vm.publishFormId(formId)
    } catch (e) {
      Logger.error(TAG, `[WidgetAbility] onAddForm error: ${e}`);
    }
    if (PreferenceUtil.getInstance(this.context).get('formDataInfo')) {
      PreferenceUtil.getInstance(this.context).get(this.getFormPreferenceKey());
      const formDataInfo = PreferenceUtil.getInstance().get('formDataInfo') as object;
      return formBindingData.createFormBindingData(formDataInfo);
    } else {
      return formBindingData.createFormBindingData({});
    }
  }


  onRemoveForm(formId: string) {
    Logger.info(TAG, `[WidgetAbility] onRemoveForm ${formId}`);
    try {
      PreferenceUtil.getInstance(this.context).removeFromArray(this.getFormPreferenceKey(), formId);
    } catch (e) {
      Logger.error(TAG, `[WidgetAbility] onRemoveForm error: ${e}`);
    }
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }


  private getFormPreferenceKey() {
    return 'order_status_widget_form_id';
  }
};