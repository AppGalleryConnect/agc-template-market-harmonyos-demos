import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { MockVideo } from './mockdata/MockVideo';
import { MockPost } from './mockdata/MockPost';
import { BaseNews } from '../database/NewsType';
import { Utils } from '../utils/Utils';
import { NewsEnum } from '../constants/Constants';
import { PostImgList } from '../params/base/BaseModel';
import { NewsResponse } from '../params/response/NewsResponse';
import { VideoFollowRequest, VideoInfoRequest, VideoListRequest } from '../params/request/CommonRequest';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';

/**
 * 新闻视频Mock
 */
export class VideoServiceMock {
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询视频关注流
    adapter.onGet('/video/follow/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as VideoFollowRequest;
      const videos: NewsResponse[] = []
      params.followedUserIds.forEach((userId: string) => {
        const followedUserVideos = MockVideo.list
          .filter(v => v.authorId === userId)
          .map((video: BaseNews) => this.baseNewsMock.queryNews(video.id))
          .filter(v => Boolean(v)) as NewsResponse[];

        videos.push(...followedUserVideos)
      })
      const list = Utils.shuffleArray([...videos]);
      return [HttpStatusCode.Ok, list];
    });

    // 查询视频流，如果有userId，查询对应用户的视频
    adapter.onGet('/video/author/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as VideoListRequest;
      let list = MockVideo.list;
      if (params.userId) {
        if (params.type === NewsEnum.Video) {
          list = list.filter(v => v.authorId === params.userId)
        } else if (params.type === NewsEnum.Post) {
          const newsVideoList = MockPost.list.filter((item: BaseNews) => {
            const isVideo = item.postImgList?.some((postImgItem: PostImgList) => {
              return postImgItem.surfaceUrl && postImgItem.picVideoUrl
            });
            return isVideo
          })
          list = [...newsVideoList].filter(v => v.authorId === params.userId)
        }
      }
      const videos = list
        .map((video: BaseNews) => this.baseNewsMock.queryNews(video.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      const result = Utils.shuffleArray([...videos]);
      return [HttpStatusCode.Ok, result];
    });

    // 查询直播视频（返回正在直播的视频）
    adapter.onGet('/video/live/list').reply(() => {
      const now = Date.now();
      const videos = MockVideo.liveVideoList
        .filter((video: BaseNews) => {
          // 返回正在直播的视频：liveStartTime <= now && liveEndTime > now
          return video.liveStartTime && video.liveStartTime <= now &&
          video.liveEndTime && video.liveEndTime > now;
        })
        .map((video: BaseNews) => this.baseNewsMock.queryNews(video.id))
        .filter(v => Boolean(v)) as NewsResponse[]
      videos.sort((a, b) => (a.liveStartTime || 0) - (b.liveStartTime || 0));
      return [HttpStatusCode.Ok, videos];
    });

    // 查询直播预约列表（只返回未开始的直播）
    adapter.onGet('/video/reservation/list').reply(() => {
      const now = Date.now();
      const videos = MockVideo.liveVideoList
        .filter((video: BaseNews) => video.liveStartTime && video.liveStartTime > now)
        .map((video: BaseNews) => this.baseNewsMock.queryNews(video.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      videos.sort((a, b) => (a.liveStartTime || 0) - (b.liveStartTime || 0));
      return [HttpStatusCode.Ok, videos];
    });

    // 查询精彩回放视频（返回已结束的直播）
    adapter.onGet('/video/highlight/list').reply(() => {
      const now = Date.now();
      // 返回已结束的直播：liveEndTime <= now
      const expiredLiveVideos = MockVideo.liveVideoList
        .filter((item) => item.liveEndTime && item.liveEndTime <= now)
        .map((video: BaseNews) => this.baseNewsMock.queryNews(video.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      expiredLiveVideos.sort((a, b) => (a.liveEndTime || 0) - (b.liveEndTime || 0));
      return [HttpStatusCode.Ok, expiredLiveVideos];
    });

    // 根据id查询详细信息
    adapter.onGet('/video').reply((config: AxiosRequestConfig) => {
      const params = config.params as VideoInfoRequest;
      const resp = this.baseNewsMock.queryNews(params.id)
      return [HttpStatusCode.Ok, resp];
    });
  }
}