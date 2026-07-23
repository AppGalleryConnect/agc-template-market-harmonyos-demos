/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { AdService, AdType, platformType } from '@agctemplate/open_ads'
import { NAV_PAGE_NAME } from '@agctemplate/resources'
import { appRouter, Logger, WindowManager } from '@agctemplate/utils'
import { common } from '@kit.AbilityKit'

@Builder
export function LaunchAdPageBuilder() {
  LaunchAdPage()
}

@ComponentV2
struct LaunchAdPage {
  aboutToAppear(): void {
    WindowManager.setWindowSystemBarEnable([])
  }

  aboutToDisappear(): void {
    WindowManager.setWindowSystemBarEnable(['status', 'navigation'])
  }

  build() {
    NavDestination() {
      AdService({
        platform: platformType.HUAWEI_AD,
        adId: 'testd7c5cewoj6',
        adType: AdType.AD_VIDEO,
        closeCallBack: () => {
          appRouter.replace({
            builderName: NAV_PAGE_NAME.MainTabPage.name
          })
        },
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      try {
        (this.getUIContext().getHostContext() as common.UIAbilityContext).terminateSelf()
      } catch (e) {
        console.error(`terminateSelf failed: ${e}`);
      }
      return true
    })
  }
}