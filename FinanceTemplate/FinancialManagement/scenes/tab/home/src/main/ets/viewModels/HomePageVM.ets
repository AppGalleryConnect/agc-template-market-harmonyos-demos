import { https } from 'network';
import { IProductItem, SectionLabel } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { IBannerItem, INoticeItem } from 'network/src/main/ets/types/responseTypes/NoticeResp';
import { IMainService } from '../types';

const TAG = '[HomePageVM]';

@ObservedV2
export class HomePageVM {
  private static _instance: HomePageVM;
  @Trace public flexibleAccessProductList: IProductItem[] = []
  @Trace public financialNightMarketProductList: IProductItem[] = []
  @Trace public noticeList: INoticeItem[] = []
  @Trace public bannerList: IBannerItem[] = []
  @Trace public mainServiceList: IMainService[] = [
    {
      type: 1,
      index: 0,
      name: '活钱管理',
      image: $r('app.media.ic_cash_management'),
    },
    {
      type: 2,
      index: 1,
      name: '稳健低波',
      image: $r('app.media.ic_stable_low_volatility'),
    },
    {
      type: 3,
      index: 2,
      name: '稳健增值',
      image: $r('app.media.ic_stable_growth'),
    },
    {
      type: 4,
      index: 3,
      name: '投资增益',
      image: $r('app.media.ic_steady_progress'),
    },
    {
      type: 5,
      index: 4,
      name: '投资回报',
      image: $r('app.media.ic_enterprising_investment'),
    }
  ]

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  async init() {
    this.getBannerList()
    this.getNoticeList()
    this.flexibleAccessProductList = await this.getProductList(SectionLabel.FLEXIBLE_ACCESS)
    this.financialNightMarketProductList = await this.getProductList(SectionLabel.FINANCIAL_NIGHT_MARKET)
  }

  public async getBannerList() {
    const res = await https.getBannerList();
    if (res.code === 0) {
      this.bannerList = res.data;
    }
  }

  public async getProductList(sectionLabel: SectionLabel): Promise<IProductItem[]> {
    const res = await https.getProductList({ sectionLabel: sectionLabel });
    if (res.code === 0) {
      return res.data;
    } else {
      return []
    }
  }

  public async getNoticeList() {
    const res = await https.getNoticeList();
    if (res.code === 0) {
      this.noticeList = res.data;
    }
  }
}
