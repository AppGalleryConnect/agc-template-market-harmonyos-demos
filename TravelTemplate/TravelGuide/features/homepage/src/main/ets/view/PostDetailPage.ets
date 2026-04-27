/**
 * @usage: 帖子详情页面，展示帖子的完整内容，包括图片/视频、标题、正文、话题标签、发布信息、评论列表，支持点赞和分享功能
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，中间是可滚动内容区域（媒体区、内容区、评论区），
 * 底部是操作栏（评论输入、点赞、分享）
 * @constraints: detail数据来源于postDetailService；评论列表最多显示3条，超过3条显示查看全部按钮；点赞状态通过liked字段控制
 * @isGen: true
 * @fileType: page
 * @zhName: 帖子详情
 * @domain: 旅游
 * @image: screenshots/homepage/PostDetail.jpg
 * @subPage: CommentPage
 * @component: CommonHeader,CommentItem,CommentInputBar
 */
import { BarVM, CommonHeader, TValueType, RouterMap, UserInfo } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { PostInfo, Comment, MyLikeList, LikesItem, MyPostList } from 'common_travel_guide'
import { CommentPageBuilder } from './CommentPage'
import { SharePicker } from 'aggregated_share';
import { PostDetailService } from '../common/service/PostDetailService'
import { CommentService } from '../common/service/CommentService'
import { CommentItem } from '../components/CommentItem'
import { CommentInputBar } from '../components/CommentInputBar'
import { AppStorageV2, PersistenceV2, window, UIContext, KeyboardAvoidMode } from '@kit.ArkUI';

@Builder
export function PostDetailPageBuilder(params: TValueType) {
  PostDetailPage({ post: params as PostInfo })
}

@ComponentV2
export struct PostDetailPage {
  @Param @Require post: PostInfo
  @Local detail: PostInfo | null = null
  @Local refreshKey: number = 0  // 用于强制刷新 UI
  @Local videoController: VideoController = new VideoController()
  @Local isPlaying: boolean = false
  @Local currentImageIndex: number = 0
  @Local isVideoPrepared: boolean = false
  @Local isCommentInputFocused: boolean = false
  @Local commentText: string = ''
  @Local likesList: MyLikeList = AppStorageV2.connect(MyLikeList, () => new MyLikeList())!
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!
  @Local myPostList: MyPostList = AppStorageV2.connect(MyPostList, () => new MyPostList())!
  scroller: Scroller = new Scroller()
  // 帖子详情服务
  private postDetailService: PostDetailService = PostDetailService.instance
  // 评论服务
  private commentService: CommentService = CommentService.instance

  aboutToAppear() {
    // 设置当前正在查看的帖子
    this.postDetailService.setCurrentPost(this.post.id)
    // 从服务获取详情
    this.refreshDetail()
    // 设置键盘避让模式为 NONE，防止键盘推动页面
    this.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
  }

  aboutToDisappear() {
    // 增加浏览量
    if (this.detail) {
      this.detail.views = (this.detail.views || 0) + 1
      this.postDetailService.updatePostDetail(this.detail)
    } else if (this.post) {
      this.post.views = (this.post.views || 0) + 1
      this.postDetailService.updatePostDetail(this.post)
    }
    this.postDetailService.clearCurrentPost()
    // 恢复键盘避让模式为默认值
    this.setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
  }


  // 设置键盘避让模式
  setKeyboardAvoidMode(mode: KeyboardAvoidMode) {
    window.getLastWindow(getContext()).then((currentWindow: window.Window) => {
      const uiContext: UIContext = currentWindow.getUIContext()
      uiContext.setKeyboardAvoidMode(mode)
    }).catch(() => {
    })
  }

  // 监听帖子详情变化
  @Monitor('postDetailService.currentPostDetail')
  onPostDetailChange(monitor: IMonitor) {
    const newDetail = monitor.value()?.now as PostInfo | null
    if (newDetail && newDetail.id === this.post.id) {
      this.detail = newDetail
      this.refreshKey++
    }
  }

  // 刷新帖子详情数据
  refreshDetail() {
    const originalDetail = this.postDetailService.getPostDetailById(this.post.id) || this.post
    if (originalDetail) {
      this.detail = originalDetail
      this.refreshKey++
    }
  }

