import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'external_interactions';

const TAG = '[Consulting]';

@ComponentV2
export struct Consulting {
  @Local isShow: boolean = false
  @Param phone: string = ''
  @Builder
  callBuilder() {
    Column({space:12}) {
      Text(this.phone)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .opacity(0.9)
        .width('100%')
        .height(40)
        .textAlign(TextAlign.Center)
      Row() {
        Image($r('app.media.call'))
          .width(24)
          .height(24)
        Text('一键拨号')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .margin({ left: 8 })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(40)
      .borderRadius(20)
      .backgroundColor('#FF9019')
      .onClick(() => {
        try {
          call.makeCall(this.phone, (err: BusinessError) => {
            if (err) {
              Logger.error(TAG, `makeCall fail, err->${JSON.stringify(err)}`);
            } else {
              Logger.info(TAG, `makeCall success`);
            }
          });
        } catch (e) {
          Logger.error(TAG, `call makeCall failed. error: ${JSON.stringify(e)}`)
        }
      })

      Row() {
        Text('取消')
          .opacity(0.6)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .backgroundColor($r('app.color.main_background_color'))
      .onClick(() => {
        this.isShow = false
      })
    }
    .layoutWeight(1)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
    .margin({left:16,right:16})
  }

  @Builder
  sheetTitleBuilder() {
    Text('联系客服')
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
  }

  build() {
    Column() {
      Image($r('app.media.consult'))
        .height(24)
        .width(24)
        .objectFit(ImageFit.Cover)
      Text($r('app.string.Consultation'))
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .opacity(0.6)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .bindSheet($$this.isShow, this.callBuilder(), {
      detents: [280, 400],
      title: this.sheetTitleBuilder(),
      dragBar: true,
      showClose: true
    })
    .onClick(() => {
      this.isShow = true
    })
  }
}
