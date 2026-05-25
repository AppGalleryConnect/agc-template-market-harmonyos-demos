import { webview } from '@kit.ArkWeb';
import {  Constants, FontModel } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ActivityPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local controller: webview.WebviewController = new webview.WebviewController();
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    NavDestination() {
      Column() {
        Web({ src: $rawfile('reading_app_activity.html'), controller: this.controller })
          .darkMode(WebDarkMode.Auto)
          .forceDarkAccess(true)
          .fileAccess(false)
          .geolocationAccess(false)
          .textZoomRatio(this.fontModel.getFontScale() * 100)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .title('活动中心')
    .padding({top:this.windowTopHeight})
  }
}