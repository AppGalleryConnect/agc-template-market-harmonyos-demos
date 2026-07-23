import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2, display } from '@kit.ArkUI';
import {
  BreakpointModel,
  BreakpointNameEnum,
  BreakpointType,
  Constant,
  GridRowColSetting,
  LazyDataSource,
  Logger,
} from 'common';
import { RouteModel, RouteParam } from 'module_base';
import { https } from 'network';
import { TitleBar } from 'uicomponents';
import { mapperRouteLineList } from '../mapper/Index';

@Builder
export function RouteBuilder() {
  Route();
}

@ComponentV2
export struct Route {
  @Local routeLineList: LazyDataSource<RouteModel> = new LazyDataSource();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    https.getRouteLineList().then((res) => {
      this.routeLineList.pushArrayData(mapperRouteLineList(res.data));
      Logger.info('total count of routeLine ' + this.routeLineList.totalCount());
    });
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', (data: display.FoldStatus) => {
        UtilLog.info(`unregistering FoldStatus changes callback. Data: ${data}`);
      });
    } catch (e) {
      UtilLog.error(JSON.stringify(e));
    }
  }

  @Builder
  RouteCardBuilder(item: RouteModel) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(item.routeBanner).width(Constant.FULL_PERCENT).height(184).borderRadius(16).objectFit(ImageFit.Fill);
      Column({ space: 4 }) {
        Row() {
          Text('最热').fontColor($r('sys.color.font_on_primary')).fontSize($r('sys.float.Caption_M'));
        }
        .width(36)
        .height(20)
        .padding({
          left: 8,
          top: 3,
          right: 8,
          bottom: 3,
        })
        .borderRadius({
          topLeft: 14,
          topRight: 0,
          bottomRight: 14,
          bottomLeft: 0,
        })
        .backgroundColor($r('sys.color.alert'))
        .margin({ left: 2, top: 2 });

        Column() {
          Text(`${item.routeName}`)
            .fontWeight(FontWeight.Bold)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'));
          Row({ space: 12 }) {
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.tropicaltrees_and_sand_1'))
                .fontSize(16)
                .width(16)
                .height(16)
                .fontColor([$r('sys.color.icon_on_secondary')]);
              Text(`${item.attractionIds.length}个景点`)
                .fontSize(12)
                .fontColor($r('sys.color.font_on_primary'));
            };

            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.time_inerval'))
                .fontSize(16)
                .width(16)
                .height(16)
                .fontColor([$r('sys.color.icon_on_secondary')]);
              Text(`${item.duration}小时`).fontSize(12).fontColor($r('sys.color.font_on_primary'));
            };

            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.route_plan'))
                .fontSize(16)
                .width(16)
                .height(16)
                .fontColor([$r('sys.color.icon_on_secondary')]);
              Text(`${item.routeDistance}km`).fontSize(12).fontColor($r('sys.color.font_on_primary'));
            };
          };
        }.alignItems(HorizontalAlign.Start).padding({ left: 12, right: 12, bottom: 12 });
      }
      .height(184)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);
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
          .columnsTemplate(new BreakpointType({
            [BreakpointNameEnum.SM]: '1fr '.repeat(1),
            [BreakpointNameEnum.MD]: '1fr '.repeat(2),
            [BreakpointNameEnum.LG]: '1fr '.repeat(3),
            [BreakpointNameEnum.XL]: '1fr '.repeat(3),
          }).getValue(this.breakPointModel.currentBreakpoint))
          .cachedCount(10)
          .columnsGap(GridRowColSetting.getGutter(this.breakPointModel.currentBreakpoint))
          .rowsGap(12)
          .layoutDirection(GridDirection.Row);
        }
        .padding({
          top: 8,
          bottom: 8,
          left: 16,
          right: 16,
        })
        .height('90%');
      };
    }.hideTitleBar(true);
  }
}