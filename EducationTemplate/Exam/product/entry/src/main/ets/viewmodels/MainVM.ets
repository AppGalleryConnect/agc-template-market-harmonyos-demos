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

import { BaseViewModel, BreakpointUtils, RouterMap, RouterModule } from 'commonlib';
import { TabListItem, TAB_CONFIG } from '../model/TabListItem';
import { AppStorageV2, window } from '@kit.ArkUI';
import { FormCardJump } from '../types/Types';
import { UserInfo } from 'login_info';
import { ShortcutRouter } from '../model/Types';
import { HdsTabsController } from '@kit.UIDesignKit';

@ObservedV2
export class MainVM extends BaseViewModel {
  // 页签索引
  @Trace curIndex: number = 0;
  public controller: TabsController = new TabsController();
  public hdsController: HdsTabsController = new HdsTabsController();
  public tabList: TabListItem[] = TAB_CONFIG;
  private static _instance: MainVM;
  breakpoint: BreakpointUtils | null = null;
  public uiContext?: UIContext;
  public mainWindow?: window.Window;
  @Trace formCardJump: FormCardJump = AppStorageV2.connect(FormCardJump, () => new FormCardJump())!;
  @Trace shortcutRouter: ShortcutRouter = AppStorageV2.connect(ShortcutRouter, () => new ShortcutRouter())!;
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  public static get instance() {
    if (!MainVM._instance) {
      MainVM._instance = new MainVM();
    }
    return MainVM._instance;
  }

  @Monitor('shortcutRouter.pageName')
  onShortcutClick() {
    this.checkShortcutScene();
  }

  @Monitor('userInfo.isLogin')
  changeLogin() {
    if(this.userInfo.isLogin && this.shortcutRouter.pageName) {
      setTimeout(() => {
        this.checkShortcutScene();
      }, 300)
    }
  }

  registerBreakpointListener(mainWindow: window.Window) {
    this.breakpoint = new BreakpointUtils(mainWindow);
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }

  backToHomePage() {
    const currentPage = RouterModule.getStack().getAllPathName().pop();
    if (currentPage !== RouterMap.MAIN_PAGE) {
      RouterModule.popToName(RouterMap.MAIN_PAGE, undefined);
    }
  }

  checkShortcutScene() {
    if(!this.userInfo.isLogin) {
      RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
      return ;
    }
    if (this.shortcutRouter.pageName) {
      this.backToHomePage();
      switch (this.shortcutRouter.pageName) {
        case 'SearchInputPage':
          RouterModule.push({ url : RouterMap.SEARCH_INPUT_PAGE });
          break;
        case 'AnswerQuestionsPage':
          RouterModule.push({ url : RouterMap.ANSWER_QUESTIONS_PAGE });
          break;
      }
      this.shortcutRouter.pageName = '';
    }
  }
}