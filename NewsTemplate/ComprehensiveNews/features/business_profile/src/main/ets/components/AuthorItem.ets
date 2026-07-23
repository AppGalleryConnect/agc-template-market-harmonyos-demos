import { CommonConstants, RouterMap, RouterUtils } from 'lib_common'
import { AuthorModel } from 'lib_news_api';
import { WatchButton } from './WatchButton';

@ComponentV2
export struct AuthorItem {
  @Require @Param author: AuthorModel;
  @Param fontSizeRatio: number = 1;

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image(this.author.authorIcon || $r('app.media.ic_user_default'))
        .width($r('app.float.head_icon_width'))
        .aspectRatio(1)
        .borderRadius(CommonConstants.HALF_PERCENT)
        .draggable(false)
      Text(this.author.authorNickName)
        .fontSize(16 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      WatchButton({
        author: this.author,
      })
    }
    .onClick(() => {
      RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.author.authorId);
    })
  }
}