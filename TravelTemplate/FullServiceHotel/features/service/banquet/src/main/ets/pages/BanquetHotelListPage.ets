import { CommonHeader } from 'componentlib';
import { https } from 'network';
import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { BanquetHotelCard } from '../components/BanquetHotelCard';
import { BanquetHotelItem, BanquetListRouteParam } from '../types';


@ComponentV2
struct BanquetHotelListPage {
  private readonly topBannerHeight: number = 50;
  @Local
  private banquetHotelList: BanquetHotelItem[] = [];

  aboutToAppear(): void {
    https.getBanquetHotelList().then((res) => {
      if (res.code === 0) {
        const initList: BanquetHotelItem[] = res.data;
        this.banquetHotelList = initList.map((item) => {
          return {
            hotelName: item.hotelName,
            hotelAddress: item.hotelAddress,
            maxArea: item.maxArea,
            maxCapacity: item.maxCapacity,
            id: item.id,
            displayImg: FormatUtil.getImgResource(item.displayImg),
          } as BanquetHotelItem;
        });
      }
    });
  }

  build() {
    NavDestination() {
      CommonHeader({
        title: '婚宴预订',
      });
      Column() {
        Scroll() {
          Column() {
            if (this.banquetHotelList.length) {
              ForEach(
                this.banquetHotelList,
                (item: BanquetHotelItem) => {
                  BanquetHotelCard({
                    title: item.hotelName,
                    cover: item.displayImg,
                    address: item.hotelAddress,
                    maxArea: item.maxArea,
                    maxCapacity: item.maxCapacity,
                  })
                    .onClick(() => {
                      RouterModule.push({
                        url: RouterMap.BANQUET_LIST,
                        param: {
                          hotelName: item.hotelName,
                          id: item.id,
                        } as BanquetListRouteParam,
                      });
                    });
                },
                (item: BanquetHotelItem) => JSON.stringify(item),
              );
            }
          }
          .width('100%');
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .margin({ bottom: this.topBannerHeight });
      };
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%');
  }
}

@Builder
export function banquetHotelListPageBuilder() {
  BanquetHotelListPage();
}