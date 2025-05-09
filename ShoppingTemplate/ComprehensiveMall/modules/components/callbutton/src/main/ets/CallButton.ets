import { call } from '@kit.TelephonyKit';

@ComponentV2
export struct CallButton {

  @Local
  public isOpen: boolean = false;

  @BuilderParam
  public contentBuilder: () => void = buildEmptyComponent;

  build(): void {
    Column() {
      Column() {
        this.contentBuilder()
      }
      .onClick(() => {
        this.isOpen = true;
      })
      .bindSheet($$this.isOpen, this.buildMakeCallComponent(), {
        title: this.buildTitle(),
        dragBar: true,
        detents: [SheetSize.FIT_CONTENT]
      })
    }
  }

  @Builder
  buildMakeCallComponent() {
    Column() {
      Column() {
        Text('012****7890')
          .fontSize(18)
          .fontColor('#E6000000')
          .lineHeight(30)
          .halfLeading(true)
        Button() {
          Row() {
            Image($r('app.media.ic_phone'))
              .height(24)
              .objectFit(ImageFit.Contain)
              .margin({ right: 5 })
            Text('一键拨号')
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(600)
          }
        }
        .width('100%')
        .height(45)
        .type(ButtonType.Normal)
        .backgroundColor('#FFE64566')
        .borderRadius(21)
        .onClick(() => {
          if (canIUse('SystemCapability.Applications.Contacts')) {
            call.makeCall('01234567890');
          }
          this.isOpen = false;
        })
        Button() {
          Text('取消')
            .fontSize(15)
            .fontColor($r('sys.color.mask_secondary'))
            .fontWeight(600)
        }
        .width('100%')
        .height(45)
        .type(ButtonType.Normal)
        .backgroundColor('#0D000000')
        .borderRadius(21)
        .onClick(() => this.isOpen = false)
      }
      .width('100%')
      .height(170)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16, right: 16, bottom: 56, top: 8 })
  }

  @Builder
  buildTitle() {
    Text('联系客服')
      .fontSize(18)
      .fontColor('#E6000000')
      .fontWeight(500)
  }
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
