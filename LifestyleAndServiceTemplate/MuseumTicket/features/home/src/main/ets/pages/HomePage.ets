import { Banner } from '../component/Banner';
import { MainServer } from '../component/MainServer';
import { OrderBar } from '../component/OrderBar';
import { RecommendBar } from '../component/RecommendBar';
import { UserBar } from '../component/UserBar';
import { HomePageVM } from '../viewModels/HomePageVM';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function HomePageBuilder() {
  HomePage();
}


@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;

  async aboutToAppear(): Promise<void> {
    await this.vm.initData();
  }

  build() {
    NavDestination() {
      Scroll() {
        Stack({ alignContent: Alignment.Top }) {
          Banner();
          Column({ space: 10 }) {
            // 用户信息
            UserBar();
            //   订票
            OrderBar();
            //   主要服务
            MainServer();
            //   精彩推荐
            RecommendBar();

          }
          .justifyContent(FlexAlign.Start)
          .padding({ left: 10, right: 10 })
          .margin({ top: 173 });
        }.backgroundColor($r('sys.color.ohos_id_color_sub_background'));

      }.height('100%')
      .scrollBar(BarState.Off);
    }.title('博物馆', { paddingStart: LengthMetrics.vp(16) });
  }
}
