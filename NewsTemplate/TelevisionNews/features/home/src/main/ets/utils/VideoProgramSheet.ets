import { PopViewUtils } from 'lib_common';
import { videoProgramBuilder } from '../components/VideoProgramBuilder';

export class VideoProgramSheet {
  public static openProgram(videoId: string) {
    PopViewUtils.showSheet<string>(wrapBuilder(videoProgramBuilder), {
      title: {
        title: '节目单',
      },
      showClose: true,
      detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE],
      preferType: SheetType.CENTER,
      dragBar: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
    }, videoId);
  }
}