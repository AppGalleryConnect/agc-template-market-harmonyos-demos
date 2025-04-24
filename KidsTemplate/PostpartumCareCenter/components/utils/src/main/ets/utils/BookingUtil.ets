import { BookingRec } from '../model/BookingRec';
import { ActivityBookingStates, CommonConstants } from '../constants/CommonContants';
import { Logger } from './Logger';
import { ActivityBookingRecordModel } from '../model/activity/ActivityBookingRecordModel';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG = '[BookingUtil]';
@ObservedV2
export class BookingUtil {
  @Trace private static _bookingRec: BookingRec = PersistenceV2.connect(BookingRec,
    CommonConstants.STORE_KEY_ACTIVITY_BOOKING_RECORD, () => new BookingRec())!;

  public static getActivityBookingRec() : ActivityBookingRecordModel[]{
    if (BookingUtil._bookingRec.activityBookingRecords === undefined){
      return [];
    }
    return BookingUtil._bookingRec.activityBookingRecords;
  }

  public static addActivityBookingRec(newRec: ActivityBookingRecordModel){
    newRec.id = BookingUtil.getActivityBookingRec().length;
    newRec.state = ActivityBookingStates.BOOKING_SUCCESS;
    BookingUtil._bookingRec.activityBookingRecords?.push(newRec);
    Logger.info(TAG,JSON.stringify(BookingUtil._bookingRec));
  }
}