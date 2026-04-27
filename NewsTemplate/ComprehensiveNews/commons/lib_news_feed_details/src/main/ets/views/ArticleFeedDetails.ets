import { webview } from '@kit.ArkWeb';
import { emitter } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { FeedComment, CommentOperation } from 'module_feedcomment';
import {
  FormatCount,
  RouterMap,
  RouterParams,
  RouterUtils,
  SettingModel,
  BundleInfo,
  NewsEnum,
  CommonConstants,
  loadingPage,
  EventEnum,
} from 'lib_common';
import { CommentResponse, NewsResponse } from 'lib_news_api';
import { BaseAgent, NavHeaderBar, Share } from 'lib_widget';
import { FeedCard } from 'module_newsfeed';
import { TextRead } from 'module_text_reader';
import { CardLongTakeDelegate, LongTakeAnimationProperties } from 'module_transition';
import { extractText, handlerCoverImage } from '../utils/Utils';
import { ArticleDetailsFooter } from '../components/ArticleDetailsFooter';
import { RecommendArea } from '../components/RecommendArea';
import NewsFeedVM from '../viewmodel/NewsFeedVM';
import { NewsContent } from '../components/NewsContent';
import { NewsFeedInfo } from '../model/Model';
import { FeedBreakPointVM } from '../viewmodel/FeedBreakPointVM';

@Builder
export function ArticleFeedDetailsBuilder() {
  ArticleFeedDetails()
}

@ComponentV2
export struct ArticleFeedDetails {
  @Local isShow: boolean = true;
  @Local articleId: string = ''
  @Local pixelMap: PixelMap | null = null
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local formType: string = ''
  @Param newsFeedVM: NewsFeedVM = new NewsFeedVM()
  @Local bundleInfo: BundleInfo | undefined = undefined
  @Local newsBreakPoint: FeedBreakPointVM = new FeedBreakPointVM()
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  webViewController: webview.WebviewController = new webview.WebviewController();

  async aboutToAppear() {
    let params = RouterUtils.getParamByName<RouterParams<NewsResponse>>(RouterMap.ARTICLE_FEED_DETAILS)
    let newsData = params?.cardData as NewsFeedInfo
    let isQueryCardData = params?.isQueryCardData as boolean
    // 销毁应用中其他AVSession
    await this.newsFeedVM.destroyAVSession()
    if (isQueryCardData) {
      this.articleId = newsData.id
      this.newsFeedVM.setCardData(newsData)
      this.formType = params?.formType ?? ''
    } else {
      this.articleId = params?.newsId ?? ''
      this.formType = params?.formType ?? ''
      await this.newsFeedVM.initArticle(this.articleId)
    }
    await this.newsFeedVM.initComment(this.articleId)
    this.newsFeedVM.setUiContext(this.getUIContext())
    this.bundleInfo = AppStorage.get('appInfo') as BundleInfo
    this.newsFeedVM.addHistory()
    this.newsFeedVM.setContinueData()
    this.newsFeedVM.onGestureShare()
  }

  aboutToDisappear(): void {
    this.newsFeedVM.offGestureShare()
  }

  readBody() {
    return this.newsFeedVM.articleDetails?.richContent ? extractText(this.newsFeedVM.articleDetails.richContent) :
      this.newsFeedVM.articleDetails.title
  }

  @Builder
  pointSplit() {
    Column() {
      Image(this.newsBreakPoint.isSplit ? $r('app.media.full_screen') : $r('app.media.split_screen'))
        .width(40)
        .height(40)
    }
    .onClick(() => {
      this.newsBreakPoint.switchSplit()
    })
    .visibility(this.newsBreakPoint.isLargeDevice ? Visibility.Visible : Visibility.None)
  }

