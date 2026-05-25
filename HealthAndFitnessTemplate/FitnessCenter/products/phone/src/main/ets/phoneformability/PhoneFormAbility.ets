import {
  BookingInfo,
  BookingRecordInfo,
  BookState,
  ConsumeType,
  CourseBookingInfo,
  CourseDetailModel,
  DateUtil,
  MockService,
  JumpLogin,
  LoginState,
  Logger,
  PreferenceUtil,
  CardManager,
} from 'external_interactions';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { AppStorageV2 } from '@kit.ArkUI';

const TAG: string = '[PhoneFormAbility]';

export class FormData {
  formDimension: number = 2;
  bookRecordList: BookingRecordInfo[] = [];
  courseBookingList: CourseBookingInfo[] = [];
  courseDetailList: CourseDetailModel[] = [];
}

export default class PhoneFormAbility extends FormExtensionAbility {
  pref: preferences.Preferences | null = null;

  onAddForm(want: Want) {
    this.pref = preferences.getPreferencesSync(this.context, { name: 'myStore' });
    if (!this.pref || !want || !want.parameters) {
      Logger.info(TAG, `FormAbility onAddForm preferences or want or want.parameters is undefined`);
      return formBindingData.createFormBindingData('');
    }
    let formId = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string
    let formDimension = want.parameters[formInfo.FormParam.DIMENSION_KEY] as number
    let formData = this.getFormData(formDimension);
    let bindingData = formBindingData.createFormBindingData(formData);
    try {
      PreferenceUtil.getInstance(this.context).putToArray(CardManager.KEY_CARD_ID, formId)
    } catch (e) {
      Logger.error(TAG, `onAddForm error: ${e}`);
    }
    return bindingData
  }

  getFormData(formDimension: number): FormData{
    let bookRecordList: BookingRecordInfo[] = []
    let courseBookingList: CourseBookingInfo[] = []
    let courseDetailList: CourseDetailModel[] = []
    if(this.pref){
      try {
        let bookingListStr = this.pref.getSync('booking', '');
        let bookingList = JSON.parse(bookingListStr.toString()) as BookingRecordInfo[]
        bookRecordList = this.getBookingListByState(BookState.TO_BE_USE, bookingList)
        courseBookingList = this.getCourseBookingList(bookRecordList);

        let courseDetailStr = this.pref.getSync('courses', '');
        courseDetailList = JSON.parse(courseDetailStr.toString()) as CourseDetailModel[]
      } catch (error) {
        // TODO: Implement error handling.
        Logger.error(TAG, `Failed to get formdata. error Code: ${error.code}, message: ${error.message}`)
      }
    } else {
      Logger.error(TAG, `preferences do not exist.`)
    }
    let formData: FormData = {
      formDimension: formDimension,
      bookRecordList: bookRecordList,
      courseBookingList: courseBookingList,
      courseDetailList: courseDetailList,
    };
    return formData
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
    PreferenceUtil.getInstance(this.context).removeFromArray(CardManager.KEY_CARD_ID, formId)
    Logger.info(TAG, `remove formId: ${formId}`);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  getBookingListByState(bookingState: BookState, bookingList: BookingRecordInfo[]): BookingRecordInfo[] {
    let list: BookingRecordInfo[] = [];
    let now: Date = new Date();
    bookingList.forEach((item: BookingRecordInfo) => {
      if (item.bookState === BookState.TO_BE_USE) {
        let bookingInfo = this.getCourseBookingByIdFromPref(item.courseBookingId)
        // 超时订单更新订单状态为已过期
        if (DateUtil.parseDateString(item.bookingDate + ' ' + bookingInfo.timeStart).getTime() <= now.getTime()) {
          item.bookState = BookState.EXPIRED
        }
      }
      if (item.bookState === bookingState || bookingState === BookState.ALL) {
        list.push(item)
      }
    })
    return list;
  }

  getCourseBookingList(bookingList: BookingRecordInfo[]): CourseBookingInfo[] {
    let list: CourseBookingInfo[] = []
    bookingList.forEach((item: BookingRecordInfo) => {
      let courseBooking = this.getCourseBookingByIdFromPref(item.courseBookingId)
      list.push(courseBooking)
    })
    return list
  }

  getCourseBookingByIdFromPref(id: string): CourseBookingInfo {
    let courseBookingMap: Map<string, CourseBookingInfo> = new Map();
    try {
      let courseBookingMapStr = this.pref?.getSync('courseBookingMap', '');
      if (courseBookingMapStr && typeof courseBookingMapStr === 'string') {
        courseBookingMap = new Map<string, CourseBookingInfo>(JSON.parse(courseBookingMapStr) as []);
      }
    } catch (error) {
      Logger.info(TAG, `getCourseBookingById error: ${error.message}`);
    }
    return courseBookingMap?.get(id) ?? MockService.courseBookingMap.get(id)!
  }
}