import { Type } from '@kit.ArkUI';


export interface TabItem {
  label: string,
  icon: ResourceStr,
  url: string,
  nextRoute: string
}


// 文件信息
export interface FileInfo {
  filePath: string,
  fileName: string
}


// 录制状态
export enum RecordStatus {
  //  等待录制
  PENDING = '0',
  //  进行中
  PROGRESS = '1',
  //  结束
  OFF = '2'
}


// 保存类型
export enum SaveType {
  ONLY_SAVE = '0',
  EDIT_SAVE = '1',
  CONVERT_SAVE = '2'
}


// 音频信息
@ObservedV2
export class AudioInfo {
  @Trace id: string = '';
  // 沙箱路径
  @Trace filePath: string = '';
  // 文件名
  @Trace fileName: string = '';
  // 格式
  @Trace format: string = 'MP3';
  // 对应pcm文件路径,用于语音识别和振幅图绘制
  @Trace pcmPath: string = '';

  constructor(id: string = '', filePath: string = '', fileName: string = '', format: string = 'MP3',
    pcmPath: string = '') {
    this.id = id;
    this.filePath = filePath;
    this.fileName = fileName;
    this.format = format;
    this.pcmPath = pcmPath;
  }
}


// 我的音频信息
@ObservedV2
export class MyAudio {
  @Type(AudioInfo)
  @Trace list: AudioInfo[] = [];

  constructor(list: AudioInfo[] = []) {
    this.list = list;
  }

  addAudio(data: AudioInfo) {
    // 判断list中重名的元素有几个
    let count = this.list.filter((item) => item.fileName === data.fileName).length;
    if (count > 0) {
      let fileName = `${data.fileName.split('.')[0]}(${count + 1}).${data.format.toLowerCase()}`;
      // 重名后加后缀
      while (this.list.some((item) => item.fileName === fileName)) {
        count++;
        fileName = `${data.fileName.split('.')[0]}(${count + 1}).${data.format.toLowerCase()}`;
      }
      data.fileName = fileName;
    }
    this.list.push(data);
  }

  removeAudio(id: string) {
    const removeAudio: AudioInfo = this.list.filter((item) => item.id === id)[0];
    this.list = this.list.filter((item) => item.id !== id);
    return removeAudio;
  }

  renameAudio(id: string, name: string) {
    this.list = this.list.map((item) => {
      if (item.id === id) {
        const fileName = `${name}.${item.format.toLowerCase()}`;
        const audio: AudioInfo = new AudioInfo(item.id, item.filePath, fileName, item.format, item.pcmPath);
        return audio;
      } else {
        return item;
      }
    });
  }

  public getAudioById(id: string) {
    const audio: AudioInfo = this.list.find((item) => item.id === id)!;
    const res = new AudioInfo(audio.id, audio.filePath, audio.fileName, audio.format, audio.pcmPath);
    return res;
  }
}


// 振幅数据
@ObservedV2
export class MyAmplitude {
  @Trace amplitude: number = 0;

  constructor(amplitude: number = 0) {
    this.amplitude = amplitude;
  }
}


// 音频波纹组件控制器
export class AudioWaveController {
  start = () => {

  };
  stop = () => {

  };
  reset = () => {

  };
  seek = (duration: number) => {

  };
}


export interface RouteParams {
  id: string,
  isOperation: boolean
}


// worker参数
export interface SaveWorkerParm {
  filePath: string,
  pcmPath: string
}


export interface MultipleWorkerParm{
  inputPath:string,
  outputPath:string,
  speed:number,
  format:string
}


export enum SaveMessageType {
  SUCCESS = '0',
  ERROR = '1'
}