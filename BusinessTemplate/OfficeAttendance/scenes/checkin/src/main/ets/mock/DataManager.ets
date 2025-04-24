// PreferencesManager.ets（数据存储）
import preferences from '@ohos.data.preferences';
import { DateUtils } from '@ohos_agcit/office_attendance_common_lib';
import { CheckInDetailRecord, CheckInHistoryDataItem, CheckInHistoryDetailDataItem } from '../types/Types';


export class DataManager {
  private static CHECK_IN_KEY: string = 'checkin';
  private static IS_QUICK_CHECK_IN_KEY: string = 'isQuickCheckIn';
  private static DEFAULT_TIME: string = '--:--:--';
  private static DEFAULT_LOCATION: string = '--------';
  private static CHECK_IN_HISTORY_QUEUE: CheckInHistoryDataItem[] = [{
    'day': '2025-02-11',
    'dayOfWeek': 2,
    'details': [
      {
        'time': '07:59:56',
        'location': '华为南京基地'
      }, {
      'time': '22:34:23',
      'location': '华为南京基地'
    }
    ]
  }, {
    'day': '2025-02-12',
    'dayOfWeek': 3,
    'details': [
      {
        'time': '07:55:45',
        'location': '南京研究所'
      }, {
      'time': '20:08:12',
      'location': '华为南京基地'
    }
    ]
  }, {
    'day': '2025-02-13',
    'dayOfWeek': 4,
    'details': [
      {
        'time': '08:17:46',
        'location': '南京研究所'
      }, {
      'time': '20:55:04',
      'location': '华为南京基地'
    }
    ]
  }, {
    'day': '2025-02-14',
    'dayOfWeek': 5,
    'details': [
      {
        'time': '08:17:45',
        'location': '南京研究所'
      }, {
      'time': '--:--:--',
      'location': '--------'
    }
    ]
  }, {
    'day': '2025-02-17',
    'dayOfWeek': 1,
    'details': [
      {
        'time': '08:20:26',
        'location': '南京研究所'
      }, {
      'time': '21:54:04',
      'location': '南京研究所'
    }, {
      'time': '21:54:25',
      'location': '华为南京基地'
    }
    ]
  }, {
    'day': '2025-02-18',
    'dayOfWeek': 2,
    'details': [
      {
        'time': '08:01:25',
        'location': '南京研究所'
      }, {
      'time': '22:10:52',
      'location': '华为南京基地'
    }
    ]
  }];

  static init() {
  }

  static queryCheckInHistories(): CheckInHistoryDataItem[] {
    return DataManager.getCheckInDetails().slice().reverse();
  }

  static getTodayCheckInDetail(): CheckInHistoryDetailDataItem[] {
    let checkInDetails: CheckInHistoryDataItem[] = DataManager.getCheckInDetails();
    const latestCheckInRecord = checkInDetails[5];
    if (DateUtils.isToday(latestCheckInRecord.day)) {
      return latestCheckInRecord.details;
    }

    return [{ time: DataManager.DEFAULT_TIME, location: DataManager.DEFAULT_LOCATION },
      { time: DataManager.DEFAULT_TIME, location: DataManager.DEFAULT_LOCATION }];
  }

  static addCheckInDetail(value: CheckInDetailRecord) {
    let checkInDetails: CheckInHistoryDataItem[] = DataManager.getCheckInDetails();
    const latestCheckInRecord = checkInDetails[5];
    const detailItem: CheckInHistoryDetailDataItem = { time: value.time, location: value.location };
    if (latestCheckInRecord.day === value.day) {
      if (latestCheckInRecord.details[1].time === DataManager.DEFAULT_TIME) {
        latestCheckInRecord.details[1] = detailItem
      } else {
        latestCheckInRecord.details.push(detailItem)
      }
    } else {
      const dataItem: CheckInHistoryDataItem = {
        day: value.day,
        dayOfWeek: value.dayOfWeek,
        details: [detailItem, { time: DataManager.DEFAULT_TIME, location: DataManager.DEFAULT_LOCATION }]
      }
      checkInDetails.shift();
      checkInDetails.push(dataItem)
    }
    DataManager.getPreferences().putSync(DataManager.CHECK_IN_KEY, JSON.stringify(checkInDetails));
    DataManager.getPreferences().flush();
  }

  static saveIsQuickCheckIn(value: boolean) {
    DataManager.getPreferences().putSync(DataManager.IS_QUICK_CHECK_IN_KEY, value);
    DataManager.getPreferences().flush();
  }

  static isQuickCheckIn() {
    let isQuickCheckIn = DataManager.getPreferences().getSync(DataManager.IS_QUICK_CHECK_IN_KEY, '');
    if (isQuickCheckIn === '') {
      return false;
    }

    return isQuickCheckIn as boolean;
  }

  private static getCheckInDetails(): CheckInHistoryDataItem[] {
    let checkInDetails = DataManager.getPreferences().getSync(DataManager.CHECK_IN_KEY, '');
    if (checkInDetails === '') {
      return DataManager.CHECK_IN_HISTORY_QUEUE;
    }

    return JSON.parse(checkInDetails as string);
  }

  static getPreferences() {
    return preferences.getPreferencesSync(getContext(), { 'name': 'checkin-detail' })
  }
}