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

import { HomeMainPageBuilder } from '@agctemplate/home';
import { MinePageBuilder } from '@agctemplate/mine';
import { getMedia } from '@agctemplate/resources';
import { TabListItem } from '../model/TabListItem';

export const TAB_CONFIG: TabListItem[] = [
  {
    label: '直播',
    icon: getMedia('sys.symbol.play_video_fill'),
    component: wrapBuilder(HomeMainPageBuilder),
  },
  {
    label: '开直播',
    icon: getMedia('sys.symbol.plus_circle_fill'),
  },
  {
    label: '我的',
    icon: getMedia('sys.symbol.person_fill'),
    component: wrapBuilder(MinePageBuilder),
  },
];

@ObservedV2
export class MainVM {
  // 页签索引
  @Trace curIndex: number = 0;
  public controller: TabsController = new TabsController();
  public tabList: TabListItem[] = TAB_CONFIG;
  private static _instance: MainVM;

  public static get instance() {
    if (!MainVM._instance) {
      MainVM._instance = new MainVM();
    }
    return MainVM._instance;
  }
}