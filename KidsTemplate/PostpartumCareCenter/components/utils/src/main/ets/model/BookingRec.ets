import { ActivityBookingRecordModel } from './activity/ActivityBookingRecordModel';

@ObservedV2
export class BookingRec{
  @Trace activityBookingRecords? : ActivityBookingRecordModel[];

  constructor() {
    this.activityBookingRecords = [];
  }
}