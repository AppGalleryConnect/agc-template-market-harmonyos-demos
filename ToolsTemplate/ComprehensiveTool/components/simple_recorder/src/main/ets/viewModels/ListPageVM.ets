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
import { PersistenceV2 } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { MyAudio } from '../model/Index';
import { RouterMap, getInstance } from '../util/Route';
import { Logger } from '../util/Logger';


const TAG = '[ListPageVM]';

@ObservedV2
export class ListPageVM {
  @Trace navTitle: string = '音频编辑';
  @Trace nextRoute: RouterMap = RouterMap.OPERATION;
  // 我的录音
  @Trace myAudio: MyAudio = PersistenceV2.connect(MyAudio, () => new MyAudio())!;
  @Trace delId: string = '';
  @Trace expandIndex: number = -1;
  private static _instance: ListPageVM;

  public static get instance() {
    if (!ListPageVM._instance) {
      ListPageVM._instance = new ListPageVM();
    }
    return ListPageVM._instance;
  }

  public getNextUrl() {
    const params = getInstance().getParamByName(RouterMap.LIST)[0] as RouterMap | undefined;
    if (params) {
      this.nextRoute = params;
      switch (params) {
        case RouterMap.OPERATION:
          this.navTitle = '音频剪辑';
          break;
        case RouterMap.FORMAT:
          this.navTitle = '格式转换';
          break;
        default:
          this.navTitle = '音频转文字';
      }
    }
  }


  public removeAudio() {
    const audio = this.myAudio.removeAudio(this.delId);
    this.expandIndex = -1;
    try {
      fs.unlinkSync(audio.filePath);
      fs.unlinkSync(audio.pcmPath);
    } catch (e) {
      Logger.error('删除录音失败');
    }
  }
}