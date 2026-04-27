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
import { util } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { forMatAudio, createFd } from '../util/ConvertUtil';
import { RouterMap, getInstance } from '../util/Route';
import { MyAudio, AudioInfo } from '../model/Index';

const TAG = '[FormatPageVM]';

@ObservedV2
export class FormatPageVM {
  // 当前可转换的格式
  @Trace formatArr: string[] = [];
  @Trace currentIndex: number = -1;
  // 我的录音
  @Trace myAudio: MyAudio = PersistenceV2.connect(MyAudio, () => new MyAudio())!;
  // 当前录音
  @Trace curAudio: AudioInfo = new AudioInfo();
  // 输出的文件路径
  @Trace outputFilePath: string = '';
  // 输出的文件名
  @Trace outputFileName: string = '';
  // 标志是否可以保存
  @Trace isCanSave: boolean = false;
  // 默认支持的格式
  private defaultFormat: string[] = ['M4a', 'MP3', 'AAC', 'WAV'];
  private static _instance: FormatPageVM;

  public static get instance() {
    if (!FormatPageVM._instance) {
      FormatPageVM._instance = new FormatPageVM();
    }
    return FormatPageVM._instance;
  }

  // 获取路由及参数初始化
  public getRouteParam() {
    const id: string = getInstance().getParamByName(RouterMap.FORMAT)[0] as string;
    this.curAudio = this.myAudio.getAudioById(id);
    this.formatArr = this.defaultFormat.filter((item) => item !== this.curAudio.format);
    this.isCanSave = false;
    this.currentIndex = -1;
  }


  public chaneFormat(format: string, loadingController: CustomDialogController) {
    loadingController.open();
    // 重新转换时删除上一段留存的语音
    if (this.outputFilePath) {
      fs.unlinkSync(this.outputFilePath);
    }
    this.outputFilePath = createFd(format.toLowerCase(), true).filePath;
    forMatAudio(this.curAudio.filePath, this.outputFilePath, (code: number) => {
      if (code === 0) {
        promptAction.showToast({ message: '转换成功' });
        this.outputFileName = `转换_${this.curAudio.fileName.split('.')[0]}.${format.toLowerCase()}`;
        this.isCanSave = true;
      } else {
        promptAction.showToast({ message: '转换失败' });
        this.isCanSave = false;
      }
      loadingController.close();
    });
  }

  // 清理掉未保存的音频文件
  public clearFile() {
    if (this.outputFilePath) {
      fs.unlinkSync(this.outputFilePath);
      this.outputFilePath = '';
    }
    this.outputFileName = '';
    this.isCanSave = false;
  }


  //  保存当前转换的文件
  public async saveFile() {
    if (this.isCanSave) {
      const pcmPath = createFd('PCM').filePath;
      fs.copyFileSync(this.curAudio.pcmPath, pcmPath);
      this.myAudio.addAudio(new AudioInfo(util.generateRandomUUID(false), this.outputFilePath, this.outputFileName,
        this.formatArr[this.currentIndex], pcmPath));
      promptAction.showToast({ message: '保存成功' });
      this.isCanSave = false;
      this.outputFilePath = '';
      this.outputFileName = '';
      getInstance().pop();
    } else {
      promptAction.showToast({ message: '请选择转换格式' });
    }

  }
}