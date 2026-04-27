import { common } from '@kit.AbilityKit';
import { WindowUtil } from 'module_ui_base';
import { CommonConstants } from '../constants/CommonConstants';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { LogoutBtn } from '../components/LogoutBtn';
import { SettingCard } from '../components/SettingCard';
import { SettingGroup } from '../types/SettingItem';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { DisplayType } from '../types/SettingType';

@ComponentV2
export struct SettingView {
  // 设置列表
  @Param settingList: SettingGroup[] = [];
  // 路由栈
  @Param pathStack: NavPathStack = new NavPathStack();
  // 展示形式
  @Param displayType: DisplayType = DisplayType.PAGE;
  // 主题色
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  // 页面内边距
  @Param pagePadding: Padding = {};
  // 是否已登录
  @Param isLogin: boolean = false;
  // 退出登录api
  @Event signOutApi: () => Promise<void> = () => new Promise((resolve) => resolve());
  @Local vm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext())
    this.initParams();
    this.vm.handleSettingList(this.settingList);
    this.vm.onConfigurationUpdate();
    this.vm.windowModel.onAvoidAreaChange();
  }

  aboutToDisappear(): void {
    this.vm.offConfigurationUpdate();
    this.vm.windowModel.offAvoidAreaChange();
  }

  build() {
    Column() {
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
        .onBreakpointChange((breakpoints: string) => {
          this.vm.breakPointModel.currentBreakpoint = breakpoints;
        })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .defaultFocus(true)
    .onFocus(() => {
      this.vm.getLatestPushStatus();
    })
  }

  initParams() {
    this.vm.uiContext = this.getUIContext();
    this.vm.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.setCoreInfo();
    this.setPadding();
  }

  setCoreInfo() {
    this.vm.configInfo.pathStack = this.pathStack;
    this.vm.configInfo.displayType = this.displayType;
    this.vm.configInfo.themeColor = this.themeColor;
  }

  setPadding() {
    this.vm.windowModel.windowTopPadding = this.pagePadding.top;
    this.vm.windowModel.windowBottomPadding = this.pagePadding.bottom;
    this.vm.windowModel.windowLeftPadding = this.pagePadding.left;
    this.vm.windowModel.windowRightPadding = this.pagePadding.right;
  }

  @Monitor('pagePadding')
  onPaddingChange() {
    this.setPadding();
  }

  @Builder
  coreView() {
    Column() {
      Scroll() {
        Column({ space: CommonConstants.SPACE_M }) {
          ForEach(this.vm.settingList, (v: SettingGroup) => {
            SettingCard({
              title: v.title,
              list: v.list,
            })
          }, (v: SettingGroup) => v.id)
        }
        .padding({
          top: CommonConstants.PADDING_M,
        })
      }
      .attributeModifier(this.vm.scrollModifier)

      LogoutBtn({
        visible: this.isLogin,
        signOutApi: this.signOutApi,
      })
    }
    .layoutWeight(1)
    .padding({
      left: this.vm.windowModel.pageLeftPadding,
      right: this.vm.windowModel.pageRightPadding,
      top: this.vm.windowModel.windowTopPadding,
      bottom: this.vm.windowModel.pageBottomPadding,
    })
  }
}