import { commentManager, updateManager } from '@kit.AppGalleryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ErrorMessage } from '../models/ErrorMessageModel';
import { ToastUtils } from './ToastUtils';
import { CheckUpdateCallback, CommentCallback, UpdateCallback } from '../Interface/Interface';
import { CommentDialogConfig } from '../models/CommentModel';
import { PreferencesUtils, PREF_KEY_LAST_COMMENT_TIME } from './PreferencesUtils';
import { UpdateCheckResult } from '../models/UpdateModel';

const TAG = '[AppServiceUtils]';
const DOMAIN = 0;

export class AppServiceUtils {
  private context: UIContext
  private noNewVersionTips: string = '已是最新版本'
  private updateFailedTips: string = '升级版本失败~'
  private onCheckUpdateSuccess: (checkResult: updateManager.CheckUpdateResult) => void = () => {
  }
  private onCheckUpdateFailed: (error: ErrorMessage) => void = () => {
  }
  private onUpdateSuccess: (checkResult: updateManager.ShowUpdateResultCode) => void = () => {
  }
  private onUpdateFailed: (error: ErrorMessage) => void = () => {
  }
  private onCommentSuccess: () => void = () => {
  }
  private onCommentFailed: (error: ErrorMessage) => void = () => {
  }

  constructor(context: UIContext) {
    this.context = context
  }

  /**
   * 检查应用市场是否有新的版本
   * 本地安装版本须低于应用市场在架版本才能检查到更新。
   * 本地安装版本须和应用市场在架版本签名信息保持一致。
   * 暂不支持邀请测试和公开测试。
   * */
  public async checkAppUpdate(): Promise<updateManager.CheckUpdateResult | ErrorMessage> {
    ToastUtils.setContext(this.context)
    try {
      const checkResult = await updateManager.checkAppUpdate(this.context.getHostContext() as common.UIAbilityContext);
      UtilLog.info(DOMAIN, TAG, `Succeeded in checking update, updateAvailable: ${checkResult.updateAvailable}`);
      /**
       * updateAvailable
       * 0 表示无新版本
       * 1 表示有新版本
       * */
      if (checkResult.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
        this.showUpdateDialog(this.context.getHostContext() as common.UIAbilityContext).then((updateInfo) => {
          if (updateInfo !== updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS) {
            ToastUtils.showToast({ message: this.updateFailedTips })
          }
        }).catch((e: ErrorMessage) => {
          ToastUtils.showToast({ message: this.updateFailedTips })
        })
        this.onCheckUpdateSuccess(checkResult)
        UtilLog.info(DOMAIN, TAG, 'New version is available');
      } else {
        ToastUtils.showToast({ message: this.noNewVersionTips })
        this.onCheckUpdateSuccess(checkResult)
        UtilLog.info(DOMAIN, TAG, 'No new version available');
      }

      return checkResult;
    } catch (error) {
      const err = error as BusinessError;
      UtilLog.error(DOMAIN, TAG, `checkAppUpdate failed, code: ${err.code}, message: ${err.message}`);
      let errorMessage = new ErrorMessage(err.code, err.message);
      this.onCheckUpdateFailed(errorMessage)
      return errorMessage;
    }
  }

  /**
   * 显示升级弹框
   * */
  private showUpdateDialog(context: common.UIAbilityContext): Promise<UpdateCheckResult> {
    return new Promise(async (resolve, reject) => {
      try {
        const resultCode = await updateManager.showUpdateDialog(context);
        const success = resultCode === updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS;
        UtilLog.info(DOMAIN, TAG, `showUpdateDialog result: ${success ? 'success' : 'failure'}`);
        this.onUpdateSuccess(resultCode)
        resolve(resultCode);
      } catch (error) {
        const err = error as BusinessError;
        UtilLog.error(DOMAIN, TAG, `showUpdateDialog failed, code: ${err.code}, message: ${err.message}`);
        let errorMessage = new ErrorMessage(err.code, err.message);
        this.onUpdateFailed(errorMessage)
        reject(errorMessage)
      }
    })
  }

