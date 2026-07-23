import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointType, GridRowColSetting } from 'module_weather_core';
import { CommonHeader } from '../components/CommonHeader';
import { ThemeSwiper } from '../components/ThemeSwiper';
import { IThemeInfo } from '../types/Types';
import { ThemeController } from '../utils/ThemeController';
import { WindowUtil } from '../utils/WindowUtil';

@ComponentV2
export struct ThemeDetailPage {
  @Local stack: NavPathStack | undefined;
  @Local theme: IThemeInfo | undefined;
  @Local themePics: Resource[] = [];
  @Local breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local themeImgW: BreakpointType<number> = new BreakpointType<number>({
    sm: 188,
    md: 188,
    lg: 112,
    xl: 188,
  });
  @Local themeImgH: BreakpointType<number> = new BreakpointType<number>({
    sm: 400,
    md: 400,
    lg: 240,
    xl: 400,
  });

  @Computed
  get isLargeWindow(): boolean {
    return this.breakpointModel.isLargeWindow;
  }

  build() {
    NavDestination() {
      CommonHeader({ title: this.theme?.label, stack: this.stack })

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.SMALL_CENTER_COL_SPAN,
          offset: GridRowColSetting.SMALL_CENTER_COL_OFFSET,
        }) {
          Column() {
            Scroll() {
              Column() {
                ThemeSwiper({
                  imgWidth: this.themeImgW.getValue(this.breakpointModel.currentBreakpoint),
                  imgHeight: this.themeImgH.getValue(this.breakpointModel.currentBreakpoint),
                  imgList: this.themePics,
                  shadowRatio: 2,
                  indicator: true,
                  isLoop: true,
                  autoPlay: true,
                })

                Text(this.theme?.label)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_L'))
                  .margin({ top: 40, bottom: 8 })

                Text(this.theme?.desc)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Body_M'))
                  .margin({ bottom: 8 })

                Blank().layoutWeight(1)
              }
            }
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)

            Text(ThemeController.getThemeId() === this.theme?.id ? '使用中' : '立即使用')
              .width('100%')
              .constraintSize({ maxWidth: 448 })
              .backgroundColor('#3F7EF7')
              .height(40)
              .borderRadius('50%')
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_L'))
              .textAlign(TextAlign.Center)
              .onClick(() => {
                ThemeController.change(this.theme!.id);
              })
          }
          .height('100%')
        }
      }
      .layoutWeight(1)
      .margin({
        left: this.breakpointModel.pagePadding,
        right: this.breakpointModel.pagePadding,
      })
    }
    .hideTitleBar(true)
    .padding({
      bottom: WindowUtil.getAvoidArea().bottom,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .onReady(res => {
      this.stack = res.pathStack;
      const id = (this.stack.getParamByName('ThemeDetail') as number[]).pop()!;
      this.theme = ThemeController.getThemeById(id);
      this.themePics = ThemeController.getThemePicsById(id);
    })
  }
}


@Builder
export function themeDetailPageBuilder() {
  ThemeDetailPage()
}
