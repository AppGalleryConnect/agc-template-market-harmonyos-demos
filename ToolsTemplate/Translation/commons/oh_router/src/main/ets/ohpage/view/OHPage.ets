import { OHPageBody } from './OHPageBody';
import { OHPageConfig } from '../config/OHPageConfig';
import { phoneRouterControl } from '../../router/PhoneImpl/PhoneRouterManager';
import { BreakpointModel, UserInfo, BarVM } from 'common';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';

const TAG = 'OHPage: '

/**
 * @fileType: common
 * @zhName: 通用页面容器
 */
@ComponentV2
export struct OHPage {
  /** 页面属性配置 */
  @Param pageConfig?: OHPageConfig = undefined
  /** 自定义Builder */
  @BuilderParam childBuilder: (id?: string) => void = this.defaultBuilder
  /** 安全边距，折叠屏、直板机等不同设备的左右的页面安全间距，默认true，ture：padding left、right生肖 */
  @Param useSafePadding: boolean = false
  /** 是否全屏，true: 自动padding顶部状态栏、底部导航栏，false：顶部与底部padding为0，默认true
   * 特殊场景如：滚动列表需传true适配，普通页面无需传true */
  @Param isFullScreen: boolean = true
  /** 页面背景色 */
  @Param pageBackgroundColor?: ResourceColor = $r('sys.color.background_secondary')
  /** 是否扩展安全区域（用于沉浸式全屏页面，如相机预览） */
  @Param expandSafeAreaEnabled: boolean = false
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  pageId: string = ''

  @Builder
  defaultBuilder(id?: string) {
    // 兜底布局
  }

  build() {
    NavDestination() {
      OHPageBody({
        pageConfig: this.pageConfig,
        childBuilder: this.childBuilder
      })
        .width('100%')
        .height('100%')
        .constraintSize({
          minHeight: '100%',
          minWidth: '100%'
        })
    }
    .onAppear(() => {
      this.pageConfig?.aboutToAppear?.()
    })
    .onShown(() => {
      this.pageConfig?.onPageShow?.()
    })
    .onHidden(() => {
      this.pageConfig?.onPageHide?.()
    })
    .onDisAppear(() => {
      this.pageConfig?.aboutToDisappear?.()
    })
    .padding({
      left: this.useSafePadding ? this.breakPointModel.pagePadding : 0,
      right: this.useSafePadding ? this.breakPointModel.pagePadding : 0,
      top: this.isFullScreen ? BarVM.instance.staBarH : 0,
      bottom: this.isFullScreen ? BarVM.instance.aiBarH : 0
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.pageConfig?.onBackPress === undefined) {
        // 业务未拦截，路由统一出栈
        phoneRouterControl.popPage()
        return true
      } else {
        // 业务拦截此处不拦截
        return this.pageConfig?.onBackPress?.()
      }
    })
    .backgroundColor(this.pageBackgroundColor)
    .expandSafeArea(
      this.expandSafeAreaEnabled ? [SafeAreaType.SYSTEM] : [],
      this.expandSafeAreaEnabled ? [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM] : []
    )
  }
}