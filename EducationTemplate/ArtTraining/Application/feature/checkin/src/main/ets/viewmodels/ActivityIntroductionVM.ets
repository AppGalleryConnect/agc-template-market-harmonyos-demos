import { AccountUtil, CheckInActivity, RouterMap, RouterModule } from 'commonlib';
import { https } from 'network';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class ActivityIntroductionVM {
  // 任务信息
  @Trace activity: CheckInActivity | null = null;
  @Trace currentIndex: number = 0;
  @Trace showBottomButton: boolean = true;
  @Trace isLoading: boolean = false;
  tabController: TabsController = new TabsController();
  private static _instance: ActivityIntroductionVM;

  public static get instance() {
    if (!ActivityIntroductionVM._instance) {
      ActivityIntroductionVM._instance = new ActivityIntroductionVM();
    }
    return ActivityIntroductionVM._instance;
  }

  @Computed
  public get bottomButtonLabel() {
    if (!AccountUtil.getUserInfo().phone) {
      return '打卡';
    }
    return this.activity?.orderTime ? '打卡' : '免费参与活动';
  }

  public async getActivityIntro() {
    this.isLoading = true;
    this.currentIndex = 0;
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.ACTIVITY_INTRODUCTION,
    });
    if (typeof param === 'number') {
      if (param === 0) {
        this.showBottomButton = false;
      } else {
        this.showBottomButton = true;
        const res = await https.getCheckInActivityDetail({ activityId: param });
        if (res.ret.code === 0) {
          this.activity = res.result;
        }
      }
    }
    this.isLoading = false;
  }

  public async jumpToTaskPage() {
    if (!AccountUtil.getUserInfo().phone) {
      RouterModule.push({
        url: RouterMap.BIND_PHONE,
      });
      return;
    }
    if (!this.activity) {
      return;
    }
    if (this.activity.orderTime) {
      RouterModule.push({
        url: RouterMap.ACTIVITY_TASK,
        param: this.activity.activityId,
      });
      return;
    } else {
      const res = await https.createCheckInActivityOrder({
        activityId: this.activity.activityId,
      });
      if (res.ret.code === 0) {
        promptAction.showToast({ message: '打卡活动参与成功！' });
        this.getActivityIntro();
        const timer = setTimeout(() => {
          RouterModule.push({
            url: RouterMap.ACTIVITY_TASK,
            param: this.activity!.activityId,
          });
          clearTimeout(timer);
        }, 1000);
      } else {
        promptAction.showToast({ message: '打卡活动参与失败，请稍后重试~' });
      }
    }
  }
}