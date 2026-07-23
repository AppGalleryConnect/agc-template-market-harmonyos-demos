import { BaseViewModel, RouterMap, RouterModule } from 'commonlib'
import { FeedbackRouteMap } from 'feedback';
import { MenuInfo } from '../model/MineModel';

@ObservedV2
export class MinePageVM extends BaseViewModel {
  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  public menuList: MenuInfo[] = [
    {
      label: '意见反馈',
      icon: $r('app.media.ic_me_feedback'),
      action: () => {
        if (this.userInfo.isLogin) {
          RouterModule.push({ url: FeedbackRouteMap.FeedbackSubmit });
        } else {
          RouterModule.push({
            url: RouterMap.LOGIN_PAGE,
            onPop: () => {
              RouterModule.push({ url: FeedbackRouteMap.FeedbackSubmit })
            }
          })
        }
      },
    },
    {
      label: '设置',
      icon: $r('app.media.setting'),
      action: () => {
        RouterModule.push({ url: RouterMap.SETTING_PAGE });
      },
    },
  ]
}