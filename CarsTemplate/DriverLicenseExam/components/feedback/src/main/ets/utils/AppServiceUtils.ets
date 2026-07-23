import { commentManager } from '@kit.AppGalleryKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { PreferencesUtils, PREF_KEY_LAST_COMMENT_TIME } from './PreferencesUtils';
import { CommentCallback, CommentDialogConfig, ErrorMessage } from '../models/CommentModels';

const TAG = '[AppServiceUtils]';
const DOMAIN = 0;

/**
 * 应用服务工具类
 */
export class AppServiceUtils {
  /**
   * 显示评论弹窗
   * 当前评论弹窗采取达到 "正向阈值" 做基础判断后弹出
   * 正向阈值条件：
   * 间隔天数 默认3天 才会重新弹窗
   * 也可以使用forceShow强制弹窗
   * */
  public static async showCommentDialog(
    context: common.UIAbilityContext,
    config?: CommentDialogConfig,
    callbacks?: CommentCallback
  ): Promise<boolean> {
    const intervalDays = config?.intervalDays ?? 3;
    const forceShow = config?.forceShow ?? false;

    try {
      const preferencesUtils = PreferencesUtils.getInstance();
      await preferencesUtils.init(context);

      if (!forceShow) {
        const canShow = await AppServiceUtils.checkCommentDialogInterval(preferencesUtils, intervalDays);
        if (!canShow) {
          UtilLog.info(DOMAIN, TAG, `Comment dialog skipped: interval of ${intervalDays} days not reached`);
          const errorMessage = new ErrorMessage(0, `Comment dialog skipped: interval of ${intervalDays} days not reached`);
          if (callbacks?.onFailed) {
            callbacks.onFailed(errorMessage);
          }
          return false;
        }
      }
      const showed = await AppServiceUtils.openCommentDialog(context, callbacks);

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
      const errorMessage = new ErrorMessage(0, `showCommentDialogWithInterval failed: ${err.message}`);
      if (callbacks?.onFailed) {
        callbacks.onFailed(errorMessage);
      }
      return false;
    }
  }

  /**
   * 检查是否满足评论弹窗的时间间隔
   * @param preferencesUtils PreferencesUtils实例
   * @param intervalDays 间隔天数
   * @returns 是否可以弹出
   */
  private static async checkCommentDialogInterval(
    preferencesUtils: PreferencesUtils,
    intervalDays: number
  ): Promise<boolean> {
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

      UtilLog.info(
        DOMAIN,
        TAG,
        `Last comment dialog: ${new Date(lastTime).toLocaleString()}, ` +
          `Elapsed: ${Math.floor(elapsed / (24 * 60 * 60 * 1000))} days, ` +
          `Required: ${intervalDays} days`
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
  private static async openCommentDialog(
    context: common.UIAbilityContext,
    callbacks?: CommentCallback
  ): Promise<boolean> {
    return new Promise((resolve) => {
      try {
        commentManager.showCommentDialog(context)
          .then(() => {
            UtilLog.info(DOMAIN, TAG, 'Succeeded in showing commentDialog.');
            if (callbacks?.onSuccess) {
              callbacks.onSuccess();
            }
            resolve(true);
          })
          .catch((error: BusinessError<Object>) => {
            const errorMessage = new ErrorMessage(error.code, error.message);
            if (callbacks?.onFailed) {
              callbacks.onFailed(errorMessage);
            }
            UtilLog.error(DOMAIN, TAG, `showCommentDialog failed, Code: ${error.code}, message: ${error.message}`);
            resolve(false);
          });
      } catch (error) {
        const err = error as BusinessError;
        const errorMessage = new ErrorMessage(err.code, err.message);
        if (callbacks?.onFailed) {
          callbacks.onFailed(errorMessage);
        }
        UtilLog.error(DOMAIN, TAG, `showCommentDialog failed, Code: ${err.code}, message: ${err.message}`);
        resolve(false);
      }
    });
  }
}