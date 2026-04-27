import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { NewsEnum } from '../constants/Constants';
import { BaseNews } from '../database/NewsType';
import { AddArticleRequest, AddFlexLayoutRequest } from '../params/request/CommonRequest';
import { FlexLayoutModel } from '../params/response/LayoutResponse';
import { MockArticle } from './mockdata/MockArticle';
import { MockFlexLayout } from './mockdata/MockFlexLayout';
import { Utils } from '../utils/Utils';
import { AuthorServiceMock } from './AuthorServiceMock';

/**
 * 新闻文章Mock
 */
export class ArticleServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 添加文章
    adapter.onPost('/add/article').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AddArticleRequest;
      let articleInfo: BaseNews = {
        id: `article_${Utils.randomArticleId()}`,
        type: NewsEnum.Article,
        title: data.title,
        tags: ['生活', '军事', '科技', '自然'],
        authorId: this.authorMock.queryAuthorInfo()?.authorId as string,
        markCount: 0,
        postImgList: data.postImgList,
        recommends: [{
          newsId: 'article_6',
          newsType: 1,
        }, {
          newsId: 'article_8',
          newsType: 1,
        }],
        richContent: data.content,
        createTime: new Date().getTime(),
        commentCount: 0,
        likeCount: 0,
        shareCount: 0,
        isLiked: false,
        isMarked: false,
        isLocalPublish: true,
        navInfo: {
          setting: data.setting,
        },
      }
      MockArticle.list.unshift(articleInfo)
      return [HttpStatusCode.Ok, articleInfo];
    });

    // 动态布局添加数据
    adapter.onPost('/add/flex/layout').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AddFlexLayoutRequest;
      let flexInfo: FlexLayoutModel = {
        navInfo: {
          setting: data.setting,
        },
        articles: [
          data.articleId,
        ],
        extraInfo: {
          'flexId': `flexId_${Utils.randomArticleId()}`,
          'isNeedAuthor': false,
        },
      }
      MockFlexLayout.recommendList.splice(1, 0, flexInfo)
      return [HttpStatusCode.Ok];
    });
  }
}