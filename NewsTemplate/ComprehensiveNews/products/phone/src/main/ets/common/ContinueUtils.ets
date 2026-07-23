import { AbilityConstant, common, wantConstant } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { ContinueModel, Logger } from 'lib_common';

const TAG = '[ContinueUtils]';

/**
 * 应用接续工具类
 */
export class ContinueUtils {
  /**
   * 源应用接续事件处理
   * @param wantParam
   * @param context
   * @returns
   */
  public static handleContinue(wantParam: Record<string, Object>,
    context: common.UIAbilityContext): AbilityConstant.OnContinueResult {
    // 获取迁移对端应用的版本号
    const targetVersion = wantParam.version;
    // 替换为应用自己支持兼容的最小版本号
    const versionThreshold: number = 0;
    if (targetVersion < versionThreshold) {
      // 建议在校验版本兼容性失败后，提示用户拒绝迁移的原因
      try {
        const window = context.windowStage.getMainWindowSync();
        const prompt = window.getUIContext().getPromptAction();
        prompt.showToast({
          message: '目标端应用版本号过低，不支持接续，请您升级应用版本后再试',
          duration: 2000,
        });
      } catch (error) {
        Logger.error(TAG, 'showToast fail, error: ' + JSON.stringify(error));
      }
      return AbilityConstant.OnContinueResult.MISMATCH;
    }
    Logger.info(TAG, `onContinue targetVersion = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);
    const continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
    if (continueModel.newsId) {
      wantParam.newsId = continueModel.newsId;
      wantParam.newsType = continueModel.newsType;
      wantParam.playerProgress = continueModel.playerProgress;
      wantParam.scrollOffset = continueModel.scrollOffset;
      wantParam.breakpoint = continueModel.breakpoint;
    }
    Logger.info(TAG, 'continue params: ' + JSON.stringify(continueModel));
    // 迁移成功后，不退出迁移源端应用
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] = false;
    return AbilityConstant.OnContinueResult.AGREE;
  }

  /**
   * 关闭迁移能力
   */
  public static disableContinue(context: common.UIAbilityContext) {
    context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE)
      .then(() => {
        Logger.info(TAG, 'success setMissionContinueState: INACTIVE');
      })
      .catch(() => {
        Logger.error(TAG, 'fail setMissionContinueState: INACTIVE');
      });
  }
}