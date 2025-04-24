import { Constant, LazyDataSource } from 'common';
import { TitleBar } from 'components';
import { CommodityInfo } from '../model/CommodityInfo';
import { CommodityTabBarData, COMMODITY_TABS_INFO } from '../model/CommodityTabInfo';
import { CommodityVM } from '../viewmodel/CommodityVM';

@Builder
export function MallBuilder() {
  MallView();
}

@ComponentV2
export struct MallView {
  vm: CommodityVM = CommodityVM.instance;
  private scroller: Scroller = new Scroller();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.getCommodityList();
  }

  @Builder
  CommodityTabBar(title: ResourceStr, targetIndex: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontColor(this.vm.type === targetIndex ? '#64BB5C' :
        Color.Black)
        .opacity(this.vm.type === targetIndex ? 1 :
          0.6);

      if (this.vm.type === targetIndex) {
        Divider().color('#64BB5C').strokeWidth(3).width(64);
      }
    }
    .onClick(() => {
      // 切换tab触发数据请求
      this.vm.type = targetIndex;
      this.vm.getCommodityList();
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  CommodityWaterFlowBuilder(commodityList: LazyDataSource<CommodityInfo>) {
    Grid() {
      LazyForEach(commodityList, (item: CommodityInfo) => {
        GridItem() {
          this.CommodityCardBuilder(item);
        }
        .width(Constant.FULL_PERCENT);
      }, (item: CommodityInfo) => item.commodityId.toString());
    }
    .cachedCount(10)
    .columnsTemplate('1fr 1fr')
    .columnsGap(6)
    .rowsGap(6)
    .width(Constant.FULL_PERCENT)
    .padding(16)
    .backgroundColor('#F1F3F5');
  }

  @Builder
  CommodityCardBuilder(item: CommodityInfo) {
    Column() {
      Image(item.banner).objectFit(ImageFit.Contain).clip(true).borderRadius(8);

      Column() {
        Text(item.name)
          .fontSize(12)
          .fontWeight(500)
          .margin({ top: 8, bottom: 12 })
          .maxLines(2)
          .width(Constant.FULL_PERCENT)
          .textAlign(TextAlign.Start);

        Row() {
          Row() {
            Text() {
              Span('￥').fontSize(12).fontColor('#E84026');
              Span(`${item.spuInfo[item.basicSpu]?.spuDiscountPrice}`)
                .fontSize(16)
                .fontWeight(500)
                .fontColor('#E84026');
            };

            Text(`￥${item.spuInfo[item.basicSpu]?.spuOriginalPrice}`)
              .fontSize(10)
              .decoration({ type: TextDecorationType.LineThrough })
              .opacity(0.4);
          }.alignItems(VerticalAlign.Bottom);

          Button('预订')
            .backgroundColor('#64BB5C')
            .fontSize(12)
            .height(28)
            .borderRadius(24)
            .fontColor(Color.White);
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
      }.padding(12);
    }.onClick(() => {
      this.mainPathStack.pushPathByName('CommodityDetail', item.commodityId);
    }).backgroundColor(Color.White).borderRadius(8);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '特色文创', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tabs({ index: this.vm.type }) {
          ForEach(COMMODITY_TABS_INFO, (item: CommodityTabBarData) => {
            TabContent() {
              this.CommodityWaterFlowBuilder(this.vm.commodityList);
            }.tabBar(this.CommodityTabBar(item.title, item.type));
          }, (item: CommodityTabBarData) => item.title.toString());
        }.barWidth(160).animationMode(AnimationMode.NO_ANIMATION).height('90%').onChange((value: number) => {
          this.vm.type = value;
          this.vm.getCommodityList();
        });
      };
    }.hideTitleBar(true);
  }
}