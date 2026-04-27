import { MockAccountSingleModel } from '../model/MockAccountSingleModel';

@ComponentV2
export struct MockAccountSingleRow {
  @Param @Require dialogVM: MockAccountSingleModel;
  @Param @Require selectUserId: string;
  @Event onSelectClick: () => void = () => {
  };

  build() {
    Row() {
      Image($r('app.media.' + this.dialogVM.avatarUrl))
        .width($r('app.float.vp_60'))
        .height($r('app.float.vp_60'))
        .objectFit(ImageFit.Contain)
        .borderRadius($r('sys.float.corner_radius_level2'))

      Blank().width($r('app.float.vp_16'))

      Column() {
        Text(this.dialogVM.nickName)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)

        Blank().height($r('app.float.vp_6'))

        Text(this.dialogVM.userId)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.color_66000000'))
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Radio({
        value: this.selectUserId,
        group: 'radioGroup',
        indicatorType: RadioIndicatorType.TICK
      }).checked(this.dialogVM.userId === this.selectUserId)
        .height(24)
        .width(24)// .enabled(this.loginUserId === this.dialogVM.userId)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.onSelectClick();
          }
        })
    }
    .height($r('app.float.vp_88'))
    .width('100%')
    .padding($r('app.float.vp_16'))
    .backgroundColor(Color.White)
    .clip(true)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .alignItems(VerticalAlign.Center)
  }
}