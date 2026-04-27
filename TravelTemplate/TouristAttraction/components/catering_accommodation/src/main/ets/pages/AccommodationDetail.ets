import { common } from '@kit.AbilityKit';
import { LazyDataSource, SystemUtil } from 'module_base';
import { CustomTitle } from '../component/TitleBar';
import { AccommodationInfo } from '../model/Index';

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
        Column() {
          CustomTitle({
            isShowBack: true, title: this.detailInfo.name, clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Scroll() {
            Column() {
              Swiper() {
                LazyForEach(this.banners, (item: ResourceStr) => {
                  Image(item).size({ width: '100%', height: 240 });
                }, (item: string) => item);
              }.cachedCount(3);

              Column({ space: 16 }) {
                Column({ space: 16 }) {
                  Column({ space: 8 }) {
                    Text(`${this.detailInfo.name}`)
                      .fontSize(20)
                      .fontWeight(700)
                      .width('100%')
                      .textAlign(TextAlign.Start);

                    Row({ space: 8 }) {
                      ForEach(this.detailInfo.labels, (item: string) => {
                        Text(item).fontSize(10).border({ width: 1, color: '#2EB78A', radius: 4 }).padding(2);
                      }, (item: string) => item);
                    }.width('100%').justifyContent(FlexAlign.Start).borderRadius(8);
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
                      SystemUtil.routerToPetalMap(this.detailInfo.latitude, this.detailInfo.longitude,
                        this.detailInfo.name, this.getUIContext().getHostContext() as common.UIAbilityContext);
                    });
                  }
                  .padding(12)
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .backgroundColor('#F1F3F5F2')
                  .borderRadius(8)
                  .opacity(0.95);

                }.alignItems(HorizontalAlign.Start);

                Column({ space: 8 }) {
                  Text('酒店概况').fontWeight(500).width('100%').textAlign(TextAlign.Start);

                  Text(this.detailInfo.detail).fontSize(14).lineHeight(20);
                };

                ForEach(this.detailInfo.detailImages, (item: ResourceStr) => {
                  Image(item).width('100%');
                }, (item: ResourceStr) => JSON.stringify(item));
              }.padding(12);
            };
          }.edgeEffect(EdgeEffect.Spring).height('80%').align(Alignment.Top).scrollBar(BarState.Off);
        };

        Row() {
          Button('马上预约').width('100%').backgroundColor('#64BB5C').borderRadius(20).onClick(() => {
            SystemUtil.triggerForCall(this.getUIContext(), '12345678911');
          });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .padding({ left: 12, right: 12 })
        .backgroundColor($r('sys.color.font_on_primary'))
      }.height('100%').justifyContent(FlexAlign.SpaceBetween)
    }.title(this.detailInfo.name).hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.detailInfo = context.pathInfo.param as AccommodationInfo;
      this.banners.pushArrayData(this.detailInfo.banners);
    });
  }
}