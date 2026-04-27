import { HomePageVM } from '../viewModels/HomePageVM';
import { EventCard } from '../components/EventCard';
import { MainService } from '../components/MainService';
import { ServiceCard } from '../components/ServiceCard';
import { VipCard } from '../components/VipCard';
import { Title } from '../components/Title';
import { RouterMap } from 'module_base';
import { RouterModule } from 'lib_foundation';


@Builder
export function homePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.queryMemberStatus()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Row() {
          Image($r('app.media.banner'))
            .height(240)
            .width('100%')
            .draggable(false)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }
        .width('100%')

        Column() {
          Scroll() {
            Column() {
              Column() {
                Row() {
                  Text('寄快递低至5元/单')
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  Row() {
                    Text('立即寄件')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(Color.White)
                    Image($r('app.media.ic_banner_right'))
                      .width(16)
                      .height(16)
                  }
                  .width(80)
                  .height(28)
                  .borderRadius(16)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                  .linearGradient({
                    direction: GradientDirection.Right,
                    repeating: true,
                    colors: [[0x0A59F7, 0], [0x3B7AF9, 1]],
                  })
                  .onClick(() => {
                    if (!this.vm.userInfoModel.isLogin) {
                      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
                      return
                    }
                    RouterModule.push({ url: RouterMap.EXPRESS_PAGE })
                  })
                }
                .width('100%')
              }
              .margin({
                top: 22,
                bottom: 12,
                left: 16,
                right: 16,
              })

              EventCard()
              MainService()
              ServiceCard()
              VipCard()
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }
        .padding({ left: 16, right: 16 })
        .margin({ top: 47 })

        Title()
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#F1F3F5')
  }
}