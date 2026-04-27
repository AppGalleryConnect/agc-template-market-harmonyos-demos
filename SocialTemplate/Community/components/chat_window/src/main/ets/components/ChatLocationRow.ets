import { AppStorageV2 } from '@kit.ArkUI';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ChatBaseRow } from './ChatBaseRow';

const TAG = 'ChatLocationRow';

@ComponentV2
export struct ChatLocationRow {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require keyId: string;
  @Param @Require onChatBubbleClick: (chatVM: ChatContentSingleModel) => void;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local mapOption?: mapCommon.MapOptions
  @Local mapController?: map.MapComponentController
  @Local mapCallBack: AsyncCallback<map.MapComponentController> = (err, mapController) => {
    hilog.info(0x0000, TAG, '%{public}s', 'mapCallBack err: ' + JSON.stringify(err));
    if (mapController !== undefined) {
      mapController.on('mapLoad', () => {
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.chatVM.locationLatitude,
            longitude: this.chatVM.locationLongitude
          },
          icon: $r('app.media.chat_map_marker')
        };
        mapController.addMarker(markerOptions);
      });
    }
  }

  aboutToAppear(): void {
    this.resetKeyId();
  }

  @Monitor('keyId')
  resetKeyId() {
    this.mapOption = {
      position: {
        target: {
          latitude: this.chatVM.locationLatitude,
          longitude: this.chatVM.locationLongitude
        },
        zoom: 16
      },
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      compassControlsEnabled: false,
      logoScale: 0.8
    }
  }

  @Builder
  render() {
    Column() {
      Text(this.chatVM.locationName)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor(Color.Black)
        .lineHeight($r('app.float.vp_20'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .height($r('app.float.vp_38'))
        .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })

      Stack() {
        MapComponent({
          mapOptions: this.mapOption,
          mapCallback: this.mapCallBack
        })
          .width('100%')
          .height('100%')

        Row().width('100%').height('100%')
          .onClick(() => {
            this.onChatBubbleClick?.(this.chatVM);
          })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width(this.locationChatMaxWidth)
    .height($r('app.float.vp_140'))
    .backgroundColor(Color.White)
    .onClick(() => {
      this.onChatBubbleClick?.(this.chatVM);
    })
  }

  build() {
    ChatBaseRow({
      childBuilder: () => {
        this.render();
      },
      chatVM: this.chatVM,
      onChatAvatarClick: this.onChatAvatarClick
    })
  }

  @Computed
  get locationChatMaxWidth() {
    let locationSingle = this.chatBreakpoint.getColumnWidth(this.getUIContext());
    //头像 36 + 头像和消息间隙 8
    return locationSingle * 4 + 36 - 44;
  }
}