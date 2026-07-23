/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AlertDialog, AppStorageV2, window } from '@kit.ArkUI';
import { PreferenceUtil, PreferConstant, GlobalContextUtils, RouterMap, RouterModule } from 'commonlib';
import { QuestionsRouterModel } from 'answer_questions';
import { RouterTable } from '../model/RouterTable';
import { MainVM } from '../viewmodels/MainVM';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { UserInfo } from 'login_info';

const TAG = '[Index]';

@Entry
@ComponentV2
struct Index {
  // 弹框页
  dialogPages: string[] = [RouterMap.PRIVACY_USE_PAGE, RouterMap.LOGIN_PAGE];
  backPageDialogController?: CustomDialogController;
  content = '';
  leftButtonText = '';
  rightButtonText = '';
  mainVM: MainVM = MainVM.instance;
  private ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  backPageDialogOpen(content: string, leftButtonText: string, rightButtonText: string) {
    this.backPageDialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: '温馨提示',
        content: content,
        secondaryButton: {
          value: rightButtonText,
          action: () => {
          }
        },
        primaryButton: {
          value: leftButtonText,
          fontColor: $r('sys.color.font_tertiary'),
          action: () => {
            RouterModule.pop();
          },
        },
      }),
    });
    this.backPageDialogController.open();
  }

  aboutToAppear() {
    GlobalContextUtils.setUIContext('entry', this.getUIContext());
    try {
      let colorMode = PreferenceUtil.getInstance().get(PreferConstant.COLOR_MODE, -1) as number;
      this.handleDark(colorMode);
      this.mainVM.registerBreakpointListener(this.ctx.windowStage.getMainWindowSync());
    } catch (e) {
      UtilLog.error(TAG, 'registerBreakpointListener, error: ' + JSON.stringify(e));
    }
    RouterModule.replace({ url: RouterMap.LAUNCH_AD_PAGE })
  }

  @Builder
  pageMap(name: string) {
    NavDestination() {
      RouterTable.getBuilder(name).builder();
    }
    .mode(this.dialogPages.includes(name) ? NavDestinationMode.DIALOG : NavDestinationMode.STANDARD)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .onBackPressed(() => {
      return this.backPress(name);
    });
  }

  build() {
    Column() {
      Navigation(RouterModule.stack) {
      }
      .hideNavBar(true)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageMap)
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  // 侧滑返回拦截
  backPress(name: string): boolean {
    if (this.isIntercept(name)) {
      this.backPageDialogOpen(this.content, this.leftButtonText, this.rightButtonText);
      return true;
    }
    return false;
  }

  isIntercept(name: string): boolean {
    if (name === 'AnswerQuestionsTwoPage') {
      this.content = '您还有题目没有作答是否直接交卷结束考试！';
      this.leftButtonText = '结束考试';
      this.rightButtonText = '继续考试';
      return true;
    } else if (name === 'AnswerQuestionsPage') {
      let param: QuestionsRouterModel | undefined =
        RouterModule.getNavParam({ url: RouterMap.ANSWER_QUESTIONS_PAGE });
      if (param?.sourceType === '我的错题' || param?.sourceType === '我的收藏') {
        return false;
      }
      this.content = '您的练习计划还没有完成！确定需要退出本次练习训练吗？';
      this.leftButtonText = '结束练习';
      this.rightButtonText = '继续练习';
      return true;
    }
    return false;
  }

  handleDark(colorMode: number) {
    try {
      this.getUIContext()?.getHostContext()?.getApplicationContext()
        .setColorMode(colorMode);
    } catch (e) {
    }
  }

  setStatusBarColor(statusContentColor: string) {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      let windowClass = ctx.windowStage.getMainWindowSync();
      let sysBarProperties = {
        statusBarContentColor: statusContentColor,
      } as window.SystemBarProperties;
      windowClass.setWindowSystemBarProperties(sysBarProperties).then().catch();
    } catch (error) {
      UtilLog.error(TAG, `setStatusBarTextColor error: ${JSON.stringify(error)}`);
    }
  }
}
