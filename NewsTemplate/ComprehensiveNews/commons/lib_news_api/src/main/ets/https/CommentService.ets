import request from '../common/BaseRequest';
import { BaseComment } from '../database/CommentType';
import { CommentRequest } from '../params/request/CommonRequest';
import { CommentResponse } from '../params/response/CommentResponse';

/**
 * 评论类
 */
export class CommentService {
  /**
   * 查询单个评论
   * @param commentId
   * @param ignoreReplyInner
   * @returns
   */
  public queryComment(commentId: string, ignoreReplyInner: boolean = false): Promise<CommentResponse | undefined> {
    return request.get('/comment', { params: { commentId, ignoreReplyInner } });
  }

  /**
   * 查询评论列表
   * @param newsId
   * @param ignoreReplyInner
   * @returns
   */
  public queryCommentList(newsId: string, ignoreReplyInner: boolean = false): Promise<CommentResponse[] | undefined> {
    return request.get('/news/comment/list', { params: { newsId, ignoreReplyInner } });
  }

  /**
   * 查询评论的总数
   * @param newsId
   * @returns
   */
  public queryTotalCommentCount(newsId: string): Promise<number> {
    return request.get('/comment/count', { params: { newsId } });
  }

  /**
   * 添加评论
   * @param newItem
   */
  public addComment(newItem: BaseComment) {
    return request.post('/comment/add', newItem);
  }

  /**
   * 删除评论
   * @param commentId
   */
  public deleteComment(commentId: string) {
    const data: CommentRequest = { commentId };
    return request.post('/comment/delete', data);
  }

  /**
   * 点赞评论
   * @param commentId
   */
  public addCommentLike(commentId: string) {
    const data: CommentRequest = { commentId };
    return request.post('/comment/like', data);
  }

  /**
   * 取消点赞评论
   * @param commentId
   */
  public cancelCommentLike(commentId: string) {
    const data: CommentRequest = { commentId };
    return request.post('/comment/like/cancel', data);
  }
}

const instance = new CommentService();

export { instance as CommentServiceApi }