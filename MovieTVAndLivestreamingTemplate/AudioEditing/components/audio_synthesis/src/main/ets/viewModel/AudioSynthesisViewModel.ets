import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { MsgRes, TaskAbstract, WorkersController } from 'audio_worker';
import { FileUtil } from 'audio_common';

export class AudioSynthesisViewModel extends TaskAbstract {
  workerId: number = -1;
  audioFiles: string[] = [] // 待合成的音频文件路径列表
  outPath: string = '' // 音频合成输出路径
  logPath: string = '' // 音频处理过程中产生的进度文件路径
  taskStatus: boolean = false // 任务状态，true执行中，false未开始

  resultCallBack: (outPath: string) => void = (outPath: string) => {
  }

  // 开始任务
  onStart() {
    const workerId = this.workerId
    const deleteTempFile = () => {
      this.deleteTempFile()
    }
    const release = () => {
      this.release()
    }

    let callBack: ICallBack = {
      callBackResult(code: number) {
        if (code === 0) {
          WorkersController.noticeWorkerTaskEnd(workerId)
        } else {
          deleteTempFile()
          release()
        }
      }
    }

    // 构建 ffmpeg 合成命令
    const filesToMerge = this.audioFiles.slice(0, 5)
    const fileCount = filesToMerge.length

    // 动态构建输入文件参数
    const inputParams = filesToMerge.map(path => `-i "${path}"`).join(' ')

    // 构建 concat 滤镜参数
    const concatFilter = `concat=n=${fileCount}:v=0:a=1`

    // 根据输出文件扩展名确定编码参数
    const ext = this.outPath.substring(this.outPath.lastIndexOf('.')).toLowerCase()
    let codecParams = ''
    
    switch (ext) {
      case '.mp3':
        codecParams = '-c:a libmp3lame -b:a 128k'
        break
      case '.aac':
        codecParams = '-c:a aac -b:a 128k'
        break
      case '.m4a':
        codecParams = '-c:a aac -b:a 128k'
        break
      case '.wav':
        codecParams = '-c:a pcm_s16le'
        break
      default:
        codecParams = '-c:a libmp3lame -b:a 128k' // 默认使用 mp3
        break
    }

    // 完整的 ffmpeg 命令
    const cmd = `ffmpeg -y ${inputParams} -filter_complex "${concatFilter}" ${codecParams}` +
      ` "${this.outPath}" -progress ${this.logPath}`

    MP4Parser.ffmpegCmd(cmd, callBack)
  }

  // 实际取消执行的清理操作
  onCancel() {
    this.deleteTempFile()
    FileUtil.deleteFile(this.outPath)
    this.release()
  }

  onComplete() {
    this.deleteTempFile()
    this.resultCallBack(this.outPath)
    this.release()
  }

  deleteTempFile() {
    FileUtil.deleteFile(this.logPath)
  }

  onMessage(msgRes: MsgRes) {
    // 可以在这里处理进度消息
  }

  // 释放资源
  release() {
    this.taskStatus = false
    const tempWorkerId = this.workerId
    this.workerId = -1
    WorkersController.teminateWorker(tempWorkerId)
  }
}
