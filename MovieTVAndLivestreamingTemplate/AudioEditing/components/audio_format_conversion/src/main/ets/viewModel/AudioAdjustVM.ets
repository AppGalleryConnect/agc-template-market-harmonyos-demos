import { MusicService } from '../common/MusicService';
import { getMusicModel, MusicModel } from './MusicModelVM';
import { FileUtil, ProgressDialogInfo, SongItem } from 'audio_common';
import { util, } from '@kit.ArkTS';
import { exportAudio } from '../model/AudioAdjustModel';

import { BusinessError } from '@kit.BasicServicesKit';
import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { AppStorageV2, ComponentContent, PromptAction } from '@kit.ArkUI';
import { ExportStateVM } from 'audio_common';
import { MsgRes, TaskAbstract, WorkersController } from 'audio_worker';

@ObservedV2
export class AudioAdjustVM extends TaskAbstract {
  @Trace player?: MusicService;
  @Trace speedValue: number = 1
  @Trace splitAudioOutputPath: string = '';
  @Trace audioOutputPath: string = '';
  @Trace audioLogPath: string = '';
  @Trace nextAction: 'onComplete' | 'onCancel' = 'onComplete'
  @Trace loading: boolean = false;
  @Trace saveResult: boolean = false
  @Trace exportStatus: string = ''
  @Trace dialogState: ProgressDialogInfo = new ProgressDialogInfo(); //弹框双向绑定数据
  @Trace exportStateInfo: ExportStateVM = AppStorageV2.connect(ExportStateVM, () => new ExportStateVM())!;
  @Trace exportParams: exportAudio = {
    exportType: '',
  }
  @Trace songInfo: SongItem = {
    src: '',
    targetFilePath: '',
    label: '',
    fileName: ''
  }
  @Trace musicModel: MusicModel = getMusicModel();
  @Trace hasCancel: boolean = false
  @Trace fileUtil: FileUtil | null = null
  // 导出弹框
  @Trace contentNode: ComponentContent<object> | null = null;
  @Trace promptActionUI: PromptAction | null = null
  @Trace workId: number = -1
  @Trace workersController: WorkersController = new WorkersController()
  callBack: ICallBack = {
    callBackResult: (code: number) => {
      this.saveResult = true
      this.nextAction = 'onComplete'
      WorkersController.noticeWorkerTaskEnd(this.workId)
      if (code !== 0) {
        this.closeDialog()
        return
      }
      setTimeout(() => {
        if (this.exportStatus === 'cancel') {
          return
        }
        this.exportStatus = 'finish'
      }, 300)

    }
  };

  /*
     * 任务启动回调，
     * */
  onStart() {
    this.saveAudioFormatConVersion()
  };

  /*
   * 任务取消回调，
   * 任务结束后会自动执行，前提是先workersController的setNextAtion(),并告诉worker线程任务结束了，
   * */
  onCancel() {
    WorkersController.teminateWorker(this.workId)
  }

  /*
   * 任务完成回调，
   * 前提是告诉worker线程任务结束了
   * */
  onComplete() {
    WorkersController.teminateWorker(this.workId)
    if (this.hasCancel) {
      this.fileUtil?.deleteFileByPath(this.audioLogPath)
      this.fileUtil?.deleteFileByPath(this.splitAudioOutputPath)
    }
  }

  //消息回调
  onMessage(msgRes: MsgRes) {

  }


  closeDialog() {
    this.dialogState.completeValue = 0
    this.promptActionUI?.closeCustomDialog(this.contentNode)
      .then(() => {

      })
      .catch((error: BusinessError) => {

      })
  }


  private saveAudioFormatConVersion(): void {
    let cmd =
      'ffmpeg -y -i ' + this.songInfo.targetFilePath + ' -af "afreqshift=freq=' + this.speedValue + '" ' +
      this.audioOutputPath + ' -progress ' + this.audioLogPath
    try {
      MP4Parser.ffmpegCmd(util.format(cmd),
        this.callBack);
    } catch (e) {

    }

  }
}
