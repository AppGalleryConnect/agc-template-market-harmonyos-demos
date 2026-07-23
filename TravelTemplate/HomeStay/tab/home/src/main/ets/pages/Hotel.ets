import { CommonHeader } from 'component';
import { Constants } from 'constant';
import { TenantInfo } from 'type';
import { BasicInfoArea } from '../components/BasicInfoArea';
import { Surroundings } from '../components/Surroundings';
import { Foundations } from '../components/Foundations';
import { Reservation } from '../components/Reservation';
import { HotelTabBar, HOTEL_TABS_INFO } from '../model/HotelTabInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Extend(Column)
function detailCommon() {
  .backgroundColor($r('sys.color.comp_background_primary'))
  .padding(12)
  .borderRadius(16);
}

@Builder
export function HotelBuilder() {
  Hotel();
}

@ComponentV2
export struct Hotel {
  @Local isShow: boolean = false;
  @Local index: number = 0;
  @Local activeIndex: number = 0;
  vm: HomePageVM = HomePageVM.instance;
  @Local tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  scroller = new Scroller();

  @Builder
  InfoBuilder() {
    List({ space: 16, scroller: this.scroller }) {
      ListItem() {
        Column({ space: 16 }) {
          BasicInfoArea({ isHome: false });
          Column() {
            Text(this.vm.hotelInfo.appInfo.introduction)
              .fontSize(14).lineHeight(24);
          }.detailCommon().width(Constants.FULL_SCREEN);
        };
      };

      ListItem() {
        Foundations({
          foundations: this.vm.hotelInfo.appInfo.instructions?.foundations
        })
      };

      ListItem() {
        Reservation({
          reservation: this.vm.hotelInfo.appInfo.instructions?.reservation,
        })
      };

      ListItem() {
        Surroundings({
          tenantInfo: this.vm.tenantInfo,
          foodList: this.vm.surroundings.food,
          attractionsList: this.vm.surroundings.attractions
        })
      };
    }.scrollBar(BarState.Off)
    .padding({ left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .layoutWeight(1);
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: '门店信息', showBackButton: true, backButtonClick: () => {
          this.mainPathStack.pop();
        }})

        Row() {
          ForEach(HOTEL_TABS_INFO, (item: HotelTabBar) => {
            Column() {
              Text(item.title)
                .fontSize(14)
                .fontColor(this.index === item.index ? $r('sys.color.font_emphasize') :
                  $r('sys.color.font_secondary'))
                .fontWeight(this.index === item.index ? FontWeight.Bold : FontWeight.Regular);
            }
            .onClick(() => {
              this.index = item.index;
              this.scroller.scrollToIndex(this.index);
            })
            .layoutWeight(1)
            .height(40)
            .justifyContent(FlexAlign.Center);
          }, (item: HotelTabBar) => JSON.stringify(item));
        }.width(Constants.FULL_SCREEN)

        this.InfoBuilder();
      };
    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'));
  }
}