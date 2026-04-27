import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { MsgRes, TaskAbstract, WorkersController } from 'audio_worker';
import { expect } from '@ohos/hypium';
import { FileUtil, ProgressDialogInfo, ProgressDialogVM } from 'audio_common';

const TAG = 'AudioEditViewModel'

export class AudioEditViewModel extends TaskAbstract {
  workerId: number = -1;
  startTime: string = ''; //剪裁开始时间
  endTime: string = ''; //剪裁结束时间
  tempSourcePath: string = '' //音频操作的临时文件路径
  outPath: string = '' //音频处理输出路径
  logPath: string = '' //音频处理过程中产生的进度文件路径
  musicTitle: string = '' //音频资源名称，解决中文名称时与存储名称不一致的问题

  taskStatus: boolean = false //任务状态，true执行中，false未开始

  dialogState: ProgressDialogInfo = new ProgressDialogInfo()
  progressDialogVM: ProgressDialogVM | undefined = undefined
  resultCallBack: (outPath: string) => void = (outPath: string) => {
  }

  //开始任务
  onStart() {
    const workerId = this.workerId
    const deleteTmepFile = () => {
      this.deleteTmepFile()
    }
    const release = () => {
      this.release()
    }
    let callBack: ICallBack = {
      callBackResult(code: number) {
        if (code === 0) {
          WorkersController.noticeWorkerTaskEnd(workerId)
        } else {
          deleteTmepFile()
          release()
        }

        expect(0).assertEqual(code)
      }
    }
    const cmd =
      `ffmpeg -y -i ${this.tempSourcePath} -vn -acodec copy -ss ${this.startTime}` +
        ` -to ${this.endTime} ${this.outPath} -progress ${this.logPath}`


    MP4Parser.ffmpegCmd(cmd, callBack)
  }

  //实际取消执行的清理操作
  onCancel() {
    this.deleteTmepFile();
    FileUtil.deleteFile(this.outPath);
    this.release();
    this.progressDialogVM?.toast('取消成功')
  }

  onComplete() {
    this.deleteTmepFile();
    this.resultCallBack(this.outPath);
    this.release();
    this.progressDialogVM?.closeDialog()
  }

  deleteTmepFile() {
    FileUtil.deleteFile(this.tempSourcePath);
    FileUtil.deleteFile(this.logPath);
  }

  onMessage(msgRes: MsgRes) {

  }

  //释放资源
  release() {
    this.taskStatus = false;
    const tempWorkerId = this.workerId;
    this.workerId = -1;
    WorkersController.teminateWorker(tempWorkerId)
  }

  /*
   * 设置剪裁起始时间
   * startTime:number秒
   */
  setStartTime(startTime: number) {
    this.startTime = this.translateSecond(startTime)
  }

  /*
   * 设置剪裁起始时间
   * endTime:秒
   */
  setEndTime(endTime: number) {
    this.endTime = this.translateSecond(endTime)
  }

  /*
   * 时间转换，将单位为秒的时间转换为HH:MM:SS
   * time:number
   */
  translateSecond(time: number) {
    const hours: number = Math.floor(time / 3600);
    const remaining = time % 3600;
    const minutes: number = Math.floor(remaining / 60);
    const seconds: number = Math.floor(remaining % 60);
    // 补零函数
    const pad = (num: number) => num < 10 ? `0${num}` : `${num}`;
    return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
  }

  /*
   * 打开弹窗
   */
  openProgressDialog() {
    this.dialogState.progressTitle = '正在剪裁中...'
    this.dialogState.fileTime = 60000
    this.dialogState.cancel = () => {
      // 取消任务
      this.cancekTask()
      this.progressDialogVM?.closeDialog()
    };
    this.progressDialogVM?.openDialog(this.dialogState)
  }
}