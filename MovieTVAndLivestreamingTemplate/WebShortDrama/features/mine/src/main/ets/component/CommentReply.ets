import { RequestAPI } from '@agctemplate/server';
import { container } from '@agctemplate/utils';
import { CommentData, Reply } from '@agctemplate/widgets';
import { MineMessageCard } from './MineMessageCard';
import { CommentInfo, CommentListRes, LikeInfo } from '@agctemplate/server';
import { jumpDetailPage, MyMessageStorage } from '@agctemplate/detail';
import { WindowManager } from '@agctemplate/utils';

@Preview
@ComponentV2
export struct CommentReply {
  @Param mineMessageList: Array<CommentData> = []
  @Local myMessageStorage: MyMessageStorage = MyMessageStorage.instance()

  aboutToAppear(): void {
    container.resolve(RequestAPI).getRelyList({
      pageSize: 0,
      pageNum: 20
    })
      .then((response) => {
        let commentListRes: CommentListRes = new CommentListRes(response.getBody())
        commentListRes.commentList?.map((commentInfo: CommentInfo) => {
          this.mineMessageList.push(commentInfo as CommentData)
        })
      })
  }

  build() {
    List() {
      ForEach(
        this.mineMessageList,
        (item: CommentData) => {
          ForEach(
            item.replyList,
            (each: Reply, index: number) => {
              if (each.replyPeople === item.name) {
                ListItem() {
                  MineMessageCard({
                    replyAvatar: each.replyAvatar,
                    replyName: each.replyName,
                    replyTimeAgo: each.replyTimeAgo,
                    replyContent: each.replyContent,
                    coverUrl: item.coverUrl,
                    commentContent: item.commentContent
                  })
                }
                .onClick(() => {
                  //点击跳转详情页
                  jumpDetailPage(item.drama, item.drama.curIndex, 0, () => {
                    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  })
                  this.myMessageStorage.isShowCommentSheet = true
                  this.myMessageStorage.isSpread = true
                  let commentIndex: number = this.mineMessageList.indexOf(item)
                  this.myMessageStorage.moreList[commentIndex] = index - index % 5 + 5
                  if (commentIndex === 0) {
                    this.myMessageStorage.scrollIndex = index
                  } else {
                    this.mineMessageList.slice(0, commentIndex).forEach((comment) => {
                      if (comment.replyList.length > 0) {
                        this.myMessageStorage.scrollIndex++
                      }
                    })
                    this.myMessageStorage.scrollIndex += (commentIndex + index)
                  }
                }
                )
              }
            }, (item: Reply) => item.replyName + item.replyContent + item.replyTimeAgo.toString()
          )
        }, (item: CommentData) => item.id.toString()
      )
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}