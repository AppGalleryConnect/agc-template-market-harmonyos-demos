import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { LunarModel,Https } from 'common';
import dayjs from 'dayjs';


export default class EntryFormAbility extends FormExtensionAbility {
  dateInfo: LunarModel | null = null

  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    let formData = '';
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    this.updateDateInfo(formId)
  }

  onFormEvent(formId: string, message: string) {
    this.updateDateInfo(formId)
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }


  updateDateInfo(formId: string) {
    let curDate = dayjs()
    Https.getOldAlmanac({
      date: curDate.format('YYYY-MM-DD')
    }).then((resp) => {
      if (resp) {
        const dateInfo = new LunarModel(curDate, resp)
        dateInfo.yangli = dateInfo.dayjsObj.format('YYYY年MM月DD日')
        let formInfo = formBindingData.createFormBindingData({
          dateInfo
        })
        formProvider.updateForm(formId, formInfo).then((data) => {
          console.info('FormAbility updateForm success.' + JSON.stringify(data));
        })
      }
    })
  }
};