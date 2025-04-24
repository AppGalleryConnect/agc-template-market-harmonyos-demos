import { BaseService, Constants } from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { http } from '@kit.NetworkKit';
import { QueryMatchMakerResponse } from '../model/QueryMatchMakerResponse';
import { Matchmaker } from '../model/Matchmaker';


export class MatchMakerService extends BaseService {

  async queryMatchMaker(curPage?: number, pageSize?: number): Promise<Matchmaker[]> {
    let queryRsp =
      await this.doRequest<QueryMatchMakerResponse>(super.appendPageParam(curPage, '/matchmaker/list/', pageSize),
        http.RequestMethod.GET, null);
    if (queryRsp == null || queryRsp.ret.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('queryMatchMaker failed');
      return [];
    } else {
      return queryRsp.list;
    }
  }
}

export default new MatchMakerService({
  baseUrl: BaseService.BASE_URL_MOCK, isMock: true
});