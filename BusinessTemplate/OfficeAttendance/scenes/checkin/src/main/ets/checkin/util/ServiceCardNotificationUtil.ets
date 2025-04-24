import { CheckInStatus } from '@ohos_agcit/office_attendance_common_lib/src/main/ets/constants/CheckInEnums';
import { preferences } from '@kit.ArkData';
import { formBindingData, formProvider } from '@kit.FormKit';
import { Logger } from '@ohos_agcit/office_attendance_common_lib';
import { RequestProxy } from '../../api/RequestProxy';
import { CheckInHistoryDetailDataItem } from '../../types/Types';

const TAG: string = '[ServiceCardNotificationUtil]';

export class ServiceCardNotificationUtil {
  public static notify(checkInStatus: CheckInStatus) {
    const preference = preferences.getPreferencesSync(getContext(), {
      'name': 'service_card'
    });

    let key: string = 'formIds';
    const formIds = preference.getSync(key, '') as string;
    if (formIds === '') {
      return;
    }

    const formIdArray = formIds.split(',');
    RequestProxy.getTodayCheckInDetail().then((value: CheckInHistoryDetailDataItem[]) => {
      const startTime = value[0].time;
      const endTime = value[value.length - 1].time;
      formIdArray.forEach((formId: string) => {
        let formMsg: formBindingData.FormBindingData =
          formBindingData.createFormBindingData({
            startTime: startTime,
            endTime: endTime,
            checkInStatus: checkInStatus
          });
        formProvider.updateForm(formId, formMsg).then(() => {
          Logger.info(TAG, `updateForm success.`);
        }).catch((error: Error) => {
          Logger.error(TAG, `updateForm failed: ${JSON.stringify(error)}`);
        });
      })
    });

  }
}