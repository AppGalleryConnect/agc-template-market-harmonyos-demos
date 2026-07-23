import { PopViewUtils, UserInfoModel } from 'lib_common';
import { PersistenceV2 } from '@kit.ArkUI';
import { CommentParams } from '../model/Model';
import { publishCommentBuilder } from '../components/PublishComment';
import { LoginSheetUtils } from 'lib_account';

@ObservedV2
export class CommentUtils {
  @Trace static userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  /**
   * 打开评论弹窗
   * @param replyAuthor 回复对象
   * @param callback 回复回调事件
   */
  public static commentSheetOpen(replyAuthor: string | null, callback: (replyContent: string) => void) {
    if (!CommentUtils.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    CommentUtils.openPublishComment(replyAuthor, callback)
  }

  public static openPublishComment(replyAuthor: string | null, callback: (replyContent: string) => void) {
    PopViewUtils.showSheet<CommentParams>(wrapBuilder(publishCommentBuilder), {
      showClose: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      preferType: SheetType.BOTTOM,
      detents: [SheetSize.FIT_CONTENT],
      dragBar: true,
    }, new CommentParams(replyAuthor, callback));
  }

  public static formatToK(number: number) {
    if (Math.abs(number) < 1000) {
      return String(number);
    }
    const valueInK = (number / 1000).toFixed(1);
    return valueInK.replace(/\.0$/, '') + 'k';
  }
}