import { RequestAPI } from '@agctemplate/server';
import { GetLiveListRes, LiveInfoModel } from '@agctemplate/server/src/main/ets/bean/response/GetLiveInfoRes';
import { BaseResponse, container, Logger } from '@agctemplate/utils';
import { VideoPlayDataSource } from '@agctemplate/video_swiper';
import { PreferType } from 'live_interaction';
import { LiveInfo } from '../models/LiveInfo';

const TAG = '[DetailItemListVM]'

@ObservedV2
export class DetailItemListVM {
  @Trace ready: boolean = false
  // 短剧列表
  data: VideoPlayDataSource = new VideoPlayDataSource();
  private static _instance: DetailItemListVM;

  public static get instance() {
    if (!DetailItemListVM._instance) {
      DetailItemListVM._instance = new DetailItemListVM();
    }
    return DetailItemListVM._instance;
  }

  async init() {
    try {
      let liveListRes: BaseResponse<GetLiveListRes> =
        await container.resolve(RequestAPI).getLiveList();
      (liveListRes.getBody() as GetLiveListRes).liveList.map((liveInfo: LiveInfoModel) => {
        let videoData: LiveInfo = new LiveInfo(liveInfo.url, liveInfo.id, liveInfo, liveInfo.preferType as PreferType)
        this.data.pushData(videoData);
      })
      this.ready = true
    } catch (e) {
      Logger.error(TAG, 'fetch liveList failed')
    }
  }
}