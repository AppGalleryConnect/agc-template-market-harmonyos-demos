import { ICallBack, MP4Parser } from '@ohos/mp4parser';
import { expect } from '@ohos/hypium';
import { FileUtil } from 'audio_common';
import { common } from '@kit.AbilityKit';
import { AudioFileMetadata } from '../util/MP4ParseUtil';

const TAG = 'MP4ParseUtil'


export interface StringCallBack {
  callBackResult: (code: string) => void
}


/*
 *path: 沙箱目录
 */
export function getMetaData(path: string, callBack: StringCallBack) {
  MP4Parser.getMetaData(path, callBack)
}

/*
 *context：上下文
 * path:文件沙箱目录
 * sampleRate：采样率
 * channelLayout：声道
 * callBack: 返回pcm文件沙箱路径
 */
export function changeToPcm(context: Context, path: string,
  callBackPCM: (pcmPath: string, channelLayout: number, sampleRate: number) => void, error: () => void) {

  getMetaData(path, {
    callBackResult: (res: string) => {
      if (!res) {
        error()
        return
      }

      const tempData = JSON.parse(res) as AudioFileMetadata
      const streams = tempData.streams

      let sampleRate = ''
      let channelLayout = 0
      for (let index = 0; index < streams.length; index++) {
        const stream = streams[index];
        if (stream.codec_type === 'audio') { //音频声道
          sampleRate = stream.sample_rate
          channelLayout = getChannelLayout(stream.channel_layout)
          break
        }
      }
      const fileUtil = new FileUtil(context as common.UIAbilityContext)
      let pcmDir = fileUtil.getAudioPcmDir()
      let prefixName = fileUtil.splitFilePath(path)[1]
      const pcmPath = pcmDir + prefixName + '.pcm';
      const logPath = pcmDir + prefixName + '.log';
      fileUtil.deleteFileByPath(pcmPath)
      fileUtil.deleteFileByPath(logPath)

      let callBack: ICallBack = {
        callBackResult(code: number) {
          if (code === 0) {
            let path = pcmDir + prefixName + '.pcm'
            callBackPCM(path, channelLayout, Number(sampleRate))
          } else {
            error()
          }

          expect(0).assertEqual(code)
        }
      }
      let cmd: string =
        `ffmpeg -i ${path} -ar ${sampleRate} -ac ${channelLayout} -f f32le ${pcmPath} -progress ${logPath}`
      MP4Parser.ffmpegCmd(cmd, callBack)
    }
  })


}

function getChannelLayout(ac: string) {
  let tempAc = 1 //默认单声道
  switch (ac) {
    case 'mono':
      tempAc = 1
      break;
    case 'stereo':
      tempAc = 2
      break;
    case '5.1':
      tempAc = 6
      break;
    case '7.1':
      tempAc = 8
      break;
    default:
      break;
  }
  return tempAc
}