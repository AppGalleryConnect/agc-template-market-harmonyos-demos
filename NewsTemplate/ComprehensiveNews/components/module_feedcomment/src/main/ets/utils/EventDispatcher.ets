import { CommentInfo } from '../model/Model';

export class CommentEventDispatcher {
  static addCommentCallback?: (commentInfo: CommentInfo, parentCommentId: string) => void;
  static giveLikeCallback?: (commentInfo: CommentInfo, isLike: boolean) => void;
  static goUserHome?: (authorId: string) => void;
  static interceptLogin?: (isLoginCb: (isLogin: boolean) => void) => void;
  static deleteComment: (commentId: string) => void;
  static reportComment: (commentId: string) => void;

  static dispatchToAddComment(commentInfo: CommentInfo, parentCommentId: string) {
    if (CommentEventDispatcher.addCommentCallback) {
      CommentEventDispatcher.addCommentCallback(commentInfo, parentCommentId);
    }
  }

  static dispatchToDeleteComment(commentId: string) {
    if (CommentEventDispatcher.deleteComment) {
      CommentEventDispatcher.deleteComment(commentId);
    }
  }

  static dispatchToReportComment(commentId: string) {
    if (CommentEventDispatcher.reportComment) {
      CommentEventDispatcher.reportComment(commentId);
    }
  }

  static dispatchToGiveLike(commentInfo: CommentInfo, isLike: boolean) {
    if (CommentEventDispatcher.giveLikeCallback) {
      CommentEventDispatcher.giveLikeCallback(commentInfo, isLike);
    }
  }

  static dispatchToInterceptLogin(isLoginCb: (isLogin: boolean) => void) {
    if (CommentEventDispatcher.interceptLogin) {
      CommentEventDispatcher.interceptLogin(isLoginCb);
    }
  }

  static dispatchToUserHome(authorId: string) {
    if (CommentEventDispatcher.goUserHome) {
      CommentEventDispatcher.goUserHome(authorId);
    }
  }
}