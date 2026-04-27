import { AppStorageV2 } from '@kit.ArkUI'
import { AccountUtil } from 'commonlib';
import { CommentModel } from '../model/CommentModel'

@ObservedV2
export class CommentStore {
  @Trace initRecipeId = 1;
  @Trace commentList: CommentModel[] = []
  private initCommentList: CommentModel[] = JSON.parse(JSON.stringify(this.commentList))

  // ── 查询：按 recipeId 过滤 ──────────────────
  getByRecipeId(recipeId: number): CommentModel[] {
    return this.commentList.filter(c => c.recipeId === recipeId)
  }

  addComment(
    recipeId: number,
    authorId: number,
    nickName: string,
    icon: ResourceStr,
    comment: string,
    score: number
  ) {
    const maxId = this.commentList.reduce(
      (max, c) => Math.max(max, c.commentId), 0
    )
    const newComment: CommentModel = {
      recipeId: recipeId,
      commentId: maxId + 1,
      authorId: authorId,
      nickName: nickName,
      icon: AccountUtil.getUserInfo().avatar,
      comment: comment,
      time: Date.now(),
      score: score,
    }
    this.commentList.unshift(newComment)
    this.commentList.forEach(item => {
      item.icon = AccountUtil.getUserInfo().avatar;
    })
  }

  // ── 删除 ────────────────────────────────────
  removeComment(commentId: number) {
    this.commentList = this.commentList.filter(c => c.commentId !== commentId)
  }

  // ── 单例 ────────────────────────────────────
  static instance(): CommentStore {
    return AppStorageV2.connect(CommentStore, 'CommentStore', () => new CommentStore())!
  }
}