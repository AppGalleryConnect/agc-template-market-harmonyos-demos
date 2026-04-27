import { common } from '@kit.AbilityKit';
import { TextReader } from '@kit.SpeechKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ReaderContent } from './Model';

export class ParamsTransform {
  public static async readerParamTransform(context: common.UIAbilityContext, readInfo: ReaderContent,
    readSystemInfo: TextReader.ReadInfo) {
    readSystemInfo.id = readInfo.id
    readSystemInfo.title = readInfo.title as TextReader.TextInfo
    readSystemInfo.bodyInfo = readInfo.bodyInfo
    if (readInfo.category) {
      readSystemInfo.category = readInfo.category
    }
    if (readInfo.author) {
      readSystemInfo.author = readInfo.author as TextReader.TextInfo
    }
    if (readInfo.imgSrc) {
      if (typeof readInfo.imgSrc === 'string') {
        readSystemInfo.imageUrl = readInfo.imgSrc
      } else if ((readInfo.imgSrc as Resource).id) {
        try {
          readSystemInfo.image =
            context.resourceManager.getDrawableDescriptor((readInfo.imgSrc as Resource).id).getPixelMap()
        } catch (error) {
          hilog.error(0x000F, '[TextReader]',
            `getDrawableDescriptor failed, error code: ${error.code}, message: ${error.message}.`);
        }
      } else {
        readSystemInfo.image = readInfo.imgSrc as PixelMap
      }
    }
    if (readInfo.date) {
      readSystemInfo.date = readInfo.date as TextReader.TextInfo
    }
    if (readInfo.bodyInfoObject) {
      readSystemInfo.bodyInfoObject = readInfo.bodyInfoObject
    }
    if (readInfo.categoryObject) {
      readSystemInfo.categoryObject = readInfo.categoryObject
    }
    if (readInfo.audioInfo) {
      readSystemInfo.audioInfo = readInfo.audioInfo
    }
    if (readInfo.isFavorite) {
      readSystemInfo.isFavorite = readInfo.isFavorite
    }
  }
}