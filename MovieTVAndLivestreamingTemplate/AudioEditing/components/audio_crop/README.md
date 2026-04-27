# 音频裁剪组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了音频裁剪功能，支持可视化波形展示、精确时间选择、实时预览播放等功能。

<img src='screenshots/audiocrop.jpg' style='width:250px;object-fit:contain'>


## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.1(13)及以上

### 权限

- 无

### 调试
- 本组件不支持模拟器调试，请使用真机进行调试。

## 使用

1. 安装组件

   如果是在 DevEco Studio 使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的 xxx 目录下。

   b. 在项目根目录 build-profile.json5 添加 audio_worker、audio_common、audio_crop 模块。

    ```json5
    // 在项目根目录 build-profile.json5 填写 audio_worker、audio_common、audio_crop 路径。其中 xxx 为组件存放的目录名
    "modules": [
      {
        "name": "audio_crop",
        "srcPath": "./xxx/audio_crop"
      },
      {
        "name": "audio_common",
        "srcPath": "./xxx/audio_common",
      },
      {
      "name": "audio_worker",
      "srcPath": "./xxx/audio_worker",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [
            "default"
          ]
        }
      ]
     }
    ]
    ```

   c. 在项目根目录 oh-package.json5 中添加依赖。

    ```json5
    // xxx 为组件存放的目录名称
    {
      "dependencies": {
        "audio_common": "file:./XXX/audio_common",
        "audio_crop": "file:./xxx/audio_crop",
      }
    }
    ```

2. 在项目entry模块的src/main/ets/entryability/EntryAbility.ets文件中，给吸色功能初始化Context（必须）

   ```typescript
    
   import { CommonContext } from 'audio_common';
   
   // 初始化上下文
   onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
      CommonContext.setContext(this.context)
   }
   ```

3. 引入组件。

    ```typescript
    import { AudioCropPage } from 'audio_crop';
    ```

