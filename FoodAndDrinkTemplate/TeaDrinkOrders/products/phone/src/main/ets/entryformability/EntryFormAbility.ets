import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { CardManager, PreferenceUtil } from 'common';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    let formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    console.info(`[EntryFormAbility] onAddForm formId: ${formId}`);
    if (!formId) {
      return formBindingData.createFormBindingData({
        text: 'onAddFormWithoutFormId',
      });
    }
    try {
      PreferenceUtil.getInstance(this.context).putToArray(this.getFormPreferenceKey(), formId)
    } catch (e) {
      console.error(`[EntryFormAbility] onAddForm error: ${e}`);
    }
    return formBindingData.createFormBindingData({});
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
      PreferenceUtil.getInstance(this.context).removeFromArray(CardManager.KEY_CARD_ID, formId)
    } catch (e) {
      console.error(`[EntryFormAbility] onRemoveForm error: ${e}`);
    }
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  private getFormPreferenceKey() {
    return `card_id`
  }
};