import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { RouteModel } from 'module_base';
import { CommonConstant } from '../constant/Index';
import { queryAttractionDetail } from '../utils/ApiManage';
import { AttractionModel, LocationInfo, RouteParam } from '../model/Index';
import { MakerCanvasUtil } from '../utils/MakerCanvasUtil';
import { UtilLog } from '@hw-agconnect/util-log';

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
  @Local isMinSheet: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  mapEventManager?: map.MapEventManager;
  mapController: map.MapComponentController = new map.MapComponentController();
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private locationInfo: LocationInfo =
    PersistenceV2.connect(LocationInfo, 'locationInfo', () => new LocationInfo())!;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Up | PanDirection.Down });

  aboutToAppear(): void {
    this.initMap();
  }

  @Builder
  routeSheetBuilder() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
        }
        .width(CommonConstant.FULL_PERCENT)
        .height(CommonConstant.FULL_PERCENT)
        .backgroundColor('#fff').borderRadius({ topLeft: 16, topRight: 16 });

        Scroll() {
          Column({ space: 8 }) {
            Row() {
              Row()
                .width(60)
                .height(4)
                .borderRadius(4)
                .backgroundColor($r('sys.color.comp_background_gray'));
            }
            .height(12)
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .gesture(
              PanGesture(this.panOption)
                .onActionStart((event: GestureEvent) => {
                  UtilLog.info(0x0000, 'RoutePageDetail', 'pan gesture start');
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.isMinSheet = (event.offsetY > 0 ? true : false);
                })
                .onActionEnd((event: GestureEvent) => {
                  UtilLog.info(0x0000, 'RoutePageDetail', 'pan gesture end');
                }),
            );

            Column() {
              Text(this.route.routeName)
                .fontSize(20)
                .opacity(0.9)
                .fontWeight(FontWeight.Medium)
                .width(CommonConstant.FULL_PERCENT)
                .textAlign(TextAlign.Start);

              Row({ space: 8 }) {
                ForEach(this.route.label, (item: string) => {
                  Text(item)
                    .fontSize(10)
                    .fontColor('#0A59F7')
                    .padding(4)
                    .border({ width: 1, color: '#0A59F7', radius: 12 });
                }, (item: string) => item);
              }.width(CommonConstant.FULL_PERCENT).justifyContent(FlexAlign.Start).margin({ top: 8, bottom: 20 });

              Column({ space: 8 }) {
                Text('概览')
                  .fontSize(14)
                  .opacity(0.9)
                  .fontWeight(FontWeight.Medium);
                Text(`${this.route.brief}`).fontSize(14).opacity(0.6);
              }.padding(12).backgroundColor('rgba(10, 89, 247, 0.1)').borderRadius(8).alignItems(HorizontalAlign.Start);

              Column({ space: 24 }) {
                ForEach(this.attractions, (item: AttractionModel, index: number) => {
                  Column({ space: 12 }) {
                    Text(`${index + 1}.${item.name}`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .opacity(0.9);
                    Flex({
                      direction: FlexDirection.Row,
                      justifyContent: FlexAlign.SpaceBetween,
                      alignItems: ItemAlign.Center,
                      wrap: FlexWrap.Wrap,
                    }) {
                      Row() {
                        Row({ space: 8 }) {
                          ForEach(item.labels, (item: string) => {
                            Text(item)
                              .fontSize(10)
                              .fontColor('#0A59F7')
                              .padding(4)
                              .border({ width: 1, color: '#0A59F7', radius: 12 });
                          }, (item: string) => item);
                        }.margin({ right: 12 });

                        Text(`预计游玩时间:${item.duration}h`).fontSize(14).opacity(0.6);
                      };

                      Button('购票')
                        .fontSize(14)
                        .fontColor($r('sys.color.white'))
                        .backgroundColor('rgb(10, 89, 247)')
                        .width(72)
                        .height(28)
                        .onClick(() => {
                          this.mainPathStack.pushPathByName('Tickets', true, false);
                        });
                    };

                    Text(`${item.introduction}`).fontSize(14).opacity(0.6).lineHeight(20);
                  }.alignItems(HorizontalAlign.Start);
                }, (item: AttractionModel, index: number) => item.name);
              }.margin({ top: 12 });
            };
          }
          .padding({
            top: 8,
            left: 16,
            right: 16,
            bottom: 16,
          });
        }
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .width(CommonConstant.FULL_PERCENT);
      };
    }.mode(NavDestinationMode.DIALOG).hideTitleBar(true);
  }

  initMap() {
    let location = {
      target: {
        latitude: this.locationInfo.latitude,
        longitude: this.locationInfo.longitude,
      },
      zoom: 15,
    } as mapCommon.CameraPosition;

    this.mapOptions = {
      position: location,
      myLocationControlsEnabled: false,
      compassControlsEnabled: false,
    };

    let locationButtonClick = () => {
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition(location);
      // 1000ms内移动相机到mark点位置
      this.mapController?.animateCamera(cameraUpdate, 1000);
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapController?.setMyLocationEnabled(true);
        this.mapEventManager = this.mapController.getEventManager();
        this.mapController.setMinZoom(2);
        this.mapController.setMaxZoom(20);
        this.mapEventManager?.on('myLocationButtonClick', locationButtonClick);
      }
    };
  }

  async addMakers() {
    let mcu = new MakerCanvasUtil();
    this.attractions.forEach(async (item: AttractionModel, index: number) => {
      let markerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: item.latitude,
          longitude: item.longitude,
        },
        clickable: true,
        icon: mcu.getMakerIcon(`${index + 1}.${item.name}`),
      };
      this.mapController?.addMarker(markerOptions).then((maker) => {
        this.createMakerListener();
        UtilLog.info(0xff00, 'RouteDetail', 'add maker success' + maker.getTitle());
      });
    });
  }

  createMakerListener() {
    let mapEventManager: map.MapEventManager = this.mapController.getEventManager();
    mapEventManager.on('markerClick', () => {
      this.isMinSheet = false;
    });
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.Bottom }) {
          MapComponent({
            mapOptions: this.mapOptions,
            mapCallback: this.callback,
          }).height(CommonConstant.FULL_PERCENT)
            .width(CommonConstant.FULL_PERCENT);

          if (this.isMinSheet) {
            List({ space: 12 }) {
              ForEach(this.attractions, (item: AttractionModel, index: number) => {
                ListItem() {
                  Stack({ alignContent: Alignment.TopStart }) {
                    Row({ space: 8 }) {
                      Image(item.banner).size({ height: 96, width: 96 }).borderRadius(16);
                      Column({ space: 8 }) {
                        Text(item.name).fontWeight(FontWeight.Medium).opacity(0.9);
                        Row({ space: 8 }) {
                          ForEach(item.labels, (item: string) => {
                            Text(item)
                              .fontSize(10)
                              .fontColor('#0A59F7')
                              .padding(4)
                              .border({ width: 1, color: '#0A59F7', radius: 12 });
                          }, (item: string) => item);
                        };

                        Text('夏季:10:00-18:00 冬季:09:00-17:30').fontSize(12).opacity(0.6);
                        Text(item.location).fontSize(12).opacity(0.6);
                      }.alignItems(HorizontalAlign.Start);
                    }.padding(12).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start);

                    Text(`${index + 1}`)
                      .backgroundColor('rgb(10, 89, 247)')
                      .size({ height: 24, width: 24 })
                      .textAlign(TextAlign.Center)
                      .fontWeight(FontWeight.Medium)
                      .borderRadius({ topLeft: 16, bottomRight: 8 })
                      .fontColor($r('sys.color.white'));
                  }.onClick(() => {
                    this.mainPathStack.pushPathByName('AttractionDetail', item.attractionId);
                  });
                }.backgroundColor($r('sys.color.white')).borderRadius(16).clip(true);
              }, (item: AttractionModel) => item.name);
            }
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .margin({ left: 16, bottom: 60 })
            .height(124)
            .align(Alignment.Start)
            .edgeEffect(EdgeEffect.Spring);
          }

          Column() {
            this.routeSheetBuilder();
          }
          .height(this.isMinSheet ? 56 : '60%');

          Image($r('app.media.left_arrow'))
            .size({ height: 24, width: 24 })
            .onClick(() => {
              this.mainPathStack.pop();
            }).position({ left: 12, top: this.windowTopHeight + 16 });
        };
      };
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