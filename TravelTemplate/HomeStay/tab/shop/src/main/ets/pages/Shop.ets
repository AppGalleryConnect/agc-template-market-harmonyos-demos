import { CommonBlank, CommonHeader } from 'component';
import { Constants, NavPathName } from 'constant';
import { Commodity } from 'type';
import { CommodityWaterFlow } from '../components/CommodityWaterFlow';
import { ShopPageVM } from '../viewmodel/ShopPageVM';

@Builder
export function ShopBuilder() {
  Shop();
}

@ComponentV2
export struct Shop {
  vm: ShopPageVM = ShopPageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Stack() {
            if (this.vm.carouselImageList.length > 0) {
              Image(this.vm.carouselImageList[0].image)
                .height(276)
                .width(Constants.FULL_SCREEN)
                .objectFit(ImageFit.Cover)
            }
            Column()
              .height(138)
              .width(Constants.FULL_SCREEN)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['rgba(255,255,255,0.6)', 0.0], ['rgba(255,255,255,0.0)', 1.0]]
              })
            CommonHeader({ title: '商城' })
          }.alignContent(Alignment.TopStart)

          Column() {
            Column() {
              Row() {
                Text('新品推荐')
                  .fontSize(18)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Bold);
                Row({ space: 4 }) {
                  Text('查看更多')
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'));
                  Image($r('app.media.icon_direction_right_gray'))
                    .size({ width: 12, height: 24 })
                    .objectFit(ImageFit.Contain);
                }.onClick(() => {
                  this.viewFull();
                }).alignItems(VerticalAlign.Center);
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);

              if (this.vm.commodityList.length !== 0) {
                List({ space: 12 }) {
                  ForEach(this.vm.commodityList.slice(0, 3), (item: Commodity) => {
                    ListItem() {
                      Column() {
                        Image(item.banner)
                          .size({ width: 120, height: 120 })
                          .borderRadius(8)
                          .objectFit(ImageFit.Cover);
                        Text(item.goodsName)
                          .fontSize(12)
                          .fontColor($r('sys.color.font_primary'))
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .width(120)
                          .margin({ top: 8 });
                        Row({ space: 4 }) {
                          Row() {
                            Text('￥')
                              .fontSize(12)
                              .fontWeight(FontWeight.Medium)
                              .fontColor($r('sys.color.warning'));
                            Text(`${(item.retailPrice[0] * 100) / 100}`)
                              .fontSize(16)
                              .fontWeight(FontWeight.Medium)
                              .fontColor($r('sys.color.warning'));
                          }
                          Text(`￥${(item.counterPrice[0] * 100) / 100}`)
                            .fontSize(12)
                            .fontColor($r('sys.color.font_tertiary'))
                            .decoration({ type: TextDecorationType.LineThrough });
                        }.margin({ top: 4 })
                          .alignItems(VerticalAlign.Center);
                      }
                      .alignItems(HorizontalAlign.Start)
                      .borderRadius(16)
                      .backgroundColor($r('sys.color.comp_background_primary'))
                      .padding(12);
                    }.onClick(() => {
                      this.mainPathStack.pushPathByName(NavPathName.COMMODITY_DETAIL, item);
                    });
                  }, (item: Commodity) => item.id.toString());
                }.listDirection(Axis.Horizontal).margin({ top: 12 }).scrollBar(BarState.Off).alignListItem(ListItemAlign.Start).width('100%');
              } else {
                CommonBlank();
              }
            }.margin({ top: 10 });

            Column({ space: 8 }) {
              Row() {
                Text('全部推荐')
                  .fontSize(18)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Bold);
                Row({ space: 4 }) {
                  Text('查看更多')
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'));
                  Image($r('app.media.icon_direction_right_gray'))
                    .size({ width: 12, height: 24 })
                    .objectFit(ImageFit.Contain);
                }.onClick(() => {
                  this.viewFull();
                }).alignItems(VerticalAlign.Center);
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);

              CommodityWaterFlow();
            }.margin({ top: 12 });
          }.padding({ left: 16, right: 16 })
            .borderRadius({ topLeft: 8, topRight: 8 })
            .backgroundColor($r('sys.color.background_secondary'))
            .width(Constants.FULL_SCREEN);
        };
      }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
        .backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true);
  }

  viewFull() {
    this.mainPathStack.pushPathByName(NavPathName.COMMODITY_LIST, true);
  }
}