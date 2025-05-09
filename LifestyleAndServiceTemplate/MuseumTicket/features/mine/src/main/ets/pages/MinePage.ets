import { RouterModule, RouterMap, CommonConstants } from 'commonlib';
import { Header } from '../components/Header';
import { Main } from '../components/Main';
import { RecommendBar } from '../components/RecommendBar';
import { MinePageVM } from '../viewModels/MinePageVM';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@ComponentV2
export struct MinePage {
  vm: MinePageVM = MinePageVM.instance;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.vm.getRecommendList();
    this.vm.getBannerImg();
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('个人中心').fontSize(16).fontWeight(700).padding({ left: 16 }).height(56);
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.vm.titleBgOpacity);
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            Header();

            Column({ space: 10 }) {
              //  内容区
              Main();
              RecommendBar();
            }
            .padding({
              left: 10,
              right: 10,
              top: 18,
            })
            .backgroundColor(CommonConstants.BG_COLOR_GRAY);

          }
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
          .backgroundColor(CommonConstants.BG_COLOR_GRAY)
          .width('100%')
        }
        .height('100%')
        .width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .onDidScroll(() => {
          this.vm.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
        });

        this.titleBuilder();
      }.alignContent(Alignment.Top)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

  }
}