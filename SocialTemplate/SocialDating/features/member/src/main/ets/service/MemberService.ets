import { BaseService, CommonRsp, Constants, MockService } from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { MemberShip, QueryMemberShipResponse } from '../model/QueryMemberShipResponse';
import { http } from '@kit.NetworkKit';

export class MemberService extends BaseService {
  async queryMembership(): Promise<MemberShip[]> {
    let queryRsp =
      await this.doRequest<QueryMemberShipResponse>('/membership/list/',
        http.RequestMethod.GET, null);
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('queryMembership failed');
      return [];
    } else {
      return queryRsp.list;
    }
  }

  async subscribeMember(uid: number, membershipId: number, membershipStartTime: number): Promise<CommonRsp | null> {
    if (this.serviceConfig.isMock) {
      return MockService.subscribeMember(uid, membershipId, membershipStartTime);
    }
    let subscribeMemberRsp =
      await this.doRequest<CommonRsp>('/membership/subscribe',
        http.RequestMethod.POST, null);
    if (subscribeMemberRsp == null || subscribeMemberRsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('subscribeMember failed');
      return null;
    } else {
      return subscribeMemberRsp;
    }
  }
}

export default new MemberService({
  baseUrl: BaseService.BASE_URL_MOCK, isMock: true
});