  @Builder
  readNewsBuilder() {
    Row({ space: 10 }) {
      this.pointSplit()
      if (!this.newsFeedVM.loading) {
        TextRead({
          currentId: this.newsFeedVM.articleDetails.id,
          readInfoList: [
            {
              id: this.newsFeedVM.articleDetails.id,
              title: { text: this.newsFeedVM.articleDetails.title, isClickable: true },
              author: { text: this.newsFeedVM.articleDetails.author.authorNickName, isClickable: true },
              bodyInfo: this.readBody(),
              imgSrc: handlerCoverImage(this.newsFeedVM.articleDetails),
            },
          ],
          readerParam: {
            isVoiceBrandVisible: true,
            businessBrandInfo: { panelName: this.bundleInfo?.appName ?? '综合新闻模板' },
          },
        })
      }
    }
  }

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        recordId: this.newsFeedVM.articleDetails.id,
        title: this.newsFeedVM.articleDetails.title,
        subTitle: this.newsFeedVM.articleDetails?.author?.authorNickName,
        createTime: this.newsFeedVM.articleDetails.createTime,
        coverUrl: handlerCoverImage(this.newsFeedVM.articleDetails),
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.share_active'))
        .width(21)
        .height(21)
        .fillColor($r('sys.color.font_primary'))
      Text(FormatCount.formatToK(this.newsFeedVM.articleDetails.shareCount))
        .fontSize(10 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
    }
    .accessibilityText('分享' + FormatCount.formatToK(this.newsFeedVM.articleDetails.shareCount))
  }

  @Builder
  ContentBuilder() {
    Column() {
      NavHeaderBar({
        title: '新闻详情',
        rightPartBuilder: () => {
          this.readNewsBuilder()
        },
      })
      if (this.newsFeedVM.loading) {
        loadingPage()
      } else {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Column() {
            List({ initialIndex: 0, scroller: this.newsFeedVM.scroller }) {
              if (this.newsFeedVM.articleDetails.type === NewsEnum.Article) {
                ListItem() {
                  NewsContent({
                    newsFeedVM: this.newsFeedVM,
                    fontSizeRatio: this.settingInfo.fontSizeRatio,
                    onAddLike: () => {
                      this.newsFeedVM.newsLike()
                    },
                    onAddWatch: () => {
                      this.newsFeedVM.watchOperation()
                    },
                    onComment: () => {
                      this.newsFeedVM.scrollToComment()
                    },
                    onQuestionExpand: (isShow) => {
                      this.isShow = !isShow;
                    },
                  })
                }
              } else {
                ListItem() {
                  FeedCard({
                    componentId: 'feedDetails_news',
                    feedCardInfo: this.newsFeedVM.articleDetails,
                    fontSizeRatio: this.settingInfo.fontSizeRatio,
                    isNeedOperation: false,
                    onGoUserInfo: (authorId: string) => {
                      RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
                    },
                    onLike: () => {
                      this.newsFeedVM.newsLike()
                    },
                    onWatch: () => {
                      this.newsFeedVM.watchOperation()
                    },
                    onComment: () => {
                      this.newsFeedVM.scrollToComment()
                    },
                  })
                }
                .padding(this.newsBreakPoint.breakpointModel.pagePadding)
                .backgroundColor($r('sys.color.background_primary'))
              }
              ListItem() {
                ArticleDetailsFooter({
                  newsFeedVM: this.newsFeedVM,
                })
              }
              .padding({
                left: this.newsBreakPoint.breakpointModel.pagePadding,
                right: this.newsBreakPoint.breakpointModel.pagePadding,
              })
              .backgroundColor($r('sys.color.background_primary'))

              ListItem() {
                RecommendArea({
                  newsFeedVM: this.newsFeedVM,
                  isFolderStatus: this.newsBreakPoint.isFolderStatus,
                  settingInfo: this.settingInfo,
                })
              }
              .margin({ bottom: 8 })

              ListItem() {
                FeedComment({
                  userInfo: this.newsFeedVM.getUserInfo(),
                  commentList: this.newsFeedVM.commentInfoList,
                  fontSizeRatio: this.settingInfo.fontSizeRatio,
                  isDark: this.settingInfo.darkSwitch,
                  navPathStack: RouterUtils.getStack(),
                  addComment: (comment: CommentResponse, parentCommentId: string) => {
                    this.newsFeedVM.addSingleComment(comment, parentCommentId)
                  },
                  giveLike: (comment: CommentResponse, isLike: boolean) => {
                    this.newsFeedVM.addLike(comment, isLike)
                  },
                  onGoAuthorInfo: (authorId: string) => {
                    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
                  },
                  onDeleteComment: (commentId: string) => {
                    this.newsFeedVM.deleteComment(commentId)
                  },
                  onFirstComment: (commentContent: string) => {
                    this.newsFeedVM.addNewsComment(commentContent)
                  },
                })
              }
              .id('news_feedComment_1')
              .padding({
                left: this.newsBreakPoint.breakpointModel.pagePadding,
                right: this.newsBreakPoint.breakpointModel.pagePadding,
              })
              .backgroundColor($r('sys.color.background_primary'))
              .visibility(!this.newsBreakPoint.isFolderStatus ? Visibility.Visible : Visibility.None)
              .onAppear(() => {
                if (this.formType === 'comment') {
                  this.newsFeedVM.scrollToComment()
                }
              })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .backgroundColor($r('sys.color.background_secondary'))
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .onAppear(() => {
              this.newsFeedVM.scrollToRestorePosition();
            })
            .onDidScroll(() => {
              this.newsFeedVM.setContinueOffset();
            })
          }
          .width(!this.newsBreakPoint.isFolderStatus ? CommonConstants.FULL_PERCENT : CommonConstants.HALF_PERCENT)

          Column() {
            FeedComment({
              feedCommentScroller: this.newsFeedVM.feedCommentScroller,
              userInfo: this.newsFeedVM.getUserInfo(),
              commentList: this.newsFeedVM.commentInfoList,
              fontSizeRatio: this.settingInfo.fontSizeRatio,
              isDark: this.settingInfo.darkSwitch,
              navPathStack: RouterUtils.getStack(),
              addComment: (comment: CommentResponse, parentCommentId: string) => {
                this.newsFeedVM.addSingleComment(comment, parentCommentId)
              },
              giveLike: (comment: CommentResponse, isLike: boolean) => {
                this.newsFeedVM.addLike(comment, isLike)
              },
              onGoAuthorInfo: (authorId: string) => {
                RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, authorId)
              },
              onDeleteComment: (commentId: string) => {
                this.newsFeedVM.deleteComment(commentId)
              },
              onFirstComment: (commentContent: string) => {
                this.newsFeedVM.addNewsComment(commentContent)
              },
            })

          }
          .width(!this.newsBreakPoint.isFolderStatus ? CommonConstants.FULL_PERCENT : CommonConstants.HALF_PERCENT)
          .id('news_feedComment_2')
          .padding({
            left: this.newsBreakPoint.breakpointModel.pagePadding,
            right: this.newsBreakPoint.breakpointModel.pagePadding,
          })
          .backgroundColor($r('sys.color.background_primary'))
          .visibility(this.newsBreakPoint.isFolderStatus ? Visibility.Visible : Visibility.None)
          .onAppear(() => {
            if (this.formType === 'comment') {
              this.newsFeedVM.scrollToComment()
            }
          })
        }
        .layoutWeight(1)
        .parallelGesture(
          PinchGesture({ fingers: 2 })
            .onActionStart(() => this.newsBreakPoint.pinchGestureUtils.onActionStart())
            .onActionUpdate((event: GestureEvent) => this.newsBreakPoint.pinchGestureUtils.onActionUpdate(event))
            .onActionEnd(() => this.newsBreakPoint.pinchGestureUtils.onActionEnd()),
        )

        Flex({ justifyContent: FlexAlign.Center }) {
          BaseAgent({ queryText: '' });
        }.width('100%').position({ bottom: 108 }).visibility(this.isShow ? Visibility.Visible : Visibility.None);

        Column() {
          CommentOperation({
            commentCount: this.newsFeedVM.articleDetails.commentCount,
            fontSizeRatio: this.settingInfo.fontSizeRatio,
            isDark: this.settingInfo.darkSwitch,
            markCount: this.newsFeedVM.articleDetails.markCount!!,
            shareCount: this.newsFeedVM.articleDetails.shareCount,
            isMarked: this.newsFeedVM.articleDetails.isMarked!!,
            onMarked: (value: boolean) => {
              this.newsFeedVM.addMark(value)
            },
            shareBuilder: () => {
              this.shareBuilder()
            },
            onScrollToComment: () => {
              this.newsFeedVM.scrollToComment(this.newsBreakPoint.isSplit)
            },
            onComment: (commentContent: string) => {
              this.newsFeedVM.addNewsComment(commentContent)
              emitter.emit(EventEnum.INTERACTION_RECOMMEND_REFRESH)
            },
          })
        }
        .margin({ top: 16, bottom: 32 })
        .padding({
          left: this.newsBreakPoint.breakpointModel.pagePadding,
          right: this.newsBreakPoint.breakpointModel.pagePadding,
        })
      }
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  build() {
    NavDestination() {
      if (this.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .backgroundColor(this.longTakeSession.navDestinationBgColor)
    .hideTitleBar(true)
    .id('ArticleFeedDetails')
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
    .onReady((navDestContext: NavDestinationContext) => {
      this.newsFeedVM.registerCustomTransition(navDestContext, this.longTakeSession)
    })
    .onShown(() => {
      this.newsFeedVM.enableContinue(this.getUIContext().getHostContext() as common.UIAbilityContext);
    })
  }
}