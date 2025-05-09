import { CheckInActivity, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';

@ObservedV2
export class CheckInActivityVM {
  @Trace activityList: CheckInActivity[] = [];
  @Trace isLoading: boolean = false;
  private static _instance: CheckInActivityVM;

  public static get instance() {
    if (!CheckInActivityVM._instance) {
      CheckInActivityVM._instance = new CheckInActivityVM();
    }
    return CheckInActivityVM._instance;
  }

  public async getActivityList() {
    this.isLoading = true;
    const res = await https.getCheckInActivityList();
    if (res.ret.code === 0) {
      this.activityList = res.result.list;
    }
    this.isLoading = false;
  }

  public jumpToActivityIntroPage(activity: CheckInActivity) {
    RouterModule.push({
      url:RouterMap.ACTIVITY_INTRODUCTION,
      param:activity.activityId,
    });
  }
}