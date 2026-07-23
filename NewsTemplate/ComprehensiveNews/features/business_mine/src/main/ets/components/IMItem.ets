import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, TimeUtils } from 'lib_common';
import { CustomBadge } from 'lib_widget';
import { BriefIMModel } from '../common/ObservedModel';

@ComponentV2
export struct IMItem {
  @Require @Param info: BriefIMModel;
  @Param fontSizeRatio: number = 1;

  build() {
    Row({ space: CommonConstants.SPACE_M }) {
      CustomBadge({
        count: this.info?.allUnreadCount,
        maxCount: 99,
        bodyBuilder: () => {
          this.bodyBuilder()
        },
      })

      Column({ space: CommonConstants.SPACE_XS }) {
        Text(this.info?.chatAuthor?.authorNickName)
          .fontSize(16 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(21)
        Text(this.info?.latestNews)
          .fontSize(12 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(TimeUtils.handleMsgTimeDiff(this.info?.receiveTime))
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))

    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
    })
  }

  @Builder
  bodyBuilder() {
    Image(this.info?.chatAuthor?.authorIcon)
      .width($r('app.float.menu_icon_width'))
      .aspectRatio(1)
      .clipShape(new CircleShape({ width: 48, height: 48 }))
  }

  @Builder
  doNothingBuilder() {
  }
}