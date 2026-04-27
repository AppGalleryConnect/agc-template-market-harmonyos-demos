import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { FormatUtil } from './FormatUtil';
import { FileInfo } from '../model/Index';
import { Logger } from '../util/Logger';

function commonCmd(cmd: string, callBack: Function) {
  const callback: ICallBack = {
    callBackResult: (code: number) => {
      callBack(code);
    },
  };
  try {
    MP4Parser.ffmpegCmd(cmd, callback);
  } catch (e) {
    Logger.error(JSON.stringify(e));
  }

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


// mp3 wav aac m4a 格式互转
export async function forMatAudio(inputFilePath: string, outputFilePath: string, callBack: Function) {
  const cmd = `ffmpeg -i ${inputFilePath} ${outputFilePath}`;
  commonCmd(cmd, callBack);
}


// 根据传入文件类型，生成一个沙箱中的路径 tag增加标志防止文件重复
export function createFd(fileType: string, isAddTag: boolean = false, tag: string = ''): FileInfo {
  const context: Context = AppStorage.get('simple_recorder_context') as Context;
  const fileName: string = isAddTag ? `转换_${FormatUtil.formatFullDate(new Date())}_录音${tag}.${fileType}` :
    `${FormatUtil.formatFullDate(new Date())}_录音.${fileType}`;
  const path: string = context.filesDir + `/${fileName}`; // 文件沙箱路径，文件后缀名应与封装格式对应
  const fileInfo: FileInfo = {
    filePath: path,
    fileName: fileName,
  };
  return fileInfo;
}


// 截取文件 startTime 截取开始的位置单位s, duration 向后截取多少s
export function captureAudio(inputFilePath: string, outputFilePath: string, startTime: number, duration: number) {
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
    const cmd = `ffmpeg -i ${inputFilePath} -ss ${startTime} -t ${duration} -vn -acodec copy ${outputFilePath}`;
    MP4Parser.ffmpegCmd(cmd, callback);
  });
}


// 音频变速 支持MP3、WAV、AAC、M4A
export function multipleAudio(inputFilePath: string, outputFilePath: string, speed: number, format: string,
  callBack: Function) {
  let cmd = '';
  switch (format) {
    case 'MP3':
      cmd = `ffmpeg -i ${inputFilePath} -vn -sn -filter:a "atempo=${speed}" -c:a libmp3lame -b:a 128k -compression_level 9 ${outputFilePath}`;
      break;
    case 'WAV':
      cmd = `ffmpeg -i ${inputFilePath} -filter:a "atempo=${speed}" -acodec pcm_s16le -ar 44100 ${outputFilePath}`;
      break;
    case 'AAC':
      cmd = `ffmpeg -i ${inputFilePath} -filter:a "atempo=${speed}" -acodec aac -b:a 128k ${outputFilePath}`;
      break;
    default:
      cmd = `ffmpeg -i ${inputFilePath} -filter:a "atempo=${speed}" -c:a aac -b:a 128k ${outputFilePath}`;
      break;
  }
  commonCmd(cmd, callBack);
}


// 调节音调  shift 音调变化，大于1为升 小于1为降
export function toneAudio(inputFilePath: string, outputFilePath: string, shift: number, format: string,
  callBack: Function) {
  let cmd = '';
  if (format === 'WAV') {
    cmd =
      `ffmpeg -i ${inputFilePath} -af "asetrate=48000*${shift},atempo=1/${shift}" -acodec pcm_s16le -ar 48000  ${outputFilePath}`;
  } else {
    cmd = `ffmpeg -i ${inputFilePath} -af "asetrate=48000*${shift},atempo=1/${shift}" ${outputFilePath}`;
  }

  commonCmd(cmd, callBack);
}


// 合并音频文件
export function contactAudio(inputFilePath1: string, inputFilePath2: string, outputFilePath: string,
  callBack: Function) {
  const cmd = `ffmpeg -i "concat:${inputFilePath1}|${inputFilePath2}" -vn -acodec copy ${outputFilePath}`;
  commonCmd(cmd, callBack);
}