  /**
   * 显示评论弹窗
   * 当前评论弹窗采取达到 “正向阈值” 做基础判断后弹出
   * 正向阈值条件：
   * 间隔天数 默认3天 才会重新弹窗
   * 也可以使用forceShow强制弹窗
   * */
  public async showCommentDialog(config?: CommentDialogConfig) {
    const intervalDays = config?.intervalDays ?? 3;
    const forceShow = config?.forceShow ?? false;

    try {
      const preferencesUtils = PreferencesUtils.getInstance();
      await preferencesUtils.init(this.context.getHostContext() as common.UIAbilityContext);

      if (!forceShow) {
        const canShow = await this.checkCommentDialogInterval(preferencesUtils, intervalDays);
        if (!canShow) {
          UtilLog.info(DOMAIN, TAG, `Comment dialog skipped: interval of ${intervalDays} days not reached`);
          let errorMessage =
            new ErrorMessage(0, `Comment dialog skipped: interval of ${intervalDays} days not reached`);
          this.onCommentFailed(errorMessage);
          return false;
        }
      }
      const showed = await this.openCommentDialog();

      // 如果成功弹出，保存当前时间
      if (showed) {
        const now = Date.now();
        await preferencesUtils.put(PREF_KEY_LAST_COMMENT_TIME, now);
        UtilLog.info(DOMAIN, TAG, `Comment dialog showed, saved timestamp: ${now}`);
      }

      return showed;
    } catch (error) {
      const err = error as BusinessError;
      UtilLog.error(DOMAIN, TAG, `showCommentDialogWithInterval failed: ${err.message}`);
      let errorMessage = new ErrorMessage(0, `showCommentDialogWithInterval failed: ${err.message}`);
      this.onCommentFailed(errorMessage);
      return false;
    }
  }

  /**
   * 检查是否满足评论弹窗的时间间隔
   * @param preferencesUtils Preferences工具实例
   * @param intervalDays 间隔天数
   * @returns 是否可以弹出
   */
  private async checkCommentDialogInterval(preferencesUtils: PreferencesUtils, intervalDays: number): Promise<boolean> {
    try {
      const lastTime = await preferencesUtils.get(PREF_KEY_LAST_COMMENT_TIME, 0) as number;

      // 如果从未弹出过，可以弹出
      if (lastTime === 0) {
        UtilLog.info(DOMAIN, TAG, 'Comment dialog never showed before, can show');
        return true;
      }

      const now = Date.now();
      const intervalMs = intervalDays * 24 * 60 * 60 * 1000;
      const elapsed = now - lastTime;

      UtilLog.info(DOMAIN, TAG,
        `Last comment dialog: ${new Date(lastTime).toLocaleString()}, ` +
          `Elapsed: ${Math.floor(elapsed / (24 * 60 * 60 * 1000))} days, ` +
          `Required: ${intervalDays} days`,
      );

      return elapsed >= intervalMs;
    } catch (error) {
      UtilLog.error(DOMAIN, TAG, `Failed to check interval: ${JSON.stringify(error)}`);
      return true;
    }
  }

  /**
   * 评论弹窗主体
   */
  private async openCommentDialog(): Promise<boolean> {
    return new Promise((resolve) => {
      try {
        commentManager.showCommentDialog(this.context.getHostContext() as common.UIAbilityContext)
          .then(() => {
            UtilLog.info(DOMAIN, TAG, 'Succeeded in showing commentDialog.');
            this.onCommentSuccess();
            resolve(true);
          })
          .catch((error: BusinessError<Object>) => {
            let errorMessage = new ErrorMessage(error.code, error.message);
            this.onCommentFailed(errorMessage);
            UtilLog.error(DOMAIN, TAG, `showCommentDialog failed, Code: ${error.code}, message: ${error.message}`);
            resolve(false);
          });
      } catch (error) {
        const err = error as BusinessError;
        let errorMessage = new ErrorMessage(err.code, err.message);
        this.onCommentFailed(errorMessage);
        UtilLog.error(DOMAIN, TAG, `showCommentDialog failed, Code: ${err.code}, message: ${err.message}`);
        resolve(false);
      }
    });
  }

  /**
   * 设置暂无最新版本提示词
   * 需要再方法调用前设置，否则使用默认提示词
   * */
  setNoNewVersionTips(tips: string) {
    this.noNewVersionTips = tips
    return this
  }

  /**
   * 设置升级失败提示词
   * 需要再方法调用前设置，否则使用默认提示词
   * */
  setUpdateFailedTips(tips: string) {
    this.updateFailedTips = tips
    return this
  }

  /**
   * 检查升级状态监听回调
   * */
  setCheckUpdateListener(callbacks: CheckUpdateCallback) {
    if (callbacks.onSuccess) {
      this.onCheckUpdateSuccess = callbacks.onSuccess;
    }
    if (callbacks.onFailed) {
      this.onCheckUpdateFailed = callbacks.onFailed;
    }
    return this;
  }

  /**
   * 升级状态监听回调
   * */
  setUpdateListener(callbacks: UpdateCallback) {
    if (callbacks.onSuccess) {
      this.onUpdateSuccess = callbacks.onSuccess;
    }
    if (callbacks.onFailed) {
      this.onUpdateFailed = callbacks.onFailed;
    }
    return this;
  }

  /**
   * 评论弹窗状态监听回调
   * */
  setCommentListener(callbacks: CommentCallback) {
    if (callbacks.onSuccess) {
      this.onCommentSuccess = callbacks.onSuccess;
    }
    if (callbacks.onFailed) {
      this.onCommentFailed = callbacks.onFailed;
    }
    return this;
  }
}