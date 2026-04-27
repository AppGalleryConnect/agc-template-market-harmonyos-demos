import { common } from '@kit.AbilityKit';
import { commentManager } from '@kit.AppGalleryKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { COMMENT_DURATION, STAY_TIME } from '../constant/Index';
import { ForegroundFlag, CommentTimeParm } from '../model/Index';


export class CommentUtil {
  public static setForegroundFlag() {
    let foregroundFlag: ForegroundFlag = AppStorageV2.connect(ForegroundFlag, () => new ForegroundFlag())!;
    foregroundFlag.time = new Date().getTime();
  }

  public static toComment(uiContext: common.UIAbilityContext) {
    let current = new Date().getTime();
    let foregroundFlag: ForegroundFlag = AppStorageV2.connect(ForegroundFlag, () => new ForegroundFlag())!;
    // 连续使用app一段时间
    if (current - foregroundFlag.time > STAY_TIME) {
      CommentUtil.handleCommentDuration(uiContext);
    }
  }

  // 评论弹窗必须间隔一段时间弹出
  private static handleCommentDuration(uiContext: common.UIAbilityContext) {
    let commentTimeParm = PersistenceV2.connect(CommentTimeParm, () => new CommentTimeParm())!;
    if (commentTimeParm.time !== 0) {
      const curTime = new Date().getTime();
      const duration = curTime - commentTimeParm.time;
      if (duration >= COMMENT_DURATION) {
        CommentUtil.showComment(uiContext);
      }
    } else {
      CommentUtil.showComment(uiContext);
    }
  }

  private static showComment(uiContext: common.UIAbilityContext) {
    try {
      commentManager.showCommentDialog(uiContext).then(() => {
        Logger.info('succeeded in showing commentDialog.');
        const time = new Date().getTime();
        let commentTime: CommentTimeParm = PersistenceV2.connect(CommentTimeParm, () => new CommentTimeParm())!;
        commentTime.time = time;
      }).catch((error: BusinessError<Object>) => {
        Logger.error(`showCommentDialog failed, Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      Logger.error(`showCommentDialog failed, Code: ${error.code}, message: ${error.message}`);
    }
  }
}