import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { MockArticle } from './mockdata/MockArticle';
import { MockVideo } from './mockdata/MockVideo';
import { MockPost } from './mockdata/MockPost';
import { NewsResponse } from '../params/response/NewsResponse';
import { AbstractRequestListData, RequestListData } from '../params/response/LayoutResponse';
import { AuthorRequest, NewsRequest, SearchRequest } from '../params/request/CommonRequest';
import { BaseNews, SimpleNews } from '../database/NewsType';
import { Utils } from '../utils/Utils';
import { AuthorServiceMock } from './AuthorServiceMock';
import { CommentServiceMock } from './CommentServiceMock';
import { MockBroadcast } from './mockdata/MockBroadcast';
import { MockTelevision } from './mockdata/MockTelevision';
import { AvResponse } from '../params/response/AvResponse';
import { PRESET_KEYWORD, PRESET_KEYWORD_CONTENT, TextSpanInfo } from '../constants/Constants';

/**
 * 新闻基础Mock
 */
export class BaseNewsServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();
  private commentMock: CommentServiceMock = new CommentServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询新闻
    adapter.onGet('/news').reply((config: AxiosRequestConfig) => {
      const params = config.params as NewsRequest;
      const result = this.queryNews(params.newsId);
      return [HttpStatusCode.Ok, result];
    });

    // 查询作者的所有创作内容
    adapter.onGet('/author/news/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as AuthorRequest;
      const list = [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
        .filter(v => v.authorId === params.authorId)
        .map(v => this.handleRawNews(v, true));
      return [HttpStatusCode.Ok, list];
    });

    // 查询所有文章、动态、详情
    adapter.onGet('/all/news/list').reply(() => {
      const list = [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
        .map(v => this.handleRawNews(v, true));
      return [HttpStatusCode.Ok, list];
    });

    // 查询搜索结果列表
    adapter.onGet('/news/search/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as SearchRequest;
      let abstractList = new AbstractRequestListData();
      abstractList.list = [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
        .filter(v => {
          const title = this.handleTitle(v.title);
          return title.includes(params.search);
        })
        .map(v => this.handleRawNews(v))
        .map(v => this.layoutTrans(v));
      if (params.search === PRESET_KEYWORD && abstractList.list.length) {
        abstractList.abstract = PRESET_KEYWORD_CONTENT;
      }
      return [HttpStatusCode.Ok, abstractList];
    });

    // 查询用户发布的文章
    adapter.onGet('/author/article/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as AuthorRequest;
      const list = MockArticle.list
        .filter(v => v.authorId === params.authorId)
        .map(v => this.handleRawNews(v))
        .map(v => this.layoutTrans(v));
      list.sort((a, b) => b.articles[0]?.createTime - a.articles[0]?.createTime);
      return [HttpStatusCode.Ok, list];
    });

    // 查询用户发布的视频
    adapter.onGet('/author/video/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as AuthorRequest;
      const list = MockVideo.list.filter(v => v.authorId === params.authorId)
        .map(v => this.handleRawNews(v))
        .map(v => this.layoutTrans(v));
      list.sort((a, b) => b.articles[0]?.createTime - a.articles[0]?.createTime);
      return [HttpStatusCode.Ok, list];
    });

    // 查询用户发布的动态
    adapter.onGet('/author/post/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as AuthorRequest;
      const list = MockPost.list
        .filter(v => v.authorId === params.authorId)
        .map(v => this.handleRawNews(v))
        .map(v => this.layoutTrans(v));
      list.sort((a, b) => b.articles[0]?.createTime - a.articles[0]?.createTime);
      return [HttpStatusCode.Ok, list];
    });

    // 收藏
    adapter.onPost('/news/mark/add').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config?.data ?? '{}') as NewsRequest;
      const news = this.queryRawNews(params.newsId);
      if (news) {
        news.isMarked = true;
        news.markCount += 1;
      }
      return [HttpStatusCode.Ok];
    });

    // 取消收藏
    adapter.onPost('/news/mark/cancel').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config?.data ?? '{}') as NewsRequest;
      const news = this.queryRawNews(params.newsId);
      if (news) {
        news.isMarked = false;
        news.markCount -= 1;
      }
      return [HttpStatusCode.Ok];
    });
  }

  /**
   * 获取纯文本的标题
   * @param title
   * @returns
   */
  handleTitle(title: string): string {
    try {
      return (JSON.parse(title || '[]') as TextSpanInfo[]).map(v => v.text).join('');
    } catch (e) {
      return title || '';
    }
  }

  /**
   * 查询新闻
   * @param newsType
   * @param newsId
   * @returns
   */
  public queryNews(newsId: string): NewsResponse | undefined {
    const item = this.queryRawNews(newsId);
    if (item) {
      return this.handleRawNews(item, false);
    }
    return undefined;
  }

  /**
   * 查询新闻数据库字段-不对外
   * @param newsId
   * @param isQueryAll
   * @returns
   */
  public queryRawNews(newsId: string, isQueryAll: boolean = true): BaseNews | undefined {
    let list: BaseNews[] = [...MockArticle.list, ...MockVideo.list, ...MockPost.list];
    if (isQueryAll) {
      return list.find(v => v.id === newsId);
    }
    return list.find(v => v.id === newsId && !v.isLocalPublish);
  }

  /**
   * 查询广播/电视数据库字段-不对外
   * @param newsId
   * @param authorId
   * @returns
   */
  public queryRawAv(newsId: string, authorId?: string): AvResponse | undefined {
    let list = [...MockBroadcast.list, ...MockTelevision.list];
    const authorInfo = this.authorMock.queryAuthorInfo(authorId);
    const avInfo = list.find(v => v.id === newsId);
    const copy = JSON.parse(JSON.stringify(avInfo)) as AvResponse;
    if (copy) {
      copy.isFollow = authorInfo?.subscribe?.includes(avInfo?.id ?? '') ?? false;
    }
    return copy;
  }

  /**
   * 数据库字段转换成接口字段-不对外
   * @param item
   * @returns
   */
  public handleRawNews(item: BaseNews, ignoreRec: boolean = false): NewsResponse {
    const copyItem = JSON.parse(JSON.stringify(item)) as NewsResponse;
    const authorInfo = this.authorMock.queryAuthorInfo(item.authorId);
    if (authorInfo) {
      copyItem.author = authorInfo;
    }

    copyItem.commentCount = this.commentMock.queryRawCommentList(item.id).length;
    copyItem.comments = [];
    copyItem.relativeTime = Utils.getDateDiff(copyItem.createTime);
    if (copyItem.recommends?.length && !ignoreRec) {
      copyItem.recommends = (item?.recommends || [])
        .map((news: SimpleNews) => {
          const raw = this.queryRawNews(news.newsId);
          if (raw) {
            return this.handleRawNews(raw, true);
          }
          return undefined;
        })
        .filter(v => Boolean(v)) as NewsResponse[];
    }

    return copyItem;
  }

  /**
   * 转换成动态布局的结构
   * @param news
   * @returns
   */
  public layoutTrans(news: NewsResponse): RequestListData {
    const resp: RequestListData = {
      navInfo: news.navInfo!,
      articles: [news as NewsResponse],
      extraInfo: news.extraInfo || {},
    };
    return resp;
  }
}