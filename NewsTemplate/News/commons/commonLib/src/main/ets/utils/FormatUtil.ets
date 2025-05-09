import { Logger } from './Logger';

const TAG: string = '[FormatUtil]';

export class FormatUtil {
  public static formatDate(date: Date): string {
    const pad = (n: number) => (n < 10 ? '0' + n : n.toString());

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
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