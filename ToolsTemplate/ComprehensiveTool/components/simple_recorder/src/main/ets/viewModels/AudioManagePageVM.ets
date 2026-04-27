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
import { Logger } from '../util/Logger';
import { AudioInfo } from '../model/Index';


const TAG = '[AudioManagePageVM]';

@ObservedV2
export class AudioManagePageVM {
  // 我的录音
  @Trace myAudio: MyAudio = PersistenceV2.connect(MyAudio, () => new MyAudio())!;
  @Trace delId: string = '';
  // 展开项的item
  @Trace expandIndex: number = -1;
  // 是否激活编辑状态
  @Trace isActive: boolean = false;
  // 选中的id
  @Trace ids: string[] = [];
  // 删除提示语
  @Trace tips: string = '是否删除此文件？';
  // 将要修改的文件名
  @Trace targetFileName: string = '';
  // 将要修改文件的id
  @Trace targetId: string = '';
  private static _instance: AudioManagePageVM;

  public static get instance() {
    if (!AudioManagePageVM._instance) {
      AudioManagePageVM._instance = new AudioManagePageVM();
    }
    return AudioManagePageVM._instance;
  }


  public addAllId() {
    if (this.ids.length === this.myAudio.list.length) {
      this.ids = [];
    } else {
      this.ids = this.myAudio.list.map((item) => item.id);
    }
  }

  public removeId(id: string) {
    this.ids = this.ids.filter((item) => item !== id);
  }

  public addId(id: string) {
    if (!this.ids.some((item) => item === id)) {
      this.ids.push(id);
    }
  }

  // 单个删除文件
  public removeAudio(id: string) {
    const audio: AudioInfo = this.myAudio.removeAudio(id);
    this.expandIndex = -1;
    try {
      fs.unlinkSync(audio.filePath);
      fs.unlinkSync(audio.pcmPath);
    } catch (e) {
      Logger.error('删除文件失败');
    }
    // 去除对应选中id
    this.removeId(id);
  }

  // 批量删除
  public batchDelete() {
    this.ids.forEach((item: string) => {
      this.removeAudio(item);
    });
    this.ids = [];
  }


  public getTips() {
    if (this.ids.length === 1) {
      this.tips = '是否删除此文件？';
    }
    if (this.ids.length > 1) {
      this.tips = `是否删除${this.ids.length}条文件？`;
    }
    if (this.ids.length === this.myAudio.list.length) {
      this.tips = '是否删除全部文件？';
    }
  }

  public initData() {
    this.isActive = false;
    this.expandIndex = -1;
    this.ids = [];
  }
}