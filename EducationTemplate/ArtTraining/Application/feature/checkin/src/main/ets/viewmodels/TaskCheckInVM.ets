import {
  CheckInActivity,
  RouterMap,
  RouterModule,
  TaskCheckInStatus,
  CheckInTaskItem,
  CheckInRecord,
  PickerPreviewItem,
  PickerResourceType,
} from 'commonlib';
import { https } from 'network';
import { CheckInLogRouteParam, TaskCheckInPopParam } from '../types/Index';

@ObservedV2
export class CheckInTaskVM {
  // 任务信息
  @Trace activity: CheckInActivity | null = null;
  @Trace taskDirectory: CheckInTaskItem[] = [];
  @Trace currentTask: CheckInTaskItem | null = null;
  @Trace historyRecordList: CheckInRecord[] = [];
  @Trace currentIndex: number = 0;
  @Trace showMoreTask: boolean = false;
  @Trace isLoading: boolean = false;
  tabController: TabsController = new TabsController();
  private static _instance: CheckInTaskVM;
  public readonly DEFAULT_DISPLAY_TASK_NUM = 3;

  public static get instance() {
    if (!CheckInTaskVM._instance) {
      CheckInTaskVM._instance = new CheckInTaskVM();
    }
    return CheckInTaskVM._instance;
  }

  @Computed
  public get displayTaskDirectory() {
    if (this.showMoreTask) {
      return this.taskDirectory.slice();
    }
    return this.taskDirectory.slice(0, this.DEFAULT_DISPLAY_TASK_NUM);
  }

  public async getTaskIntro() {
    this.isLoading = true;
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.ACTIVITY_TASK,
    });
    if (param) {
      const res = await https.getCheckInActivityDetail({ activityId: param });
      if (res.ret.code === 0) {
        this.activity = res.result;
      }
    }
    this.getTaskEntry();
    this.getCheckInRecord();
    this.isLoading = false;
  }

  public getTaskEntry() {
    if (this.activity) {
      this.taskDirectory = this.activity.taskDirectory.slice();
      this.taskDirectory.sort((a, b) => a.taskId - b.taskId);
      this.currentTask = this.taskDirectory.find((item) => item.taskStatus === TaskCheckInStatus.NOT_STARTED)!;
    }
  }

  public async getCheckInRecord() {
    if (this.activity) {
      const res = await https.getUserCheckInRecordList({ activityId: this.activity.activityId });
      if (res.ret.code === 0) {
        this.historyRecordList = res.result.list;
        this.historyRecordList.sort((a, b) => {
          return Number(b.createTime) - Number(a.createTime);
        });
      }
    }
  }

  public getTaskNameById(taskId: number) {
    const item = this.taskDirectory.find((item) => item.taskId === taskId);
    return item?.taskName ?? '';
  }

  public isTaskChecked(item: CheckInTaskItem) {
    if (this.currentTask) {
      return item.taskId < this.currentTask.taskId;
    }
    if (this.historyRecordList.length === this.taskDirectory.length) {
      return true;
    }
    return false;
  }

  public jumpToFullScreenPage(type: PickerResourceType, uri: ResourceStr) {
    const item: PickerPreviewItem = {
      type,
      uri,
    };
    RouterModule.push({
      url: RouterMap.ACTIVITY_FULL_SCREEN_MEDIA,
      param: item,
    });
  }

  public jumpToActivityIntro() {
    RouterModule.push({
      url: RouterMap.ACTIVITY_INTRODUCTION,
      param: 0,
    });
  }

  public jumpToSubmitCheckIn() {
    if (this.activity && this.currentTask) {
      RouterModule.push({
        url: RouterMap.ACTIVITY_SUBMIT,
        param: {
          task: this.currentTask,
          activity: this.activity,
        } as CheckInLogRouteParam,
        onPop: (popInfo) => {
          let result = popInfo.result;
          if (result && (result as TaskCheckInPopParam).needUpdate) {
            this.getTaskIntro();
          }
        },
      });
    }
  }
}