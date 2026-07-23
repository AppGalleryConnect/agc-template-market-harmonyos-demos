import { UtilLog } from '@hw-agconnect/util-log';
import { display, PersistenceV2 } from '@kit.ArkUI';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { Constant, RouteModel } from 'module_base';
import { BreakpointNameEnum, GridRowColSetting } from '../constant/GridRowColSetting';
import { HEIGHT_LOW_MIDDLE, HEIGHT_LOW_SMALL } from '../constant/Index';
import { AttractionModel, LocationInfo, RouteParam } from '../model/Index';
import { queryAttractionDetail } from '../utils/ApiManage';

@Builder
export function RoutePageDetailBuilder() {
  RoutePageDetail();
}

@ComponentV2
export struct RoutePageDetail {
  @Local attractionIds: number[] = [];
  @Local route: RouteModel = new RouteModel();
  @Local attractions: AttractionModel[] = [];
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local showAttractionsSheet: boolean = true;
  @Local breakpoint: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  mapEventManager?: map.MapEventManager;
  mapController: map.MapComponentController = new map.MapComponentController();
  @Local columnHeight: number = 200;
  @Local tempColumnHeight: number = 200;
  panOptionHeight: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Up | PanDirection.Down,
  });
  panOptionPosition: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left | PanDirection.Right, distance: 10,
  });
  private swiperController: SwiperController = new SwiperController();
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private locationInfo: LocationInfo = PersistenceV2.connect(LocationInfo, 'locationInfo', () => new LocationInfo())!;

  @Computed
  get sheetMinHeight() {
    return this.breakpoint === BreakpointNameEnum.SM ? HEIGHT_LOW_SMALL : HEIGHT_LOW_MIDDLE;
  }

  @Computed
  get maxSheetHeight(): number {
    return this.getUIContext().px2vp(display.getDefaultDisplaySync().height) - 150;
  }

  aboutToAppear(): void {
    this.initMap();
  }

  initMap() {
    let location = {
      target: {
        latitude: this.locationInfo.latitude, longitude: this.locationInfo.longitude,
      }, zoom: 15,
    } as mapCommon.CameraPosition;

    this.mapOptions = {
      position: location,
      myLocationControlsEnabled: false,
      compassControlsEnabled: false,
      zoomControlsEnabled: false,
    };

    let locationButtonClick = () => {
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(location); // 1000ms内移动相机到mark点位置
      this.mapController?.animateCamera(cameraUpdate, 1000);
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) { // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(false);
        this.mapEventManager = this.mapController.getEventManager();
        this.mapController.setMinZoom(2);
        this.mapController.setMaxZoom(20);
        this.mapEventManager?.on('myLocationButtonClick', locationButtonClick);
      }
    };
  }

  async addMakers() {
    this.attractions.forEach(async (item: AttractionModel, index: number) => {
      let markerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: item.latitude, longitude: item.longitude,
        }, clickable: true,
        // 自定义标记组件
        iconBuilder: () => {
          this.renderBuilder(item.name);
        },
      };
      this.mapController?.addMarker(markerOptions).then((maker) => {
        UtilLog.info(0xff00, 'RouteDetail', 'add maker success' + maker.getTitle());
      });
    });
    this.createMakerListener();
  }

  createMakerListener() {
    let mapEventManager: map.MapEventManager = this.mapController.getEventManager();
    mapEventManager.on('markerClick', (marker: map.Marker) => {
      this.showAttractionsSheet = true;
      let markerPosition = marker.getPosition();
      let targetIndex = this.attractions.findIndex(
        (item: AttractionModel) => item.latitude === markerPosition.latitude &&
          item.longitude === markerPosition.longitude);
      if (targetIndex !== -1) {
        this.swiperController.changeIndex(targetIndex, true);
      }
    });
  }

  @Builder
  renderBuilder(name: string) {
    Column() {
      Text(name)
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_M'))
        .maxLines(1)
        .padding({
          top: 4,
          bottom: 4,
          left: 12,
          right: 12,
        })
        .backgroundColor($r('sys.color.mask_tertiary'))
        .borderRadius(56)
        .margin({ bottom: 4 });
      SymbolGlyph($r('sys.symbol.local_fill')).width(40).height(40).fontSize(40).fontColor([$r('sys.color.warning')]);
    };
  }

  @Builder
  sheetBuilder() {
    GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
      GridCol({ span: GridRowColSetting.SMALL_LEFT_COL_SPAN }) {
        Stack() {
          Column() {
            Row() {
              Text(this.route.routeName)
                .fontSize($r('sys.float.Title_S'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold);
            }.width(Constant.FULL_PERCENT).height(56).padding({ left: 16, right: 16 });

            Scroll() {
              Column() {
                Swiper(this.swiperController) {
                  ForEach(this.attractions, (item: AttractionModel, index: number) => {
                    Stack({ alignContent: Alignment.TopStart }) {
                      Row({ space: 8 }) {
                        Image(item.banner).size({ height: 80, width: 80 }).borderRadius(8);
                        Column({ space: 4 }) {
                          Text(item.name)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                            .fontSize($r('sys.float.Body_L'));
                          Row({ space: 8 }) {
                            ForEach(item.labels, (item: string) => {
                              Text(item)
                                .fontSize($r('sys.float.Caption_M'))
                                .fontColor($r('sys.color.font_secondary'))
                                .padding({
                                  top: 1,
                                  bottom: 1,
                                  left: 4,
                                  right: 4,
                                })
                                .border({ width: 1, color: $r('sys.color.comp_divider'), radius: 4 });
                            }, (item: string) => item);
                          };

                          Text('夏季:10:00-18:00 冬季:09:00-17:30')
                            .fontSize($r('sys.float.Body_S'))
                            .fontColor($r('sys.color.font_secondary'));
                          Text(item.location)
                            .fontSize($r('sys.float.Body_S'))
                            .fontColor($r('sys.color.font_secondary'));
                        }.alignItems(HorizontalAlign.Start);
                      }
                      .padding(12)
                      .backgroundColor($r('sys.color.comp_background_tertiary'))
                      .borderRadius(16)
                      .width(Constant.FULL_PERCENT);

                      Text(`${index + 1}`)
                        .backgroundColor($r('sys.color.multi_color_04'))
                        .size({ height: 20, width: 24 })
                        .textAlign(TextAlign.Center)
                        .borderRadius({ topLeft: 14, bottomRight: 14 })
                        .fontColor($r('sys.color.font_on_primary'))
                        .margin({ left: 2, top: 2 });
                    }.onClick(() => {
                      this.showAttractionsSheet = false;
                      this.mainPathStack.pushPathByName('AttractionDetail', item.attractionId);
                    });
                  }, (item: AttractionModel) => item.name);
                }
                .cachedCount(3)
                .itemSpace(8)
                .width(Constant.FULL_PERCENT)
                .nextMargin(8)
                .prevMargin(8)
                .autoPlay(false)
                .loop(false)
                .indicator(false);

                Column({ space: 24 }) {
                  Column({ space: 8 }) {
                    Text('概览')
                      .fontSize($r('sys.float.Subtitle_L'))
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Bold)
                      .margin({ bottom: 8 });
                    Text(`${this.route.brief}`)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_secondary'));
                  }.alignItems(HorizontalAlign.Start);

                  Column({ space: 24 }) {
                    ForEach(this.attractions, (item: AttractionModel, index: number) => {
                      Column() {
                        Text(`${index + 1}.${item.name}`)
                          .fontSize($r('sys.float.Subtitle_L'))
                          .fontColor($r('sys.color.font_primary'))
                          .fontWeight(FontWeight.Bold);
                        Row() {
                          Column({ space: 4 }) {
                            Row({ space: 8 }) {
                              ForEach(item.labels, (item: string) => {
                                Text(item)
                                  .fontSize($r('sys.float.Caption_M'))
                                  .fontColor($r('sys.color.font_secondary'))
                                  .padding({
                                    top: 1,
                                    bottom: 1,
                                    left: 4,
                                    right: 4,
                                  })
                                  .border({ width: 1, color: $r('sys.color.comp_divider'), radius: 4 });
                              }, (item: string) => item);
                            };

                            Text(`预计游玩时间:${item.duration}h`)
                              .fontSize($r('sys.float.Body_S'))
                              .fontColor($r('sys.color.font_secondary'));
                          }.alignItems(HorizontalAlign.Start);

                          Button('购票', { controlSize: ControlSize.SMALL })
                            .fontColor($r('sys.color.font_on_primary'))
                            .backgroundColor($r('sys.color.multi_color_04'))
                            .width(72)
                            .height(28)
                            .onClick(() => {
                              this.showAttractionsSheet = false;
                              this.mainPathStack.pushPathByName('TicketDetail', item.ticketId);
                            });
                        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).margin({ top: 8 });

                        Text(`${item.introduction}`)
                          .fontSize($r('sys.float.Body_M'))
                          .fontColor($r('sys.color.font_secondary'))
                          .margin({ top: 12 });
                      }.alignItems(HorizontalAlign.Start);
                    }, (item: AttractionModel) => item.name);
                  }.margin({ top: 12 });
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ top: 24, left: 16, right: 16 })
                .width(Constant.FULL_PERCENT)
                .constraintSize({ maxWidth: Constant.FULL_PERCENT });
              }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);
            }
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .width(Constant.FULL_PERCENT)
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring);
          }.margin({ top: 8, bottom: 16 });


          Row() {
            Row().width(48).height(4).borderRadius(2).backgroundColor($r('sys.color.icon_fourth'));
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center).padding({
            top: 8,
            bottom: 4,
            left: 24,
            right: 24,
          }).gesture(PanGesture(this.panOptionHeight).onActionUpdate((event?: GestureEvent) => {
            if (event) {
              let height = this.columnHeight - event.offsetY;
              this.tempColumnHeight = height;
              if (this.tempColumnHeight < this.sheetMinHeight) {
                this.tempColumnHeight = this.sheetMinHeight;
              }
              if (this.tempColumnHeight > this.maxSheetHeight) {
                this.tempColumnHeight = this.maxSheetHeight;
              }
            }
          }).onActionEnd(() => {
            if (this.tempColumnHeight > (this.maxSheetHeight - this.maxSheetHeight) / 2 + this.maxSheetHeight) {
              this.columnHeight = this.maxSheetHeight;
            } else if (this.tempColumnHeight <
              (this.maxSheetHeight - this.sheetMinHeight) / 2 + this.sheetMinHeight) {
              this.columnHeight = this.sheetMinHeight;
            } else {
              this.columnHeight = this.maxSheetHeight;
            }
            this.tempColumnHeight = this.columnHeight;
          }));
        }
        .width(Constant.FULL_PERCENT)
        .height(this.tempColumnHeight)
        .constraintSize({ maxWidth: Constant.FULL_PERCENT })
        .alignContent(Alignment.Top)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius({
          topLeft: 32,
          topRight: 32,
          bottomLeft: this.breakpoint === BreakpointNameEnum.SM ? 0 : 32,
          bottomRight: this.breakpoint === BreakpointNameEnum.SM ? 0 : 32,
        })
        .margin({
          left: this.breakpoint === BreakpointNameEnum.SM ? 0 : GridRowColSetting.getPageMargin(this.breakpoint),
          bottom: this.breakpoint === BreakpointNameEnum.SM ? 0 : this.windowBottomHeight,
        });
      };
    }
    .onBreakpointChange((breakpoint) => {
      this.breakpoint = breakpoint;
    });
  }

  build() {
    NavDestination() {
      Stack() {
        MapComponent({
          mapOptions: this.mapOptions, mapCallback: this.callback,
        }).height(Constant.FULL_PERCENT)
          .width(Constant.FULL_PERCENT);

        Column({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .width(40)
            .height(40)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(1000)
            .padding(8)
            .margin({ left: GridRowColSetting.getPageMargin(this.breakpoint) })
            .onClick(() => {
              this.showAttractionsSheet = false;
              this.mainPathStack.pop();
            });
          this.sheetBuilder();
        }
        .width(Constant.FULL_PERCENT)
        .height(Constant.FULL_PERCENT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: this.windowTopHeight });
      }.alignContent(Alignment.TopStart);
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      const params: RouteParam = context.pathInfo.param as RouteParam;
      this.attractionIds = params.attractionIds;
      this.route = params.route;
      queryAttractionDetail(this.attractionIds).then((resp: ESObject) => {
        resp.data.forEach((item: ESObject) => {
          let attraction = new AttractionModel(item);
          this.attractions.push(attraction);
        });
        this.addMakers();
      });
    });
  }
}