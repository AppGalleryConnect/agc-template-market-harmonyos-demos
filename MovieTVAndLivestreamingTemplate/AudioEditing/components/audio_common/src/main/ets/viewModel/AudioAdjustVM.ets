import { util } from '@kit.ArkTS';
import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { promptAction, PromptAction } from '@kit.ArkUI';
import { ComponentContent } from '@kit.ArkUI';
import { MsgRes, TaskAbstract, WorkersController } from 'audio_worker';
import { common } from '@kit.AbilityKit';
import { ProgressDialogInfo } from '../model/ProgressDialogModel';
import { ProgressDialogVM } from './ProgressDialogVM';
import { FileUtil } from '../util/FileUtil';
import { PCMPlayer } from '../util/PCMPlay';

@ObservedV2
export class AudioAdjustVM extends TaskAbstract {
  @Trace speedValue: number = 0
  @Trace audioOutputPath: string = '';
  @Trace audioLogPath: string = '';
  @Trace nextAction: 'onComplete' | 'onCancel' = 'onComplete'
  @Trace saveResult: boolean = false
  @Trace exportStatus: string = ''
  @Trace dialogState: ProgressDialogInfo = new ProgressDialogInfo(); //弹框双向绑定数据
  @Trace progressDialogVM: ProgressDialogVM | null = null
  @Trace fileUtil: FileUtil | null = null
  // 导出弹框
  @Trace contentNode: ComponentContent<object> | null = null;
  @Trace promptActionUI: PromptAction | null = null
  @Trace workId: number = -1
  @Trace workersController: WorkersController = new WorkersController()
  @Trace context: common.UIAbilityContext | null = null
  @Trace targetFilePath: string = ''
  @Trace sampleRate: number = 0 //采样率
  @Trace sourcePath: string = ''
  @Trace duration: number = 0
  @Trace pageType: string = ''
  @Trace pcmPlayer?: PCMPlayer
  @Trace format: string = ''
  saveWork: (outPath: string) => void = (outPath: string) => {
  }
  callBack: ICallBack = {
    callBackResult: (code: number) => {

      if (this.exportStatus !== 'cancel') {
        this.saveResult = true
      }
      this.nextAction = 'onComplete'
      WorkersController.noticeWorkerTaskEnd(this.workId) //不管成功失败进入到完成状态调用onComplete方法
      setTimeout(() => {
        this.saveResult = false
      }, 3000)
      if (code !== 0) {
        this.exportStatus = 'unFinish'
        this.closeDialog()
        return
      }
      this.progressDialogVM?.completeDialog()
      setTimeout(() => {
        if (this.exportStatus === 'cancel') {
          return
        }
        this.exportStatus = 'finish'
        this.saveWork(this.audioOutputPath)
      }, 300)

    }
  };

  /*
     * 任务启动回调，
     * */
  onStart() {
    if (this.pageType === 'AudioAdjustTone') {
      this.saveAudioAdjustTone()
    } else if (this.pageType === 'AudioNoiseReduction') {
      this.saveAudioNoiseReduction()
    } else {
      this.saveAudioAdjustSpeed()
    }

  };

  /*
   * 任务取消回调，
   * 任务结束后会自动执行，前提是先workersController的setNextAtion(),并告诉worker线程任务结束了，
   * */
  onCancel() {

  }

  /*
   * 任务完成回调，
   * 前提是告诉worker线程任务结束了
   * */
  onComplete() {
    WorkersController.teminateWorker(this.workId)
    this.fileUtil?.deleteFileByPath(this.targetFilePath) //完成时删除已复制的文件
    if (this.exportStatus === 'cancel') { //点击取消删除导出的文件
      this.fileUtil?.deleteFileByPath(this.audioOutputPath)
    }

  }


  //消息回调
  onMessage(msgRes: MsgRes) {

  }

  closeDialog() {

    this.progressDialogVM?.closeDialog()
  }

  save(text: string) {

    this.exportStatus = ''
    this.saveResult = false
    this.targetFilePath = this.fileUtil!.copyFilePath(this.sourcePath)
    this.audioLogPath = this.fileUtil!.getLogOutPath()
    this.audioOutputPath = this.fileUtil?.getAudioOutDir() + this.fileUtil!.generateUniquePathname(text)
    this.dialogState.logoFilePath = this.audioLogPath
    this.dialogState.completeValue = 0
    this.progressDialogVM?.openDialog(this.dialogState)
    WorkersController.startTask(this.workId)
  }

  private saveAudioAdjustTone(): void {
    //rate倍数 asetrate调节后的值,atempo（与rate）取反处理时长被拉长或缩短  取值极限asetrate倍数取值 0.5-17   atempo值是0.5-94 （综合取值 asetrate  0.5-2）
    let rate = (this.speedValue + this.sampleRate) / this.sampleRate
    let asetrate = this.speedValue + this.sampleRate
    let atempo = 1 / rate
    let cmd =
      'ffmpeg -y -i ' + this.targetFilePath + ' -filter:a "asetrate=' + asetrate + ',atempo=' + atempo + '" ' +
      this.audioOutputPath
    try {
      MP4Parser.ffmpegCmd(util.format(cmd),
        this.callBack);
    } catch (e) {

    }


  }

  private saveAudioNoiseReduction(): void {
    // nf分贝(db取值-80至-20） 过滤噪音强度有低到高（-80过滤微弱噪音 -20过滤噪较强音）    nr降噪强度（模型1至97）
    let cmd =
      'ffmpeg  -y -i ' + this.targetFilePath + ' -filter:a "afftdn=nf=-20:nr=' + this.speedValue + '" ' +
      this.audioOutputPath
    try {
      MP4Parser.ffmpegCmd(util.format(cmd),
        this.callBack);
    } catch (e) {

    }


  }

  private saveAudioAdjustSpeed(): void {

    let cmd =
      'ffmpeg -y  -i ' + this.targetFilePath + ' -filter:a "atempo=' + this.speedValue + '" ' +
      this.audioOutputPath
    try {
      MP4Parser.ffmpegCmd(util.format(cmd),
        this.callBack);
    } catch (e) {

    }


  }
}
