import { PersistenceV2, UIUtils } from '@kit.ArkUI'
import { CommonConstants, SettingModel, TimeUtils } from 'lib_common'
import { LayoutParams } from 'module_flexlayout'
import { PostImgList } from 'lib_news_api'
import { BaseImage } from 'lib_widget'
import { Highlight } from 'module_highlight'
import { AuthorCard } from '../builder/AuthorBuilder'
import { CardViewModel } from '../viewmodel/CardViewModel'

@Builder
export function LeftTextRightImageCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Param showAuthor: boolean = true;
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
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Column({ space: CommonConstants.SPACE_XS }) {
          if (!this.cardData?.extraInfo?.searchKey) {
            Text(this.cardData.nativeCardData?.title)
              .maxLines(2)
              .fontSize(16 * this.settingInfo.fontSizeRatio)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          } else {
            Highlight({
              keywords: [this.cardData.extraInfo.searchKey as string],
              sourceString: this.cardData.nativeCardData?.title,
              highLightColor: '#E84026',
              textColor: $r('sys.color.font_primary'),
            })
          }
          Row({ space: 8 }) {
            Text(this.cardData.nativeCardData?.author?.authorNickName)
              .fontSize(12 * this.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_tertiary'))
              .visibility(this.showAuthor ? Visibility.Visible : Visibility.None)
            Text(
              TimeUtils.formatDate(this.cardData.nativeCardData?.createTime, 'YYYY-MM-DD HH:mm'))
              .fontSize(12 * this.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_tertiary'))
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
            SymbolGlyph($r('sys.symbol.dot_grid_1x2'))
              .fontSize(16)
              .fontColor([$r('sys.color.icon_tertiary')])
              .onClick(() => {
                if (this.cardData.extraInfo.onMoreClick) {
                  (this.cardData.extraInfo.onMoreClick as Function)();
                }
              })
          }
          .visibility(this.cardData.extraInfo.isNeedAuthor ? Visibility.None : Visibility.Visible)
        }
        .width('65%')
        .alignItems(HorizontalAlign.Start)
        .accessibilityGroup(true)
        .accessibilityLevel('yes')

        if (this.cardData.nativeCardData?.postImgList?.length) {
          Column() {
            ForEach(this.cardData.nativeCardData?.postImgList, (item: PostImgList) => {
              ListItem() {
                Column() {
                  if (item.surfaceUrl) {
                    Stack() {
                      BaseImage({
                        url: item.surfaceUrl,
                        downloadWithoutWlan: this.settingInfo.network.downloadWithoutWlan,
                      })
                        .size({ width: 96, height: 72 })
                        .clip(true)
                      Image($r('app.media.play')).width(43).height(43)
                    }
                  } else {
                    BaseImage({
                      url: item.picVideoUrl,
                      downloadWithoutWlan: this.settingInfo.network.downloadWithoutWlan,
                    })
                      .size({ width: 96, height: 72 })
                      .clip(true)
                  }
                }
              }
            }, (item: PostImgList) => JSON.stringify(item))
          }
        }
      }
    }
    .onClick(() => {
      this.cardViewModel.pushToNewsDetails(this.cardData)
    })
  }
}