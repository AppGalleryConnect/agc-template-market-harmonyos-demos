/*
 * Copyright (C) 2024 桃花镇童长老 @pura/harmony-utils
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bundleManager from '@ohos.bundle.bundleManager';
import { LogUtil } from './LogUtil';
import { BusinessError } from '@ohos.base';
import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * TODO App相关工具类(使用该工具前请在UIAbility的onCreate方法中调用AppUtil的init方法初始化)
 * author: 桃花镇童长老ᥫ᭡
 * since: 2024/05/01
 */
export class AppUtil {
  private static context: common.UIAbilityContext; //common.UIAbilityContext，上下文


  /**
   * 初始化方法,缓存全局变量，在UIAbility的onCreate方法中初始化该方法。
   * @param windowStage 窗口管理器
   */
  static init(context: common.UIAbilityContext) {
    AppUtil.context = context;
  }


  /**
   * 获取上下文，common.UIAbilityContext
   * @returns
   */
  static getContext(): common.UIAbilityContext {
    if (!AppUtil.context) {
      LogUtil.error('请在UIAbility的onCreate方法中调用AppUtil的init方法初始化！');
    }
    return AppUtil.context;
  }


  /**
   * 获取WindowStage
   * @returns
   */
  static getWindowStage(): window.WindowStage {
    return AppUtil.getContext().windowStage;
  }

  /**
   * 获取主窗口
   */
  static getMainWindow(): window.Window {
    return AppUtil.getContext().windowStage.getMainWindowSync();
  }

  /**
   * 获取UIContext
   * @returns
   */
  static getUIContext(): UIContext {
    return AppUtil.getMainWindow().getUIContext();
  }


  /**
   * 获取当前窗口的属性
   * @param windowClass 不传该值，获取主窗口的属性
   * @returns
   */
  static getWindowProperties(windowClass: window.Window = AppUtil.getMainWindow()): window.WindowProperties {
    return windowClass.getWindowProperties();
  }


  /**
   * 获取虚拟键盘抬起时的页面避让模式（OFFSET-上抬模式、RESIZE-压缩模式）。
   */
  static getKeyboardAvoidMode(): KeyboardAvoidMode {
    let mode = AppUtil.getUIContext().getKeyboardAvoidMode();
    if (typeof mode === 'string') {
      if ('KeyBoardAvoidMode.RESIZE' === mode) {
        return KeyboardAvoidMode.RESIZE;
      } else {
        return KeyboardAvoidMode.OFFSET;
      }
    }
    return mode;
  }


  /**
   * 设置虚拟键盘弹出时，页面的避让模式。
   * @param value （OFFSET-上抬模式、RESIZE-压缩模式）
   */
  static setKeyboardAvoidMode(value: KeyboardAvoidMode): boolean {
    try {
      AppUtil.getUIContext().setKeyboardAvoidMode(value);
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AppUtil-setKeyboardAvoidMode-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return false;
    }
    return true;
  }

