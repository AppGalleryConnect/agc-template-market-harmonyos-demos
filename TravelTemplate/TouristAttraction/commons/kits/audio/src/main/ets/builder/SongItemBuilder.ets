import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SongItem } from 'types';
import { Logger } from 'common';

export default class SongItemBuilder {
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private realUrl?: resourceManager.RawFileDescriptor;
  private rawFileDescriptor?: resourceManager.RawFileDescriptor;
  private songItem: SongItem | null = null;

  public async build(songItem: SongItem): Promise<SongItem> {
    this.songItem = songItem;
    if (!this.context) {
      return this.songItem;
    }
    let rawfileFd = await this.context.resourceManager.getRawFd(songItem.src)
      .catch((error: BusinessError) => {
        Logger.error(`resourceManager error code ${error.code} message ${error.message}`);
      })
    if (rawfileFd) {
      this.realUrl = rawfileFd;
    } else {
      Logger.error('get rawfileFd failed')
    }
    Logger.info('MediaAssetBuilder build realUrl:' + this.realUrl);
    return this.songItem;
  }

  public getRealUrl(): resourceManager.RawFileDescriptor | undefined {
    Logger.info(`url ${this.realUrl}`)
    return this.realUrl;
  }

  public getRawFileDescriptor(): resourceManager.RawFileDescriptor | undefined {
    Logger.info(`rawFileDescriptor: ${this.rawFileDescriptor}`);
    return this.rawFileDescriptor;
  }

  public async release(): Promise<void> {
    if (this.context && this.context !== null && this.songItem !== null) {
      this.context.resourceManager.closeRawFd(this.songItem.src);
    }
    this.songItem = null;
  }
}