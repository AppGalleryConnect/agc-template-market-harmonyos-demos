import { LiveInfoModel } from '@agctemplate/server/src/main/ets/bean/response/GetLiveInfoRes';
import { VideoPlayData } from '@agctemplate/video_swiper';
import { media } from '@kit.MediaKit';
import { PreferType } from 'live_interaction';

export class LiveInfo implements VideoPlayData {
  url: string;
  liveId: string;
  preferType: PreferType
  data: LiveInfoModel

  constructor(url: string, liveId: string, data: LiveInfoModel, preferType: PreferType = PreferType.PORTRAIT) {
    this.url = url;
    this.liveId = liveId;
    this.preferType = preferType
    this.data = data
  }

  getUrl(): string | media.AVFileDescriptor {
    return this.url;
  }

  getPlayTime(): number {
    return 0;
  }

  getPic(): ResourceStr {
    return ''
  }

  getType(): number {
    return this.preferType
  }
}