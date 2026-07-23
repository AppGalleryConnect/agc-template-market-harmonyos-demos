import { common } from '@kit.AbilityKit';
import { Constant, LazyDataSource, SystemUtil } from 'module_base';
import { CallTelSheetBuilder } from '../component/CallTelSheetBuilder';
import { CustomTitle } from '../component/TitleBar';
import { GridRowColSetting } from '../constant/GridRowColSetting';
import { AccommodationInfo } from '../model/Index';
import { BreakPointUtils } from '../utils/BreakPointUtils';

@Builder
export function AccommodationDetailBuilder() {
  AccommodationDetail();
}

@ComponentV2
export struct AccommodationDetail {
  @Local detailInfo: AccommodationInfo = new AccommodationInfo();
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Local showCallTelSheet: boolean = false;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local currentBreakpoint: string = 'sm';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      GridRow({
        columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
        breakpoints: {
          value: GridRowColSetting.BREAK_POINT_VALUE,
          reference: BreakpointsReference.WindowSize,
        },
        direction: GridRowDirection.Row,
      }) {
        GridCol({
          span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
        }) {
          Column() {
            CustomTitle({
              isShowBack: true,
              title: '',
              breakpoint: this.currentBreakpoint,
              clickEvent: () => {
                this.mainPathStack.pop();
              },
            });

            Column() {
              Scroll() {
                Column() {
                  Swiper() {
                    LazyForEach(this.banners, (item: ResourceStr) => {
                      Image(item).size({ width: '100%', height: 240 });
                    }, (item: string) => item);
                  }.cachedCount(3);

                  Column() {
                    Column() {
                      Column({ space: 4 }) {
                        Text(`${this.detailInfo.name}`).fontSize(20).fontWeight(700);

                        Row({ space: 8 }) {
                          ForEach(this.detailInfo.labels, (item: string) => {
                            Text(item)
                              .fontSize($r('sys.float.Caption_M'))
                              .fontColor($r('sys.color.font_secondary'))
                              .border({ width: 1, color: $r('sys.color.comp_divider'), radius: 4 })
                              .padding({
                                top: 1,
                                bottom: 1,
                                left: 4,
                                right: 4,
                              });
                          }, (item: string) => item);
                        }.width('100%').justifyContent(FlexAlign.Start).borderRadius(8);
                      }.alignItems(HorizontalAlign.Start);

                      Row() {
                        Row({ space: 4 }) {
                          SymbolGlyph($r('sys.symbol.local'))
                            .width(16)
                            .height(16)
                            .fontSize(16)
                            .fontColor([$r('sys.color.icon_secondary')]);
                          Text(this.detailInfo.address)
                            .fontSize($r('sys.float.Body_M'))
                            .fontColor($r('sys.color.font_secondary'))
                            .layoutWeight(1)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis });
                        }.layoutWeight(1);

                        Row() {
                          SymbolGlyph($r('sys.symbol.location_north_up_right'))
                            .width(16)
                            .height(16)
                            .fontSize(16)
                            .fontColor([$r('sys.color.icon_primary')]);
                          Text('导航').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                        }.onClick(() => {
                          SystemUtil.routerToPetalMap(this.detailInfo.latitude, this.detailInfo.longitude,
                            this.detailInfo.name, this.getUIContext().getHostContext() as common.UIAbilityContext);
                        });
                      }
                      .width('100%')
                      .height(48)
                      .justifyContent(FlexAlign.SpaceBetween)
                      .borderRadius(16)
                      .padding({ left: 12, right: 12 })
                      .margin({ top: 12 })
                      .backgroundColor($r('sys.color.comp_background_tertiary'));

                    }.alignItems(HorizontalAlign.Start);

                    Column({ space: 8 }) {
                      Text('酒店概况')
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                        .fontSize($r('sys.float.Subtitle_L'));

                      Text(this.detailInfo.detail)
                        .fontSize($r('sys.float.Body_M'))
                        .fontColor($r('sys.color.font_secondary'))
                        .margin({ bottom: 16 });
                    }.alignItems(HorizontalAlign.Start).margin({ top: 24 });

                    ForEach(this.detailInfo.detailImages, (item: ResourceStr) => {
                      Image(item).width('100%');
                    }, (item: ResourceStr) => JSON.stringify(item));
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({
                    left: BreakPointUtils.getBreakPointGutter(this.currentBreakpoint),
                    right: BreakPointUtils.getBreakPointGutter(this.currentBreakpoint),
                    top: 16,
                  })
                  .constraintSize({ maxWidth: Constant.FULL_PERCENT });
                };
              }.edgeEffect(EdgeEffect.Spring).layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off);

              Row() {
                Button('马上预约')
                  .width('100%')
                  .constraintSize({ maxWidth: Constant.MAX_WIDTH })
                  .backgroundColor($r('sys.color.multi_color_04'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .onClick(() => {
                    this.showCallTelSheet = true;
                  });
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .backgroundColor($r('sys.color.font_on_primary'))
              .padding({
                left: BreakPointUtils.getBreakPointGutter(this.currentBreakpoint),
                right: BreakPointUtils.getBreakPointGutter(this.currentBreakpoint),
                top: 8,
                bottom: 8,
              })
              .bindSheet($$this.showCallTelSheet,
                CallTelSheetBuilder(this.detailInfo.phone, this.getUIContext(), () => {
                  this.showCallTelSheet = false;
                }), {
                  height: 253, title: { title: '联系客服' }, preferType: SheetType.CENTER,
                });
            }.layoutWeight(1);
          }.margin({ bottom: this.windowBottomHeight });
        };
      }
      .onBreakpointChange((breakpoint: string) => {
        this.currentBreakpoint = breakpoint;
      });
    }.title(this.detailInfo.name).hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.detailInfo = context.pathInfo.param as AccommodationInfo;
      this.banners.pushArrayData(this.detailInfo.banners);
    });
  }
}