@CustomDialog
export struct RecorderToolDialog {
  controller: CustomDialogController;
  save: () => void = () => {

  };
  edit: () => void = () => {

  };
  convert: () => void = () => {

  };
  cancel: () => void = () => {

  };

  @Builder
  listItem(str: string) {
    Column() {
      Row() {
        Text(str)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium);
        Image($r('app.media.record_arrow_right')).width(12);
      }.width('100%').justifyContent(FlexAlign.Center).height(55).justifyContent(FlexAlign.SpaceBetween);

      Divider();
    }.justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    Column() {
      Column({ space: 24 }) {
        Column() {
          Row({ space: 16 }) {
            Image($r('app.media.ic_save')).width(24);
            Row() {
              this.listItem('仅保存');
            }.layoutWeight(1).onClick(() => {
              this.save();
            });
          };

          Row({ space: 16 }) {
            Image($r('app.media.ic_waveform_cut')).width(24);
            Row() {
              this.listItem('保存并编辑');
            }.layoutWeight(1).onClick(() => {
              this.edit();
            });
          };

          Row({ space: 16 }) {
            Image($r('app.media.ic_voice_convert_text')).width(24);
            Row() {
              this.listItem('保存并转文字');
            }.layoutWeight(1).onClick(() => {
              this.convert();
            });
          };
        };


        Row() {
          Text('取消')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
        }.width(144).height(40).justifyContent(FlexAlign.Center).onClick(() => {
          this.cancel();
        });
      }
      .width('100%')
      .padding({
        top: 24,
        left: 24,
        right: 24,
        bottom: 16,
      })
      .borderRadius($r('sys.float.corner_radius_level16'))
      .backgroundColor('rgba(255, 255, 255, 0.9)')
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK);
    }.width('100%').padding({ left: 16, right: 16 });
  }
}