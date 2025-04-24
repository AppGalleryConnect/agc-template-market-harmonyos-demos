import { Logger } from './Logger';
import { pad } from './ScheduleConfigUtil';

const TAG: string = '[FormatUtil]';

export class FormatUtil {
  public static formatDate(date: Date, splitter: string = '.'): string {
    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    return `${year}${splitter}${month}${splitter}${day}`;
  }

  public static formatImgResource(str: string): string {
    if (!str.length) {
      return '';
    }
    if (str.startsWith('mockImage://')) {
      const resourceName = str.split('//')[1];
      try {
        const resource = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(TAG, 'get image resource failed', err);
      }
    }
    return str;
  }
}