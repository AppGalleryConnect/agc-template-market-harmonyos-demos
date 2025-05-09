import { UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { FrameworkUtil, Logger, RouterMap, RouterModule, TabsIndexMap } from 'commonlib';
import { buffer } from '@kit.ArkTS';
import auth from '@hw-agconnect/auth';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onCreate(want: Want): void {
    // 认证服务初始化
    let file = this.context.resourceManager.getRawFileContentSync('agconnect-services.json');
    let json: string = buffer.from(file.buffer).toString();
    auth.init(this.context, json);

    // 获取router事件中传递的targetPage参数
    Logger.info(TAG, `Ability onCreate: ${JSON.stringify(want?.parameters)}`);
    if (want?.parameters?.params) {
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      const cardType = params.cardType as string;
      const message = params.message as string;
      this.handleWantInfo(cardType, message);
    }
  }

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  public onNewWant(want: Want): void {
    Logger.info(TAG, `Ability onNewWant: ${JSON.stringify(want?.parameters)}`);
    if (want?.parameters?.params) {
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      const cardType = params.cardType as string;
      const message = params.message as string;
      const data = params.data as string;
      this.handleWantInfo(cardType, message, data);
    }
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/EmptyPage', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
  }

  public handleWantInfo(cardType: string, message: string, data?: string) {
    if (cardType === 'mini') {
      if (message === 'home') {
        FrameworkUtil.switchTab(TabsIndexMap.HOME);
      } else if (message === 'checkIn') {
        FrameworkUtil.switchTab(TabsIndexMap.CHECK_IN);
      }
    } else if (cardType === 'middle') {
      if (message === 'home') {
        FrameworkUtil.switchTab(TabsIndexMap.HOME);
      } else if (message === 'courseDetail' && data) {
        const courseId: number | undefined = JSON.parse(data)?.courseId;
        if (courseId) {
          RouterModule.clear();
          RouterModule.push({
            url: RouterMap.COURSE_DETAIL,
            param: {
              courseId,
            },
          });
        }
      }
    }
  }
}
