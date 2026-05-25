/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { Configuration, UIAbility, Want } from '@kit.AbilityKit';
import { KeyboardAvoidMode, window, AppStorageV2 } from '@kit.ArkUI';
import { AbilityConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ThemeController } from '../controller/ThemeController';
import { AppUtil, WindowUtil } from '@ohos_agcit/notes_utils';
import { notificationManager } from '@kit.NotificationKit';
import { SettingController } from '../controller/SettingController';
import { distributedKVStore } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { ContinueUtils } from 'continue';
import GlobalContext from '../utils/ContextConfig';
import { systemShare } from '@kit.ShareKit';
import { GlobalInfoModel } from '@ohos_agcit/notes_utils';


interface SharedRecordWithContent extends systemShare.SharedRecord {
  content?: string;
}

export default class EntryAbility extends UIAbility {
  private themeController: ThemeController = ThemeController.instance;
  private settingController: SettingController = SettingController.instance;
  securityLevel: distributedKVStore.SecurityLevel = distributedKVStore.SecurityLevel.S1;
  private storage: LocalStorage = new LocalStorage();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AppUtil.init(this.context);
    this.themeController.currentColorMode = this.context.config.colorMode;
    // 处理接续恢复（冷启动）
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(0x0000, 'EntryAbility', '冷启动接续恢复');
      ContinueUtils.handleTargetContinue(want, this.context);

