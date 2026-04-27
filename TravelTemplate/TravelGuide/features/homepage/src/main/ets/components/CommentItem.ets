import { Comment, PostInfo } from 'common_travel_guide'
import { PostDetailService } from '../common/service/PostDetailService'

/**
 * 评论项组件
 */
@ComponentV2
export struct CommentItem {
  @Param comment: Comment = new Comment('', '', '')
  @Param detail: PostInfo | null = null
  @Param postDetailService: PostDetailService = PostDetailService.instance

  build() {
    Column() {
      Row({ space: 8 }) {
        // 用户头像
        Image(this.comment.avatarUrl || 
          (typeof this.comment.userInfo.avatarUrl === 'string' ? this.comment.userInfo.avatarUrl : '') ||
          $r('app.media.path2x'))
          .width(32)
          .height(32)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.ic_attraction'))

        // 评论内容
        Column({ space: 5 }) {
          Text(this.comment.nickName || this.comment.userInfo.nickName || '')
            .fontSize(12)
            .fontColor('#80000000')

          Text(this.comment.content)
            .fontSize(14)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 评论信息
          Row({ space: 12 }) {
            Text(this.comment.commentTime)
              .fontSize(10)
              .fontColor('#80000000')
            Text(this.comment.commentLocation)
              .fontSize(10)
              .fontColor('#80000000')
          }
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Blank()

        Column({ space: 2 }) {
          Image(this.comment.liked ? $r('app.media.ic_like') : $r('app.media.ic_like_default'))
            .width(14)
            .height(14)
          Text(this.comment.likes.toString())
            .fontSize(10)
            .fontColor('#80000000')
        }
        .onClick(() => {
          this.comment.handleLike()
          // 保存评论点赞状态（通过服务更新，会自动触发 @Monitor 监听）
          if (this.detail) {
            this.postDetailService.updatePostDetail(this.detail)
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }
}
