import { Constant, LazyDataSource, routerToPetalMap, triggerForCall } from 'common';
import { SwiperComponent, TitleBar } from 'components';
import { AccommodationInfo } from 'types';
import { common } from '@kit.AbilityKit';

@Builder
export function AccommodationDetailBuilder() {
  AccommodationDetail();
}

@ComponentV2
export struct AccommodationDetail {
  @Local detailInfo: AccommodationInfo = new AccommodationInfo();
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

        Stack({ alignContent: Alignment.End }) {
          Scroll() {
            Column() {
              SwiperComponent(this.banners);
              Column({ space: 16 }) {
                Column({ space: 16 }) {
                  Column({ space: 8 }) {
                    Text(`${this.detailInfo.name}`)
                      .fontSize(20)
                      .fontWeight(700)
                      .width(Constant.FULL_PERCENT)
                      .textAlign(TextAlign.Start);

                    Row({ space: 8 }) {
                      ForEach(this.detailInfo.labels, (item: string) => {
                        Text(item).fontSize(10).border({ width: 1, color: '#2EB78A', radius: 4 }).padding(2);
                      }, (item: string) => item);
                    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start).borderRadius(8);
                  };

                  Row() {
                    Row({ space: 8 }) {
                      Image($r('app.media.location')).size({ width: 14, height: 14 });
                      Text(this.detailInfo.address)
                        .fontSize(12)
                        .opacity(0.6)
                        .width(240)
                        .textAlign(TextAlign.Start)
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
                  .padding(12)
                  .width(Constant.FULL_PERCENT)
                  .justifyContent(FlexAlign.SpaceBetween)
                  .backgroundColor('#F1F3F5F2')
                  .borderRadius(8)
                  .opacity(0.95);

                }.alignItems(HorizontalAlign.Start);

                Column({ space: 8 }) {
                  Text('酒店概况').fontWeight(500).width(Constant.FULL_PERCENT).textAlign(TextAlign.Start);

                  Text(this.detailInfo.detail).fontSize(14).lineHeight(20);
                };

                ForEach(this.detailInfo.detailImages, (item: ResourceStr) => {
                  Image(item).width(Constant.FULL_PERCENT);
                }, (item: ResourceStr) => JSON.stringify(item));
              }.padding(12);
            };
          }.height(Constant.FULL_PERCENT).align(Alignment.Top).scrollBar(BarState.Off);

          Row() {
            Button('马上预约').width(Constant.FULL_PERCENT).backgroundColor('#64BB5C').borderRadius(20).onClick(() => {
              triggerForCall('12345678911');
            });
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(Constant.FULL_PERCENT)
          .height('10%')
          .padding({ left: 12, right: 12 })
          .backgroundColor(Color.White)
          .position({ y: '90%' });
        }.height('90%');
      };
    }.title(this.detailInfo.name).hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.detailInfo = context.pathInfo.param as AccommodationInfo;
      this.banners.pushArrayData(this.detailInfo.banners);
    });
  }
}