      // 恢复页面栈
      if (want.parameters?.noteId) {
        this.context.restoreWindowStage(this.storage);
      }
    }

    this.handleAppLinking(want);
    this.tryHandleSharePayload(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', 'onNewWant called');

    // 2. 处理接续恢复（热启动）
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(0x0000, 'EntryAbility', '热启动接续恢复');
      ContinueUtils.handleTargetContinue(want, this.context);

      // 恢复页面栈
      if (want.parameters?.noteId) {
        this.context.restoreWindowStage(this.storage);
      }
    }

    this.handleAppLinking(want);
    this.tryHandleSharePayload(want);
  }

  private static getShareRecordContent(record: systemShare.SharedRecord): string | undefined {
    const v = (record as SharedRecordWithContent).content;
    return typeof v === 'string' ? v : undefined;
  }


  private tryHandleSharePayload(want: Want): void {
    systemShare.getSharedData(want).then((data: systemShare.SharedData) => {
      const records = data.getRecords();
      if (!records || records.length === 0) {
        return;
      }
      for (const record of records) {
        const content = EntryAbility.getShareRecordContent(record);
        if (typeof content !== 'string' || content.length === 0) {
          continue;
        }
        if (content.startsWith('NOTES_IMPORT:')) {
          const jsonStr = content.substring('NOTES_IMPORT:'.length);
          const payload = JSON.parse(jsonStr) as Record<string, Object>;
          AppStorage.setOrCreate('shared_note_payload', payload);
          AppStorage.setOrCreate('from_gesture_share_content', true);
          hilog.info(0x0000, 'GesturesShare', 'getSharedData 收到隔空传送笔记内容');
          return;
        }
      }
    }).catch((_err: BusinessError) => {
      // 非分享场景会失败，忽略
    });
  }

  // 接续生命周期方法
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(0x0000, 'EntryAbility', '收到接续请求');
    return ContinueUtils.handleSourceContinue(wantParam, this.context);
  }


  private handleAppLinking(want: Want): void {
    try {
      const uri: string = want?.uri as string;
      if (!uri) {
        return;
      }

      if (uri.includes('/import?') && uri.includes('data=')) {
        const payload = this.parseImportDataFromUri(uri);
        if (payload) {
          AppStorage.setOrCreate('shared_note_payload', payload);
          AppStorage.setOrCreate('from_gesture_share_content', true);
          hilog.info(0x0000, 'GesturesShare', '收到隔空传送笔记内容');
        }
        return;
      }

      if (this.isExpectedAppLinking(uri)) {
        const noteId = this.parseNoteIdFromUri(uri);

        if (noteId) {
          AppStorage.setOrCreate('share_note_id', noteId);
          AppStorage.setOrCreate('from_gesture_share', true);
          hilog.info(0x0000, 'GesturesShare', `收到分享链接: noteId=${noteId}`);
        }
      }
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `处理链接失败: ${err.code} ${err.message}`);
    }
  }


  private parseImportDataFromUri(uri: string): Record<string, Object> | null {
    try {
      const dataKey = 'data=';
      const startIndex = uri.indexOf(dataKey);
      if (startIndex === -1) {
        return null;
      }
      const encoded = decodeURIComponent(uri.substring(startIndex + dataKey.length));
      const jsonStr = this.base64Decode(encoded);
      return JSON.parse(jsonStr) as Record<string, Object>;
    } catch (error) {
      hilog.error(0x0000, 'GesturesShare', `解析 import 数据失败: ${JSON.stringify(error)}`);
      return null;
    }
  }

  private base64Decode(encoded: string): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    const len = encoded.length;
    let bytes: number[] = [];
    for (let i = 0; i < len; i += 4) {
      const a = chars.indexOf(encoded[i]);
      const b = chars.indexOf(encoded[i + 1]);
      const c = encoded[i + 2] === '=' ? -1 : chars.indexOf(encoded[i + 2]);
      const d = encoded[i + 3] === '=' ? -1 : chars.indexOf(encoded[i + 3]);
      if (a < 0 || b < 0) {
        continue;
      }
      bytes.push((a << 2) | (b >> 4));
      if (c >= 0) {
        bytes.push(((b & 15) << 4) | (c >> 2));
      }
      if (d >= 0) {
        bytes.push(((c & 3) << 6) | d);
      }
    }
    const u8 = new Uint8Array(bytes);
    const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
    return decoder.decodeToString(u8, { stream: false });
  }

  private isExpectedAppLinking(uri: string): boolean {
    return uri.includes('/open?') && uri.includes('noteId=');
  }

  /**
   * 从URI中解析noteId
   * URI格式：https://notes.app/open?noteId=123&title=xxx
   */
  private parseNoteIdFromUri(uri: string): string {
    try {
      // 查找noteId参数
      const noteIdKey = 'noteId=';
      const startIndex = uri.indexOf(noteIdKey);

      if (startIndex === -1) {
        return '';
      }

      // 找到noteId值的起始位置
      const valueStart = startIndex + noteIdKey.length;

      // 查找参数的结束位置（下一个&或字符串结尾）
      let valueEnd = uri.indexOf('&', valueStart);
      if (valueEnd === -1) {
        valueEnd = uri.length;
      }

      const noteId = uri.substring(valueStart, valueEnd);

      return decodeURIComponent(noteId);
    } catch (error) {
      return '';
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  initWindow(windowStage: window.WindowStage) {
    let windowClass: window.Window = windowStage.getMainWindowSync();
    let size = windowClass.getWindowProperties().windowRect;

    AppStorage.setOrCreate('screenHeight', windowStage.getMainWindowSync().getUIContext().px2vp(size.height));
    AppStorage.setOrCreate('screenWidth', windowStage.getMainWindowSync().getUIContext().px2vp(size.width));
    // ComponentV2 页面通过 GlobalInfoModel 响应窗口宽度变化
    const globalInfo: GlobalInfoModel =
      AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
    globalInfo.screenWidthVp = windowStage.getMainWindowSync().getUIContext().px2vp(size.width);

    windowClass.on('windowSizeChange', data => {
      AppStorage.setOrCreate('screenHeight', windowStage.getMainWindowSync().getUIContext().px2vp(data.height));
      AppStorage.setOrCreate('screenWidth', windowStage.getMainWindowSync().getUIContext().px2vp(data.width));
      globalInfo.screenWidthVp = windowStage.getMainWindowSync().getUIContext().px2vp(data.width);
    });
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    GlobalContext.setContext(this.context);

    // 一多适配-折叠屏
    WindowUtil.registerBreakPoint(windowStage);

    let windowClass: window.Window = windowStage.getMainWindowSync();

    // 隐藏底部导航栏
    windowClass.setSpecificSystemBarEnabled('navigationIndicator', false).then(() => {
      hilog.info(0x0000, 'EntryAbility', 'Succeeded in setting the navigation indicator to be invisible.');
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'EntryAbility',
        `Failed to set the navigation indicator to be invisible. Code is ${err.code}, message is ${err.message}`);
    });
    this.loadSplashPage(windowStage);
  }

  /**
   * 加载首页
   */
  private loadIndexPage(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('pages/Index', (err: BusinessError | undefined) => {
        if (err !== undefined) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        try {
          this.initWindow(windowStage);
          windowStage.getMainWindowSync().getUIContext().getKeyboardAvoidMode();
          windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
        } catch (e) {
          const inner = e as BusinessError;
          hilog.error(0x0000, 'testTag', 'initWindow after Index load failed: %{public}s',
            `${inner.code} ${inner.message}`);
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
    } catch (e) {
      const err = e as BusinessError;
      hilog.error(0x0000, 'testTag', 'loadContent(Index) threw: %{public}s', `${err.code} ${err.message}`);
    }
  }

  /**
   * 加载启动页（开屏广告页）
   */
  private loadSplashPage(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('pages/SplashPage', (err: BusinessError | undefined) => {
        if (err !== undefined) {
          hilog.error(0x0000, 'testTag', 'Failed to load the splash content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        try {
          this.initWindow(windowStage);
          windowStage.getMainWindowSync().getUIContext().getKeyboardAvoidMode();
          windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
        } catch (e) {
          const inner = e as BusinessError;
          hilog.error(0x0000, 'testTag', 'initWindow after Splash load failed: %{public}s',
            `${inner.code} ${inner.message}`);
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the splash content.');
      });
    } catch (e) {
      const err = e as BusinessError;
      hilog.error(0x0000, 'testTag', 'loadContent(Splash) threw: %{public}s', `${err.code} ${err.message}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // 判断是否通知授权
    try {
      let isEnabledPromise = notificationManager.isNotificationEnabled();
      isEnabledPromise.then((result: boolean) => {
        this.settingController.isNoticeGrant = result;
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility',
          `isNotificationEnabled failed. code: ${error.code}, message: ${error.message}`);
        this.settingController.isNoticeGrant = false;
      });
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'EntryAbility',
        `isNotificationEnabled throw error. code: ${err.code}, message: ${err.message}`);
      this.settingController.isNoticeGrant = false;
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 夜间模式
   * @param newConfig
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    if (this.themeController.currentColorMode !== newConfig.colorMode &&
    this.themeController.isFollowSystemSetting) {
      this.themeController.currentColorMode = newConfig.colorMode;
    }
  }
};