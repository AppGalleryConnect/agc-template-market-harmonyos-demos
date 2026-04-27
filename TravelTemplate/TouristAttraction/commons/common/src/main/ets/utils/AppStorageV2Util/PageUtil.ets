import { AppStorageV2 } from '@kit.ArkUI';
import { Page } from 'types';

@ObservedV2
export class PageUtil {
  private static page: Page = AppStorageV2.connect(Page, 'Page', () => new Page())!;

  public static getPageInfo(): Page {
    return PageUtil.page;
  }

  public static setPageInfo(index: number) {
    PageUtil.page.index = index;
    AppStorageV2.connect(Page, 'Page', () => new Page())!;
  }
}