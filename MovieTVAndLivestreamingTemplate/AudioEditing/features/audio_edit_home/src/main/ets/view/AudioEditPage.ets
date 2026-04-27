/**
 * @usage: 音频剪辑页面,用户从SelectPage选择音频后跳转到此页面进行音频剪辑操作。
 * 提供可视化波形显示和精确裁剪功能,支持拖动时间轴选择起止时间点。
 * 剪辑成功后自动保存到作品列表并切换到作品Tab页展示。
 * @layout: 页面采用NavDestination包裹Column垂直布局,顶部为状态栏占位,
 * 下方渲染AudioCropPage组件进行实际的剪辑操作。
 * @constraints: 必须从SelectPage传递音频文件信息(pcm路径、源文件路径、采样率、声道数、时长等)。
 * 剪辑成功后自动保存到作品列表。返回时弹出未保存更改提示对话框。
 * @domain: 音频编辑
 * @zhName: 音频剪辑页面
 * @fileType: page
 * @isGen: true
 * @subPage: 
 * @component: AudioCropPage,UnsavedChangesDialog
 * @image: screenshots/audioEditHome/audio_crop.jpg
 */
import { AudioCropPage } from 'audio_crop'
import { phoneRouterControl } from 'oh_router'
import { fileIo } from '@kit.CoreFileKit'
import { media } from '@kit.MediaKit'
import { FileUtil, PersistenceV2Util } from 'audio_common'
import { common } from '@kit.AbilityKit'
import { getFormatSize } from '../util/CommonUtil'
import { MusicParam } from 'common_view'
import { MusicViewModelArray } from 'common_view/src/main/ets/viewModel/MusicListViewModel'
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel'
import { UnsavedChangesDialogController } from '../components/UnsavedChangesDialog'
import { BarVM, ChangeTabUtilContr } from 'common'
import { NavPageInfo } from 'oh_router/src/main/ets/router/interface/RouterPageInfo'

const TAG = 'AudioEditPage'

phoneRouterControl.registerPageBuilder('AudioEditPage', wrapBuilder(AudioEditPageBuilder))

@Builder
export function AudioEditPageBuilder(params: object) {
  AudioEditPage()
}

@ComponentV2
export struct AudioEditPage {
  @Local musicTitle: string = ''
  @Local pcmPath: string = '' //pcm路径
  @Local sourcePath: string = '' //源文件路径
  @Local channelLayout: number = 0 //声道数量
  @Local sampleRate: number = 0 //采样率
  @Local duration: number = 0 //音频时长（毫秒）
  @Local sampleFormat: number = 0 //音频时长（毫秒）
  persistenceV2Util = new PersistenceV2Util()
  resultCallBack = async (outPath: string) => {
    const fileUtil = new FileUtil(this.getUIContext().getHostContext() as common.UIAbilityContext)
    const format = fileUtil.splitFilePath(outPath)[2]
    let fileName = fileUtil.splitFilePath(outPath)[1]
    const fd = fileIo.openSync(outPath).fd
    let musicParam: MusicParam | undefined = undefined
    try {
      const fileInfo = await fileIo.stat(fd)
      // 创建AVMetadataExtractor对象。
      let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      // // 获取rawfile目录下资源文件描述符，设置fdSrc属性。
      avMetadataExtractor.fdSrc = { fd: fd }
      const avMetaData = await avMetadataExtractor.fetchMetadata()
      let title = fileName
      let duration = Number(avMetaData.duration)
      let size = getFormatSize(fileInfo.size)
      musicParam = {
        uri: '',
        title: title,
        duration: duration,
        size: size,
        format: format,
        path: outPath
      }
    } catch (e) {
      fileIo.closeSync(fd)
    } finally {
      fileIo.closeSync(fd)
    }

    const tempStr = this.persistenceV2Util.getData('work');
    let tmepData: MusicViewModelArray = []
    if (tempStr) {
      tmepData = JSON.parse(tempStr) as MusicViewModelArray;
    }
    if (!musicParam) {
      return
    }
    const tempMusicViewModel =
      new MusicViewModel(musicParam.uri, musicParam.title, musicParam.duration, musicParam.size, musicParam.format,
        musicParam.path);
    tmepData.unshift(tempMusicViewModel)
    this.persistenceV2Util.setData(JSON.stringify(tmepData), 'work')
    if (!this.persistenceV2Util.setData(JSON.stringify(tmepData), 'work')) {
      this.getUIContext().getPromptAction().showToast({
        message: '数据存储超出限制!。',
        duration: 3000
      })
      FileUtil.deleteFile(outPath)
      return
    }
    ChangeTabUtilContr.isBackHome = true
    let navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList()
    phoneRouterControl.popIndex(0)
  }
  backHandle = () => {
    UnsavedChangesDialogController.openDialog(this.getUIContext(), {
      onConfirm: () => {
        phoneRouterControl.popPage()
      },
      onCancel: () => {
      }
    })

  }

  build() {
    NavDestination() {
      Column() {
        Divider().width('100%').height(BarVM.instance.staBarH)
        AudioCropPage({
          musicTitle: this.musicTitle,
          pcmPath: this.pcmPath,
          sourcePath: this.sourcePath,
          channelLayout: this.channelLayout,
          sampleRate: this.sampleRate,
          duration: this.duration,
          sampleFormat: this.sampleFormat,
          resultCallBack: this.resultCallBack,
          backHandle: this.backHandle
        })
      }.width('100%').height('100%')
      .backgroundColor('#0A0D1E')
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .onReady((context) => {
      let param = context.pathInfo.param as Record<string, string | number>
      this.pcmPath = param.path as string || ''
      this.sourcePath = param.sourcePath as string || ''
      this.channelLayout = param.channelLayout as number || 0
      this.sampleRate = param.sampleRate as number || 0
      this.duration = param.duration as number || 0
      this.musicTitle = param.title as string || ''
      this.sampleFormat = param.sampleFormat as number || 0
    })
    .onBackPressed(() => {
      this.backHandle()
      return true
    })
  }
}