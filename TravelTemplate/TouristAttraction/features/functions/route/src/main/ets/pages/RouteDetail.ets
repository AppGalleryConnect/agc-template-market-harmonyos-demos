import { Constant, Logger } from 'common';
import { TitleBar } from 'components';
import { https } from 'network';
import { AttractionInfo } from 'types';
import { mapperRouteLineDetail } from '../mapper/Index';
import { RouteLineInfo } from '../model/RouteLineInfo';

@Builder
export function RouteDetailBuilder() {
  RouteDetail();
}

@ComponentV2
export struct RouteDetail {
  @Local routeId: number = 0;
  @Local routeLineInfo: RouteLineInfo = new RouteLineInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  getRouteInfoById() {
    https.getRouteDetail(this.routeId).then((res) => {
      this.routeLineInfo = mapperRouteLineDetail(res.data);
      Logger.info('route info is ' + JSON.stringify(this.routeLineInfo));
    });
  }

  @Builder
  RouteSummaryBuilder() {

    Column() {
      Text(this.routeLineInfo.routeName).fontSize(20).fontWeight(700);

      Text() {
        Span('景点：');
        Span(`${this.routeLineInfo.attractions.length}个景点`);
      }.fontSize(12).opacity(0.6).margin({ top: 8, bottom: 4 });

      Text() {
        Span('路线：');
        Span(`${this.routeLineInfo.routeDistance}km`);
      }.fontSize(12).opacity(0.6);
    }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);
  }

  @Builder
  RouteBriefBuilder() {
    Column({ space: 8 }) {
      Text('路线简介').fontWeight(500);
      Text(this.routeLineInfo.brief).fontSize(14).opacity(0.6);
      Grid() {
        ForEach(this.routeLineInfo.attractions, (item: AttractionInfo, index: number) => {
          GridItem() {
            Column({ space: 4 }) {
              Stack({ alignContent: Alignment.TopStart }) {
                Image(item.banner).size({ width: 100, height: 100 }).borderRadius(8).onClick(() => {
                  this.mainPathStack.pushPathByName('AttractionDetail', item.attractionId);
                });
                Text(`0${index}`)
                  .padding(2)
                  .backgroundColor('rgba(0, 0, 0, 0.6)')
                  .fontSize(10)
                  .borderRadius({ topLeft: 8, bottomRight: 8 });
              };

              Text(item.name).fontSize(12).opacity(0.4);
            };
          };
        }, (item: AttractionInfo) => item.attractionId.toString());
      }.columnsGap(12);
    }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);
  }

  @Builder
  RouteDetailBuilder() {
    Column({ space: 8 }) {
      Text('路线详情').fontWeight(500);
      Text(this.routeLineInfo.introduction).fontSize(14).opacity(0.6);
    }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        TitleBar({
          isShowBack: true, title: this.routeLineInfo.routeName, clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        Scroll() {
          Column() {
            Image(this.routeLineInfo.routeBanner).width(Constant.FULL_PERCENT).height(200);

            Column({ space: 12 }) {
              this.RouteSummaryBuilder();
              this.RouteBriefBuilder();
              this.RouteDetailBuilder();
            }.padding(12);
          };
        }.height('90%').align(Alignment.Top);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.routeId = context.pathInfo.param as number;
      this.getRouteInfoById();
    });
  }
}