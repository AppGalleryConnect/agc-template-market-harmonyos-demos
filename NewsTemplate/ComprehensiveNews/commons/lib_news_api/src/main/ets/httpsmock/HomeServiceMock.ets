import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { NewsEnum } from '../constants/Constants';
import { BaseNews } from '../database/NewsType';
import {
  ActionFollowRequest,
  BroadcastRequest,
  CityRequest,
  ENewsRequest,
  HomeFollowRequest,
  HomeListRequest,
} from '../params/request/CommonRequest';
import { FlexLayoutModel, RequestListData } from '../params/response/LayoutResponse';
import { NewsResponse } from '../params/response/NewsResponse';
import { MockArticle } from './mockdata/MockArticle';
import { MockFlexLayout } from './mockdata/MockFlexLayout';
import { MockPost } from './mockdata/MockPost';
import { MockUser } from './mockdata/MockUser';
import { MockVideo } from './mockdata/MockVideo';
import { Utils } from '../utils/Utils';
import { AuthorServiceMock } from './AuthorServiceMock';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';
import { MockBroadcast } from './mockdata/MockBroadcast';
import { MockDigitalNews } from './mockdata/MockDigitalNews';
import { MockTelevision } from './mockdata/MockTelevision';
import { BaseAv } from '../database/AvType';
import { MyAuthor } from '../database/AuthorType';

/**
 * 首页Mock
 */
