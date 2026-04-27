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
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { ThreadWorkerPriority, util, worker } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { RecorderUtil } from '../util/RecorderUtil';
import { createFd } from '../util/ConvertUtil';
import { PermissionUtil } from '../util/PermissionUtil';
import { getInstance, RouterMap } from '../util/Route';
import {
  RecordStatus,
  FileInfo,
  AudioInfo,
  MyAudio,
  SaveType,
  MyAmplitude,
  RouteParams,
  SaveWorkerParm,
  SaveMessageType,
} from '../model/Index';
import { WAVE_BAR_COUNT, AMPLITUDE_MIN_HEIGHT, AMPLITUDE_MAX_HEIGHT } from '../constant/Index';


const TAG = '[RecordPageVM]';

@ObservedV2
export class RecordPageVM {
  // 录制状态
  @Trace recordStatus: RecordStatus = RecordStatus.PENDING;
  // 我的录音
  @Trace myAudio: MyAudio = PersistenceV2.connect(MyAudio, () => new MyAudio())!;
  // 当前录音文件信息
  @Trace curFile: FileInfo | undefined = undefined;
  @Trace myAmplitude: MyAmplitude = AppStorageV2.connect(MyAmplitude, () => new MyAmplitude())!;
  @Trace waveIndex: number[] = new Array(WAVE_BAR_COUNT).fill(0);
  private random: cryptoFramework.Random = cryptoFramework.createRandom();
  private recorderUtil: RecorderUtil = new RecorderUtil();
  private saveWorker = new worker.ThreadWorker('../workers/SaveWorker', {
    priority: ThreadWorkerPriority.MEDIUM,
  });
  private static _instance: RecordPageVM;

  public static get instance() {
    if (!RecordPageVM._instance) {
      RecordPageVM._instance = new RecordPageVM();
    }
    return RecordPageVM._instance;
  }

  // 初始化数值
  public initData() {
    this.recordStatus = RecordStatus.PENDING;
    this.curFile = undefined;
    this.myAmplitude.amplitude = 0;
  }


  // 开始录制
  public async start(uiContext: UIContext) {
    const res: boolean = await PermissionUtil.requestPermissions(['ohos.permission.MICROPHONE']);
    if (!res) {
      promptAction.showToast({ message: '录音功能需要先开启麦克风权限！' });
      return;
    }
    this.curFile = await this.recorderUtil.startRecordingProcess(uiContext);
    this.recordStatus = RecordStatus.PROGRESS;
  }

  // 停止录制
  public async stop() {
    this.curFile = await this.recorderUtil.stopRecordingProcess();
    this.recordStatus = RecordStatus.OFF;
  }

  //  保存
  public async saveAudio(saveType: SaveType, controller: CustomDialogController) {
    if (this.curFile) {
      const pcmPath = createFd('PCM').filePath;

      const workData: SaveWorkerParm = {
        filePath: this.curFile.filePath,
        pcmPath: pcmPath,
      };
      this.saveWorker.postMessage(workData);
      controller.open();
      this.saveWorker.onmessage = (messageEvents) => {
        const res = messageEvents.data as string;
        if (this.curFile && res === SaveMessageType.SUCCESS) {
          const audio: AudioInfo =
            new AudioInfo(util.generateRandomUUID(false), this.curFile.filePath, this.curFile.fileName, 'MP3', pcmPath);
          this.myAudio.addAudio(audio);
          // 保存后将对象置空
          this.curFile = undefined;
          if (saveType === SaveType.ONLY_SAVE) {
            getInstance().popToName(RouterMap.HOME);
          }
          if (saveType === SaveType.EDIT_SAVE) {
            const param: RouteParams = {
              id: audio.id,
              isOperation: true,
            };
            getInstance().replacePathByName(RouterMap.OPERATION, param);
          }
          if (saveType === SaveType.CONVERT_SAVE) {
            getInstance().replacePathByName(RouterMap.CONVERT, audio.id);
          }
          controller.close();
          promptAction.showToast({ message: '保存成功' });
        } else {
          controller.close();
          promptAction.showToast({ message: '保存失败' });
        }

      };
    }

  }

  //  删除文件
  public async delAudio() {
    if (this.curFile) {
      fs.unlinkSync(this.curFile.filePath);
      this.recordStatus = RecordStatus.PENDING;
      promptAction.showToast({ message: '删除成功' });
    }
  }

  // 获取振幅数据
  getWaveHeight(): number {
    let randData = this.random.generateRandomSync(1);
    let height = Math.min(AMPLITUDE_MAX_HEIGHT,
      Math.max(AMPLITUDE_MIN_HEIGHT, this.myAmplitude.amplitude * (0.1 + randData.data[0] / 255)));
    return height;
  }
}