import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';
import { FunctionComponent, FunctionController } from '@kit.AgentFrameworkKit';
import { display } from '@kit.ArkUI';
import { AsyncCallback, BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { TextReader } from '@kit.SpeechKit';
import { AccommodationInfo, AttractionInfo, AttractionsInfo, CateringInfo, Constant, SystemUtil } from 'module_base';
import { GUIDE_TABS_INFO, HEIGHT_LOW_MIDDLE } from '../constants/Constant';
import { GridRowColSetting } from '../constants/GridRowColSetting';
import { BreakpointStatus } from '../model/BreakpointModel';
import { Guide, LocationType, SiteInfo } from '../model/GuideInfo';
import { AttractionGuideVM } from '../viewmodel/AttractionGuideVM';


@ComponentV2
export struct AttractionGuide {
  vm: AttractionGuideVM = AttractionGuideVM.instance;
  @Param @Require location: number[] = [];
  @Param @Require initAttractionInfo: AttractionsInfo;
  mapOptions?: mapCommon.MapOptions;
  callback?: AsyncCallback<map.MapComponentController>;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local tempColumnHeight: number = 120;
  @Local gridColSpan: GridColColumnOption = GridRowColSetting.SMALL_LEFT_COL_SPAN;
  // 断点切换后需要sheet组件适配一次窄大屏
  @Local breakChangeFlag: boolean = false;
  // TODO 智能体创建成功后，可在智能体配置页面的网址链接中获取。
  private agentId: string = 'agente8ea58093c7d4c8cbf9f36a5b37a7141';

  get maxSheetHeight(): number {
    return this.getUIContext().px2vp(display.getDefaultDisplaySync().height) - 150;
  }

  @Computed
  get buttonCompMargin() {
    if (this.vm.currentBreakpoint === BreakpointStatus.SM) {
      return this.tempColumnHeight;
    } else if (this.vm.currentBreakpoint === BreakpointStatus.MD) {
      return Constant.BOTTOM_TAB_BAR_HEIGHT + this.vm.windowBottomHeight;
    } else {
      return this.vm.windowBottomHeight;
    }
  }

  aboutToAppear() {
    this.tempColumnHeight =
      this.vm.getSheetMinHeight();
    this.vm.attractionInfo = this.initAttractionInfo.attractions;
    this.vm.initGuideInfo();
    this.vm.getLocation(this.getUIContext().getHostContext() as common.UIAbilityContext);
    this.initMapOptions();
    this.vm.setScreenListen(() => {
      if (this.tempColumnHeight > HEIGHT_LOW_MIDDLE) {
        this.tempColumnHeight = this.maxSheetHeight;
      } else {
        this.tempColumnHeight =
          this.vm.getSheetMinHeight();
      }
    });
  }

  aboutToDisappear(): void {
    this.vm.mapController.getEventManager().off('markerClick');
    try {
      display.off('change');
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      UtilLog.error(0xff0000, 'AttractionGuide', `Failed to off display change: ${error.message}`);
    }
  }

  async initMapOptions() {
    let location = {
      target: {
        latitude: this.vm.myLocation.latitude, longitude: this.vm.myLocation.longitude,
      }, zoom: 16,
    } as mapCommon.CameraPosition;

    this.mapOptions = {
      position: location,
      compassControlsEnabled: false,
      zoomControlsEnabled: false,
      myLocationControlsEnabled: false,
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) { // 获取地图的控制器类，用来操作地图
        this.vm.mapController = mapController;
        if (this.vm.myLocation.latitude) { // 启用我的位置按钮
          this.vm.mapController?.setMyLocationEnabled(true);
          this.vm.mapController?.setMyLocationControlsEnabled(true);
        }
        this.addMakers();
        this.vm.mapController.setMinZoom(2);
        this.vm.mapController.setMaxZoom(18);
        this.vm.createMakerListener(this.mainPathStack);
      }
    };
  }

  redrawScenes() {
    this.vm.mapController?.clear();
    this.vm.pointIds.clear();
    this.addMakers();
  }

  addMakers() {
    if (this.vm.mapController && this.vm.guideInfo.data?.length) {
      for (let i = 0; i < this.vm.guideInfo.data.length; i++) {
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.vm.guideInfo.data[i].latitude, longitude: this.vm.guideInfo.data[i].longitude,
          }, clickable: true, // 自定义组件
          iconBuilder: () => {
            this.MarkerRenderBuilder(this.vm.guideInfo.data[i].name);
          },
        };
        this.vm.mapController?.addMarker(markerOptions).then((maker) => {
          UtilLog.info(0xff00, 'AttractionGuide', 'add maker success' + maker.getTitle());
          this.vm.pointIds.set(maker.getId(), this.vm.guideInfo.data[i]);
        });
      }
      this.vm.mapController?.animateCamera(map.newLatLng({
        latitude: this.vm.guideInfo.data[0].latitude, longitude: this.vm.guideInfo.data[0].longitude,
      }, 15), 1000);
    }
  }

  @Builder
  MarkerRenderBuilder(name: string) {
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
  attractionInfoCard(item: AttractionInfo) {
    Row({ space: 8 }) {
      Row({ space: 16 }) {
        Stack() {
          Image(item.icon).width(56).height(56);
          SymbolGlyph($r('sys.symbol.play_circle_fill'))
            .width(16)
            .height(16)
            .fontColor([$r('sys.color.icon_on_primary')]);
        }.alignContent(Alignment.Center);

        Column({ space: 4 }) {
          Text(item.name)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text('真人讲解')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .border({ width: 1, color: $r('sys.color.comp_divider'), radius: 4 })
            .padding({
              top: 1,
              bottom: 1,
              left: 4,
              right: 4,
            });
        }.alignItems(HorizontalAlign.Start).height(56);
      }.layoutWeight(1);

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.location_north_up_right'))
            .width(16)
            .height(16)
            .fontSize(16)
            .fontColor([$r('sys.color.icon_primary')]);
          Text('导航').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
        }.onClick(() => {
          SystemUtil.routerToPetalMap(item.latitude, item.longitude, item.name,
            this.getUIContext().getHostContext() as common.UIAbilityContext);
        });

        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.info_circle'))
            .width(16)
            .height(16)
            .fontSize(16)
            .fontColor([$r('sys.color.icon_primary')]);
          Text('详情').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
        }.onClick(() => {
          this.mainPathStack.pushPathByName('AttractionDetail', item.attractionId);
        });
      };
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_tertiary'));
  }

  @Builder
  CateringInfoCard(item: CateringInfo | AccommodationInfo, type: number) {
    Row({ space: 16 }) {
      Image(item.banner).width(72).height(96).borderRadius(8);

      Column({ space: 4 }) {
        Column({ space: 4 }) {
          Text(item.name)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.local'))
              .width(16)
              .height(16)
              .fontSize(16)
              .fontColor([$r('sys.color.icon_secondary')]);
            Text(item.address)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          };
        }.alignItems(HorizontalAlign.Start);

        Row({ space: 16 }) {
          Text() {
            Span('￥').fontSize($r('sys.float.Body_S'));
            Span(`${item.startPrice || 0}`).fontWeight(FontWeight.Medium).fontSize($r('sys.float.Subtitle_L'));
            Span('起').fontSize($r('sys.float.Body_S'));
          }.fontColor($r('sys.color.warning'));

          Button('预订', { controlSize: ControlSize.SMALL })
            .backgroundColor($r('sys.color.multi_color_04'))
            .fontColor($r('sys.color.font_on_primary'))
            .width(72)
            .onClick(() => {
              if (type === LocationType.CATERING) {
                this.vm.goCateringDetail(item as CateringInfo, this.mainPathStack);
              } else if (type === LocationType.ACCOMMODATION) {
                this.vm.goAccommodationDetail(item as AccommodationInfo, this.mainPathStack);
              }
            });
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
      }.layoutWeight(1).height(96).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween);
    }
    .alignItems(VerticalAlign.Center)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_tertiary'));
  }

  @Builder
  sheetBuilder() {
    GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
      GridCol({ span: this.gridColSpan }) {
        Column() {
          Row() {
            Row().width(48).height(4).borderRadius(2).backgroundColor($r('sys.color.icon_fourth'));
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center).padding({
            top: 8,
            bottom: 4,
            left: 24,
            right: 24,
          }).gesture(PanGesture(this.vm.panOptionHeight).onActionUpdate((event?: GestureEvent) => {
            if (event) {
              let height = this.vm.columnHeight - event.offsetY;
              this.tempColumnHeight = height;
              if (this.tempColumnHeight < this.vm.getSheetMinHeight()) {
                this.tempColumnHeight = this.vm.getSheetMinHeight();
              }
              if (this.tempColumnHeight > this.maxSheetHeight) {
                this.tempColumnHeight = this.maxSheetHeight;
              }
            }
          }).onActionEnd(() => {
            if (this.tempColumnHeight > (this.maxSheetHeight - this.maxSheetHeight) / 2 + this.maxSheetHeight) {
              this.vm.columnHeight = this.maxSheetHeight;
            } else if (this.tempColumnHeight <
              (this.maxSheetHeight - this.vm.getSheetMinHeight()) / 2 + this.vm.getSheetMinHeight()) {
              this.vm.columnHeight = this.vm.getSheetMinHeight();
            } else {
              this.vm.columnHeight = this.maxSheetHeight;
            }
            this.tempColumnHeight = this.vm.columnHeight;
          }));

          List({ space: 8 }) {
            ForEach(GUIDE_TABS_INFO, (item: Guide<AttractionInfo | SiteInfo>, index: number) => {
              ListItem() {
                Row({ space: 6 }) {
                  SymbolGlyph(item.icon)
                    .width(16)
                    .height(16)
                    .fontColor(
                      [this.vm.type === index ? $r('sys.color.icon_on_primary') : $r('sys.color.icon_secondary')]);
                  Text(item.title)
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(
                      this.vm.type === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'));
                }
                .height(36)
                .padding({ left: 16, right: 16, })
                .borderRadius(20)
                .backgroundColor(
                  this.vm.type === index ? $r('sys.color.multi_color_04') : $r('sys.color.comp_background_tertiary'));
              }.onClick(() => { // 释放播控资源
                TextReader.stop().then(() => {
                  TextReader.release();
                });
                this.vm.guideInfo = GUIDE_TABS_INFO[index];
                this.vm.type = index;
                this.vm.changeGuideInfo(index); // 重新绘制地图
                this.redrawScenes();
              });
            }, (item: Guide<AttractionInfo | SiteInfo>) => item.title);
          }
          .listDirection(Axis.Horizontal)
          .contentStartOffset(16)
          .contentEndOffset(16)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .height(56)
          .margin({ top: 10, bottom: 10 })
          .width('100%');

          List({ space: 12 }) {
            ForEach(this.vm.guideInfo.data, (item: AttractionInfo | CateringInfo | AccommodationInfo) => {
              ListItem() {
                if (this.vm.guideInfo.type === LocationType.ATTRACTION) {
                  this.attractionInfoCard(item as AttractionInfo);
                } else {
                  this.CateringInfoCard(item as CateringInfo | AccommodationInfo, this.vm.guideInfo.type);
                }
              };
            }, (item: AttractionInfo | SiteInfo) => item.name);
          }
          .contentStartOffset(4)
          .contentEndOffset(12)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .padding({ left: 16, right: 16 })
          .width('100%')
          .layoutWeight(1);
        }
        .backgroundColor(Color.White)
        .visibility(this.vm.isShow ? Visibility.Visible : Visibility.None)
        .borderRadius({
          topLeft: 32,
          topRight: 32,
          bottomLeft: this.vm.currentBreakpoint === BreakpointStatus.SM ? 0 : 32,
          bottomRight: this.vm.currentBreakpoint === BreakpointStatus.SM ? 0 : 32,
        })
        .margin({
          left: this.vm.currentBreakpoint === BreakpointStatus.SM ? 0 :
            GridRowColSetting.getPageMargin(this.vm.currentBreakpoint),
          bottom: this.vm.sheetMarginBottom,
        })
        .width(Constant.FULL_PERCENT)
        .constraintSize({ maxWidth: 400 })
        .height(this.tempColumnHeight);
      }.onAreaChange((_oldValue: Area, newValue: Area) => {
        // 适配pure X Max窄大屏
        if (this.breakChangeFlag) {
          this.breakChangeFlag = false;
          if (newValue.width < 320) {
            this.gridColSpan = GridRowColSetting.SMALL_LEFT_WIDE_COL_SPAN;
          } else {
            this.gridColSpan = GridRowColSetting.SMALL_LEFT_COL_SPAN;
          }
        }
      });
    }
    .onBreakpointChange((breakpoint) => {
      this.vm.setCurrentBreakpoint(breakpoint);
      this.breakChangeFlag = true;
    });
  }

  @Builder
  buttonComp() {
    Column({ space: 12 }) {
      if (deviceInfo.sdkApiVersion > 20) {
        FunctionComponent({
          agentId: this.agentId,
          onError: (err: BusinessError) => {
            UtilLog.error(JSON.stringify(err));
          },
          options: {
            queryText: '创建一个新的模式',
            isShowShadow: true,
            controlSize: ControlSize.SMALL,
            iconSize: 24,
            backgroundColor: $r('sys.color.comp_background_primary'),
          },
          controller: new FunctionController(),
        });
      }
      SymbolGlyph($r('sys.symbol.position'))
        .width(40)
        .height(40)
        .fontSize(24)
        .fontColor([$r('sys.color.icon_primary')])
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(1000)
        .padding(8)
        .onClick(() => {
          this.vm.moveToMyLocation(this.getUIContext());
        });
    }.margin({ bottom: this.buttonCompMargin + 8, right: 16 });
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      MapComponent({
        mapOptions: this.mapOptions, mapCallback: this.callback,
      }).width('100%');

      this.sheetBuilder();

      if (this.tempColumnHeight === this.vm.getSheetMinHeight() || this.vm.currentBreakpoint !== BreakpointStatus.SM) {
        this.buttonComp();
      }
    };
  }
}