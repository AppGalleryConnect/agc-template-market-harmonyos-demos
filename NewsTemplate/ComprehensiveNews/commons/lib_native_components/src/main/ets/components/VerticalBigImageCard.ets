import { PersistenceV2, UIUtils } from '@kit.ArkUI'
import { CommonConstants, FormatCount, SettingModel, NewsEnum } from 'lib_common'
import { BaseImage } from 'lib_widget'
import { LayoutParams, LayoutSetting } from 'module_flexlayout'
import { CardViewModel } from '../viewmodel/CardViewModel'
import { ComponentModifier } from '../utils/Modifier'

@Builder
export function VerticalBigImageCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Local layout: LayoutSetting = new LayoutSetting()
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local cardViewModel: CardViewModel = new CardViewModel(this.getUIContext())

  aboutToAppear(): void {
    this.cardData.nativeCardData = UIUtils.makeObserved(this.cardData.nativeCardData)
    this.layout = this.cardData.layout
  }

  @Computed
  get getSurface() {
    return this.cardData.nativeCardData.type === NewsEnum.Video ?
      this.cardData.nativeCardData?.postImgList?.[0]?.surfaceUrl :
      this.cardData.nativeCardData?.postImgList?.[0].picVideoUrl
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      BaseImage({
        url: this.getSurface,
        downloadWithoutWlan: this.settingInfo.network.downloadWithoutWlan,
      })
      Column({ space: CommonConstants.SPACE_S }) {
        Flex({ alignItems: ItemAlign.Center }) {
          Image($r('app.media.play_secondary')).width(14).height(14)
            .margin({ right: 5 })
          Text() {
            Span(FormatCount.formatToK(Number(this.cardData.nativeCardData?.playCount)))
            Span('次播放')
          }
          .fontSize(12 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_on_secondary'))
        }

        Text(this.cardData.nativeCardData?.title)
          .fontSize(14 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_on_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12, right: 12, bottom: 12 })
    }
    .attributeModifier(new ComponentModifier(this.layout.style)).clip(true)
    .id('news_flow_video' + this.cardData.extraInfo.channelId + this.cardData.currentIndex +
      this.cardData.extraInfo.flowIndex +
      this.cardData.extraInfo.flexId)
    .onClick(() => {
      this.cardViewModel.pushToNewsDetails(this.cardData, '',
        'news_flow_video' + this.cardData.extraInfo.channelId + this.cardData.currentIndex +
          this.cardData.extraInfo.flowIndex +
          this.cardData.extraInfo.flexId)
    })
  }
}