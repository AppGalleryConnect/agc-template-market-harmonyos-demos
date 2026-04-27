import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
const MS_TIME: number = 1000;
const MIN_TIME: number = 60;
const TEN_NUMBER: number = 10;

export default class MediaLibraryUtils {
  // @ts-ignore
  private context = getContext(this) as common.UIAbilityContext;

  async openFileDescriptor(name: string): Promise<media.AVFileDescriptor> {
    let fileDescriptor: media.AVFileDescriptor;
    await this.context.resourceManager.getRawFd(name).then(value => {
      fileDescriptor = {
        fd: value.fd, offset: value.offset, length: value.length
      };
    }).catch(error => {
    });
    return fileDescriptor;
  }

  async closeFileDescriptor(name: string): Promise<void> {
    await this.context.resourceManager.closeRawFd(name).then(() => {
    }).catch(error => {
    });
  }

  getFilePath(name: string): string {
    return this.context.filesDir + '/' + name;
  }

  getShowTime(ms): string {
    let seconds: number = Math.round(ms / MS_TIME);
    let sec: number = (seconds % MIN_TIME);
    let min: number = (seconds - sec) / MIN_TIME;
    let secStr: string = sec.toString();
    let minStr: string = min.toString();
    if (sec < TEN_NUMBER) {
      secStr = '0' + sec;
    }
    if (min < TEN_NUMBER) {
      minStr = '0' + min;
    }
    return minStr + ':' + secStr;
  }
}