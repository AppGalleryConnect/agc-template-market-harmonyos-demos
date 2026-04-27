import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { BaseAuthor, MyAuthor } from '../database/AuthorType';
import { BaseComment } from '../database/CommentType';
import { SafeRandomGenerate } from '../utils/SafeRandomNumer';
import {
  AddReservationRequest,
  AuthorRequest,
  DeleteCommentRequest,
  ModifyPersonalInfoRequest,
  NewsRequest,
  PublishCommentRequest,
  SubscribeRequest,
  UserRequest,
} from '../params/request/CommonRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { AggregateNewsComment } from '../params/response/AggregateResponse';
import { CommentResponse } from '../params/response/CommentResponse';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';
import { CommentServiceMock } from './CommentServiceMock';
import { AuthorServiceMock } from './AuthorServiceMock';
import { AvResponse } from '../params/response/AvResponse';
import { ReservationInfo } from '../database/AuthorType';

/**
 * 我的Mock
 */
export class MineServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();
  private commentMock: CommentServiceMock = new CommentServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 点赞
    adapter.onPost('/my/like/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo.myLikes.splice(0, 0, data.newsId);

      const news = this.baseNewsMock.queryRawNews(data.newsId);
      if(news) {
        news.likeCount++
        news.isLiked = true
      }
      const author = this.authorMock.queryAuthorRaw(news?.authorId);
      if (author?.likeNum) {
        author.likeNum++;
      }

      return [HttpStatusCode.Ok];
    });

    // 取消点赞
    adapter.onPost('/my/like/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.myLikes.findIndex(id => id === data.newsId);
      if (index !== -1) {
        mineUserInfo.myLikes.splice(index, 1);
      }
      const news = this.baseNewsMock.queryRawNews(data.newsId);
      if (news) {
        news.isLiked = false;
        news.likeCount--
      }

      const author = this.authorMock.queryAuthorRaw(news?.authorId);
      if (author?.likeNum) {
        author.likeNum--;
      }

      return [HttpStatusCode.Ok];
    });

    // 查询我的点赞
    adapter.onGet('/my/like/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const list = mineUserInfo.myLikes
        .map((id: string) => {
          return this.baseNewsMock.queryNews(id);
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 查询新增的粉丝
    adapter.onGet('/new/fans/list').reply(() => {
      const list = this.authorMock.queryFollowers('').filter((v, index) => index < 5);
      return [HttpStatusCode.Ok, list];
    });

    // 添加关注
    adapter.onPost('/watch/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AuthorRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo.watchers.splice(0, 0, data.authorId);

      const otherUserInfo = this.authorMock.queryAuthorRaw(data.authorId) as BaseAuthor;
      otherUserInfo.followers.splice(0, 0, mineUserInfo.authorId);

      return [HttpStatusCode.Ok];
    });

    // 取消关注
    adapter.onPost('/watch/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AuthorRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.watchers.findIndex(id => id === data.authorId);
      if (index !== -1) {
        mineUserInfo?.watchers.splice(index, 1);
      }

      const otherUserInfo = this.authorMock.queryAuthorRaw(data.authorId) as BaseAuthor;
      const index1 = otherUserInfo?.followers?.findIndex(id => id === mineUserInfo.authorId);
      if (index !== -1) {
        otherUserInfo?.followers?.splice(index1, 1);
      }

      return [HttpStatusCode.Ok];
    });

    // 订阅公众号
    adapter.onPost('/subscribe/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SubscribeRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo.subscribe.splice(0, 0, data.subscribeId);
      return [HttpStatusCode.Ok];
    });

    // 取消订阅
    adapter.onPost('/subscribe/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SubscribeRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.subscribe.findIndex(id => id === data.subscribeId);
      if (index !== -1) {
        mineUserInfo?.subscribe.splice(index, 1);
      }
      return [HttpStatusCode.Ok];
    });

    // 取消全部订阅
    adapter.onPost('/subscribe/cancel/all').reply((config: AxiosRequestConfig) => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (mineUserInfo) {
        mineUserInfo.subscribe = []
      }
      return [HttpStatusCode.Ok];
    });

    // 查询我的订阅
    adapter.onGet('/my/subscribe/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw(params.userId) as MyAuthor;
      const list = mineUserInfo.subscribe
        .map((id: string) => {
          return this.baseNewsMock.queryRawAv(id);
        })
        .filter(v => Boolean(v)) as AvResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 收藏
    adapter.onPost('/my/mark/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const news = this.baseNewsMock.queryRawNews(data.newsId);
      if (news) {
        news.isMarked = true;
        news.markCount++
      }
      mineUserInfo?.myMarks.splice(0, 0, data.newsId);
      return [HttpStatusCode.Ok];
    });

    // 取消收藏
    adapter.onPost('/mark/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;

      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo?.myMarks.findIndex(id => id === data.newsId);
      if (index !== -1) {
        mineUserInfo?.myMarks.splice(index, 1);
      }

      const news = this.baseNewsMock.queryRawNews(data.newsId);
      if (news) {
        news.isMarked = false;
        news.markCount--
      }
      return [HttpStatusCode.Ok];
    });

    // 查询我的收藏
    adapter.onGet('/my/mark/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const list = mineUserInfo.myMarks
        .map((id: string) => {
          return this.baseNewsMock.queryNews(id);
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 发表评论
    adapter.onPost('/publish/comment').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config.data) as PublishCommentRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const newItem: BaseComment = {
        commentId: `comment_${SafeRandomGenerate.generate()}`,
        parentCommentId: params.parentCommentId,
        newsId: params.newsId,
        authorId: mineUserInfo.authorId,
        commentBody: params.content,
        commentLikeNum: 0,
        createTime: new Date().getTime(),
        isLiked: false,
        replyComments: [],
      };
      mineUserInfo.myComments.splice(0, 0, newItem.commentId);
      this.commentMock.addComment(newItem);
      const resp = this.commentMock.queryComment(newItem.commentId) as CommentResponse;
      return [HttpStatusCode.Ok, resp];
    });

    // 查询我的评论
    adapter.onGet('/my/comment/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const comments = this.commentMock.queryCommentByAuthorId(mineUserInfo.authorId)
        .filter(v => !v.parentCommentId)
        .map(v => {
          const item = v as AggregateNewsComment;
          const resp = this.baseNewsMock.queryNews(v.newsId);
          if (resp) {
            item.newsDetailInfo = resp;
          }
          return item;
        })
        .sort((a, b) => b.createTime - a.createTime);
      return [HttpStatusCode.Ok, comments];
    });

    // 删除评论
    adapter.onPost('/comment/delete').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as DeleteCommentRequest;

      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.myComments.findIndex(v => v === data.commentId);
      if (index !== -1) {
        mineUserInfo.myComments.splice(index, 1);
      }
      this.commentMock.deleteComment(data.commentId);
      return [HttpStatusCode.Ok];
    });

    // 添加到阅读历史
    adapter.onPost('/history/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      this.deleteFromHistory(data.newsId);
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo?.myHistory.splice(0, 0, data.newsId);
      return [HttpStatusCode.Ok];
    });

    // 从阅读历史中删除
    adapter.onPost('/history/delete').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      this.deleteFromHistory(data.newsId);
      return [HttpStatusCode.Ok];
    });

    // 查询我的阅读记录
    adapter.onGet('/my/history/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const list = mineUserInfo.myHistory
        .map((id: string) => {
          return this.baseNewsMock.queryNews(id);
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 修改个人信息
    adapter.onPost('/modify/personal/info').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config.data) as ModifyPersonalInfoRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (params.authorIcon) {
        mineUserInfo.authorIcon = params.authorIcon;
      }
      if (params.authorNickName) {
        mineUserInfo.authorNickName = params.authorNickName;
      }
      if (params.authorPhone) {
        mineUserInfo.authorPhone = params.authorPhone;
      }
      if (params.authorDesc) {
        mineUserInfo.authorDesc = params.authorDesc;
      }
      return [HttpStatusCode.Ok];
    });

    // 添加预约
    adapter.onPost('/my/reservation/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AddReservationRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (!mineUserInfo.myReservations) {
        mineUserInfo.myReservations = [];
      }
      mineUserInfo.myReservations.splice(0, 0, {
        newsId: data.newsId,
        liveStartTime: data.liveStartTime,
        eventId: data.eventId,
      });
      return [HttpStatusCode.Ok];
    });

    // 取消预约
    adapter.onPost('/my/reservation/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (mineUserInfo.myReservations) {
        const index = mineUserInfo.myReservations.findIndex(item => item.newsId === data.newsId);
        if (index !== -1) {
          mineUserInfo.myReservations.splice(index, 1);
        }
      }
      return [HttpStatusCode.Ok];
    });

    // 查询我的预约列表
    adapter.onGet('/my/reservation/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (!mineUserInfo.myReservations) {
        return [HttpStatusCode.Ok, []];
      }
      const list = mineUserInfo.myReservations
        .map((item: ReservationInfo) => {
          const news = this.baseNewsMock.queryNews(item.newsId);
          if (news) {
            // 直接设置eventId字段
            if (!news.extraInfo) {
              news.extraInfo = {};
            }
            news.extraInfo.eventId = item.eventId;
          }
          return news;
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      const now = Date.now();
      list.sort((a, b) => {
        const aStart = a.liveStartTime ?? 0;
        const bStart = b.liveStartTime ?? 0;

        // 定义状态优先级：直播中(2) > 即将直播(1) > 已过期(0)
        const getLiveStatus = (item: NewsResponse): number => {
          const start = item.liveStartTime ?? 0;
          const end = item.liveEndTime ?? 0;
          // 直播中：当前时间在开始和结束时间之间
          if (now >= start && now <= end) {
            return 2;
          }
          // 即将直播：当前时间早于开始时间
          if (now < start) {
            return 1;
          }
          // 已过期：当前时间晚于结束时间
          return 0;
        };

        // 第一步：按状态优先级排序（高优先级在前）
        const statusDiff = getLiveStatus(b) - getLiveStatus(a);
        if (statusDiff !== 0) {
          return statusDiff;
        }

        // 第二步：同状态下按直播开始时间排序（默认升序，即早的在前）
        return aStart - bStart;
      });


      return [HttpStatusCode.Ok, list];
    });

    // 批量删除预约记录
    adapter.onPost('/my/reservation/delete').reply((config: AxiosRequestConfig) => {
      const newsIds = JSON.parse(config.data) as string[];
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (mineUserInfo.myReservations) {
        mineUserInfo.myReservations = mineUserInfo.myReservations.filter(item => !newsIds.includes(item.newsId));
      }
      return [HttpStatusCode.Ok];
    });

    // 拉黑作者
    adapter.onPost('/my/block/author').reply((config: AxiosRequestConfig) => {
      const authorId = config.data as string;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (mineUserInfo && !mineUserInfo.myBlockAuthors.includes(authorId)) {
        mineUserInfo.myBlockAuthors.push(authorId);
      }
      return [HttpStatusCode.Ok];
    });

    // 屏蔽新闻
    adapter.onPost('/my/block/news').reply((config: AxiosRequestConfig) => {
      const newsId = config.data as string;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (mineUserInfo && !mineUserInfo.myBlockNewsList.includes(newsId)) {
        mineUserInfo.myBlockNewsList.push(newsId);
      }
      return [HttpStatusCode.Ok];
    });
  }

  public deleteFromHistory(newsId: string) {
    const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo?.myHistory.findIndex(id => id === newsId);
    if (index !== -1) {
      mineUserInfo?.myHistory.splice(index, 1);
    }
  }
}