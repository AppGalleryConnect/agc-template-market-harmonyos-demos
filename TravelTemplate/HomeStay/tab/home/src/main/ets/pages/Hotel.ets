import { TitleBar } from 'component';
import { Constants } from 'constant';
import { CommonMap } from 'mapview';
import { TenantInfo } from 'type';
import { BasicInfoArea } from '../components/BasicInfoArea';
import { Checkout } from '../components/Checkout';
import { Foundations } from '../components/Foundations';
import { Reservation } from '../components/Reservation';
import { HotelTabBar, HOTEL_TABS_INFO } from '../model/HotelTabInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Extend(Column)
function detailCommon() {
  .backgroundColor(Color.White)
  .padding(10)
  .borderRadius(8);
}

@Builder
export function HotelBuilder() {
  Hotel();
}

@Component
export struct Hotel {
  @State isShow: boolean = true;
  @State index: number = 0;
  @State activeIndex: number = 0;
  vm: HomePageVM = HomePageVM.instance;
  @State tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  scroller = new Scroller();

  @Builder
  hotelTabBar(title: ResourceStr, targetIndex: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontColor(this.index === targetIndex ? '#007DFF' :
          '#333333')
        .opacity(this.index === targetIndex ? 1 :
          0.6)
        .fontWeight(this.index === targetIndex ? 600 :
          400);

      if (this.index === targetIndex) {
        Divider().color('#007DFF').strokeWidth(2).width(20);
      }
    }
    .onClick(() => {
      this.index = targetIndex;
      this.goToHotelInfo();
    })
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  InfoBuilder() {
    List({ space: 16, scroller: this.scroller }) {
      ListItem() {
        Column({ space: 16 }) {
          BasicInfoArea({ isHome: false }).backgroundColor(Color.White).borderRadius(8).padding(10);
          Column() {
            Text(this.vm.hotelInfo.appInfo.introduction)
              .fontSize(14).lineHeight(24);
          }.detailCommon().width(Constants.FULL_SCREEN);
        };
      };

      ListItem() {
        Foundations({ foundations: this.vm.hotelInfo.appInfo.instructions?.foundations }).backgroundColor(Color.White)
          .borderRadius(8).padding(16);
      };

      ListItem() {
        Reservation({
          reservation: this.vm.hotelInfo.appInfo.instructions?.reservation,
        }).backgroundColor(Color.White)
          .borderRadius(8).padding(16);
      };

      ListItem() {
        Checkout({
          checkOut: this.vm.hotelInfo.appInfo.instructions.checkOut,
        }).backgroundColor(Color.White)
          .borderRadius(8).padding(16);
      };

      ListItem() {
        Column({ space: 16 }) {
          Text(`周边信息`).fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start);
          CommonMap({
            latitude: this.tenantInfo?.position[1],
            longitude: this.tenantInfo?.position[0],
            name: this.tenantInfo?.appName,
            isShow: this.isShow,
          })
            .height(172);
        };
      };
    }.scrollBar(BarState.Off).padding({ left: 16, right: 16 }).edgeEffect(EdgeEffect.Spring);
  }

  goToHotelInfo() {
    if (this.index === 0) {
      this.scroller.scrollToIndex(0);
    } else {
      this.scroller.scrollToIndex(1);
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          TitleBar({
            isShowBack: true, title: '门店信息', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Tabs({ index: this.index }) {
            ForEach(HOTEL_TABS_INFO, (item: HotelTabBar) => {
              TabContent() {
                this.InfoBuilder();
              }.tabBar(this.hotelTabBar(item.title, item.index));
            }, (item: HotelTabBar) => JSON.stringify(item));
          }
          .height('88%')
          .barPosition(BarPosition.Start)
          .animationDuration(0)
          .backgroundColor('#F5F6FA')
          .barWidth(Constants.FULL_SCREEN)
          .onChange((value: number) => {
            this.index = value;
            this.goToHotelInfo();
          });
        };
      }
    }.hideTitleBar(true);
  }
}