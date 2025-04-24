import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { CardManager, FormDataClass, Subscriber as SubscriberClass } from 'common';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    let formId: string = ''
    if (want?.parameters) {
      formId = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string
      if (formId) {
        // 保存获取到formId,后续手动调用刷新
        CardManager.get().saveCardId(this.context, formId)
        SubscriberClass.publish(SubscriberClass.eventFormId, formId)
      }
    }
    let formData = new FormDataClass();
    const bindingData: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    // 定义需要通过Push Kit代理刷新的字段，每个key均需要在上面bindingData中定义
    const text_key: formBindingData.ProxyData = {
      key: 'orderState',
      subscriberId: formId,
    };
    bindingData.proxies = [text_key];
    return bindingData;
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
    CardManager.get().saveCardId(this.context, formId)
    CardManager.get().updateCard(this.context, formId)
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    console.log('onUpdateForm start')
    let initFormData = new FormDataClass();
    let formData: formBindingData.FormBindingData = formBindingData.createFormBindingData(initFormData);
    formProvider.updateForm(formId, formData).catch((error: BusinessError) => {
      console.error('onUpdateForm error:' + error.message)
    });
  }

  onFormEvent(formId: string, message: string) {

    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    CardManager.get().clearCardId(this.context)
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};