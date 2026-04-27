/**
 * @usage: 视频合成加载组件，用于展示视频导出转换时的加载动画和缩略图预览
 * @layout: 层叠布局，中心图片+加载进度指示器，带圆角边框
 * @isGen: true
 * @fileType: component
 * @zhName: 视频合成加载组件
 * @domain: 视频
 */
@ComponentV2
export struct TransformLoading {
  @Param thumbnailImg: Resource | string = '';
  @Param rectW: number = 184; // 矩形的宽度
  @Param rectH: number = 304; // 矩形的高度
  @Param radiusW: number = 24; // 矩形的圆角
  @Param thick: number = 4; // 边框的宽度
  @Param loading: boolean = false; // 是否加载中

  build() {
    Column() {
      // 图片边框加载动画（顺时针 Top -> Right -> Bottom -> Left）
      Stack({ alignContent: Alignment.Center }) {
        // 中心图片（透明度随进度由暗到清晰）
        Image(this.thumbnailImg)
          .width(this.rectW + 2 * this.thick)
          .height(this.rectH + 2 * this.thick)
          .borderRadius(this.radiusW)
          .objectFit(ImageFit.Cover)

        if (this.loading) {
          LoadingProgress()
            .color($r('sys.color.icon_on_primary'))
            .size({
              width: $r('app.float.loadingProgress_size'),
              height: $r('app.float.loadingProgress_size')
            });
        }
      }
      .width(this.rectW)
      .height(this.rectH)
      .borderRadius(this.radiusW)
      .borderWidth(this.thick)
      .borderColor('#ff666666')
      .clip(true)
    }
  }
}
