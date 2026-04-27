import { common } from '@kit.AbilityKit';
import { FileUtil, PersistenceV2Util } from 'audio_common';
import { fileIo } from '@kit.CoreFileKit'
import { MusicParam } from 'common_view';
import { media } from '@kit.MediaKit';
import { getFormatSize } from '../util/CommonUtil'
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel';
import { MusicViewModelArray } from 'common_view/src/main/ets/viewModel/MusicListViewModel';
import { GlobalContext } from 'common';
import { phoneRouterControl } from 'oh_router';

export class AudioSave {
  context: UIContext | null = null

  constructor(context: UIContext) {
    this.context = context
  }

  static persistenceV2Util = new PersistenceV2Util()

  async save(context: common.UIAbilityContext, outPath: string) {
    const fileUtil = new FileUtil(context)
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

    const tempStr = AudioSave.persistenceV2Util.getData('work');
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
    tmepData.unshift(tempMusicViewModel);
    if (!AudioSave.persistenceV2Util.setData(JSON.stringify(tmepData), 'work')) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '数据存储超出限制'
      })
      return
    }
    AudioSave.persistenceV2Util.setData(JSON.stringify(tmepData), 'work')
    phoneRouterControl.popIndex(0)

  }
}