import { window, UIContext } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

/**
 * 安全区域工具类，用于获取状态栏和底部导航栏高度
 */
export class SafeAreaUtils {
  /**
   * 获取状态栏高度
   * @param uiContext UIContext（可选，如果不提供则尝试从全局获取）
   * @returns Promise<number> 状态栏高度（vp）
   */
  static async getStatusBarHeight(uiContext?: UIContext): Promise<number> {
    try {
      let context: common.Context | undefined
      
      // 如果提供了 UIContext，尝试从中获取 Context
      if (uiContext) {
        context = uiContext.getHostContext() as common.Context
      } else {
        // 尝试使用全局 Context（如果可用）
        try {
          // 使用 getContext() 不带参数（在模块级别函数中）
          context = getContext() as common.Context
        } catch {
          return 0
        }
      }
      
      if (!context) {
        return 0
      }
      
      const mainWindow: window.Window = await window.getLastWindow(context)
      if (!mainWindow) {
        return 0
      }
      const avoidArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      return px2vp(avoidArea.topRect.height)
    } catch {
      return 0
    }
  }

  /**
   * 获取底部导航栏高度
   * @param uiContext UIContext（可选，如果不提供则尝试从全局获取）
   * @returns Promise<number> 底部导航栏高度（vp）
   */
  static async getBottomSafeArea(uiContext?: UIContext): Promise<number> {
    try {
      let context: common.Context | undefined
      
      // 如果提供了 UIContext，尝试从中获取 Context
      if (uiContext) {
        context = uiContext.getHostContext() as common.Context
      } else {
        // 尝试使用全局 Context（如果可用）
        try {
          // 使用 getContext() 不带参数（在模块级别函数中）
          context = getContext() as common.Context
        } catch {
          return 0
        }
      }
      
      if (!context) {
        return 0
      }
      
      const mainWindow: window.Window = await window.getLastWindow(context)
      if (!mainWindow) {
        return 0
      }
      const avoidArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      return px2vp(avoidArea.bottomRect.height)
    } catch {
      return 0
    }
  }
}

