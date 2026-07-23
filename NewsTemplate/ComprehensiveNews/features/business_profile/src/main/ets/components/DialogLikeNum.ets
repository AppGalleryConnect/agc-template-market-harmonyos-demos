import { CommonConstants, GridRowColSetting, PopViewUtils, } from 'lib_common'
import { AuthorModel } from 'lib_news_api'
import { Constants } from '../common/Constants'

@Builder
export function dialogLikeNumBuilder(params: AuthorModel) {
  Column() {
    Column({ space: CommonConstants.SPACE_XXL }) {
      Column({ space: CommonConstants.SPACE_S }) {
        Text(params.authorNickName)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
        Row({ space: CommonConstants.SPACE_XS }) {
          Text('共获得')
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Text(params.likeNum.toString())
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.multi_color_08'))
          Text('个赞')
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
      }

      Image($r('app.media.ic_like_show'))
        .width(Constants.LIKE_SHOW_W)
        .aspectRatio(1)
        .draggable(false)
      Button('好的').width(200).height(40).onClick(() => {
        PopViewUtils.closePopView();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.xxl_radius'))
    .padding(CommonConstants.PADDING_XXL)
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({
    left: CommonConstants.PADDING_L,
    right: CommonConstants.PADDING_L,
  })
}