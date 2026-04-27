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
import { TabItem } from '../model/Index';
import { RouterMap } from '../util/Route';


const TAG = '[RecorderHomePageVM]';

@ObservedV2
export class RecorderHomePageVM {
  @Trace tabList: TabItem[] =
    [{
      label: '音频编辑',
      icon: $r('app.media.ic_public_scissors_waveform'),
      url: RouterMap.LIST,
      nextRoute: RouterMap.OPERATION,
    },
      {
        label: '格式转换',
        icon: $r('app.media.ic_public_simulcast_english'),
        url: RouterMap.LIST,
        nextRoute: RouterMap.FORMAT,
      },
      {
        label: '音频转文字',
        icon: $r('app.media.ic_public_mic'),
        url: RouterMap.LIST,
        nextRoute: RouterMap.CONVERT,
      },
      {
        label: '文件管理',
        icon: $r('app.media.ic_file_management'),
        url: RouterMap.AUDIO_MANAGE,
        nextRoute: '',
      },
    ];
  private static _instance: RecorderHomePageVM;

  public static get instance() {
    if (!RecorderHomePageVM._instance) {
      RecorderHomePageVM._instance = new RecorderHomePageVM();
    }
    return RecorderHomePageVM._instance;
  }
}