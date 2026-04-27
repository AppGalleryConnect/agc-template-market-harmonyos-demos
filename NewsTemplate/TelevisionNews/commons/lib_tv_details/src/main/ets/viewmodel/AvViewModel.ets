import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { AvModel, MineServiceApi } from 'lib_tv_apis';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';

const TAG = '[AvViewModel]';

@ObservedV2
export class AvViewModel extends BaseViewModel {
  @Trace curAudioInfo: AvModel = new AvModel();

  public registerCustomTransition(navDestContext: NavDestinationContext, longTakeSession: LongTakeAnimationProperties) {
    let param = navDestContext.pathInfo?.param as Record<string, Object>;
    let longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(navDestContext, longTakeTransitionParam, {
        pop: () => {
          navDestContext.pathStack.pop()
        },
      });
    }
  }

  /**
   * 订阅操作
   * @param avInfo 音频信息
   * @param isLoginCb 是否登录回调
   * */
  public followOperation(avInfo: AvModel, isLoginCb?: (isLogin: boolean) => void) {
    isLoginCb?.(this.userInfoModel.isRelative)
    if (!this.userInfoModel.isRelative) {
      this.contextModel.globalUIContext.getPromptAction().showToast({ message: '请先关联账号~' })
      return
    }
    if (!avInfo.isFollow) {
      avInfo.isFollow = true
      this.addFollow(avInfo.id)
      return
    }
    this.cancelFollow(avInfo.id, () => {
      avInfo.isFollow = false
    })
  }

  public addFollow(subscribeId: string) {
    MineServiceApi.AddSubscribeWatch(subscribeId)
  }

  public cancelFollow(subscribeId: string, cb: () => void) {
    CommonConfirmDialog.show({
      content: '确定不再订阅TA？',
      confirm: () => {
        MineServiceApi.cancelSubscribeWatch(subscribeId);
        cb()
      },
    })
  }
}