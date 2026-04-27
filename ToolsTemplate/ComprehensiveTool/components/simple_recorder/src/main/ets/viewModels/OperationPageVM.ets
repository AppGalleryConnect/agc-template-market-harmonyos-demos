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
import { ThreadWorkerPriority, util, worker } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { PlayUtil } from '../util/PlayUtil';
import { createFd, captureAudio, contactAudio, toneAudio, extractToPCM } from '../util/ConvertUtil';
import { getInstance, RouterMap } from '../util/Route';
import { MyAudio, AudioInfo, AudioWaveController, RouteParams, MultipleWorkerParm } from '../model/Index';
import { MAX_EDIT_DURATION } from '../constant/Index';




@ObservedV2
export class OperationPageVM {
  @Trace splitBtnIndex: number = 0;
  @Trace splitBtnArr: string[] = ['保留截取片段', '删除截取片段'];
  // 截取弹框是否显示
  @Trace splitSheetVisible: boolean = false;
  // 速度刻度
  @Trace speedArr: string[] = ['0.5x', '1.0x', '1.5x', '2.0x'];
  // 当前速度
  @Trace currentSpeed: number = 1;
  // 当前音调
  @Trace currentTone: number = 1;
  // 变速弹框是否显示
  @Trace speedSheetVisible: boolean = false;
  // 音调弹框是否显示
  @Trace toneSheetVisible: boolean = false;
  // 我的录音
  @Trace myAudio: MyAudio = PersistenceV2.connect(MyAudio, () => new MyAudio())!;
  // 当前录音
  @Trace curAudio: AudioInfo = new AudioInfo();
  // 录音时长：单位秒
  @Trace duration: number = 1;
  // 当前播放位置
  @Trace curTime: number = 0;
  // 截取开始位置
  @Trace startTime: number = 0;
  // 截取结束位置
  @Trace endTime: number = 1;
  // 是否正在播放
  @Trace isPlaying: boolean = false;
  // 标志是否已经产生可保存音频
  @Trace isCanSave: boolean = false;
  // 编辑后文件的命名
  @Trace fileName: string = '';
  // 标志是否有编辑栏
  @Trace isOperation: boolean = true;
  // 音频波纹组件控制器
  controller: AudioWaveController = new AudioWaveController();
  // 播放工具类
  private playUtil: PlayUtil = new PlayUtil();
  // 编辑worker
  private editWorker = new worker.ThreadWorker('../workers/EditWorker', {
    priority: ThreadWorkerPriority.MEDIUM,
  });
  private static _instance: OperationPageVM;

  public static get instance() {
    if (!OperationPageVM._instance) {
      OperationPageVM._instance = new OperationPageVM();
    }
    return OperationPageVM._instance;
  }

  // 获取当前音频并初始化数据
  public getRouteParam() {
    const params: RouteParams = getInstance().getParamByName(RouterMap.OPERATION)[0] as RouteParams;
    this.isOperation = params.isOperation;
    this.curAudio = this.myAudio.getAudioById(params.id);
    this.splitBtnIndex = 0;
    this.currentSpeed = 1;
    this.currentTone = 1;
    this.duration = 1;
    this.curTime = 0;
    this.fileName = '';
  }


  // 初始化播放器
  public initPlayer() {
    this.playUtil.onCompleted = this.onCompleted;
    this.playUtil.onPrepared = this.onPrepared;
    this.playUtil.onTimeUpdate = this.onTimeUpDate;
    this.playUtil.onSeekDone = this.onSeekDone;
    this.curTime = 0;
    this.playUtil.avPlayerUrlInit(this.curAudio.filePath);
  }

  // 播放音频
  public play() {
    this.controller.start();
    this.playUtil.avPlay();
    this.isPlaying = true;
  }

  // 暂停
  public pause() {
    this.playUtil.avPause();
    this.controller.stop();
    this.isPlaying = false;
  }

  // 实例销毁销毁临时文件
  public released() {
    this.playUtil.avReleased();
    if (this.isCanSave) {
      fs.unlinkSync(this.curAudio.filePath);
      fs.unlinkSync(this.curAudio.pcmPath);
    }
    this.isPlaying = false;
    this.isCanSave = false;
  }

  // 跳转指定时间
  public async seek(targetTime: number) {
    if (this.isPlaying) {
      this.playUtil.avSeek(targetTime);
      this.controller.seek(targetTime * 1000);
    } else {
      this.playUtil.avSeek(targetTime);
      this.controller.seek(targetTime * 1000);
      this.controller.start();
      this.isPlaying = true;
    }
  }