4. 调用组件，详细参数配置说明参见[API参考](#API参考)。


## API参考

### 接口

AudioCropPage(options: [AudioCropPageOptions](#AudioCropPageOptions对象说明))

音频裁剪页面组件，包含完整的音频裁剪功能界面。

### AudioCropPageOptions对象说明

| 参数名            | 类型                                        | 是否必填 | 说明              |
|----------------|-------------------------------------------|------|-----------------|
| musicTitle     | string                                    | 是    | 音频文件标题          |
| pcmPath        | string                                    | 是    | 输出PCM文件的沙箱路径    |
| sourcePath     | string                                    | 是    | 源音频文件沙箱路径       |
| channelLayout  | number                                    | 是    | 声道数量            |
| sampleRate     | number                                    | 是    | 采样率             |
| duration       | number                                    | 是    | 音频时长（毫秒）        |
| sampleFormat   | number                                    | 是    | 采样格式            |
| resultCallBack | (outPath: string) => void                 | 是    | 裁剪完成回调，返回输出文件路径 |
| backHandle     | () => void                                | 是    | 返回按钮回调          |

## 示例代码

```
import { AudioCropPage } from 'audio_crop'
import { audio } from '@kit.AudioKit'
import { FileUtil, ICallBack, MP4Parser } from 'audio_common'
import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { picker } from '@kit.CoreFileKit'

interface AudioFileMetadata {
  streams: AudioStream[]
  format: AudioFormatInfo
}

interface AudioStream {
  codec_type: 'audio' | 'video' | 'subtitle'
  sample_rate: string
  channel_layout: string
}

interface AudioFormatInfo {
  duration: string
  format_name: string
}

interface StringCallBack {
  callBackResult: (code: string) => void
}

function getChannelLayout(ac: string): number {
  switch (ac) {
    case 'mono':
      return 1
    case 'stereo':
      return 2
    case '5.1':
      return 6
    case '7.1':
      return 8
    default:
      return 1
  }
}

function getMetaData(path: string, callBack: StringCallBack): void {
  MP4Parser.getMetaData(path, callBack)
}

function changeToPcm(
  context: Context,
  path: string,
  callBackPCM: (pcmPath: string, channelLayout: number, sampleRate: number) => void,
  error: () => void
): void {
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
        const stream = streams[index]
        if (stream.codec_type === 'audio') {
          sampleRate = stream.sample_rate
          channelLayout = getChannelLayout(stream.channel_layout)
          break
        }
      }

      if (!sampleRate || channelLayout === 0) {
        error()
        return
      }

      const fileUtil = new FileUtil(context as common.UIAbilityContext)
      const pcmDir = fileUtil.getAudioPcmDir()
      const prefixName = fileUtil.splitFilePath(path)[1]
      const pcmPath = pcmDir + prefixName + '.pcm'
      const logPath = pcmDir + prefixName + '.log'
      fileUtil.deleteFileByPath(pcmPath)
      fileUtil.deleteFileByPath(logPath)

      const callBack: ICallBack = {
        callBackResult(code: number) {
          if (code === 0) {
            callBackPCM(pcmPath, channelLayout, Number(sampleRate))
          } else {
            error()
          }
        }
      }
      const ffmpegCmd =
        `ffmpeg -i ${path} -ar ${sampleRate} -ac ${channelLayout} -f f32le ${pcmPath} -progress ${logPath}`
      MP4Parser.ffmpegCmd(ffmpegCmd, callBack)
    }
  })
}

@Entry
@Component
struct AudioAdjustSpeedPage {
  @State pcmPath: string = ''
  @State sourcePath: string = ''
  @State channelLayout: number = 0
  @State sampleRate: number = 0
  @State duration: number = 0
  @State musicTitle: string = ''
  @State format: string = ''
  @State sampleFormat: number = audio.AudioSampleFormat.SAMPLE_FORMAT_F32LE
  @State isLoading: boolean = true
  @State isReady: boolean = false
  private dialogController: CustomDialogController | null = null
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    this.selectAudioFile()
  }

  selectAudioFile(): void {
    let audioSelectOptions = new picker.AudioSelectOptions();
    let audioPicker = new picker.AudioViewPicker(this.context);
    // 配置单选参数（关键步骤）
    audioSelectOptions.maxSelectNumber = 1; // 单选限制为1个文件
    audioPicker.select(audioSelectOptions).then(async (audioSelectResult: Array<string>) => {
      if (!audioSelectResult || audioSelectResult.length === 0) {
        promptAction.showToast({ message: '未选择音频文件' })
        return
      }
      const uri = audioSelectResult[0]
      try {
        const fileUtil = new FileUtil(this.context)
        const format = fileUtil.splitFilePath(uri)[2]
        const fileName = decodeURIComponent(fileUtil.splitFilePath(uri)[1]).replace(/\s+/g, '')
        const cacheDir = fileUtil.getAudioCacheDir()
        const targetPath = cacheDir + fileName + '.' + format
        await FileUtil.copyFileToDestPath(uri, targetPath)
        this.getAudioMetadata(targetPath, fileName + '.' + format, format)
      } catch (err) {
        promptAction.showToast({ message: '处理音频文件失败' })
      }
    })
  }

  getAudioMetadata(filePath: string, fileName: string, format: string): void {
    getMetaData(filePath, {
      callBackResult: (res: string) => {
        if (!res) {
          promptAction.showToast({ message: '获取音频信息失败' })
          return
        }

        try {
          const tempData = JSON.parse(res) as AudioFileMetadata
          const formatInfo = tempData.format
          const duration = formatInfo.duration ? Math.floor(parseFloat(formatInfo.duration) * 1000) : 0
          this.convertToPcm(filePath, fileName, duration, format)
        } catch (err) {
          promptAction.showToast({ message: '解析音频信息失败' })
        }
      }
    })
  }

  convertToPcm(filePath: string, fileName: string, duration: number, format: string): void {
    const callBack = (pcmPath: string, channelLayout: number, sampleRate: number) => {
      this.pcmPath = pcmPath
      this.sourcePath = filePath
      this.channelLayout = channelLayout
      this.sampleRate = sampleRate
      this.duration = duration
      this.musicTitle = fileName
      this.format = format
      this.isLoading = false
      this.isReady = true
    }

    const errorBack = () => {
      promptAction.showToast({ message: '音频转换失败' })
    }

    changeToPcm(this.context, filePath, callBack, errorBack)
  }

  showSaveSuccessDialog(filePath: string): void {
    const fileName = filePath.substring(filePath.lastIndexOf('/') + 1)
    const displayPath = `文件已保存\n路径: ${filePath}\n文件名: ${fileName}`

    this.dialogController = new CustomDialogController({
      builder: SaveSuccessDialog({
        filePath: displayPath,
        onConfirm: () => {
          this.dialogController?.close()
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    })
    this.dialogController.open()
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#01FCEA')

          Text('正在处理音频文件...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#0A0D1E')
      } else if (this.isReady) {
        AudioCropPage({
          musicTitle: this.musicTitle,
          pcmPath: this.pcmPath,
          sourcePath: this.sourcePath,
          channelLayout: this.channelLayout,
          sampleRate: this.sampleRate,
          duration: this.duration,
          sampleFormat: this.sampleFormat,
          backHandle: () => {
          },
          resultCallBack: (outPath: string) => {
            this.showSaveSuccessDialog(outPath)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@CustomDialog
struct SaveSuccessDialog {
  controller?: CustomDialogController
  filePath: string = ''
  onConfirm: () => void = () => {
  }

  build() {
    Column() {
      Image($r('sys.media.ohos_ic_public_ok'))
        .width(48)
        .height(48)
        .fillColor('#00C853')
        .margin({ bottom: 16 })

      Text('保存成功')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      Text(this.filePath)
        .fontSize(12)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })
        .width('100%')
        .maxLines(5)

      Button('确定')
        .width('100%')
        .height(40)
        .backgroundColor('#01FCEA')
        .fontColor('#000000')
        .onClick(() => {
          this.onConfirm()
        })
    }
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('85%')
  }
}
```