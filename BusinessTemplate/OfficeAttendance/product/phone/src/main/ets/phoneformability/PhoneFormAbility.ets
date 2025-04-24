import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { DateUtils, Logger } from '@ohos_agcit/office_attendance_common_lib';
import { preferences } from '@kit.ArkData';
import { CheckInHistoryDataItem } from '@ohos_agcit/office_attendance_checkin/src/main/ets/types/Types';

const TAG = '[PhoneFormAbility]';

interface SimpleCheckInDetail {
  startTime: string;
  endTime: string;
}

export default class PhoneFormAbility extends FormExtensionAbility {
  private static DEFAULT_TIME: string = '--:--:--';

  onAddForm(want: Want) {
    if (!want || !want.parameters) {
      Logger.error(TAG, `FormAbility onAddForm want or want.parameters is undefined`);
      return formBindingData.createFormBindingData('');
    }

    let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string;

    this.saveFormId(formId)
    return formBindingData.createFormBindingData(this.getTodayCheckInDetail());
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
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  getTodayCheckInDetail(): SimpleCheckInDetail {
    // 理论上应该调接口查询，这里简化处理，直接查询preferences
    const defaultTime: SimpleCheckInDetail = {
      startTime: PhoneFormAbility.DEFAULT_TIME, endTime: PhoneFormAbility.DEFAULT_TIME
    };

    const checkInDetails = preferences.getPreferencesSync(this.context, {
      'name': 'checkin-detail'
    }).getSync('checkin', '');

    if (checkInDetails === '') {
      return defaultTime;
    }

    let checkInDetailArray: CheckInHistoryDataItem[] = JSON.parse(checkInDetails as string);
    const latestCheckInRecord = checkInDetailArray[5];
    if (DateUtils.isToday(latestCheckInRecord.day)) {
      let details = latestCheckInRecord.details;
      return {
        startTime: details[0].time, endTime: details[details.length -1].time
      };
    }

    return defaultTime;
  }

  saveFormId(formId: string) {
    const preference = preferences.getPreferencesSync(this.context, {
      'name': 'service_card'
    });

    let key: string = 'formIds';
    const formIds = preference.getSync(key, '') as string;
    if (formIds as string === '') {
      preference.putSync(key, formId);
    } else {
      preference.putSync(key, formIds + ',' + formId)
    }

    preference.flush();
  }
}