import { emitter } from '@kit.BasicServicesKit';
import { UIUtils } from '@kit.ArkUI';
import { BreakpointNameEnum, NewsEnum, RouterMap, RouterUtils, EventEnum } from 'lib_common';
import { Share } from 'lib_widget';
import { NewsResponse } from 'lib_news_api';
import { LoginSheetUtils } from 'lib_account';
import { PlayerLayoutSize } from 'module_swipeplayer';
import { CommentController } from '../controller/CommentController';
import { SideBarVM } from '../viewmodels/SideBarVM';
import { CommentSheetParams, CommentSheetUtils } from '../commons/CommentSheetUtil';

@ComponentV2
export struct Sidebar {
  // 视频信息
  @Param @Require videoInfo: NewsResponse
  // 评论组件控制器
  @Param commentController: CommentController = new CommentController();
  // 评论页面出现时，改变播放页面的尺寸
  @Param @Require playerLayoutSize: PlayerLayoutSize
  @Local isShowKeyboard: boolean = false;
  vm: SideBarVM = new SideBarVM()

  @Monitor('vm.videoExtraInfoModel.isDisplayChange')
  onDisplayGridChange(monitor: IMonitor) {
    if (!(monitor.value()?.now as boolean)) {
      this.handleCommentState(false)
    }
  }

  aboutToAppear(): void {
    this.vm.videoInfo = UIUtils.makeObserved(this.videoInfo);
    this.commentController.open = (): void => this.open();
  }

  open() {
    this.isShowKeyboard = true;
    this.vm.videoExtraInfoModel.isShowKeyboard = true;
    this.openCommentSheet();
  }

  handleCommentState(isTrue: boolean) {
    this.vm.videoExtraInfoModel.isDisplayChange = isTrue
    this.vm.videoExtraInfoModel.videoInfo = this.vm.videoInfo;
    this.commentController.showComment = isTrue
    this.vm.tabModel.showTabBar = !isTrue;
    this.playerLayoutSize.updateLayoutSizeChangeFlag(isTrue);
    let eventData: emitter.EventData = {
      data: {
        showTabHeader: !isTrue,
      },
    };
    emitter.emit(EventEnum.SHOW_TAB_HEADER, eventData)
  }

  // 评论的一多适配
  handleMultiComment() {
    // 折叠屏展开态，且是MD尺寸
    let foldableAndMd = this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.MD &&
    this.vm.displayModel.isFoldable;
    // LG尺寸或XL尺寸
    const larges = [BreakpointNameEnum.LG, BreakpointNameEnum.XL];
    let isLGOrXL = larges.includes(this.vm.breakPointModel.currentBreakpoint);
    if (foldableAndMd || isLGOrXL) {
      this.handleCommentState(true)
    } else {
      let uiContext = this.getUIContext();
      let uniqueId = this.getUniqueId();
      let frameNode: FrameNode | null = uiContext.getFrameNodeByUniqueId(uniqueId);
      let targetId = frameNode?.getFirstChild()?.getUniqueId();

      CommentSheetUtils.initParams(
        {
          videoInfo: this.vm.videoInfo,
          isShowKeyboard: this.isShowKeyboard,
          playerLayoutSize: this.playerLayoutSize,
          commentController: this.commentController,
          sheetTargetId: targetId,
        } as CommentSheetParams,
      )
      CommentSheetUtils.open()
    }
  }

  openCommentSheet() {
    // 已经有评论，可以直接看评论
    if (this.vm.videoInfo.commentCount) {
      this.handleMultiComment();
      return
    }
    // 未登录
    if (!this.vm.userInfoModel.isLogin) {
      LoginSheetUtils.open();
      return
    }
    // 已登录
    this.handleMultiComment()
  }

  build() {
    Column({ space: 12 }) {
      // 头像
      Column() {
        Image(this.videoInfo.author.authorIcon)
          .width(40)
          .height(40)
          .borderRadius(40)
          .accessibilityText(this.videoInfo.author.authorNickName + '头像')
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.videoInfo.author.authorId)
          })

        Row() {
          Image(this.vm.isFollow() ? $r('app.media.ic_follow') : $r('app.media.ic_unfollow'))
            .width(14)
            .height(14)
            .borderRadius(14)
            .backgroundColor(Color.White)
        }
        .visibility(this.vm.isFollow() ? Visibility.Hidden : Visibility.Visible)
        .offset({ bottom: 8 })
        .accessibilityText(this.vm.isFollow() ? '取消关注' : '关注')
        .onClick(() => {
          this.vm.followOperation()
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Center)

      // 点赞
      Column({ space: 4 }) {
        Image(this.vm.videoInfo.isLiked ? $r('app.media.ic_like') : $r('app.media.ic_unlike'))
          .width(22)
          .height(20)

        Text(this.vm.getLikeCount())
          .fontSize(10)
          .fontColor(Color.White)
      }
      .accessibilityGroup(true)
      .accessibilityText(this.vm.videoInfo.isLiked ? '取消点赞' + this.vm.getLikeNum() :
        '点赞' + this.vm.getLikeNum())
      .onClick(() => {
        this.vm.likeAction()
      })

      // 评论
      Column({ space: 4 }) {
        Image($r('app.media.ic_comment'))
          .width(22)
          .height(21)

        Text(this.vm.videoInfo.commentCount ? String(this.vm.videoInfo.commentCount) : '评论')
          .fontSize(10)
          .fontColor(Color.White)
      }
      .accessibilityGroup(true)
      .accessibilityText('评论' + this.vm.videoInfo.commentCount)
      .onClick(() => {
        this.isShowKeyboard = false;
        this.vm.videoExtraInfoModel.isShowKeyboard = false;
        this.openCommentSheet()
      })

      // 收藏
      Column({ space: 4 }) {
        Image(this.vm.videoInfo.isMarked ? $r('app.media.ic_favorite') : $r('app.media.ic_unfavorite'))
          .width(22)
          .height(21)

        Text(this.vm.getMarkCount())
          .fontSize(10)
          .fontColor(Color.White)
      }
      .accessibilityGroup(true)
      .accessibilityText(this.vm.videoInfo.isMarked ? '取消收藏' + this.vm.getMarkNum() :
        '收藏' + this.vm.getMarkNum())
      .onClick(() => {
        this.vm.saveAction()
      })

      // 分享
      Share({
        shareData: {
          recordId: this.videoInfo.id,
          title: this.videoInfo.title,
          subTitle: this.videoInfo.author?.authorNickName,
          createTime: this.videoInfo.createTime,
          coverUrl: this.vm.handlerCoverImage(this.videoInfo),
          type: NewsEnum.Video,
        },
        shareRenderBuilder: () => {
          this.shareCommentBuilder()
        },
      })
    }
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 1.0 && this.videoInfo.id) {
        this.vm.getVideoInfo(this.videoInfo.id)
      }
    })
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 4 }) {
      Image($r('app.media.ic_share'))
        .width(22)
        .height(22)
      Text('分享')
        .fontSize(10)
        .fontColor(Color.White)
    }
    .accessibilityGroup(true)
    .accessibilityText('分享')
  }
}