import { MainService } from '../components/MainService';
import { PublicNotice } from '../components/PublicNotice';
import { HomePageVM } from '../viewModels/HomePageVM';
import { VIPCard } from 'componentlib';
import { Banner } from '../components/Banner';
import { MainProduct } from '../components/MainProduct';


@Builder
export function homePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  vm: HomePageVM = HomePageVM.instance;

  async aboutToAppear() {
    await this.vm.initData();
  }

  build() {
    Scroll() {
      Stack({
        alignContent: Alignment.Top,
      }) {
        // 首页banner
        Banner()
        Column() {
          // 滚动公告
          PublicNotice()
          // 会员信息
          VIPCard()
          // 服务列表
          MainService()
          // 商品广告及列表 -- 商城服务
          MainProduct()
        }
        .justifyContent(FlexAlign.Start)
        .margin({ top: 200 })
        .borderRadius({
          topLeft: $r('app.string.border_radius_32'),
          topRight: $r('app.string.border_radius_32'),
        })
        .backgroundColor($r('app.color.system_color_background_auxiliary'))
        .padding($r('app.string.padding_s'))
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}