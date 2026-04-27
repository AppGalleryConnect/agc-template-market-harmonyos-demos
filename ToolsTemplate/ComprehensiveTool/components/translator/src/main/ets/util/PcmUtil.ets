import { MP4Parser } from '@ohos/mp4parser';
import { FileInfo } from '../model/Audio';
import { FormatUtil } from './FormatUtil';
import fs from '@ohos.file.fs'
import { TranLogger } from './TranLogger';
import { contextUtil } from './ContextUtil';
import { common } from '@kit.AbilityKit';

interface ICallBack {
  callBackResult: (code: number) => void
}

// 根据传入文件类型，生成一个沙箱中的路径 tag增加标志防止文件重复
export function createFd(fileType: string, isAddTag: boolean = false, tag: string = ''): FileInfo {
  const context: Context = contextUtil.getContext() as common.UIAbilityContext
  const fileName: string = isAddTag ? `转换_${FormatUtil.formatFullDate(new Date())}_录音${tag}.${fileType}` :
    `${FormatUtil.formatFullDate(new Date())}_录音.${fileType}`;
  const path: string = context.filesDir + `/${fileName}`; // 文件沙箱路径，文件后缀名应与封装格式对应
  const fileInfo: FileInfo = {
    filePath: path,
    fileName: fileName,
  };
  return fileInfo;
}

// 将录音文件复制一份
export function copyFile(path: string) {
  const context: Context = contextUtil.getContext() as common.UIAbilityContext
  let file: fs.File | null = null;
  const filePath = context.filesDir + '/temp.mp3';
  file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
  try {
    fs.copyFileSync(path, filePath)
  } catch (err) {
    TranLogger.error(`Failed to copy. Code: ${err.code}, message: ${err.message}`);
  } finally {
    if (file) {
      fs.closeSync(file)
    }
  }
  return filePath
}

// 转化为PCM格式音频
export async function extractToPCM(inputFilePath: string, outputFilePath: string) {
  return new Promise<void>((resolve, reject) => {
    const callback: ICallBack = {
      callBackResult: (code: number) => {
        if (code === 0) {
          resolve();
        } else {
          reject();
        }
      },
    };
    const cmd = `ffmpeg -i ${inputFilePath} -vn -acodec pcm_s16le -ar 16000 -ac 1 -f s16le ${outputFilePath}`;
    MP4Parser.ffmpegCmd(cmd, callback);
  });
}
