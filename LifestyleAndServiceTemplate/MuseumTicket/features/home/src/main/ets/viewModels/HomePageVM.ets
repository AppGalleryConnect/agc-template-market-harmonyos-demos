import { RouterMap, FormatUtil, Logger, AccountUtil, UserInfo } from 'commonlib';
import { ServerListItem, ExplainTextItem, IntroduceText } from '../types/Index';
import { https, RecommendListItem,ParkTextResp } from 'network';


const TAG = '[HomePageVM]';


@ObservedV2
export class HomePageVM {
  @Trace bannerUrl: string[] = [];
  // 主要服务
  @Trace serverList: ServerListItem[] = [{
    name: '讲解服务',
    value: '1',
    icon: $r('app.media.icon_main_serve1'),
    url: RouterMap.EXPLAIN,
  },
    {
      name: '省博介绍',
      value: '2',
      icon: $r('app.media.icon_main_serve2'),
      url: RouterMap.INTRODUCE,
    },
    {
      name: '场馆地图',
      value: '3',
      icon: $r('app.media.icon_main_serve3'),
      url: RouterMap.MAP,
    },
    {
      name: '停车缴费',
      value: '4',
      icon: $r('app.media.icon_main_serve4'),
      url: RouterMap.PARKING,
    },
  ];
  // 精彩推荐
  @Trace recommendList: RecommendListItem[] = [];
  // 用户信息
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  // 讲解服务
  @Trace explainText: ExplainTextItem[] = [];
  // 省博介绍
  @Trace introduceText: IntroduceText = {
    total: '',
    content: [],
  };
  @Trace parkingText: ParkTextResp[] = [];
  private static _instance: HomePageVM;

  public static get instance() {
    if (!HomePageVM._instance) {
      HomePageVM._instance = new HomePageVM();
    }
    return HomePageVM._instance;
  }

  public async initData() {
    this.getRecommendList();
    this.getBannerImg();
  }

  public async getRecommendList() {
    https.getRecommendList().then(res => {
      if (res.code === 0) {
        res.data.forEach((item: RecommendListItem, index) => {
          const img = FormatUtil.getImgResource(item.img);
          this.recommendList.push({
            id: item.id,
            price: item.price,
            img: img,
            name: item.name,
            detail: item.detail,
          });
        });
      }
    });
  }


  public async getExplainText() {
    const res = await https.getExplainText();
    if (res.code === 0) {
      this.explainText = res.data;
    }
  }

  public async getIntroduceText() {
    const res = await https.getIntroduceText();
    if (res.code === 0) {
      this.introduceText = res.data as IntroduceText;
    }
  }

  public async getParkingText() {
    const res = await https.getParkingText();
    if (res.code === 0) {
      this.parkingText = res.data;
    }
  }

  public async getBannerImg() {
    const res = await https.getBannerImg({ pageType: 1 });
    if (res.code === 0) {
      this.bannerUrl = res.data as string[];
    }
  }
}
