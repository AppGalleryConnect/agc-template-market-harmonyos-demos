import { CommonConstants } from '../common/Constant'

@ComponentV2
export struct UIEmpty {
  @Param emptyDesc: ResourceStr = '暂无内容';
  @Param fg: number = 14;

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_empty')).width(56).height(47)
      Text(this.emptyDesc).fontColor($r('app.color.common_grey')).fontSize(this.fg)
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}