export class HomeServiceMock {
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();
  private authorMock: AuthorServiceMock = new AuthorServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询首页推荐流
    adapter.onGet('/home/recommend/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as HomeListRequest;
      let postList: RequestListData[] = [];
      switch (params.postType) {
        case 'recommend':
          postList = this.getRecommendList(MockFlexLayout.recommendList);
          break;
        case 'hotService':
          postList = this.getRecommendList(MockFlexLayout.hotList);
          break;
        case 'hotTopChart':
          postList = this.getRecommendList(MockFlexLayout.hotTopChart);
          break;
        default:
          postList = Utils.shuffleArray(this.getRecommendList(MockFlexLayout.recommendList).slice(1));
          break;
      }
      const list = postList.slice(params.currentPage, params.currentIndex);
      return [HttpStatusCode.Ok, list];
    });

    // 查询互动关注流
    adapter.onGet('/action/follow/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as ActionFollowRequest;
      const myUserInfo = this.authorMock.queryAuthorRaw();
      const articles = MockArticle.list
        .filter(v => myUserInfo?.watchers.includes(v.authorId) && v.type === NewsEnum.Post)
        .map((news: BaseNews) => this.baseNewsMock.queryNews(news.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      const videos = MockVideo.list
        .filter(v => myUserInfo?.watchers.includes(v.authorId) && v.type === NewsEnum.Post)
        .map((news: BaseNews) => this.baseNewsMock.queryNews(news.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      const posts = MockPost.list
        .filter(v => myUserInfo?.watchers.includes(v.authorId) && v.type === NewsEnum.Post)
        .map((news: BaseNews) => this.baseNewsMock.queryNews(news.id))
        .filter(v => Boolean(v)) as NewsResponse[]
      const list = Utils.shuffleArray([...videos, ...posts, ...articles].slice(0, params.pageIndex));
      return [HttpStatusCode.Ok, list];
    });

    // 查询互动推荐
    adapter.onGet('/action/recommend/list').reply(() => {
      const videos = MockVideo.list
        .filter(v => v.type === NewsEnum.Post)
        .map((news: BaseNews) => this.baseNewsMock.queryNews(news.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      const posts = MockPost.list
        .filter(v => v.type === NewsEnum.Post)
        .map((news: BaseNews) => this.baseNewsMock.queryNews(news.id))
        .filter(v => Boolean(v)) as NewsResponse[]
      const list = Utils.shuffleArray([...videos, ...posts]);
      return [HttpStatusCode.Ok, list];
    });

    // 查询首页关注流
    adapter.onGet('/home/follow/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as HomeFollowRequest;
      const myUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const articles = MockArticle.list
        .filter(v => !myUserInfo.myBlockAuthors.includes(v.authorId))
        .filter(v => !myUserInfo.myBlockNewsList.includes(v.id))
        .filter(v => (myUserInfo?.watchers.includes(v.authorId) ||
          v.authorId === myUserInfo?.authorId) && params.newsType.includes(v.type))
        .map(v => this.baseNewsMock.handleRawNews(v))
        .map(v => this.baseNewsMock.layoutTrans(v));
      const videos = MockVideo.list
        .filter(v => !myUserInfo.myBlockAuthors.includes(v.authorId))
        .filter(v => (myUserInfo?.watchers.includes(v.authorId) ||
          v.authorId === myUserInfo?.authorId) && params.newsType.includes(v.type))
        .map(v => this.baseNewsMock.handleRawNews(v))
        .map(v => this.baseNewsMock.layoutTrans(v));
      const list = [...videos, ...articles].slice(params.currentPage, params.currentIndex);
      if (params.handleExtraInfo) {
        list.forEach(item => {
          item.extraInfo.isNeedAuthor = true;
          item.extraInfo.isFollow = true;
        })
      }
      return [HttpStatusCode.Ok, list];
    });

    // 查询广播列表
    adapter.onGet('/home/broadcast/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as BroadcastRequest;
      const list =
        this.getAvList([...MockBroadcast.list]).slice(params.currentPage, params.currentIndex);
      return [HttpStatusCode.Ok, list];
    })

    // 查询广播列表-猜您喜欢
    adapter.onGet('/home/broadcast/like').reply((config: AxiosRequestConfig) => {
      const list = Utils.shuffleArray([...MockBroadcast.list]).slice(3, 9)
      return [HttpStatusCode.Ok, list];
    })

    // 查询广播列表-今日推荐
    adapter.onGet('/home/broadcast/recommend').reply((config: AxiosRequestConfig) => {
      const list = Utils.shuffleArray([...MockBroadcast.list]).slice(0, 6)
      return [HttpStatusCode.Ok, list];
    })

    // 查询广播列表-热门点播
    adapter.onGet('/home/broadcast/hot').reply((config: AxiosRequestConfig) => {
      const list = Utils.shuffleArray([...MockBroadcast.list]).slice(5, 11)
      return [HttpStatusCode.Ok, list];
    })

    // 查询广播详情
    adapter.onGet('/home/broadcast/details').reply((config: AxiosRequestConfig) => {
      const params = config.params as BroadcastRequest;
      const myUserInfo = this.authorMock.queryAuthorRaw();
      const list = this.baseNewsMock.queryRawAv(params.id, myUserInfo?.authorId)
      return [HttpStatusCode.Ok, list];
    })

    // 查询电视列表
    adapter.onGet('/home/television/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as BroadcastRequest;
      const list =
        this.getAvList([...MockTelevision.list]).slice(params.currentPage, params.currentIndex);
      return [HttpStatusCode.Ok, list];
    })

    // 查询电视列表-猜您喜欢
    adapter.onGet('/home/television/like').reply((config: AxiosRequestConfig) => {
      const list = Utils.shuffleArray([...MockTelevision.list]).slice(0, 9)
      return [HttpStatusCode.Ok, list];
    })

    // 查询节目单
    adapter.onGet('/home/television/program/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as BroadcastRequest;
      const list = [...MockTelevision.program].find(item => item.id === params.id)?.programList
      return [HttpStatusCode.Ok, list];
    })

    // 查询节目详情
    adapter.onGet('/home/television/program/details').reply((config: AxiosRequestConfig) => {
      const params = config.params as BroadcastRequest;
      const myUserInfo = this.authorMock.queryAuthorRaw();
      const list = this.baseNewsMock.queryRawAv(params.id, myUserInfo?.authorId)
      return [HttpStatusCode.Ok, list];
    })

    // 查询服务卡片-新闻列表
    adapter.onGet('/form/news/list').reply(() => {
      const articleId = Utils.shuffleArray([...MockArticle.list])[0].id;
      const postId = Utils.shuffleArray([...MockPost.list])[0].id;
      const videoId = Utils.shuffleArray([...MockVideo.list])[0].id;
      const list: string[] = [articleId, postId, videoId];
      const resp = list
        .map(v => this.baseNewsMock.queryNews(v))
        .filter(v => Boolean(v))
      return [HttpStatusCode.Ok, resp];
    });

    // 根据IP获取当前所在城市
    adapter.onGet('/city/ip').reply((config: AxiosRequestConfig) => {
      const params = config.params as CityRequest;
      let resp = '';
      if (params.ip) {
        MockUser.myself.authorIp = '南京'
        resp = '南京';
      }
      return [HttpStatusCode.Ok, resp];
    });

    // 查询数字报纸列表
    adapter.onGet('/digital/news/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as ENewsRequest;
      const paperTime = Utils.formatDate(params.publishDate)
      MockDigitalNews.list.forEach(v => {
        v.id++;
        v.paperTime = paperTime;
      });

      return [HttpStatusCode.Ok, [...MockDigitalNews.list]];
    });

    // 查询报纸来源列表
    adapter.onGet('/source/list').reply(() => {
      return [HttpStatusCode.Ok, MockDigitalNews.sources];
    });
  }

  getRecommendList(recommendList: FlexLayoutModel[]) {
    let handleRes = recommendList.map(item => {
      const copyItem = JSON.parse(JSON.stringify(item)) as RequestListData;
      let flexData1 = item.articles.map(articleId => {
        const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
        if (mineUserInfo?.myBlockNewsList?.includes(articleId)) {
          return undefined;
        }
        let raw = this.baseNewsMock.queryRawNews(articleId, false);
        if (raw) {
          const newsResp = this.baseNewsMock.handleRawNews(raw);
          if (mineUserInfo?.myBlockAuthors?.includes(newsResp?.author?.authorId)) {
            return undefined;
          }
          return newsResp;
        }
        return raw;
      }).filter(v => Boolean(v))
      copyItem.articles = flexData1 as NewsResponse[];
      copyItem.navInfo = item.navInfo;
      copyItem.extraInfo = item.extraInfo;
      return copyItem;
    }).filter(v => v.articles.length > 0)
    return handleRes;
  }

  getAvList(avList: BaseAv[]) {
    let avData = avList.map(avInfo => {
      return this.baseNewsMock.queryRawAv(avInfo.id);
    }).filter(v => Boolean(v))
    return avData;
  }
}