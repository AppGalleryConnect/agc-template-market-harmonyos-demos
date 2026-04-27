import { AppStorageV2 } from '@kit.ArkUI';
import { ChatContentSingleModel } from 'chat_window';
import { ChatLocationComponent } from 'chat_location';
import { BreakpointModel, TempBarHeight, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';

@Builder
export function ViewLocationPageBuilder(locationVM: TValueType) {
  ViewLocationPage({ locationVM: locationVM })
}

@ComponentV2
export struct ViewLocationPage {
  @Param @Require locationVM: TValueType;
  @Local chatVM?: ChatContentSingleModel;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  aboutToAppear(): void {
    try {
      this.chatVM = this.locationVM as ChatContentSingleModel;
    } catch (err) {
    }
  }

  @Builder
  render() {
    ChatLocationComponent({
      latitude: this.chatVM?.locationLatitude,
      longitude: this.chatVM?.locationLongitude,
      onReturnClick: this.onReturnClick,
      address: this.chatVM?.locationName,
      addressDetail: this.chatVM?.locationDesc
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
