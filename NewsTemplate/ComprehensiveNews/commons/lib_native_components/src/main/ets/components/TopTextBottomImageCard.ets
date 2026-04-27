import { PersistenceV2, UIUtils } from '@kit.ArkUI'
import { CommonConstants, SettingModel } from 'lib_common'
import { LayoutParams } from 'module_flexlayout'
import { PostImgList } from 'lib_news_api'
import { BaseImage } from 'lib_widget'
import { Highlight } from 'module_highlight'
import { AuthorCard } from '../builder/AuthorBuilder'
import { ArticleSourceBuilder } from '../builder/ArticleSourceBuilder'
import { CardViewModel } from '../viewmodel/CardViewModel'

@Builder
export function TopTextBottomImageCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Local currentIndex: number = 0
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local cardViewModel: CardViewModel = new CardViewModel(this.getUIContext())

  aboutToAppear(): void {
    this.cardData.nativeCardData = UIUtils.makeObserved(this.cardData.nativeCardData)
  }

  build() {
    Column({ space: CommonConstants.SPACE_S }) {
      AuthorCard({
        cardData: this.cardData,
        isNeedAuthor: !!this.cardData.extraInfo.isNeedAuthor,
      })
      if (this.cardData?.extraInfo?.searchKey) {
        Highlight({
          keywords: [this.cardData.extraInfo.searchKey as string],
          sourceString: this.cardData.nativeCardData?.title,
          highLightColor: '#E84026',
          textColor: $r('sys.color.font_primary'),
        })
      } else {
        Text(this.cardData.nativeCardData?.title)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16 * this.settingInfo.fontSizeRatio)
      }
      Grid() {
        ForEach(this.cardData.nativeCardData?.postImgList, (item: PostImgList) => {
          GridItem() {
            BaseImage({
              url: item.picVideoUrl,
              downloadWithoutWlan: this.settingInfo.network.downloadWithoutWlan,
            })
              .aspectRatio(1).clip(true)
              .width('100%')
          }
        }, (item: PostImgList, index: number) => index + JSON.stringify(item))
      }
      .columnsTemplate('1fr '.repeat(this.cardData.nativeCardData?.postImgList?.length ?? 0))
      .columnsGap(8)

      ArticleSourceBuilder({
        cardData: this.cardData,
      })
    }
    .onClick(() => {
      this.cardViewModel.pushToNewsDetails(this.cardData)
    })
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }
}