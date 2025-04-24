import { Constant, LazyDataSource, Logger, routerToPetalMap, triggerForCall } from 'common';
import { SwiperComponent, TitleBar } from 'components';
import { CateringInfo } from 'types';
import { common } from '@kit.AbilityKit';

@Builder
export function CateringDetailBuilder() {
  CateringDetail();
}

@ComponentV2
export struct CateringDetail {
  @Local detailInfo: CateringInfo = new CateringInfo();
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.detailInfo.name, clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Stack() {
          Scroll() {
            Column() {
              SwiperComponent(this.banners);
              Column({ space: 8 }) {
                Text(`${this.detailInfo.name}`).fontSize(20).fontWeight(700);
                Text(`营业时间${this.detailInfo.openHours}`).fontSize(12).opacity(0.6);

                Row() {
                  Row({ space: 8 }) {
                    Image($r('app.media.location')).size({ width: 14, height: 14 });
                    Text(this.detailInfo.address)
                      .fontSize(12)
                      .opacity(0.6)
                      .textAlign(TextAlign.Start)
                      .width(240)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                  };

                  Row() {
                    Image($r('app.media.navigation')).size({ width: 14, height: 14 });
                    Text('导航').fontSize(12).opacity(0.6);
                  }.onClick(() => {
                    routerToPetalMap(this.detailInfo.latitude, this.detailInfo.longitude,
                      this.detailInfo.name, getContext(this) as common.UIAbilityContext);
                  });
                }
                .width(Constant.FULL_PERCENT)
                .justifyContent(FlexAlign.SpaceBetween)
                .borderRadius(8)
                .padding(12)
                .backgroundColor('#F1F3F5F2')
                .opacity(0.95);

                Text('餐饮详情').fontWeight(500);

                Text(this.detailInfo.detail).fontSize(14).lineHeight(20);

                ForEach(this.detailInfo.detailImages, (item: ResourceStr) => {
                  Image(item).width(Constant.FULL_PERCENT);
                }, (item: ResourceStr) => JSON.stringify(item));
              }.alignItems(HorizontalAlign.Start).padding(12);
            };
          }.height(Constant.FULL_PERCENT).align(Alignment.Top).scrollBar(BarState.Off);

          Row() {
            Text() {
              Span('￥').fontSize(12).fontColor('#E84026').fontWeight(500);
              Span(`${this.detailInfo.startPrice}起`)
                .fontColor('#E84026')
                .fontSize(20)
                .fontWeight(500);
            };

            Button('马上预约').backgroundColor('#64BB5C').fontSize(14).onClick(() => {
              triggerForCall('12345678911');
            });
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(Constant.FULL_PERCENT)
          .height('10%')
          .position({ y: '90%' })
          .backgroundColor(Color.White)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12, right: 12 });
        }.height('90%');
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.detailInfo = context.pathInfo.param as CateringInfo;
      this.banners.pushArrayData(this.detailInfo.banners);
      Logger.info('catering info is ' + this.detailInfo);
    });
  }
}