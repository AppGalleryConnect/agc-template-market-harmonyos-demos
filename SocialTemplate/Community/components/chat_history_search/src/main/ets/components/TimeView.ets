import { TimeUtil } from 'chat_base';

@ComponentV2
export struct TimeView {
  @Param @Require timestamp: number;

  build() {
    Text(TimeUtil.chatCommentData(this.timestamp))
      .fontWeight(FontWeight.Regular)
      .fontColor($r('sys.color.icon_tertiary'))
      .fontSize($r('sys.float.Body_S'))
      .lineHeight($r('app.float.vp_18'))
      .margin({ left: $r('app.float.vp_12') })
  }
}