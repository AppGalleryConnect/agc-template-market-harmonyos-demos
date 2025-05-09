import { CheckInActivity, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';

@ObservedV2
export class MyCheckInVM {
  @Trace taskList: CheckInActivity[] = [];
  @Trace isLoading: boolean = false;
  private static _instance: MyCheckInVM;

  public static get instance() {
    if (!MyCheckInVM._instance) {
      MyCheckInVM._instance = new MyCheckInVM();
    }
    return MyCheckInVM._instance;
  }

  public async getMyCheckIn() {
    this.isLoading = true;
    const res = await https.getCheckInActivityListOrdered();
    if (res.ret.code === 0) {
      this.taskList = res.result.list;
    }
    this.isLoading = false;
  }

  public jumpToTaskPage(task: CheckInActivity) {
    RouterModule.push({
      url:RouterMap.ACTIVITY_TASK,
      param:task.activityId,
    });
  }
}