import { https } from 'network';
import { mapperCommodityDetail } from '../mapper/Index';
import { CommodityInfo, SpuInfo } from '../model/CommodityInfo';
import { Constant, LazyDataSource } from 'common';
import { FullLoadingComponent, SwiperComponent, TitleBar } from 'components';
import { CommodityDetailVM } from '../viewmodel/CommodityDetailVM';

@Builder
export function CommodityDetailBuilder() {
  CommodityDetail();
}

@ComponentV2
export struct CommodityDetail {
  vm: CommodityDetailVM = CommodityDetailVM.instance;
  @Local isShow: boolean = false;
  @Local isLoading: boolean = true;
  @Local selectedSpu: number = 0;
  @Local commodityInfo: CommodityInfo = new CommodityInfo();
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  BasicInfoBuilder() {
    Column() {
      Row() {
        Text() {
          Span('￥').fontSize(12).fontColor('#E84026');
          Span(`${this.commodityInfo.spuInfo[this.selectedSpu]?.spuDiscountPrice}`)
            .fontSize(24)
            .fontWeight(500)
            .fontColor('#E84026');
        };

        Text(`￥${this.commodityInfo.spuInfo[this.selectedSpu]?.spuOriginalPrice}`)
          .fontSize(12)
          .decoration({ type: TextDecorationType.LineThrough })
          .opacity(0.4);
      };

      Text(this.commodityInfo.name)
        .fontSize(18)
        .fontWeight(500)
        .margin({ top: 8, bottom: 18 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      Row() {
        Text() {
          Span('规格：').opacity(0.4).fontSize(14);
          Span(this.commodityInfo.spuInfo[this.selectedSpu]?.spuName)
            .opacity(0.4)
            .fontSize(14)
            .fontWeight(500);
        };

        Image($r('app.media.chevron_right')).size({ height: 14, width: 6 });
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
        this.isShow = true;
      })
      .bindSheet($$this.isShow, this.SpecificationBuilder(), {
        height: '40%',
        backgroundColor: Color.White,
        title: { title: '商品规格' },
      });
    }.padding(16).alignItems(HorizontalAlign.Start);
  }

  @Builder
  DetailBuilder() {
    Column({ space: 12 }) {
      Text('商品详情')
        .fontSize(14)
        .fontWeight(500)
        .width(Constant.FULL_PERCENT)
        .textAlign(TextAlign.Start);
      ForEach(this.commodityInfo.detailImages, (item: ResourceStr) => {
        Image(item);
      }, (item: ResourceStr) => item.toString());
    }.padding(16);
  }

  @Builder
  SpecificationBuilder() {
    Column({ space: 24 }) {
      Row({ space: 12 }) {
        Image(this.commodityInfo.banner).size({ width: 64, height: 64 }).borderRadius(8);

        Column({ space: 14 }) {
          Text(this.commodityInfo.name)
            .fontSize(16)
            .maxLines(1)
            .width(200)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(500);

          Column() {
            Text() {
              Span('￥').fontSize(12).fontColor('#E84026');
              Span(`${this.commodityInfo.spuInfo[this.selectedSpu]?.spuDiscountPrice}`)
                .fontSize(18)
                .fontWeight(500)
                .fontColor('#E84026');
            };

            Text(`￥${this.commodityInfo.spuInfo[this.selectedSpu]?.spuOriginalPrice}`)
              .fontSize(12)
              .decoration({ type: TextDecorationType.LineThrough })
              .opacity(0.4);
          }.alignItems(HorizontalAlign.Start);
        }.alignItems(HorizontalAlign.Start);
      }.width(Constant.FULL_PERCENT).backgroundColor(Color.White).borderRadius(8);

      Column({ space: 12 }) {
        Text('规格').fontWeight(500);
        Row({ space: 12 }) {
          ForEach(this.commodityInfo.spuInfo, (sfc: SpuInfo, index: number) => {
            Text(`${sfc.spuName}`)
              .border({
                width: 1, color: this.selectedSpu === index ? '#64BB5C' :
                  'rgba(0, 0, 0, 0.2)', radius: 20,
              })
              .fontColor(this.selectedSpu === index ? '#64BB5C' :
                'rgba(0, 0, 0, 0.9)')
              .padding(10)
              .fontSize(12)
              .backgroundColor(Color.White)
              .onClick(() => {
                if (this.selectedSpu !== index) {
                  // 选择切换，规格变化
                  this.selectedSpu = index;
                }
              });
          }, (sfc: SpuInfo, index: number) => index + '__' + JSON.stringify(sfc));
        };
      }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);
    }.padding({ left: 16, right: 16 }).align(Alignment.Top);
  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        FullLoadingComponent();
      } else {
        Column() {
          Column() {
            TitleBar({
              isShowBack: true, title: this.commodityInfo.name, clickEvent: () => {
                this.mainPathStack.pop();
              },
            });
            Scroll() {
              Column() {
                SwiperComponent(this.banners);

                this.BasicInfoBuilder();

                this.DetailBuilder();
              };
            }.align(Alignment.Top).scrollBar(BarState.Off).height('90%');
          }.height('90%');

          Row() {
            Button('立即购买')
              .fontColor(Color.White)
              .fontSize(14)
              .width(Constant.FULL_PERCENT)
              .borderRadius(20)
              .backgroundColor('#64BB5C')
              .onClick(() => {
                this.mainPathStack.pushPathByName('CommodityReserve',
                  this.vm.mapPurchaseParam(this.commodityInfo, this.selectedSpu));
              });
          }
          .height('10%')
          .position({ y: '90%' })
          .backgroundColor(Color.White)
          .padding(12);
        }.backgroundColor('#F1F3F5');
      }
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      https.getCommodityDetail(context.pathInfo.param as number).then(res => {
        this.commodityInfo = mapperCommodityDetail(res.data);
        this.banners.pushArrayData(this.commodityInfo.banners);
        // 初始化选择的规格
        this.selectedSpu = this.commodityInfo.basicSpu;
        this.isLoading = false;
      });
    });
  }
}
