import { BaseResponse } from '@agctemplate/utils'
import { Body, POST, GET } from './Decorators'
import { Domain } from './Domain'
import './mock/ApiMock'
import { GetLiveListRes } from '../bean/response/GetLiveInfoRes'
import { SearchPageReq } from '../bean/request/SearchPageReq'
import { SearchTipRes } from '../bean/response/SearchTipRes'
import { AudienceArrRes, AudienceIdArrRes } from './mock/mockAudienceFactory'


export class RequestAPI implements Domain {
  getDomain(): string {
    // todo 替换成你业务接口访问的域名
    return 'https://agc.template.com';
  }

  @GET({ path: '/getlivelist' })
  getLiveList(): Promise<BaseResponse<GetLiveListRes>> {
    return Promise.resolve(new BaseResponse());
  }

  @GET({ path: '/search' })
  getSearchLiveList(@Body pageReq: SearchPageReq): Promise<BaseResponse<GetLiveListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @GET({ path: '/search/tip' })
  getSearchTipList(@Body searchText: string): Promise<BaseResponse<SearchTipRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/get/mywatchrecord' })
  getMyWatchRecord(): Promise<BaseResponse<GetLiveListRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/set/mywatchrecord' })
  setMyWatchRecord(@Body id: string): Promise<BaseResponse<void>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/remove/mywatchrecord' })
  removeMyWatchRecord(@Body ids: string[]): Promise<BaseResponse<void>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/addFollowing' })
  addFollowing(@Body id: string): Promise<BaseResponse<SearchTipRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/getAudience' })
  getAudience(@Body id: string): Promise<BaseResponse<AudienceArrRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/deleteFollowing' })
  deleteFollowing(@Body id: string): Promise<BaseResponse<SearchTipRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/getMyFollowing' })
  getMyFollowing(): Promise<BaseResponse<AudienceIdArrRes>> {
    return Promise.resolve(new BaseResponse())
  }
  @POST({ path: '/getMyFollower' })
  getMyFollower(): Promise<BaseResponse<AudienceIdArrRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/getFollower' })
  getFollowers(@Body id:string[]): Promise<BaseResponse<AudienceArrRes>> {
    return Promise.resolve(new BaseResponse())
  }

  @POST({ path: '/getFollowing' })
  getFollowing(@Body id:string[]): Promise<BaseResponse<AudienceArrRes>> {
    return Promise.resolve(new BaseResponse())
  }
}