import { https } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, } from 'commonlib';
import { IPositionInfo } from 'network/src/main/ets/types/responseTypes/GetPositionInfoResp';
import { IDataset, IProfile } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { positionInfoData } from '../constants';

const TAG = '[PositionInfoVM]';

@ObservedV2
export class PositionInfoVM {
  private static _instance: PositionInfoVM;
  @Trace public positionInfo: IPositionInfo = positionInfoData
  @Trace public productProfile: IProfile | undefined
  @Trace public annualizedDataset: IDataset | undefined
  @Trace public revenueDataset: IDataset | undefined
  @Trace public isExpand: boolean = false
  @Trace public isLogin: boolean = false
  @Trace public isSelected: boolean = false
  @Trace public currentIndex: number = 0
  @Trace public selectedIndex: number = 0
  @Trace public xData: string[] = []
  @Trace public seriesData: number[] = []
  @Trace public annualizedSelectedIndex: number = 0
  @Trace public revenueSelectedIndex: number = 0

  public static get instance() {
    if (!PositionInfoVM._instance) {
      PositionInfoVM._instance = new PositionInfoVM();
    }
    return PositionInfoVM._instance;
  }

  init() {
    const isLogin = AppStorage.get<boolean>('isLogin');
    if (isLogin) {
      this.isLogin = isLogin
    }
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.POSITION_INFO,
    });
    if (param) {
      this.getPositionInfo(1, param)
      this.getAnnualizedDataset(1, 1)
    }
  }

  clear() {
    this.isLogin = false
    this.isExpand = false
    this.positionInfo = positionInfoData
    this.productProfile = undefined
  }

  tabChange(index: number) {
    this.currentIndex = index
    this.selectedIndex = index
    if (this.positionInfo) {
      if (index === 0) {
        this.getAnnualizedDataset(1, 1)
      } else {
        this.getRevenueDataset(1, 1)
      }
    }
  }

  public async getPositionInfo(userId: number, id: number) {
    const res = await https.getPositionInfo(userId, id);
    if (res.code === 0) {
      this.positionInfo = res.data;
      this.getProductProfile(this.positionInfo.productId)
    }
  }

  public async getProductProfile(productId: number) {
    const res = await https.getProductProfile(productId);
    if (res.code === 0) {
      this.productProfile = res.data;
    }
  }

  public async getAnnualizedDataset(id: number, time: number) {
    const res = await https.getAnnualizedDataset({ id, time });
    if (res.code === 0) {
      this.annualizedDataset = res.data;
      const xDataArr: string[] = []
      const seriesDataArr: number[] = []
      this.annualizedDataset.data.forEach((item) => {
        xDataArr.push(item.date)
        seriesDataArr.push(item.rate)
      })
      this.xData = xDataArr
      this.seriesData = seriesDataArr
    }
  }

  public async getRevenueDataset(id: number, time: number) {
    const res = await https.getRevenueDataset({ id, time });
    if (res.code === 0) {
      this.revenueDataset = res.data;
      const xDataArr: string[] = []
      const seriesDataArr: number[] = []
      this.revenueDataset.data.forEach((item) => {
        xDataArr.push(item.date)
        seriesDataArr.push(item.rate)
      })
      this.xData = xDataArr
      this.seriesData = seriesDataArr
    }
  }
}
