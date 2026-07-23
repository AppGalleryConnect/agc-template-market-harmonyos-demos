import { GridRowColSetting } from '../common/GridRowColSetting';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { SettingH5VM } from '../viewmodels/SettingH5VM';

@Builder
export function SettingH5Builder() {
  SettingH5()
}

@ComponentV2
struct SettingH5 {
  @Local vm: SettingH5VM = new SettingH5VM();
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 0;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 0;

  aboutToAppear(): void {
    this.vm.getParams();
  }

  build() {
    NavDestination() {
      NavHeaderBar({ customPadding: { top: this.windowTopHeight } })
      if (this.vm.configInfo.isSheet) {
        this.webBuilder()
      } else {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            this.webBuilder()
          }
        }
        .layoutWeight(1)
      }
    }
    .attributeModifier(this.vm.pageModifier)
    .backgroundColor(this.pageBg)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  webBuilder() {
    Web({
      src: '',
      controller: this.vm.webViewController,
    })
      .fileAccess(false)
      .geolocationAccess(false)
      .darkMode(WebDarkMode.Auto)
      .forceDarkAccess(true)
      .verticalScrollBarAccess(false)
      .defaultFontSize(this.vm.getDefaultFontSize)
      .textZoomRatio(this.vm.getTextZoomRatio)
      .backgroundColor(this.pageBg)
      .layoutWeight(1)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_ONLY,
        scrollBackward: NestedScrollMode.SELF_ONLY,
      })
      .padding({ bottom: this.windowBottomHeight })
      .onControllerAttached(() => {
        this.vm.onControllerAttached();
      })
  }

  @Computed
  get pageBg() {
    return this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary')
  }
}
