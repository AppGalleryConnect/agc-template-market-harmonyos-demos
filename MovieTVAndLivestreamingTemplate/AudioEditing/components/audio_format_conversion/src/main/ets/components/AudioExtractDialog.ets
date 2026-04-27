import { throttle } from 'audio_common';

@ComponentV2
export struct AudioExtractDialog {
  @Param @Require onConfirm: (format: string) => void;
  @Param @Require onCancel: () => void;
  @Local currentName: string = '';
  @Local selectedFormat: string = 'mp3';
  formats: string[] = ['mp3', 'aac', 'm4a', 'wav'];

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Row() {
          Text('格式转换')
            .fontSize(18)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Image($r('app.media.ic_close'))
          .width(16)
          .height(16)
          .fillColor(Color.White)
          .margin({ right: 20 })
          .onClick(() => {
            this.onCancel();
          })
      }
      .width('100%')
      .margin({ top: 24 })


      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.formats, (item: string) => {
          Row() {
            Image(this.selectedFormat === item ? $r('app.media.ic_selected') : $r('app.media.ic_unselected'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Contain)

            Text(item)
              .fontColor(Color.White)
              .fontSize(14)
              .margin({ left: 8 })
          }
          .width('30%')
          .margin({ top: 16, bottom: 8 })
          .onClick(() => {
            this.selectedFormat = item;
          })
        }, (item: string) => item)
      }
      .padding({ left: 16, right: 16 })
      .margin({ top: 12, bottom: 24 })

      Row() {
        Text('取消')
          .width(144)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(30)
          .backgroundColor('transparent')
          .border({ width: 1, color: '#01FCEA' })
          .fontColor('#01FCEA')
          .onClick(() => {
            this.onCancel();
          })
        Text('确定')
          .width(144)
          .textAlign(TextAlign.Center)
          .borderRadius(30)
          .height(40)
          .backgroundColor('#01FCEA')
          .fontColor('#0A0D1E')
          .onClick(throttle(() => {
            this.onConfirm(this.selectedFormat);
          }, 1000))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 24 })
    }
    .width('100%')
    .backgroundColor('#202E3E')
    .borderRadius({ topLeft: 32, topRight: 32 })
  }
}
