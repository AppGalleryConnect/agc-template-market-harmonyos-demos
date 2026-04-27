import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import {
  BroadcastRequest, SearchRequest,
} from '../params/request/CommonRequest';
import { Utils } from '../utils/Utils';
import { AuthorServiceMock } from './AuthorServiceMock';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';
import { MockTelevision } from './mockdata/MockTelevision';
import { BaseAv } from '../database/AvType';

/**
 * 首页Mock
 */
export class HomeServiceMock {
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();
  private authorMock: AuthorServiceMock = new AuthorServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询所有文章、动态、详情
    adapter.onGet('/all/news/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as SearchRequest;
      const list =
        this.getAvList([...MockTelevision.list]).filter(item => item?.title.includes(params.search));
      return [HttpStatusCode.Ok, list];
    });

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

    // 查询服务卡片-视频列表
    adapter.onGet('/form/news/list').reply(() => {
      const videoList = Utils.shuffleArray([...MockTelevision.list])[0];
      return [HttpStatusCode.Ok, videoList];
    });

  }

  getAvList(avList: BaseAv[]) {
    let avData = avList.map(avInfo => {
      return this.baseNewsMock.queryRawAv(avInfo.id);
    }).filter(v => Boolean(v))
    return avData;
  }
}