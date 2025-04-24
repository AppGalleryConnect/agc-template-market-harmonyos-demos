import { BanquetCard } from '../components/BanquetCard';
import { https } from 'network';
import { BanquetRoomItem } from '../types';
import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { CommonHeader } from 'componentlib';

@ComponentV2
struct BanquetListPage {
  @Local private title: string = '';
  @Local private banquetRoomList: BanquetRoomItem[] = [];

  getBanquetRoomList(hotelId: number) {
    https.getBanquetRoomList(hotelId).then((res) => {
      if (res.code === 0) {
        const initList: BanquetRoomItem[] = res.data;
        this.banquetRoomList = initList.map((item) => {
          return {
            banquetName: item.banquetName,
            hotelId: item.hotelId,
            hotelName: item.hotelName,
            labelList: item.labelList,
            profile: item.profile,
            introduce: item.introduce,
            id: item.id,
            banner: FormatUtil.getImgResource(item.banner),
          } as BanquetRoomItem;
        });
      }
    });
  }

  build() {
    NavDestination() {
      CommonHeader({
        title: this.title,
      });
      Scroll() {
        Column() {
          if (this.banquetRoomList.length) {
            ForEach(this.banquetRoomList, (item: BanquetRoomItem) => {
              BanquetCard({
                banquetItem: item,
              })
                .onClick(() => {
                  RouterModule.push({
                    url: RouterMap.BANQUET_INFO,
                    param: item.id,
                  });
                });
              Divider()
                .strokeWidth(1)
                .padding({
                  left: $r('app.string.padding_m'),
                  right: $r('app.string.padding_m'),
                })
                .color('#FFE0E0E0');
            }, (item: BanquetRoomItem) => JSON.stringify(item));
          }
        }
        .width('100%');
      }
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)

    .onReady(() => {
      const params: Record<string, string | number> | undefined = RouterModule.getNavParam({
        url: RouterMap.BANQUET_LIST,
      });
      if (params) {
        this.title = params.hotelName as string;
        this.getBanquetRoomList(params.id as number);
      }
    });
  }
}

@Builder
export function banquetListPageBuilder() {
  BanquetListPage();
}