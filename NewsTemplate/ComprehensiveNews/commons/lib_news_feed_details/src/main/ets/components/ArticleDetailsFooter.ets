import { PersistenceV2 } from '@kit.ArkUI'
import { SettingModel } from 'lib_common'
import { ShareUtils } from 'lib_widget'
import { handlerCoverImage } from '../utils/Utils'
import NewsFeedVM from '../viewmodel/NewsFeedVM'

@ComponentV2
export struct ArticleDetailsFooter {
  @Param newsFeedVM: NewsFeedVM = new NewsFeedVM()
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!

  @Computed
  get getDarkLike() {
    return this.settingInfo.darkSwitch ? $r('app.media.details_like_dark') : $r('app.media.details_like')
  }

  build() {
    Column() {
      Flex() {
        Row() {
          Image(this.newsFeedVM.articleDetails.isLiked ? $r('app.media.details_like_active') :
            this.getDarkLike)
            .width(16 * this.settingInfo.fontSizeRatio)
            .height(14 * this.settingInfo.fontSizeRatio)
            .margin({ right: 5 })
          Text(this.newsFeedVM.articleDetails.likeCount.toString())
            .fontSize(14 * this.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.Center)
        .borderRadius(21)
        .flexGrow(1)
        .margin({ right: 5 })
        .accessibilityText('点赞' + this.newsFeedVM.articleDetails.likeCount.toString())
        .onClick(() => {
          this.newsFeedVM.newsLike()
        })

        Row() {
          Image($r('app.media.wechat'))
            .width(18 * this.settingInfo.fontSizeRatio)
            .height(15 * this.settingInfo.fontSizeRatio)
            .margin({ right: 5 })
            .fillColor($r('sys.color.font_primary'))
          Text('微信')
            .fontSize(14 * this.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(21)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .width('48%')
        .margin({ left: 5 })
        .accessibilityText('分享到微信')
        .onClick(() => {
          const instance = new ShareUtils();
          instance.shareToWX(this.getUIContext(), {
            recordId: this.newsFeedVM.articleDetails.id,
            title: this.newsFeedVM.articleDetails.title,
            subTitle: this.newsFeedVM.articleDetails?.author?.authorNickName,
            createTime: this.newsFeedVM.articleDetails.createTime,
            coverUrl: handlerCoverImage(this.newsFeedVM.articleDetails),
          });
        })
      }
    }
    .margin({ bottom: 16, top: 16 })
  }
}
