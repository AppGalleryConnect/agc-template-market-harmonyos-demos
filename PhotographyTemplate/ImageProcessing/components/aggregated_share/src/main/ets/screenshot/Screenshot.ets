import dayjs from 'dayjs';
import { CommonConstants } from '../common/Constants';
import { ShareViewData } from '../common/ShareParams';

@ComponentV2
export struct Screenshot {
  @Require @Param data: ShareViewData;
  @Local aspectRatioImg: number = CommonConstants.DEFAULT_IMG_RATIO;
  @Local w: Length = CommonConstants.FULL_PERCENT;
  @Local h: Length = CommonConstants.FULL_PERCENT;

  build() {
    Column({ space: CommonConstants.PADDING_M }) {
      Column() {
        Image(this.data.coverUrl)
          .width(this.w)
          .height(this.h)
          .aspectRatio(this.aspectRatioImg)
          .visibility(this.data.coverUrl ? Visibility.Visible : Visibility.None)
          .onComplete((event) => {
            if (event) {
              this.aspectRatioImg = event.width / event.height;
              if (this.aspectRatioImg >= CommonConstants.DEFAULT_IMG_RATIO) {
                this.w = CommonConstants.DEFAULT_IMG_MAX_WIDTH;
                this.h = CommonConstants.DEFAULT_AUTO;
              } else {
                this.w = CommonConstants.DEFAULT_AUTO;
                this.h = CommonConstants.DEFAULT_IMG_MAX_HEIGHT;
              }
            }
          })

        Column({ space: CommonConstants.PADDING_M }) {
          Text(this.data.title)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Clip })
          Text() {
            if (this.data.subTitle) {
              Span(this.data.subTitle)
            }
            if (this.data.createTime) {
              Span('  ' + dayjs(this.data.createTime).format('YYYY/MM/DD HH:mm'))
            }
          }
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
          .visibility(this.data.subTitle || this.data.createTime ? Visibility.Visible : Visibility.None)
        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(HorizontalAlign.Start)
        .padding(CommonConstants.PADDING_M)
      }
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.comp_background_tertiary'))

      Row() {
        Text('长按二维码查看详情')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
        QRCode(this.data.landingPageUrl).width(64).height(64)
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .id(CommonConstants.DEFAULT_SNAPSHOT_ID)
    .width(CommonConstants.DEFAULT_POSTER_MAX_WIDTH)
    .padding(CommonConstants.PADDING_M)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}