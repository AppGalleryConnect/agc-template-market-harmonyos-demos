import { Constant, LazyDataSource, Logger } from 'common';
import { TitleBar } from 'uicomponents';
import { RouteModel, RouteParam } from 'module_base';
import { https } from 'network';
import { mapperRouteLineList } from '../mapper/Index';
import { display } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

@Builder
export function RouteBuilder() {
  Route();
}

@ComponentV2
export struct Route {
  @Local routeLineList: LazyDataSource<RouteModel> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local folderColumn: string = '1fr'

  aboutToAppear(): void {
    this.checkDevice()
    https.getRouteLineList().then((res) => {
      this.routeLineList.pushArrayData(mapperRouteLineList(res.data));
      Logger.info('total count of routeLine ' + this.routeLineList.totalCount());
    });
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', (data: display.FoldStatus) => {
        UtilLog.info(`unregistering FoldStatus changes callback. Data: ${data}`)
      })
    } catch (e) {
      UtilLog.error(JSON.stringify(e))
    }
  }

  // 是否为折叠屏
  checkDevice() {
    if (display.isFoldable()) {
      try {
        if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          this.folderColumn = '1fr 1fr'
        } else {
          this.folderColumn = '1fr'
        }

        display.on('foldStatusChange', (data: display.FoldStatus) => {
          if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
            this.folderColumn = '1fr 1fr'
          } else {
            this.folderColumn = '1fr'
          }
        });
      } catch (e) {
        UtilLog.error(JSON.stringify(e))
      }
    }
  }

  @Builder
  RouteCardBuilder(item: RouteModel) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(item.routeBanner).width(Constant.FULL_PERCENT).height(180).borderRadius(16).objectFit(ImageFit.Fill);
      Column() {
        Text(`${item.routeName}`).fontWeight(500).margin({ bottom: 4 }).fontColor($r('sys.color.font_on_primary'));
        Row({ space: 16 }) {
          Row() {
            Image($r('app.media.route_spot')).size({ width: 16, height: 16 }).margin({ right: 2 });
            Text(`${item.attractionIds.length}个景点`)
              .fontSize(12)
              .margin({ right: 2 })
              .fontColor($r('sys.color.font_on_primary'));
          };

          Row() {
            Image($r('app.media.route_time')).size({ width: 16, height: 16 }).margin({ right: 2 });
            Text(`${item.duration}小时`).fontSize(12).fontColor($r('sys.color.font_on_primary'));
          };

          Row() {
            Image($r('app.media.route_line')).size({ width: 16, height: 16 }).margin({ right: 2 });
            Text(`${item.routeDistance}km`).fontSize(12).fontColor($r('sys.color.font_on_primary'));
          };
        };
      }.alignItems(HorizontalAlign.Start).padding({ left: 12, right: 12, bottom: 12 });
    }.onClick(() => {
      this.mainPathStack.pushPathByName('RoutePageDetail',
        { route: item, attractionIds: item.attractionIds } as RouteParam);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '路线推荐', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          Grid() {
            LazyForEach(this.routeLineList, (item: RouteModel) => {
              GridItem() {
                this.RouteCardBuilder(item);
              };
            });
          }
          .columnsTemplate(this.folderColumn)
          .cachedCount(10)
          .columnsGap(8)
          .rowsGap(8)
          .layoutDirection(GridDirection.Row)
        }
        .padding(12)
        .height('90%')
      };
    }.hideTitleBar(true);
  }
}