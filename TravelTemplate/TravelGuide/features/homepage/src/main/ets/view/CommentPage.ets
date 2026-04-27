/**
 * @usage: 评论列表页面，展示帖子的全部评论，支持发表新评论和回复评论
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，中间是可滚动的评论列表，底部是评论输入栏
 * @constraints: detail为帖子详情数据；comments为评论列表；通过postDetailService和commentService管理评论数据
 * @isGen: true
 * @fileType: page
 * @zhName: 评论列表
 * @domain: 旅游
 * @image: screenshots/homepage/Comment.jpg
 * @component: CommonHeader,CommentItem,CommentInputBar
 */
import { BarVM, CommonHeader, TValueType } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { PostInfo, Comment } from 'common_travel_guide'
import { PostDetailService } from '../common/service/PostDetailService'
import { CommentService } from '../common/service/CommentService'
import { CommentItem } from '../components/CommentItem'
import { CommentInputBar } from '../components/CommentInputBar'

@Builder
export function CommentPageBuilder(params: TValueType) {
  CommentPage({ post: params as PostInfo })
}

@ComponentV2
export struct CommentPage {
  @Param post: PostInfo = new PostInfo('', '', '', '')
  @Local detail: PostInfo | null = null
  @Local isCommentInputFocused: boolean = false
  @Local commentText: string = ''
  // 帖子详情服务
  private postDetailService: PostDetailService = PostDetailService.instance
  // 评论服务
  private commentService: CommentService = CommentService.instance

  aboutToAppear() {
    // 从服务获取详情
    this.detail = this.postDetailService.getPostDetailById(this.post.id) || this.post
  }

  async submitComment() {
    const newComment = await this.commentService.submitComment(this.commentText, this.detail)
    if (newComment) {
      // 通过服务更新帖子详情（会自动触发 @Monitor 监听）
      this.postDetailService.updatePostDetail(this.detail!)
      // 清空输入框
      this.commentText = ''
      this.isCommentInputFocused = false
    }
  }

  @Builder
  render() {
    Column() {
      CommonHeader({
        title: `共${this.detail?.commentCount || 0}条评论`,
        backgroundColorParam: '#fff',
        onReturnClick: () => {
          phoneRouterControl.popPage()
        },
      })
      Scroll() {
        Column({ space: 12 }) {
          if (this.detail && this.detail.comments && this.detail.comments.length > 0) {
            ForEach(this.detail.comments, (comment: Comment) => {
              CommentItem({
                comment: comment,
                detail: this.detail,
                postDetailService: this.postDetailService
              })
            }, (comment: Comment) => comment.id)
          } else {
            Column() {
              Text('暂无评论')
                .fontSize(14)
                .fontColor('#999')
            }
            .width('100%')
            .padding({ top: 100 })
          }
        }
        .width('100%')
        .padding({ bottom: BarVM.instance.aiBarH + 80 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

      // 底部输入栏
      this.bottomActionBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
    .padding({ top: BarVM.instance.staBarH, bottom: this.isCommentInputFocused ? 0 : BarVM.instance.staBarH })
  }

  @Builder
  bottomActionBar() {
    CommentInputBar({
      commentText: this.commentText,
      isCommentInputFocused: this.isCommentInputFocused,
      onTextChange: (value: string) => {
        this.commentText = value
      },
      onFocusCallback: () => {
        this.isCommentInputFocused = true
      },
      onBlurCallback: () => {
        this.isCommentInputFocused = false
      },
      onSubmit: () => {
        this.submitComment()
      }
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      pageBackgroundColor: '#fff',
      useSafePadding: true,
    })
  }
}

