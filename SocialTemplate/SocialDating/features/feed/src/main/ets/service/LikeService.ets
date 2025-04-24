import { BaseService, CommonRsp, LikeOperType, CreateLikeReq, Constants, MockService } from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { http } from '@kit.NetworkKit';

export class LikeService extends BaseService {
  async likeFeed(currentUid: number | null | undefined, feedId: number | null | undefined,
    likeOperType: LikeOperType): Promise<CommonRsp | null> {
    if (currentUid == null || currentUid === undefined || feedId == null || feedId === undefined) {
      Logger.error('likeFeed req invalid, currentUid=' + currentUid + ', feedId=' + feedId)
      return null;
    }
    if (this.serviceConfig.isMock) {
      return MockService.likeFeed(currentUid, feedId, likeOperType)
    }
    let rsp = await this.doRequest<CommonRsp>('/like', http.RequestMethod.POST,
      JSON.stringify(new CreateLikeReq(currentUid, feedId, likeOperType)));
    if (rsp == null || rsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('createLikeFeed failed, uid=' + currentUid + ', feedId=' + feedId);
      return null;
    } else {
      return rsp;
    }
  }
}

export default new
LikeService({
  baseUrl: BaseService.BASE_URL_MOCK, isMock: true
});