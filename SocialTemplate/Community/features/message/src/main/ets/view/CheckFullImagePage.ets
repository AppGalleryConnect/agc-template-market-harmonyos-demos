import { AppStorageV2 } from '@kit.ArkUI';
import { FullScreenImagePage } from 'chat_window';
import { TempBarHeight, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';

@Builder
export function CheckFullImagePageBuilder(param: TValueType) {
  CheckFullImagePage({ imgSrc: param as string })
}

@ComponentV2
export struct CheckFullImagePage {
  @Param @Require imgSrc: string;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  @Builder
  render() {
    FullScreenImagePage({
      imgSrc: this.imgSrc,
      backAction: this.onReturnClick,
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}
