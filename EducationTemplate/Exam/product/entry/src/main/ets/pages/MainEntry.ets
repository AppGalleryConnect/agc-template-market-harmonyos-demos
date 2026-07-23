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

import { BreakpointType, RouterMap, RouterModule } from 'commonlib';
import { TabListItem } from '../model/TabListItem';
import { MainVM } from '../viewmodels/MainVM';
import { HdsTabs } from '@kit.UIDesignKit';

@ComponentV2
struct MainPage {
  vm: MainVM = MainVM.instance;

  @Monitor('vm.formCardJump.form.id', 'vm.formCardJump.form.url')
  formChange(monitor: IMonitor) {
    if (monitor.value('vm.formCardJump.form.url')?.now) {
      let url = monitor.value('vm.formCardJump.form.url')?.now as string;
      this.widgetInterception(url);
    }
  }

  /*
    * 卡片跳转拦截
    * */
  widgetInterception(url: string) {
    if (url) {
      if (url === RouterMap.MAIN_PAGE) {
        RouterModule.popToName(RouterMap.MAIN_PAGE)
        this.vm.curIndex = 0;
        this.vm.controller.changeIndex(0);
      } else {
        if ((url === RouterMap.COLLECTION_PAGE || url === RouterMap.MESSAGE_CENTER_PAGE) && !this.vm.userInfo.isLogin) {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: url })
        } else {
          RouterModule.push({ url: url });
        }
      }
      this.vm.formCardJump.form.url = '';
    }
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column({ space: 2 }) {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(TabStyle.ICON_SIZE)
        .height(TabStyle.ICON_SIZE);
      Text(item.label)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor(this.vm.curIndex === index ?
          $r('app.color.icon_bg_blue') : $r('sys.color.icon_secondary'));
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(TabStyle.BAR_HEIGHT);
  }

  build() {
    HdsTabs({index: this.vm.curIndex, controller: this.vm.hdsController }) {
      ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
        TabContent() {
          item.component.builder();
        }
        .tabBar(this.tabBarBuilder(item, index));
      }, (item: TabListItem, index) => JSON.stringify(item) + '_' + index);
    }
    .onChange((index) => {
      this.vm.curIndex = index;
    })
    .vertical(new BreakpointType<boolean>({
      sm: false,
      md: false,
      lg: true,
      xl: true
    }).getValue(this.vm.breakPointModel.currentBreakpoint))
    .barPosition(new BreakpointType<number>({
      sm: BarPosition.End,
      md: BarPosition.End,
      lg: BarPosition.Start,
      xl: BarPosition.Start,
    }).getValue(this.vm.breakPointModel.currentBreakpoint))
    .scrollable(false)
    .barMode(BarMode.Fixed)
    .barHeight(new BreakpointType<Length>({
      sm: TabStyle.BAR_HEIGHT,
      md: TabStyle.BAR_HEIGHT,
      lg: 400,
      xl: 400,
    }).getValue(this.vm.breakPointModel.currentBreakpoint))
    .barWidth(new BreakpointType<Length>({
      sm: '100%',
      md: '100%',
      lg: TabStyle.BAR_HEIGHT,
      xl: TabStyle.BAR_HEIGHT,
    }).getValue(this.vm.breakPointModel.currentBreakpoint))
    .animationDuration(TabStyle.ANIMATION_DURATION)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}

@Builder
export function MainEntryBuilder() {
  MainPage();
}

export class TabStyle {
  static readonly BAR_HEIGHT = 48;
  static readonly ANIMATION_DURATION = 0;
  static readonly ICON_SIZE = 24;
}