import { PersistenceV2, UIUtils } from '@kit.ArkUI'
import {
  CommonConstants,
  FormatCount,
  RouterMap,
  RouterUtils,
  SettingModel,
  UserInfoModel,
} from 'lib_common'
import { Share } from 'lib_widget'
import { LayoutParams } from 'module_flexlayout'
import { FeedCard } from 'module_newsfeed'
import { CardViewModel } from '../viewmodel/CardViewModel'

@Builder
export function FeedDetailsCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
export struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Local currentIndex: number = 0
  @Local selectedId: string = '1'
  @Local cardViewModel: CardViewModel = new CardViewModel(this.getUIContext())
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  aboutToAppear(): void {
    this.cardViewModel.setAuthorId(this.cardData.nativeCardData.author.authorId)
    this.cardData.nativeCardData = UIUtils.makeObserved(this.cardData.nativeCardData)
    this.currentIndex = this.cardData.currentIndex
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: CommonConstants.SPACE_XS }) {
      Image($r('app.media.share_active'))
        .width(21)
        .height(21)
        .fillColor($r('sys.color.font_primary'))
      Text(FormatCount.formatToK(this.cardData.nativeCardData.shareCount))
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
    }
  }

  handlerCoverImage(): string {
    return this.cardData.nativeCardData.postImgList?.[0]?.surfaceUrl ||
      this.cardData.nativeCardData.postImgList?.[0]?.picVideoUrl
  }

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        recordId: this.cardData.nativeCardData.id,
        title: this.cardData.nativeCardData.title,
        createTime: this.cardData.nativeCardData.createTime,
        coverUrl: this.handlerCoverImage(),
        subTitle: this.cardData.nativeCardData.author?.authorNickName,
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  build() {
    Column() {
      FeedCard({
        componentId: 'home_news',
        feedCardInfo: this.cardData.nativeCardData,
        isAll: this.cardData.extraInfo?.showTitleTextAll as boolean ?? true,
        isNeedOperation: false,
        isNeedFollow: !!this.cardData.extraInfo?.isFollow,
        showUserBar: this.cardData.extraInfo?.showUserBar as boolean ?? true,
        showTimeBottom: this.cardData.extraInfo?.showTimeBottom as boolean ?? false,
        showImagePreviewLayer: this.cardData.extraInfo?.showImagePreviewLayer as boolean ?? true,
        fontSizeRatio: this.settingInfo.fontSizeRatio,
        searchKey: this.cardData?.extraInfo?.searchKey as string,
        onArticle: (formType?: string) => {
          let disabledClickEvent = this.cardData.extraInfo?.disabledClickEvent as boolean ?? false;
          if (!disabledClickEvent) {
            this.cardViewModel.pushToNewsDetails(this.cardData, formType, '', true)
          }
        },
        onVideo: () => {
          this.cardViewModel.pushToNewsDetails(this.cardData)
        },
        shareBuilder: () => this.shareBuilder,
        onGoUserInfo: (authorId: string) => {
          RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
        },
        onWatch: () => {
          this.cardViewModel.watchOperation()
        },
        onLike: () => {
          this.cardViewModel.likeOperation(this.cardData.nativeCardData)
        },
        onComment: () => {
          this.cardViewModel.pushToNewsDetails(this.cardData, 'comment')
        },
      })
    }
  }
}