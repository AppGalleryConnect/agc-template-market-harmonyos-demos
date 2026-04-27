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
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { CustomLinkModel, CustomShareParams, RouterModule, ShareInfo } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';

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
    this.handleShare(want);
    this.handleAppLinking(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleShare(want);
    this.handleAppLinking(want);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    LoneTakeAnimationsTransition.init(windowStage);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      this.setColorMode();
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
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

  handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    const paramStr = want?.parameters?.custShareParam as string;
    const shareParams: CustomShareParams = JSON.parse(paramStr || '{}');
    const shareRouter: CustomShareParams = AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
    shareRouter.id = new Date().getTime();
    shareRouter.pageName = '';
    shareRouter.goodId = '';
    if (shareParams?.goodId) {
      shareRouter.pageName = shareParams.pageName;
      shareRouter.goodId = shareParams.goodId;
    }
  }

  handleAppLinking(want: Want) {
    let uri = want?.uri;
    if (uri) {
      // 从链接中解析query参数（自定义参数），拿到参数后，开发者可根据自己的业务需求进行后续的处理。
      try {
        const navRouterName =  want.parameters?.navRouterName as string;
        Logger.info(TAG, 'navRouterName is: ' + navRouterName);
        // 例如，当navRouterName为GoodDetail时，跳转服务详情页面。
        if (navRouterName === 'GoodDetail') {
          const linkScanRouter: CustomLinkModel = AppStorageV2.connect(CustomLinkModel, () => new CustomLinkModel())!;
          linkScanRouter.id = new Date().getTime();
          linkScanRouter.pageUrl = navRouterName;
        }
      } catch (error) {
        Logger.error(TAG, 'Failed to parse url. error: ' + JSON.stringify(error));
      }
    }
  }
}
