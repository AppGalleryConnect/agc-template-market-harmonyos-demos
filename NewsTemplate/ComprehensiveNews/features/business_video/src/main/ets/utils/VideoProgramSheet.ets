import { PopViewUtils } from 'lib_common';
import { videoProgramBuilder } from '../components/VideoProgramBuilder';
import { Constants } from '../constants/Constants';

export class VideoProgramSheet {
  public static openProgram(videoId: string) {
    PopViewUtils.showSheet<string>(wrapBuilder(videoProgramBuilder), {
      title: {
        title: '节目单',
      },
      showClose: true,
      height: Constants.DEFAULT_SHEET_HEIGHT,
      detents: [Constants.DEFAULT_SHEET_HEIGHT, SheetSize.LARGE],
      preferType: SheetType.CENTER,
      dragBar: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
    }, videoId);
  }
}