import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { BookingRecordInfo, BookState, CourseBookingInfo, UserCard } from '../model/MockModel';
import { MockService } from '../Service/MockService';
import { Logger } from '../utils/Logger';
import { PreferenceUtil } from './PreferenceUtil';
import { WindowUtil } from '../utils/WindowUtil';

const TAG = '[CardManager]'

export class FormDataClass {
  bookRecordList?: BookingRecordInfo[]
  courseBookingList?: CourseBookingInfo[]

  constructor(bookRecordList: BookingRecordInfo[], courseBookingList: CourseBookingInfo[]) {
    this.bookRecordList = bookRecordList
    this.courseBookingList = courseBookingList
  }
}

export class CardManager {
  static KEY_CARD_ID = 'card_id'
  static KEY_CARD_INFO = 'card_info'
  private static instance: CardManager = new CardManager()

  static get(): CardManager {
    return CardManager.instance
  }

  public getFormIdArray() {
    try {
      preferences.removePreferencesFromCacheSync(WindowUtil.context, { name: 'default' })
    } catch (e) {
      Logger.error(TAG, `PreferenceUtil removePreferencesFromCacheSync failed: ${JSON.stringify(e)}`)
    }
    let preference = preferences.getPreferencesSync(WindowUtil.context, { name: 'default' })
    return PreferenceUtil.getInstance().getWithPreference(preference, CardManager.KEY_CARD_ID) as Array<string>
  }

  public createFormData(data: FormDataClass): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(data);
  }

  async updateCard(formData?: FormDataClass, formId?: string) {
    if (!this.getFormIdArray()) {
      Logger.info(TAG, `updateCard: FormIdArray does not exist`)
      return
    }
    if (!formData) {
      let bookRecordList = MockService.getBookingListByState(BookState.TO_BE_USE)
      let courseBookingList = this.getCourseBookingList(bookRecordList)
      formData = new FormDataClass(bookRecordList, courseBookingList)
    }
    let formInfo = this.createFormData(formData);

    let formIdArray: Array<string> = this.getFormIdArray()
    for (let id of formIdArray) {
      if (formId && id !== formId) {
        continue
      }
      formProvider.updateForm(id, formInfo).then(() => {
        Logger.info(TAG, `updateForm success.`)
      }).catch((error: BusinessError) => {
        Logger.info(TAG, `Operation updateForm failed. Cause: ${JSON.stringify(error)}`);
      })
    }
  }

  getCourseBookingList(bookingList: BookingRecordInfo[]): CourseBookingInfo[] {
    let list: CourseBookingInfo[] = []
    bookingList.forEach((item: BookingRecordInfo) => {
      let courseBooking = MockService.getCourseBookingById(item.courseBookingId)
      list.push(courseBooking)
    })
    return list
  }
}