import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { CardInfo, Logger, PreferenceUtil, WidgetCardModel } from 'lib_foundation';

const TAG: string = '[PhoneFormAbility]';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    let formId: string = ''
    let formDimension = 2;
    if (want?.parameters) {
      formId = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string
      // 获取卡片类型
      formDimension = want.parameters[formInfo.FormParam.DIMENSION_KEY] as number
      Logger.info(TAG, `want.parameters formId: ${formId}`);
    }
    let cardInfo: CardInfo = { formId, formDimension };
    try {
      PreferenceUtil.getInstance(this.context).putToArray('card_id', JSON.stringify(cardInfo));
    } catch (e) {
      Logger.error(TAG, `onAddForm error: ${e}`);
    }
    const formData = PreferenceUtil.getCardDataArray(this.context);
    Logger.info(TAG, `onAddForm formData: ${formData}`);
    return formBindingData.createFormBindingData(JSON.parse(formData));
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  async onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    Logger.info(TAG, `onUpdateForm, formId = ${formId}`);
    const formData = PreferenceUtil.getCardDataArray(this.context);
    Logger.info(TAG, `onUpdateForm formData: ${formData}`);
    PreferenceUtil.updateCard(JSON.parse(formData) as WidgetCardModel, this.context, formId)
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    Logger.info(TAG, `onRemoveForm, formId = ${formId}`);
    PreferenceUtil.removeCard(formId, this.context)
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};