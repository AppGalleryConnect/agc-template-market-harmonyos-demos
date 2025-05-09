import { CommonBlank } from 'component';
import { Constants, NavPathName } from 'constant';
import { CarouselImage, Commodity } from 'type';
import { CommodityWaterFlow } from '../components/CommodityWaterFlow';
import { ShopPageVM } from '../viewmodel/ShopPageVM';

@Builder
export function ShopBuilder() {
  Shop();
}

@Component
export struct Shop {
  vm: ShopPageVM = ShopPageVM.instance;
  private swiperController: SwiperController = new SwiperController();
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Swiper(this.swiperController) {
            LazyForEach(this.vm.imageList, (item: CarouselImage) => {
              Image(item.image).objectFit(ImageFit.Fill);
            });
          }
          .height(250)
          .cachedCount(2)
          .loop(false)
          .indicator(new DotIndicator()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .color($r('app.color.common_bg_color'))
            .selectedColor($r('sys.color.comp_background_emphasize')))
          .width(Constants.FULL_SCREEN);

          Column() {
            Column() {
              Row() {
                Text('新品推荐')
                  .fontWeight(600)
                  .fontSize(14);
                Row() {
                  Text('全部').fontSize(12).fontColor($r('app.color.view_more_font_color'));
                  Image($r('app.media.icon_direction_right_gray'))
                    .size({ width: 12, height: 12 })
                    .objectFit(ImageFit.Contain)
                    .onClick(() => {
                      this.viewFull();
                    });
                }.onClick(() => {
                  this.viewFull();
                }).alignItems(VerticalAlign.Center);
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);

              if (this.vm.commodityList.length !== 0) {
                List({ space: 12 }) {
                  ForEach(this.vm.commodityList.slice(0, 3), (item: Commodity) => {
                    ListItem() {
                      Stack() {
                        Flex({
                          direction: FlexDirection.Column,
                          justifyContent: FlexAlign.End,
                          alignItems: ItemAlign.Start,
                        }) {
                          Text(item.goodsName)
                            .fontSize(12)
                            .fontColor(Color.White)
                            .fontWeight(600)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis });

                          Text(`￥${item.retailPrice[0]}`).fontSize(12).fontColor(Color.White).fontWeight(600);
                        }.zIndex(1).width(Constants.FULL_SCREEN).padding(8);

                        Image(item.banner).borderRadius(10);
                      }.size({ width: 120, height: 120 });
                    }.onClick(() => {
                      this.mainPathStack.pushPathByName(NavPathName.COMMODITY_DETAIL, item);
                    });
                  }, (item: Commodity) => item.id.toString());
                }.listDirection(Axis.Horizontal).margin({ top: 12 }).scrollBar(BarState.Off);
              } else {
                CommonBlank();
              }
            }.margin({ top: 10 });

            Column() {
              Row() {
                Text('全部推荐')
                  .fontWeight(600)
                  .fontSize(14);

                Row() {
                  Text('全部').fontSize(12).fontColor($r('app.color.view_more_font_color'));
                  Image($r('app.media.icon_direction_right_gray'))
                    .size({ width: 12, height: 12 })
                    .objectFit(ImageFit.Contain);
                }.onClick(() => {
                  this.viewFull();
                });
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 });

              CommodityWaterFlow();
            }.margin({ top: 12 });
          }.padding({ left: 16, right: 16 });
        };
      }.scrollBar(BarState.Off);
    };
  }

  viewFull() {
    this.mainPathStack.pushPathByName(NavPathName.COMMODITY_LIST, true);
  }
}