import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { Logger } from 'common';
import { SECOND_BUFFER_WALK } from '../controller/PlayerData';

const TAG = 'MediaTools';

export class MediaTools {

  static async getPixelMapFromResource(context: common.UIAbilityContext,
      name: resourceManager.Resource): Promise<PixelMap> {
    let resourceMgr = context.resourceManager;
    let fileData: Uint8Array = await resourceMgr.getMediaContent(name);
    return await image.createImageSource(fileData.buffer as ArrayBuffer).createPixelMap();
  }

  static async getPixelMapFromFile(id: string, path: string): Promise<image.PixelMap> {
    Logger.info(TAG, 'getPixelMapFromFile id:' + id + ', path:' + path);
    return await image.createImageSource(path).createPixelMap();
  }

  private static fill(value: number): string {
    return value.toString().padStart(2, '0');
  }

  static getOffsetFromTime(curMs: number) {
    return (curMs / 1000) * SECOND_BUFFER_WALK;
  }

  static getMsFromByteLength(byteLength: number): number {
    return 1000 * (byteLength / SECOND_BUFFER_WALK);
  }

  static msToCountdownTime(ms: number): string {
    if (!ms) {
      return '00:00';
    }
    const days = Math.floor(ms / (1000 * 60 * 60 * 24));
    const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((ms % (1000 * 60)) / 1000);
    return `${(days ? MediaTools.fill(days) + ':' : '')}${(hours ? MediaTools.fill(hours) + ':' : '')}
      ${MediaTools.fill(minutes)}:${MediaTools.fill(seconds)} `.trim();
  }
}