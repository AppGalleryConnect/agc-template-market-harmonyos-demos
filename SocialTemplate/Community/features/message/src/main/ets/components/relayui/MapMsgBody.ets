import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { ChatContentSingleModel } from 'chat_window';

@ComponentV2
export struct MapMsgBody {
  @Param @Require chatVM: ChatContentSingleModel;
  @Local mapOption?: mapCommon.MapOptions
  @Local mapCallBack: AsyncCallback<map.MapComponentController> = (err, mapController) => {
  }

  aboutToAppear(): void {
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

  build() {
    Column() {
      Text(this.chatVM.locationName)
        .fontSize(8)
        .fontWeight(FontWeight.Regular)
        .fontColor(Color.Black)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .height(21)
        .halfLeading(true)
        .padding({ left: 10, right: 10 })

      Stack() {
        MapComponent({
          mapOptions: this.mapOption,
          mapCallback: this.mapCallBack
        })
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height(51)
    }
    .width(140)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 8, topRight: 8 })
  }
}
