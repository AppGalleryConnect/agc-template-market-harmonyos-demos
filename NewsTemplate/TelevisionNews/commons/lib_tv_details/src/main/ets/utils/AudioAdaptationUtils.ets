import { AvModel } from 'lib_news_api';
import { AudioItem } from 'module_audioplayer'

export class AudioUtils {
  /**
   * 播放器接口适配
   * @param nativeCardData 卡片源数据
   */
  public static adaptation(nativeCardData: AvModel): AudioItem[] {
    let audioList = nativeCardData.section.map((item, index) => {
      let audioInfo: AudioItem = {
        id: nativeCardData.id,
        audioId: item.id,
        mainTitle: nativeCardData.title,
        title: item.title,
        description: nativeCardData.description,
        mark: nativeCardData.coverUrl,
        label: nativeCardData.title,
        src: item.sectionUrl,
        index: index,
      }
      return audioInfo
    })
    return audioList
  }
}