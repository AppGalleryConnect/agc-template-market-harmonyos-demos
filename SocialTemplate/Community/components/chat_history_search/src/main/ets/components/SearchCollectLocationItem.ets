import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { TimeView } from './TimeView';
import { CollectSearchModel } from '../viewmodel/CollectSearchModel';

@ComponentV2
export struct SearchCollectLocationItem {
  @Param @Require collectMsg: ChatContentSingleModel;
  @Param @Require searchText: string;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local mapOption?: mapCommon.MapOptions
  @Local mapCallBack: AsyncCallback<map.MapComponentController> = (err, mapController) => {
  }
  @Local collectSearchModel: CollectSearchModel = new CollectSearchModel()

  aboutToAppear(): void {
    this.collectSearchModel.message = this.collectMsg.locationName;
    this.collectSearchModel.messageShowing = this.collectSearchModel.message;
    this.collectSearchModel.searchTextLower = this.searchText.toLowerCase();
    this.collectSearchModel.calcLightIndex();
    this.mapOption = {
      position: {
        target: {
          latitude: this.collectMsg.locationLatitude,
          longitude: this.collectMsg.locationLongitude
        },
        zoom: 10
      },
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      compassControlsEnabled: false,
      myLocationControlsEnabled: false,
    }
  }

  build() {
    Row() {
      Row() {
        MapComponent({
          mapOptions: this.mapOption,
          mapCallback: this.mapCallBack
        })
          .width($r('app.float.vp_48'))
          .height($r('app.float.vp_48'))
          .borderRadius($r('app.float.vp_12'))
          .clip(true)

        Text() {
          if (this.collectSearchModel.calcFinish) {
            ForEach(this.collectSearchModel.keyNum?.length > 0 ? this.collectSearchModel.keyNum :
              [this.collectSearchModel.messageShowing.length],
              (start: number, index: number) => {
                Span(this.collectSearchModel.messageShowing.substring(index !== 0 ?
                  (this.collectSearchModel.keyNum[index - 1] + this.searchText.length) :
                  0, start));
                Span(this.collectSearchModel.messageShowing.substring(start, (start + this.searchText.length)))
                  .fontColor($r('app.color.color_564af7'));
                if (index === (this.collectSearchModel.keyNum.length - 1)) {
                  Span(this.collectSearchModel.messageShowing.substring((start + this.searchText.length),
                    this.collectSearchModel.messageShowing.length));
                }
              }, (item: number) => item.toString())
          }
        }
        .width('100%')
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .lineHeight($r('app.float.vp_22'))
        .maxLines(2)
        .margin({ left: $r('app.float.vp_12') })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .padding(0)
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          let newW = Number.parseInt(newValue.width + '');
          this.collectSearchModel.onExpandTextSizeChange(newW);
        })
      }
      .margin({ bottom: $r('app.float.vp_4') })

      TimeView({ timestamp: this.collectMsg.timestamp })
    }
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.vp_72') })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.onChatBubbleClick?.(this.collectMsg);
    })
  }

  @Computed
  get getChatWidth() {
    let tempTotal = this.chatBreakpoint.currentScreenWidth - this.chatBreakpoint.pagePadding * 2;
    return tempTotal * 0.75 - 44;
  }
}