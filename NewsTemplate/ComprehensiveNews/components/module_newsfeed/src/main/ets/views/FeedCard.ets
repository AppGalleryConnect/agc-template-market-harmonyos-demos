import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from 'lib_common';
import { FeedDetail } from '../components/FeedDetail';
import { FeedOperate } from '../components/FeedOperate';
import { FeedCardInfoModel } from '../model/RecommendModel';

/**
 * 动态区域组件
 * 标题，图片，地理位置，转发，评论，点赞等相关模块
 */

const TAG = '[FeedCard]';

@ComponentV2
export struct FeedCard {
  @Require @Param feedCardInfo: FeedCardInfoModel
  @Require @Param componentId: string = ''
  @Param index: number = 0
  @Param fontSizeRatio: number = 1
  @Param isDark: boolean = false
  @Param isAll: boolean = false
  @Param isNeedOperation: boolean = true
  @Param showUserBar: boolean = true;
  @Param showTimeBottom: boolean = false;
  @Param showImagePreviewLayer: boolean = true;
  @Param searchKey: string = ''
  @Param isNeedFollow: boolean = false
  @BuilderParam shareBuilder: () => void
  @Event onArticle: (type?: string) => void = () => {
  }
  @Event onVideo: (type?: string) => void = () => {
  }
  @Event onWatch: () => void = () => {
  }
  @Event onLike: () => void = () => {
  }
  @Event onComment: () => void = () => {
  }
  @Event onGoUserInfo: (authorId: string) => void = () => {
  }
  controller: VideoController = new VideoController()
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  @Computed
  get getWatch() {
    return this.userInfoModel.isLogin && this.userInfoModel.watchers.includes(this.feedCardInfo.author.authorId)
  }

  @Computed
  get isFeedSelf() {
    return this.userInfoModel.authorId === this.feedCardInfo.author.authorId
  }

  @Builder
  publishTimeBuilder() {
    Row() {
      Text(this.feedCardInfo?.relativeTime)
        .fontSize(12 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
      if (this.feedCardInfo?.city) {
        Text() {
          Span('IP:')
          Span(this.feedCardInfo?.city)
        }
        .fontSize(12 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ left: 4 })
      }
    }
  }

  @Builder
  followBuilder() {
    Row() {
      Text() {
        Span(this.getWatch ? '已关注' : '关注')
      }
      .fontSize(14 * this.fontSizeRatio)
      .fontColor(this.getWatch ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
      .onClick(() => {
        this.onWatch()
      })
    }
    .padding({
      left: 12,
      right: 12,
      top: 6,
      bottom: 6,
    })
    .backgroundColor(this.getWatch ? $r('sys.color.comp_background_tertiary') : $r('app.color.app_theme'))
    .borderRadius(14)
    .justifyContent(FlexAlign.Center)
    .visibility(!this.isNeedFollow && !this.isFeedSelf ?
      Visibility.Visible : Visibility.None)
  }

  build() {
    Column() {
      /*
       * 文章详情
       * */
      FeedDetail({
        componentId: this.componentId,
        curFeedCardInfo: this.feedCardInfo,
        fontSizeRatio: this.fontSizeRatio,
        isWatch: this.getWatch,
        isFeedSelf: this.isFeedSelf,
        isDynamicsSingleDetail: false,
        isAll: this.isAll,
        searchKey: this.searchKey,
        showUserBar: this.showUserBar,
        showTimeBottom: this.showTimeBottom,
        showImagePreviewLayer: this.showImagePreviewLayer,
        followBuilderParam: () => {
          this.followBuilder()
        },
        onVideo: () => {
          this.onVideo()
        },
        publishCustomTimeBuilder: () => {
          this.publishTimeBuilder()
        },
        onGoUserInfo: (authorId: string) => {
          this.onGoUserInfo(authorId)
        },
        onAddWatch: () => {
          this.onWatch()
        },
        onAddLike: () => {
          this.onLike()
        },
        onAddComment: () => {
          this.onComment()
        },
      })
      /*
       * 文章操作相关
       * */
      FeedOperate({
        curFeedCardInfo: this.feedCardInfo,
        isDark: this.isDark,
        fontSizeRatio: this.fontSizeRatio,
        isNeedOperation: this.isNeedOperation,
        shareBuilder: () => {
          this.shareBuilder()
        },
        onArticle: () => {
          this.onArticle('comment')
        },
        onLike: () => {
          this.onLike()
        },
      })
        .visibility(this.isNeedOperation ? Visibility.Visible : Visibility.None)
    }
    .id(this.componentId)
    .onClick(() => {
      this.onArticle()
    })
  }
}