  /**
   * 设置窗口的显示方向属性，使用Promise异步回调。
   * Orientation 窗口显示方向类型枚举:
   *   UNSPECIFIED  0  表示未定义方向模式，由系统判定。
   *   PORTRAIT  1  表示竖屏显示模式。
   *   LANDSCAPE  2  表示横屏显示模式。
   *   PORTRAIT_INVERTED  3  表示反向竖屏显示模式。
   *   LANDSCAPE_INVERTED  4  表示反向横屏显示模式。
   *   AUTO_ROTATION  5  表示传感器自动旋转模式。
   *   AUTO_ROTATION_PORTRAIT  6  表示传感器自动竖向旋转模式。
   *   AUTO_ROTATION_LANDSCAPE  7  表示传感器自动横向旋转模式。
   *   AUTO_ROTATION_RESTRICTED  8  表示受开关控制的自动旋转模式。
   *   AUTO_ROTATION_PORTRAIT_RESTRICTED  9  表示受开关控制的自动竖向旋转模式。
   *   AUTO_ROTATION_LANDSCAPE_RESTRICTED  10  表示受开关控制的自动横向旋转模式。
   *   LOCKED  11  表示锁定模式。
   */
  static async setPreferredOrientation(orientation: window.Orientation,
    windowClass: window.Window = AppUtil.getMainWindow()): Promise<void> {
    try {
      await windowClass.setPreferredOrientation(orientation);
    } catch (err) {
      const error = err as BusinessError;
      LogUtil.error(`AppUtil-setPreferredOrientation-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  /**
   * 设置屏幕亮度值，使用Promise异步回调。
   * @param brightness  屏幕亮度值。该参数为浮点数，取值范围为[0.0, 1.0]或-1.0。1.0表示最亮，-1.0表示默认亮度。
   * @returns
   */
  static async setWindowBrightness(brightness: number,
    windowClass: window.Window = AppUtil.getMainWindow()): Promise<void> {
    try {
      await windowClass.setWindowBrightness(brightness);
    } catch (err) {
      const error = err as BusinessError;
      LogUtil.error(`AppUtil-setWindowBrightness-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  /**
   * 设置屏幕是否为常亮状态，使用Promise异步回调。
   * @param isKeepScreenOn  true表示常亮；false表示不常亮。
   * @returns
   */
  static async setWindowKeepScreenOn(isKeepScreenOn: boolean,
    windowClass: window.Window = AppUtil.getMainWindow()): Promise<void> {
    try {
      await windowClass.setWindowKeepScreenOn(isKeepScreenOn);
    } catch (err) {
      const error = err as BusinessError;
      LogUtil.error(`AppUtil-setWindowKeepScreenOn-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  /**
   * 设置窗口的背景色。Stage模型下，该接口需要在loadContent()或setUIContent()调用生效后使用。
   * @param color 需要设置的背景色，为十六进制RGB或ARGB颜色，不区分大小写，例如#00FF00或#FF00FF00。
   * @returns
   */
  static setWindowBackgroundColor(color: string, windowClass: window.Window = AppUtil.getMainWindow()) {
    try {
      windowClass.setWindowBackgroundColor(color);
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AppUtil-setWindowBackgroundColor-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }

  /**
   * 设置点击时是否支持切换焦点窗口，使用Promise异步回调。
   * @param isFocusable 点击时是否支持切换焦点窗口。true表示支持；false表示不支持。
   * @returns
   */
  static async setWindowFocusable(isFocusable: boolean,
    windowClass: window.Window = AppUtil.getMainWindow()): Promise<void> {
    try {
      await windowClass.setWindowFocusable(isFocusable);
    } catch (err) {
      const error = err as BusinessError;
      LogUtil.error(`AppUtil-setWindowFocusable-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }

  /**
   * 设置窗口是否为可触状态，使用Promise异步回调。
   * @param isTouchable 窗口是否为可触状态。true表示可触；false表示不可触。
   * @returns
   */
  static async setWindowTouchable(isTouchable: boolean,
    windowClass: window.Window = AppUtil.getMainWindow()): Promise<void> {
    try {
      await windowClass.setWindowTouchable(isTouchable);
    } catch (err) {
      const error = err as BusinessError;
      LogUtil.error(`AppUtil-setWindowTouchable-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  /**
   * 获取状态栏的高度，单位为px。
   * @returns
   */
  static getStatusBarHeight(): number {
    try {
      const windowClass = AppUtil.getMainWindow();
      const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      return avoidArea.topRect.height;
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AppUtil-getStatusBarHeight-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return 0;
    }
  }

  /**
   * 获取底部导航条的高度，单位为px。
   * @returns
   */
  static getNavigationIndicatorHeight(): number {
    try {
      const windowClass = AppUtil.getMainWindow();
      const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      return avoidArea.bottomRect.height;
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`AppUtil-getNavigationIndicatorHeight-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return 0;
    }
  }


  /**
   * 获取当前应用的BundleInfo
   */
  static async getBundleInfo(): Promise<bundleManager.BundleInfo> {
    try {
      return await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AppUtil', `AppUtil-getBundleInfo-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error(`获取BundleInfo失败: ${error.message}`);
    }
  }

  /**
   * 获取当前应用的BundleInfo
   */
  static getBundleInfoSync(): bundleManager.BundleInfo {
    try {
      return bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AppUtil', `AppUtil-getBundleInfoSync-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error(`同步获取BundleInfo失败: ${error.message}`);
    }
  }


  /**
   * 获取应用包的名称。
   */
  static getBundleName(): string {
    return AppUtil.getBundleInfoSync().name;
  }

  /**
   * 获取应用版本号。
   */
  static getVersionCode(): number {
    return AppUtil.getBundleInfoSync().versionCode;
  }

  /**
   * 获取应用版本名。
   */
  static getVersionName(): string {
    return AppUtil.getBundleInfoSync().versionName;
  }

  /**
   * 获取运行应用包所需要最高SDK版本号。
   */
  static getTargetVersion(): number {
    return AppUtil.getBundleInfoSync().targetVersion;
  }


  /**
   * 获取应用程序的配置信息
   * @returns
   */
  static async getAppInfo(): Promise<bundleManager.ApplicationInfo> {
    return (await AppUtil.getBundleInfo()).appInfo;
  }

  /**
   * 获取应用程序的配置信息
   * @returns
   */
  static getAppInfoSync(): bundleManager.ApplicationInfo {
    return AppUtil.getBundleInfoSync().appInfo;
  }


  /**
   * 主动退出整个应用；调用该方法后，任务中心的任务默认不会清理，如需清理，需要配置removeMissionAfterTerminate为true。
   */
  static exit() {
    try {
      AppUtil.getContext().terminateSelf();
    } catch (e) {
      const err = e as BusinessError;
      LogUtil.error(`AppUtil-exit-terminateSelf-异常 ~ code: ${err.code} -·- message: ${err.message}`);
    }
    try {
      AppUtil.getContext().getApplicationContext().killAllProcesses();
    } catch (e) {
      const err = e as BusinessError;
      LogUtil.error(`AppUtil-exit-killAllProcesses-异常 ~ code: ${err.code} -·- message: ${err.message}`);
    }
  }
}