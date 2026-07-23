import { CommonConstants } from '../constants/CommonConstants';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { SettingCard } from '../components/SettingCard';
import { SettingPrivacyVM } from '../viewmodels/SettingPrivacyVM'
import { common } from '@kit.AbilityKit';

@Builder
export function SettingPrivacyBuilder() {
  SettingPrivacy()
}

@ComponentV2
struct SettingPrivacy {
  @Local vm: SettingPrivacyVM = new SettingPrivacyVM();
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 0;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 0;

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.vm.initSwitchStatus(context);
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '隐私设置', customPadding: { top: this.windowTopHeight } })
      if (this.vm.configInfo.isSheet) {
        this.coreView()
      } else {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            this.coreView()
          }
        }
        .layoutWeight(1)
      }
    }
    .attributeModifier(this.vm.pageModifier)
    .backgroundColor(this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  coreView() {
    Scroll() {
      Column({ space: CommonConstants.SPACE_M }) {
        SettingCard({ list: this.vm.list1 })
        SettingCard({ list: this.vm.list2 })
        SettingCard({ list: this.vm.list3 })
        SettingCard({ list: this.vm.list4 })
      }
      .padding({
        top: CommonConstants.PADDING_M,
        bottom: this.windowBottomHeight + CommonConstants.PADDING_M,
      })
    }
    .attributeModifier(this.vm.scrollModifier)
  }
}
