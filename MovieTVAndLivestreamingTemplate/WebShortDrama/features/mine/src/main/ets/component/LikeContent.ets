import { jumpDetailPage, MyMessageStorage } from '@agctemplate/detail'
import { WindowManager } from '@agctemplate/utils'
import { CommentData, LikeItem } from '@agctemplate/widgets'
import { LikeCard } from './LikeCard'
import { AppStorageV2 } from '@kit.ArkUI'

@ObservedV2
class DetailPageStatus {
  @Trace isQuit: boolean

  constructor(isQuit: boolean) {
    this.isQuit = isQuit
  }
}

@ComponentV2
export struct LikeContent {
  @Param commentDataList: Array<CommentData> = []
  @Param myMessageList: Array<CommentData> = []
  @Local myMessageStorage: MyMessageStorage = MyMessageStorage.instance()
  @Local detailPageStatus: DetailPageStatus = AppStorageV2.connect(DetailPageStatus, () => new DetailPageStatus(true))!

  build() {
    List() {
      ForEach(
        this.myMessageList,
        (item: CommentData) => {
          ForEach(
            item.likeList,
            (each: LikeItem) => {
              ListItem() {
                LikeCard({
                  myMessage: item,
                  likeItem: each
                })
              }
              .onClick(() => {
                if (this.detailPageStatus.isQuit) {
                  jumpDetailPage(item.drama, item.drama.curIndex, 0, () => {
                    WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  })
                  this.myMessageStorage.isShowCommentSheet = true
                  let commentIndex: number = this.commentDataList.indexOf(item)
                  if (commentIndex === 0) {
                    this.myMessageStorage.scrollIndex = commentIndex
                  } else {
                    this.myMessageStorage.scrollIndex = commentIndex
                    this.commentDataList.slice(0, commentIndex).forEach((comment) => {
                      if (comment.replyList.length > 0) {
                        this.myMessageStorage.scrollIndex++
                      }
                    })
                  }
                }
              })
            }, (item: LikeItem) => item.likeAvatar + item.likeName + item.likeTime.toString()
          )
        }, (item: CommentData) => item.id.toString()
      )
      ListItem()
        .width('100%')
        .height(30)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}