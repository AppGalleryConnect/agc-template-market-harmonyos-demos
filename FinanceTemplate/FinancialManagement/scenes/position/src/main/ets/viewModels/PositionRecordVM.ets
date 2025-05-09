import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, UserInfoModel, } from 'commonlib';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';
import { IPositionInfo, IPositionRecord } from 'network/src/main/ets/types/responseTypes/GetPositionInfoResp';

const TAG = '[PositionRecordVM]';

@ObservedV2
export class PositionRecordVM {
  private static _instance: PositionRecordVM;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace positionRecord: IPositionRecord[] = []
  @Trace public positionInfo: IPositionInfo | undefined

  public static get instance() {
    if (!PositionRecordVM._instance) {
      PositionRecordVM._instance = new PositionRecordVM();
    }
    return PositionRecordVM._instance;
  }

  init() {
    const param = RouterModule.getNavParam<IPositionInfo>({
      url: RouterMap.POSITION_RECORD,
    });
    if (param) {
      this.positionInfo = param
      this.getPositionRecord(this.userInfo.id, this.positionInfo.id)
    }
  }

  public async getPositionRecord(userId: number, id: number) {
    const res = await https.getPositionRecord({ userId, id });
    if (res.code === 0) {
      this.positionRecord = res.data;
    }
  }
}
