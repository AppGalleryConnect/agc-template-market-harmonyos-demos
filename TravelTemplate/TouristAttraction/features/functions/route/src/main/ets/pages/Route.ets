import { Constant, LazyDataSource, Logger } from 'common';
import { TitleBar } from 'components';
import { https } from 'network';
import { mapperRouteLineList } from '../mapper/Index';
import { RouteLineInfo } from '../model/RouteLineInfo';

@Builder
export function RouteBuilder() {
  Route();
}

@ComponentV2
export struct Route {
  @Local routeLineList: LazyDataSource<RouteLineInfo> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    https.getRouteLineList().then((res) => {
      this.routeLineList.pushArrayData(mapperRouteLineList(res.data));
      Logger.info('total count of routeLine ' + this.routeLineList.totalCount());
    });
  }

  @Builder
  RouteCardBuilder(item: RouteLineInfo) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(item.routeBanner).width(Constant.FULL_PERCENT).height(180).borderRadius(16).objectFit(ImageFit.Fill);
      Column() {
        Text(`${item.routeName}`).fontWeight(500).margin({ bottom: 4 }).fontColor(Color.White);
        Row({ space: 16 }) {
          Row() {
            Image($r('app.media.route_spot')).size({ width: 16, height: 16 }).margin({ right: 2 });
            Text(`${item.attractionIds.length}个景点`)
              .fontSize(12)
              .margin({ right: 2 })
              .fontColor(Color.White);
          };

          Row() {
            Image($r('app.media.route_time')).size({ width: 16, height: 16 }).margin({ right: 2 });
            Text(`${item.duration}小时`).fontSize(12).fontColor(Color.White);
          };

          Row() {
            Image($r('app.media.route_line')).size({ width: 16, height: 16 }).margin({ right: 2 });
            Text(`${item.routeDistance}km`).fontSize(12).fontColor(Color.White);
          };
        };
      }.alignItems(HorizontalAlign.Start).padding({ left: 12, right: 12, bottom: 12 });
    }.onClick(() => {
      this.mainPathStack.pushPathByName('RouteDetail', item.routeId);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '路线推荐', clickEvent: () => {
            this.mainPathStack.pop();
          },
        })

        List({ space: 12 }) {
          LazyForEach(this.routeLineList, (item: RouteLineInfo) => {
            ListItem() {
              this.RouteCardBuilder(item);
            };
          });
        }.padding(12).height('90%');
      }
    }.hideTitleBar(true);
  }
}