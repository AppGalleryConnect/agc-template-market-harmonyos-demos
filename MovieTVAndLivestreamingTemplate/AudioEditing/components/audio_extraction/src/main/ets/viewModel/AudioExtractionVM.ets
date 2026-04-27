import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { MsgRes, TaskAbstract, WorkersController } from 'audio_worker';
import { FileUtil } from 'audio_common';

const TAG = 'AudioExtractionViewModel';

export class AudioExtractionVM extends TaskAbstract {
  workerId: number = -1;
  tempSourcePath: string = ''; // 临时源文件路径
  outPath: string = ''; // 输出文件路径
  logPath: string = ''; // 日志文件路径
  resultCallBack: (outPath: string) => void = (outPath: string) => {
  };
  isCancelled: boolean = false; // 标记是否已取消

  // 开始任务
  onStart() {
    const workerId = this.workerId;
    let callBack: ICallBack = {
      callBackResult(code: number) {
        WorkersController.noticeWorkerTaskEnd(workerId);

        if (code !== 0) {
        }
      }
    };

    const cmd = `ffmpeg -y -i "${this.tempSourcePath}" -vn "${this.outPath}" -progress "${this.logPath}"`;
    MP4Parser.ffmpegCmd(cmd, callBack);
  }

  onCancel() {
    this.isCancelled = true;
  }

  onComplete() {
    if (this.isCancelled) {
      this.deleteTempFile();
      FileUtil.deleteFile(this.outPath);
      this.release();
      return;
    }

    if (this.workerId === -1) {
      return;
    }
    this.deleteTempFile();
    this.resultCallBack(this.outPath);
  }

  deleteTempFile() {
    FileUtil.deleteFile(this.tempSourcePath);
    FileUtil.deleteFile(this.logPath);
  }

  onMessage(msgRes: MsgRes) {
  }

  // 释放资源
  release() {
    const tempWorkerId = this.workerId;
    this.workerId = -1;
    WorkersController.teminateWorker(tempWorkerId);
  }
}
