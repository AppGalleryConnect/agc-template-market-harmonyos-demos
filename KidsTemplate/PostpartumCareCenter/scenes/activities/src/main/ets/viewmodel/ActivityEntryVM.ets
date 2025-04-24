import { ACTIVITY_LIST } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { ActivityBookingRecordModel, ActivityModel, RouterModule } from '@ohos_agcit/postpartum_care_center_utils';

@ObservedV2
export class ActivityEntryVM {
  @Trace navStack: NavPathStack = RouterModule.getStack();
  @Trace activityList: ActivityModel[] = [];
  @Trace allBookingRecStr: String | undefined;
  private static _instance: ActivityEntryVM;
  @Trace cityName: string = '全部';
  @Trace type: string = '全部';

  public static get instance() {
    if (!ActivityEntryVM._instance) {
      ActivityEntryVM._instance = new ActivityEntryVM();
    }
    return ActivityEntryVM._instance;
  }

  public static addBookingRec(activityBookingRecord: ActivityBookingRecordModel) {
    /*    // String.toString(this.allBookingRecStr);
        let x : String = new String('xxx');
        x.toString();
        // his.allBookingRecStr.
        //let allBookingRec : ActivityBookingRecordModel[] = JSON.parse(this.allBookingRecStr)*/
  }

  public async init() {
    this.activityList = ACTIVITY_LIST;
  }
}