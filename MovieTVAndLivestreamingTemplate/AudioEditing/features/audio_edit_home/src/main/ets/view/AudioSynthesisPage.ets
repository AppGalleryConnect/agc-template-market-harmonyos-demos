/**
 * @usage: 音频合成页面,用户从SelectPage选择多个音频后跳转到此页面进行音频合成操作。
 * 支持多个音频文件的拼接合成,可调整合成顺序和间隔时间。
 * 合成成功后自动保存到作品列表并切换到作品Tab页展示。
 * @layout: 页面采用NavDestination包裹Column垂直布局,顶部为状态栏占位,
 * 下方渲染AudioSynthesis组件进行实际的合成操作(显示已选音频列表、支持排序和删除)。
 * @constraints: 必须从SelectPage传递已选音频列表(selectedMusicList),至少需要2个音频文件才能合成。
 * 合成成功后自动保存到作品列表并切换到作品Tab页。
 * @domain: 音频编辑
 * @zhName: 音频合成页面
 * @isGen: true
 * @fileType: page
 * @subPage:
 * @component: AudioSynthesis
 * @image: screenshots/audioEditHome/audio_synthesis.jpg
 */
import { phoneRouterControl } from 'oh_router'
import { FileUtil, PersistenceV2Util, TValueType } from 'audio_common'
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel'
import { AudioSynthesis } from 'audio_synthesis'
import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { MusicParam } from 'common_view'
import { media } from '@kit.MediaKit'
import { getFormatSize } from '../util/CommonUtil'
import { MusicViewModelArray } from 'common_view/src/main/ets/viewModel/MusicListViewModel'
import { BarVM, ChangeTabUtilContr, GlobalContext } from 'common'
import { NavPageInfo } from 'oh_router/src/main/ets/router/interface/RouterPageInfo'

const TAG = 'AudioSynthesisPage'

phoneRouterControl.registerPageBuilder('AudioSynthesisPage', wrapBuilder(AudioSynthesisPageBuilder))

@Builder
export function AudioSynthesisPageBuilder(params: TValueType) {
  AudioSynthesisPage({ pageParams: params })
}

@ComponentV2
export struct AudioSynthesisPage {
  @Param pageParams: TValueType = null;
  @Local selectedMusicList: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  persistenceV2Util = new PersistenceV2Util()
  backHandle = () => {
    phoneRouterControl.popPage({
      popData: this.selectedMusicList
    })
  }
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
    let tempData: MusicViewModelArray = []
    if (tempStr) {
      tempData = JSON.parse(tempStr) as MusicViewModelArray;
    }
    if (!musicParam) {
      return
    }
    const tempMusicViewModel =
      new MusicViewModel(musicParam.uri, musicParam.title, musicParam.duration, musicParam.size, musicParam.format,
        musicParam.path);
    tempData.unshift(tempMusicViewModel);
    if (!this.persistenceV2Util.setData(JSON.stringify(tempData), 'work')) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '数据存储超出限制'
      })
    }
    try {
      this.getUIContext().getPromptAction().showToast({
        message: '音频合成已成功',
        duration: 1000
      })
      ChangeTabUtilContr.isBackHome = true
      let navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList()
      phoneRouterControl.popIndex(0)
    } catch (error) {
    }
  }

  build() {
    NavDestination() {
      Column() {
        AudioSynthesis({
          selectedMusicList: this.selectedMusicList,
          backHandle: this.backHandle,
          resultCallBack: this.resultCallBack,
        })
      }.width('100%').height('100%')
      .padding({
        top: BarVM.instance.staBarH
      })
      .backgroundColor('#0A0D1E')
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .onBackPressed(() => {
      this.backHandle()
      return true
    })
    .onReady((context) => {
      this.selectedMusicList = (context.pathInfo.param as Record<string, MusicViewModel[]>)?.selectedMusicList
    })
  }
}