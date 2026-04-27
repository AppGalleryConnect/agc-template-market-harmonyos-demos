import { AudienceRes } from "../../api/mock/mockAudienceFactory";
import { RetBean } from "../common/RetBean";

export class GetLiveListRes {
  ret: RetBean;
  liveList: Array<LiveInfoModel>;
  total: number;

  constructor(liveListRes?: GetLiveListRes) {
    this.ret = new RetBean(liveListRes?.ret);
    this.liveList = liveListRes?.liveList || []
    this.total = liveListRes?.total || 0;
  }
}

export class LiveInfoModel {
  id: string
  url: string
  cover: string
  title: string
  streamer: AudienceRes
  audiences: AudienceRes[]
  category: string
  status: string
  watching: number
  watchTime: Date
  isSelectToDelete: boolean
  preferType: number
}
