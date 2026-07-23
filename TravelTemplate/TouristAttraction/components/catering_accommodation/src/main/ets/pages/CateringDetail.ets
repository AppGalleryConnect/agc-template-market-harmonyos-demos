import { common } from '@kit.AbilityKit';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { Constant, LazyDataSource, SystemUtil } from 'module_base';
import { CallTelSheetBuilder } from '../component/CallTelSheetBuilder';
import { CustomTitle } from '../component/TitleBar';
import { GridRowColSetting } from '../constant/GridRowColSetting';
import { CateringInfo } from '../model/Index';
import { BreakPointUtils } from '../utils/BreakPointUtils';

@Builder
export function CateringDetailBuilder() {
  CateringDetail();
}

@ComponentV2
export struct CateringDetail {
  @Local detailInfo: CateringInfo = new CateringInfo();
  @Local showCallTelSheet: boolean = false;
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local currentBreakpoint: string = 'sm';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local resources: SourceImageModel[] = [];
  options: ImagePreviewOptions = new ImagePreviewOptions();

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
                    LazyForEach(this.banners, (item: ResourceStr, index: number) => {
                      Image(item)
                        .size({ width: '100%', height: 240 })
                        .id(this.options.snapshotId(item, index))
                        .onClick(() => {
                          this.options
                            .setImageList(this.resources)
                            .setInitIndex(index);
                          ImagePreview.open(this.getUIContext(), this.options);
                        });
                    }, (item: string) => item);
                  }.cachedCount(3);

                  Column() {
                    Column({ space: 4 }) {
                      Text(`${this.detailInfo.name}`).fontSize(20).fontWeight(700);
                      Text(`预订须知：营业时间：${this.detailInfo.openHours}`)
                        .fontSize($r('sys.float.Body_S'))
                        .fontColor($r('sys.color.font_secondary'));
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

                      Row({ space: 4 }) {
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

                    Text('餐饮详情')
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('sys.color.font_primary'))
                      .fontSize($r('sys.float.Subtitle_L'))
                      .margin({ top: 24, bottom: 8 });

                    Text(this.detailInfo.detail)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_secondary'))
                      .margin({ bottom: 16 });

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
              }.layoutWeight(1).align(Alignment.Top).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring);

              Row() {
                Text() {
                  Span('￥').fontSize($r('sys.float.Body_S')).fontWeight(500);
                  Span(`${this.detailInfo.startPrice}`).fontSize(20).fontWeight(500);
                  Span('起').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.warning'));
                }.fontColor($r('sys.color.warning'));

                Button('马上预约')
                  .backgroundColor($r('sys.color.multi_color_04'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .onClick(() => {
                    this.showCallTelSheet = true;
                  });
              }
              .justifyContent(FlexAlign.SpaceBetween)
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
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.detailInfo = context.pathInfo.param as CateringInfo;
      this.banners.pushArrayData(this.detailInfo?.banners || []);
      this.resources = this.banners.dataArray.map((imageUrl) => {
        return new SourceImageModel({ imageUrl });
      });
    });
  }
}