  // 截取音频
  public async toSplitAudio(loadingController: CustomDialogController) {
    this.splitSheetVisible = false;
    loadingController.open();
    if (this.splitBtnIndex === 0) {
      const outputPath = createFd(this.curAudio.format.toLowerCase()).filePath;
      await captureAudio(this.curAudio.filePath, outputPath, this.startTime, this.endTime - this.startTime);
      this.reset(outputPath);
      await this.handleTemporaryFile(outputPath);
      this.controller.reset();
      loadingController.close();
      promptAction.showToast({ message: '保留成功' });
    } else {
      //  删除中间片段需要先截取再合并
      // 准备两个路径保存截取的前后两个片段
      const outputPath1 = createFd(this.curAudio.format.toLowerCase()).filePath;
      const outputPath2 = createFd(this.curAudio.format.toLowerCase(), true).filePath;
      await captureAudio(this.curAudio.filePath, outputPath1, 0, this.startTime);
      await captureAudio(this.curAudio.filePath, outputPath2, this.endTime, this.duration - this.endTime);
      // 添加后缀区分，防止生成文件一致
      const outputPath3 = createFd(this.curAudio.format.toLowerCase(), true, '2').filePath;
      contactAudio(outputPath1, outputPath2, outputPath3, async (code: number) => {
        if (code === 0) {
          this.reset(outputPath3);
          await this.handleTemporaryFile(outputPath3);
          this.controller.reset();
          promptAction.showToast({ message: '删除成功' });
          fs.unlinkSync(outputPath1);
          fs.unlinkSync(outputPath2);
        } else {
          promptAction.showToast({ message: '操作失败' });
        }
        loadingController.close();
      });

    }
  }

  // 音频变速
  async changeAudioSpeed(loadingController: CustomDialogController) {
    const  targetDuration = this.duration / this.currentSpeed
    if (targetDuration > MAX_EDIT_DURATION){
      promptAction.showToast({ message: '当前最大支持变速到2小时!' });
      return
    }
    this.speedSheetVisible = false;
    loadingController.open();
    const outputPath = createFd(this.curAudio.format.toLowerCase()).filePath;
    const workerData: MultipleWorkerParm = {
      inputPath: this.curAudio.filePath,
      outputPath: outputPath,
      speed: this.currentSpeed,
      format: this.curAudio.format,
    };

    this.editWorker.postMessage(workerData);

    this.editWorker.onmessage = async (messageEvents) => {
      const code = messageEvents.data as number;
      if (code === 0) {
        this.reset(outputPath);
        await this.handleTemporaryFile(outputPath);
        this.controller.reset();
        promptAction.showToast({ message: '变速成功' });
      } else {
        promptAction.showToast({ message: '变速失败' });
      }
      loadingController.close();
    };
  }


  // 改变音调
  changeTone(loadingController: CustomDialogController) {
    this.toneSheetVisible = false;
    loadingController.open();
    const outputPath = createFd(this.curAudio.format.toLowerCase()).filePath;
    toneAudio(this.curAudio.filePath, outputPath, this.currentTone, this.curAudio.format, async (code: number) => {
      if (code === 0) {
        this.reset(outputPath);
        await this.handleTemporaryFile(outputPath);
        this.controller.reset();
        promptAction.showToast({ message: '变调成功' });
      } else {
        promptAction.showToast({ message: '变调失败' });
      }
      loadingController.close();
    });
  }


  // 重置播放器
  reset(newFilePath: string) {
    this.playUtil.avReset(newFilePath);
    this.isPlaying = false;
    this.startTime = 0;
    this.endTime = this.duration;
  }


  public async handleTemporaryFile(filePath: string) {
    // 删除上一步的临时文件
    if (this.isCanSave) {
      fs.unlinkSync(this.curAudio.filePath);
      fs.unlinkSync(this.curAudio.pcmPath);
    }
    // 保存当前的临时文件路径
    this.curAudio.filePath = filePath;
    const pcmPath = createFd('PCM').filePath;
    await extractToPCM(this.curAudio.filePath, pcmPath);
    this.curAudio.pcmPath = pcmPath;
    // 拥有可保存的文件
    this.isCanSave = true;
  }


  // 保存剪辑文件
  public saveAudio() {
    if (this.fileName) {
      this.myAudio.addAudio(new AudioInfo(util.generateRandomUUID(false), this.curAudio.filePath,
        this.fileName + '.' + this.curAudio.format.toLowerCase(), this.curAudio.format, this.curAudio.pcmPath));
      this.isCanSave = false;
      getInstance().pop();
    } else {
      promptAction.showToast({ message: '请输入文件名称' });
    }
  }

  // 准备完成的回调，在该周期获取音频时长
  private onPrepared = (duration: number) => {
    this.duration = duration;
    // 默认截取位置为视频长度
    this.endTime = duration;
  };
  // 播放完成的回调
  private onCompleted = () => {
    this.isPlaying = false;
    this.controller.reset();
    this.curTime = 0;
  };
  // 播放时间更新的回调
  private onTimeUpDate = (time: number) => {
    this.curTime = time;
  };
  // 跳转完成的回调
  private onSeekDone = (time: number) => {
    this.curTime = time;
  };
}