import { ChatBreakpoint, ChatContentSingleModel, TimeUtil } from 'chat_base';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MsgCollectLocationItem {
  @Param @Require collectMsg: ChatContentSingleModel;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local mapOption?: mapCommon.MapOptions
  @Local mapCallBack: AsyncCallback<map.MapComponentController> = (err, mapController) => {
    if (mapController !== undefined) {
      mapController.on('mapLoad', () => {
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: this.collectMsg.locationLatitude,
            longitude: this.collectMsg.locationLongitude
          },
          icon: $r('app.media.chat_map_marker')
        };
        mapController.addMarker(markerOptions);
      });
    }
  }

  aboutToAppear(): void {
    this.mapOption = {
      position: {
        target: {
          latitude: this.collectMsg.locationLatitude,
          longitude: this.collectMsg.locationLongitude
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

  build() {
    Row() {
      Column() {
        Text(this.collectMsg.locationName)
          .lineHeight($r('app.float.vp_22'))
          .margin({ bottom: $r('app.float.vp_6') })
          .fontColor(Color.Black)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Stack() {
          MapComponent({
            mapOptions: this.mapOption,
            mapCallback: this.mapCallBack
          })
            .width(this.getChatWidth)
            .height($r('app.float.vp_102'))
            .backgroundColor(Color.White)
            .borderRadius($r('app.float.vp_12'))
            .clip(true)

          Row().width('100%').height('100%')
            .onClick(() => {
              this.onChatBubbleClick?.(this.collectMsg);
            })
        }
        .width(this.getChatWidth)
        .height($r('app.float.vp_102'))

        Text(TimeUtil.formatDate(this.collectMsg.timestamp * 1000, TimeUtil.PATTERN_DATE_CN))
          .margin({ top: $r('app.float.vp_4') })
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.icon_tertiary'))
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('app.float.vp_18'))
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_13'),
      bottom: $r('app.float.vp_14'),
    })
    .width('100%')
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .borderRadius($r('app.float.vp_12'))
    .justifyContent(FlexAlign.Start)
    .margin({
      bottom: $r('app.float.vp_8')
    })
  }

  @Computed
  get getChatWidth() {
    let tempTotal = this.chatBreakpoint.currentScreenWidth - this.chatBreakpoint.pagePadding * 2;
    return tempTotal * 0.75 - 44;
  }
}