  toggleVideoPlay() {
    if (this.isPlaying) {
      this.videoController.pause()
      this.isPlaying = false
    } else {
      this.videoController.start()
      this.isPlaying = true
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      pageBackgroundColor: '#fff',
    })
  }

  @Builder
  render() {
    Column() {
      CommonHeader({
        title: ((): string => {
          const currentDetail = this.postDetailService.getPostDetailById(this.post.id) || this.detail || this.post
          return currentDetail?.authorNickName || currentDetail?.userInfo.nickName || ''
        })(),
        avatarUrl: ((): ResourceStr => {
          const currentDetail = this.postDetailService.getPostDetailById(this.post.id) || this.detail || this.post
          return currentDetail?.authorAvatarUrl || currentDetail?.userInfo.avatarUrl || $r('app.media.path2x')
        })(),
        backgroundColorParam: '#fff',
        onReturnClick: () => {
          phoneRouterControl.popPage()
        },
      }).padding({ left: 16 })
      Scroll(this.scroller) {
        Column() {
          if (this.detail) {
            // 媒体区域（图片Swiper或视频AVPlayer）
            this.mediaArea(this.detail)
            // 内容区域
            Column() {
              // 标题
              Text(this.detail.title)
                .fontSize(16)
                .fontColor('#333333')
                .width('100%')
                .margin({ top: 16, bottom: 16 })

              // 正文内容
              Text(this.detail.content)
                .fontSize(14)
                .fontColor('#B3000000')
                .lineHeight(24)
                .width('100%')

              // 话题标签（如果有话题）
              if (this.detail.postTopic && this.detail.postTopic.trim() !== '') {
                Row() {
                  Text(`#${this.detail.postTopic}`)
                    .fontSize(10)
                    .fontColor('#5C7886')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#F6F8F9')
                    .borderRadius(10)
                }
                .width('100%')
                .margin({ top: 8 })
                .justifyContent(FlexAlign.Start)
              }

              // 发布信息
              Row() {
                Text(this.detail.publishTime)
                  .fontSize(12)
                  .fontColor('#80000000')
                Text(` 发布 `)
                  .fontSize(12)
                  .fontColor('#80000000')
                Text(this.detail.publishLocation)
                  .fontSize(12)
                  .fontColor('#80000000')
              }
              .margin({ top: 16 })
              .width('100%')

                Column({ space: 12 }) {
                  // 评论标题（使用 refreshKey 确保更新）
                  Row() {
                    Text(`评论 (${this.detail.commentCount || (this.detail.comments ? this.detail.comments.length : 0)})`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#111')
                    Blank()
                  }
                  .width('100%')
                  .margin({ top: 20, bottom: 8 })

                  if (this.detail.comments && this.detail.comments.length > 0) {

                    // 评论列表（最多显示3条）
                    // 使用 refreshKey 确保数据更新时 UI 刷新
                    ForEach(this.detail.comments.slice(0, 3), (comment: Comment) => {
                      CommentItem({
                        comment: comment,
                        detail: this.detail,
                        postDetailService: this.postDetailService
                      })
                    }, (comment: Comment) => `${comment.id}_${this.refreshKey}`)

                    // 查看全部评论按钮（如果评论超过3条）
                    if (this.detail.comments.length > 3) {
                      Row() {
                        Text('查看全部评论')
                          .fontSize(14)
                          .fontColor('#333')
                        Image($r('app.media.ic_right_button'))
                          .width(14)
                          .height(14)
                      }
                        .width('100%')
                      .justifyContent(FlexAlign.Center)
                        .padding({ top: 12, bottom: 12 })
                        .backgroundColor('#F6F8F9')
                        .borderRadius(24)
                        .onClick(() => {
                          if (this.detail) {
                            phoneRouterControl.jumpPage({
                              pageName: RouterMap.COMMENT_PAGE,
                              builder: wrapBuilder(CommentPageBuilder),
                              param: this.detail
                            })
                          }
                        })
                    }
                  }
                }.width('100%')

            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: BarVM.instance.aiBarH })
          }
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      this.bottomActionBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
    .padding({ top: BarVM.instance.staBarH, bottom: this.isCommentInputFocused ? 0 : BarVM.instance.staBarH })
  }


  @Builder
  mediaArea(detail: PostInfo) {
    // 判断是视频还是图片
    if (detail.videoUrl) {
      // 视频模式：使用Video组件
      this.videoPlayer(detail)
    } else if (detail.imgVideoList && detail.imgVideoList.length > 0) {
      // 图片模式：使用Swiper
      this.imageSwiper(detail)
    } else {
      // 默认显示封面图
      Image(detail.coverImg)
        .width('100%')
        .objectFit(ImageFit.Cover)
    }
  }

  @Builder
  videoPlayer(detail: PostInfo) {
    Stack() {
      // 视频播放器
      Video({
        src: detail?.videoUrl,
        controller: this.videoController,
        previewUri: detail?.coverImg
      })
        .width('100%')
        .height(400)
        .objectFit(ImageFit.Cover)
        .autoPlay(false)
        .controls(false)
        .onPrepared(() => {
          this.isVideoPrepared = true
        })
        .onStart(() => {
          this.isPlaying = true
        })
        .onPause(() => {
          this.isPlaying = false
        })
        .onStop(() => {
          this.isPlaying = false
        })
        .onFinish(() => {
          this.isPlaying = false
        })

      Row() {
        if (!this.isPlaying) {
          Image($r('app.media.ic_player'))
            .width(48)
            .height(48)
        }
      }
      .width('100%')
      .height(300)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.toggleVideoPlay()
      })
    }
    .width('100%')
  }

  @Builder
  imageSwiper(detail: PostInfo) {
    if (detail && detail.imgVideoList && detail.imgVideoList.length > 0) {
      Swiper() {
        ForEach(detail.imgVideoList, (img: ResourceStr) => {
          Image(img)
            .width('100%')
            .objectFit(ImageFit.Cover)
        }, (_img: ResourceStr, index: number) => `img_${index}`)
      }
      .indicator(
        new DotIndicator()
          .color($r('sys.color.comp_background_secondary'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .maxDisplayCount(9))
      .cachedCount(3)
      .index(this.currentImageIndex)
      .loop(false)
      .duration(300)
      .onChange((index: number) => {
        this.currentImageIndex = index
      })
    }
  }

  @Builder
  bottomActionBar() {
    Row() {
      CommentInputBar({
        commentText: this.commentText,
        isCommentInputFocused: this.isCommentInputFocused,
        inputBackgroundColor: '#F6F6F6',
        showWrapper: false,
        onTextChange: (value: string) => {
          this.commentText = value
        },
        onFocusCallback: () => {
          this.isCommentInputFocused = true
          setTimeout(() => {
            this.scroller.scrollEdge(Edge.Bottom)
          }, 200)
        },
        onBlurCallback: () => {
          this.isCommentInputFocused = false
        },
        onSubmit: () => {
          this.submitComment()
        }
      })

      // 点赞和分享按钮（输入框聚焦时隐藏）
      if (!this.isCommentInputFocused) {
        Row({ space: 16 }) {
          Column({ space: 4 }) {
            Image(((): ResourceStr => {
              const latestDetail = this.postDetailService.getPostDetailById(this.post.id) || this.detail
              return latestDetail?.liked ? $r('app.media.ic_liked') : $r('app.media.ic_liked_default')
            })())
              .width(20)
              .height(20)
            Text(((): string => {
              const latestDetail = this.postDetailService.getPostDetailById(this.post.id) || this.detail
              return latestDetail?.likes.toString() || '0'
            })())
              .fontSize(14)
              .fontColor('#333')
          }
          .onClick(() => {
            if (this.detail) {
              this.detail.handleLike()
              // 只有点赞自己的帖子时才添加到收到的赞列表
              // 通过MyPostList判断帖子是否属于当前用户
              const isMyPost = this.myPostList.getDataById(this.detail.id) !== undefined
              const date = new Date()
              let likeTime =
                `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate())
                  .padStart(2, '0')}`
              if (this.detail.liked && isMyPost) {
                const data = new LikesItem(
                  this.userInfo.nickName || '',
                  this.userInfo.avatarUrl || '',
                  likeTime,
                  this.detail.id || '',
                  this.detail.coverImg || ''
                );
                this.likesList.add(data);
              } else if (!this.detail.liked && isMyPost) {
                this.likesList.deleteById(this.detail.id);
              }
              // 保存点赞状态（通过服务更新，会自动触发 @Monitor 监听）
              this.postDetailService.updatePostDetail(this.detail)
            }
          })

          Column({ space: 4 }) {
            Image($r('app.media.ic_share_black'))
              .width(20)
              .height(20)
            Text('分享')
              .fontSize(14)
              .fontColor('#333')
          }
          .onClick(() => {
            const picker: SharePicker = new SharePicker({
              title: 'HarmonyOS官方模板集成创新活动',
            });
            picker.show();
          })
        }
        .padding({ left: 12 })
      }
    }
    .width('100%')
    .height(60)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
  }

  async submitComment() {
    const newComment = await this.commentService.submitCommentWithDeepCopy(this.commentText, this.detail)
    if (newComment) {
      this.postDetailService.updatePostDetail(this.detail!)
      this.commentText = ''
      this.isCommentInputFocused = false
    }
  }
}