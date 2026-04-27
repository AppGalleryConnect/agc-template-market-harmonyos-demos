import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { TaskAbstract, WorkersController, MsgRes } from 'audio_worker';
import { FileUtil } from 'audio_common';
import { expect } from '@ohos/hypium';


export class AudioFormatVM extends TaskAbstract {
  workerId: number = -1;
  tempSourcePath: string = ''; // 临时源文件路径
  outPath: string = ''; // 输出文件路径
  logPath: string = ''; // 日志文件路径
  resultCallBack: (outPath: string) => void = (outPath: string) => {};

  // 开始任务
  onStart() {
    const workerId = this.workerId;
    const deleteTempFile = () => {
      this.deleteTempFile()
    }
    const release = () => {
      this.release()
    }
    let callBack: ICallBack = {
      callBackResult(code: number) {
        if (code === 0) {
          WorkersController.noticeWorkerTaskEnd(workerId);
        }else{
          deleteTempFile()
          release()
        }
        expect(0).assertEqual(code);
      }
    };


    
    // 构造ffmpeg命令：
    // -y: 覆盖输出文件
    // -i: 输入文件
    // -vn: 去除视频流
    // 注意：给路径添加双引号，防止路径中包含空格导致命令执行失败
    //ffmpeg -i input.xxx output.xxx
    const cmd = `ffmpeg -y -i "${this.tempSourcePath}" "${this.outPath}"`;
    
    MP4Parser.ffmpegCmd(cmd, callBack);
  }
  deleteTempFile() {
    FileUtil.deleteFile(this.logPath);
  }
  //实际取消执行的清理操作
  onCancel() {
    this.deleteTempFile();
    FileUtil.deleteFile(this.outPath);
    this.release();
  }

  onComplete() {
    this.resultCallBack(this.outPath);
    this.release();
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
