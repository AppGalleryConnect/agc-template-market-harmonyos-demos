
@ComponentV2
export struct AudioExtractDialog {
  @Param @Require fileName: string;
  @Param @Require onConfirm: (name: string, format: string) => void;
  @Param @Require onCancel: () => void;
  @Param workerId: number = -1; // 接收外部传入的 workerId
  @Local currentName: string = '';
  @Local selectedFormat: string = 'mp3';
  formats: string[] = ['mp3', 'aac', 'm4a','wav'];
  @Local isConfirming: boolean = false;

  aboutToAppear() {
    this.currentName = '';
  }

  build() {
    Column() {
      Text('音频提取')
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 24, bottom: 24 })

      Column() {
        Text('音频名称')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ bottom: 12 })
          .width('100%')

        Stack({ alignContent: Alignment.End }) {
          TextInput({ text: this.currentName, placeholder: '请重新编辑音频名称' })
            .maxLength(15)
            .height(44)
            .width('100%')
            .backgroundColor('rgba(255,255,255,0.1)')
            .placeholderColor('#66ffffff')
            .fontColor(Color.White)
            .padding({ left: 16, right: 44 })
            .borderRadius(20)
            .onChange((value) => {
              this.currentName = value;
            })

          Image($r('app.media.ic_edit'))
            .width(20)
            .height(20)
            .fillColor(Color.White)
            .margin({ right: 20 })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

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

        Text('提取')
          .width(144)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(30)
          .backgroundColor('#01FCEA')
          .fontColor('#0A0D1E')
          .onClick(() => {
            if (this.workerId !== -1) {
              this.getUIContext().getPromptAction().showToast({ message: '已有任务在执行，请等待任务结束后再操作!' });
              return;
            }
            if (this.isConfirming) {
              return;
            }
            this.isConfirming = true;
            setTimeout(() => {
              this.isConfirming = false;
            }, 2000);

            const nameToUse = this.currentName.trim() ? this.currentName : this.fileName;
            this.onConfirm(nameToUse, this.selectedFormat);
          })
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
