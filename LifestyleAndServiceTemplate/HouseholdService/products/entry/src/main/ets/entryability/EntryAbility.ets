/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { CustomShareParams, FormUtils, RouterModule, ShareInfo, WindowUtils } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { WantUtils } from '../common/WantUtils';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.setGlobalConfig({
      tag: 'HouseHoldService', // 指定日志标识
      domain: 0xff00, // 日志对应的领域标识
      open: true,
      showStack: false,
    })
    Logger.info(TAG, 'Ability onCreate');
    WantUtils.handleShare(want);
    WantUtils.handleAppLinking(want);
    WantUtils.handleFormCardCall(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    WantUtils.handleShare(want);
    WantUtils.handleAppLinking(want);
    WantUtils.handleFormCardCall(want);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    FormUtils.clearAllFormData(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    LoneTakeAnimationsTransition.init(windowStage);

    windowStage.loadContent('pages/Index').then(() => {
      Logger.info(TAG, 'Succeeded in loading the content.');
      this.setColorMode();
      WindowUtils.setWinConfig(windowStage);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
      return;
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
    FormUtils.clearAllFormData(this.context);
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  setColorMode() {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (error) {
      Logger.error(TAG, `Failed to set color mode. Code is ${error.code}, message is ${error.message}`);
    }
  }

  onShare(wantParams: Record<string, Object>) {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = RouterModule.getStack().getAllPathName();
    let showShareMenu = false;
    if (currentName.length && ['Main', 'GoodDetail'].includes(currentName[currentName.length - 1])) {
      showShareMenu = true;
    }
    const shareParams: ShareInfo = {
      showShareMenu: showShareMenu,
      title: '家政元服务分享',
      description: '家政元服务分享',
      parameters: {} as CustomShareParams,
    };
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(CustomShareParams, 'shareInstance', () => new CustomShareParams())!;
    if (instance.goodId) {
      const pageParams: CustomShareParams = {
        id: instance.id,
        pageName: instance.pageName,
        goodId: instance.goodId,
        goodName: instance.goodName,
      }
      shareParams.title = pageParams.goodName;
      shareParams.description = pageParams.goodName;
      shareParams.parameters = pageParams;
    }

    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }
}
