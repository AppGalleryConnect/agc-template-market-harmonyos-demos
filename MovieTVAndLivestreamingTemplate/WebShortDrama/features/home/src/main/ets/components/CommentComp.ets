import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { AppStorageKeys, BreakPoint, BreakPointType, BreakPointValue,
  FontModel, UserInfoModel, CommentData, Reply, commentInputDialogBuilder } from '@agctemplate/widgets';
import { AppStorageV2, ComponentContent, display } from '@kit.ArkUI'
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { appRouter, container, Logger, WindowManager } from '@agctemplate/utils';
import { CommentInfo, CommentListRes, DramaInfo, ReplyInfo, RequestAPI } from '@agctemplate/server';

const TAG = '[CommentComp]'

@ComponentV2
export struct CommentComp {
  @Param @Require dramaInfo: DramaInfo
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(commentInputDialogBuilder), (textComment: string) => {
      this.publishComment(textComment)
    })
  private replyNode: ComponentContent<Object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(commentInputDialogBuilder), (textComment: string) => {
      this.replyComment(textComment)
    })
  @Local commentDataList: Array<CommentData> = []
  @Local moreList: Array<number> = []
  @Local commentId: number = 1
  @Local replyPerson: string = ''
  @Local replyContent: string = ''
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local isExpanded: boolean = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED
  @Local isTabletLandScape: boolean = deviceInfo.deviceType === 'tablet' &&
    (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED)
  @Event commentNum: Function = () => {
  }
  @Event closeSheet: Function = () => {
  }
  callback: Callback<number> = (data: number) => {
    if (deviceInfo.deviceType === 'tablet' &&
      (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
        display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED)) {
      this.isTabletLandScape = true
    } else {
      this.isTabletLandScape = false
    }
  }
  callback2: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      this.isExpanded = true
    } else {
      this.isExpanded = false
    }
  }

  // 发布评论
  publishComment(textComment: string): void {
    if (this.contentNode !== null) {
      this.getUIContext()
        .getPromptAction()
        .closeCustomDialog(this.contentNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
    this.commentDataList.unshift(new CommentData(this.commentDataList.length + 1, this.dramaInfo,
      this.dramaInfo.coverUrl, this.userInfo.avatar, this.userInfo.nickname, textComment, 0, false, 0, [], []))
    this.commentNum(this.commentDataList.length)
    this.moreList.unshift(0)
    container.resolve(RequestAPI).addComment({
      id: this.commentDataList.length,
      drama: this.dramaInfo,
      coverUrl: this.dramaInfo.coverUrl,
      avatar: this.userInfo.avatar,
      name: this.userInfo.nickname,
      commentContent: textComment,
      timeAgo: 0,
      isLike: false,
      likeCount: 0,
      likeList: [],
      replyList: []
    })
  }

  // 回复评论
  replyComment(textComment: string): void {
    if (this.replyNode !== null) {
      this.getUIContext()
        .getPromptAction()
        .closeCustomDialog(this.replyNode)
        .then(() => {
          Logger.info(TAG, 'CloseCustomDialog complete.')
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
    let index: number = -1
    this.commentDataList.forEach((item) => {
      if (item.id === this.commentId) {
        index = this.commentDataList.indexOf(item)
      }
    })
    this.commentDataList[index].replyList.unshift(new Reply(
      this.userInfo.avatar, this.userInfo.nickname, textComment, 0, false, 0, [], this.replyPerson, this.replyContent
    ))
    this.moreList[index] += 5
    container.resolve(RequestAPI).addReply({
      id: this.commentId,
      reply: {
        replyAvatar: this.userInfo.avatar,
        replyName: this.userInfo.nickname,
        replyContent: textComment,
        replyTimeAgo: 0,
        replyIsLike: false,
        replyLikeCount: 0,
        replyLikeList: [],
        replyPeople: this.replyPerson,
        replyComment: this.replyContent
      }
    })
  }

  aboutToAppear(): void {
    try {
      display.on('foldStatusChange', this.callback2)
      display.on('change', this.callback)
    } catch (e) {
    }
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.commentDataList = []
      this.moreList = []
      let commentListRes: CommentListRes = new CommentListRes(res.getBody())
      commentListRes.commentList?.map((commentInfo: CommentInfo) => {
        let replyListRes: Reply[] = []
        commentInfo.replyList?.map((replyInfo: ReplyInfo) => {
          replyListRes.push(new Reply(replyInfo.replyAvatar, replyInfo.replyName, replyInfo.replyContent,
            replyInfo.replyTimeAgo, replyInfo.replyIsLike, replyInfo.replyLikeCount, replyInfo.replyLikeList,
            replyInfo.replyPeople, replyInfo.replyComment))
        })
        this.commentDataList.push(new CommentData(commentInfo.id, commentInfo.drama, commentInfo.coverUrl,
          commentInfo.avatar, commentInfo.name, commentInfo.commentContent, commentInfo.timeAgo, commentInfo.isLike,
          commentInfo.likeCount, commentInfo.likeList, replyListRes))
        this.moreList.push(0)
      })
      this.commentNum(this.commentDataList.length)
    }).catch((error: Error) => {
      Logger.info(TAG, `get comment list failed:${error.message}`)
    })
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', this.callback2)
      display.off('change', this.callback)
    } catch (e) {
    }
  }

  openReplyDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.replyNode, {
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        Logger.info(TAG, 'reason' + JSON.stringify(dismissDialogAction.reason))
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
      alignment: DialogAlignment.Bottom
    })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `openCustomDialog error code is ${error.code}, message is ${error.message}`)
      })
  }

  openDialog() {
    this.getUIContext().getPromptAction().openCustomDialog(this.contentNode, {
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        Logger.info(TAG, 'reason' + JSON.stringify(dismissDialogAction.reason))
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss()
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
      alignment: DialogAlignment.Bottom
    })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `openCustomDialog error code is ${error.code}, message is ${error.message}`)
      })
  }

  build() {
    Column() {
      Row() {
        Text(`${this.commentDataList.length}条评论`)
          .lineHeight(this.fontModel.getDesFg(27))
          .fontSize(this.fontModel.getFg(20))
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
        Image(getMedia('app.media.close_btn'))
          .accessibilityText('返回')
          .width(40)
          .height(40)
          .onClick(() => {
            this.closeSheet()
          })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)

      List({ space: 12 }) {
        ForEach(
          this.commentDataList,
          (item: CommentData, index: number) => {
            ListItem() {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Image(item.avatar)
                    .width(16)
                    .height(16)
                    .borderRadius(8)
                  Text(item.name)
                    .accessibilityText(`昵称${item.name}`)
                    .lineHeight(this.fontModel.getDesFg(16))
                    .fontSize(this.fontModel.getFg(12))
                    .fontColor($r('sys.color.font_secondary'))
                }
                .width('100%')
                .height(this.fontModel.getDesFg(16))

                Row() {
                  Text(item.commentContent)
                    .lineHeight(this.fontModel.getDesFg(19))
                    .fontSize(this.fontModel.getFg(14))
                    .fontColor($r('sys.color.font_primary'))
                    .accessibilityText(`来自${item.name}的评论${item.commentContent}`)
                }
                .width('100%')
                .padding({ left: 24 })

                Row() {
                  Row() {
                    Row({ space: 8 }) {
                      Text(item.timeAgo < 1 ? '刚刚' : (item.timeAgo >= 60 ? `${Math.floor(item.timeAgo / 60)}小时前` :
                        `${item.timeAgo}分钟前`))
                        .accessibilityText(item.timeAgo < 1 ? '评论于刚刚' :
                          (item.timeAgo >= 60 ? `评论于${Math.floor(item.timeAgo / 60)}小时前` :
                            `评论于${item.timeAgo}分钟前`))
                        .lineHeight(this.fontModel.getDesFg(13))
                        .fontSize(this.fontModel.getFg(10))
                        .fontColor($r('sys.color.font_tertiary'))
                      Text('回复')
                        .accessibilityText('点击回复')
                        .lineHeight(this.fontModel.getDesFg(13))
                        .fontSize(this.fontModel.getFg(10))
                        .fontColor($r('sys.color.font_tertiary'))
                        .onClick(() => {
                          this.commentId = item.id
                          this.replyPerson = item.name
                          this.replyContent = item.commentContent
                          if (this.userInfo.isPhoneAssociated) {
                            this.openReplyDialog()
                          } else {
                            this.closeSheet()
                            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
                          }
                        })
                    }

                    Row({ space: 4 }) {
                      Image(item.isLike ? getMedia('app.media.thumb_select') : getMedia('app.media.hand_thumbsup'))
                        .accessibilityText(item.isLike ? '取消点赞' : '点赞')
                        .width(16)
                        .height(16)
                      Text(`${item.likeCount}`)
                        .accessibilityText(`有${item.likeCount}人点赞`)
                        .lineHeight(this.fontModel.getDesFg(13))
                        .fontSize(this.fontModel.getFg(10))
                        .fontColor($r('sys.color.font_tertiary'))
                    }
                    .onClick(() => {
                      if (item.isLike) {
                        this.commentDataList[index].likeCount--
                        this.commentDataList[index].isLike = false
                      } else {
                        this.commentDataList[index].likeCount++
                        this.commentDataList[index].isLike = true
                      }
                      container.resolve(RequestAPI).onCommentLike(item.id)
                    })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width('100%')
                .height(16)
                .padding({ left: 24 })

                // 更多评论
                if (item.replyList) {
                  Column({ space: 8 }) {
                    if (this.moreList[index] > 0) {
                      List({ space: 8 }) {
                        ForEach(
                          this.moreList[index] <= item.replyList.length ?
                            item.replyList.slice(0, this.moreList[index]) : item.replyList,
                          (each: Reply, replyIndex: number) => {
                            ListItem() {
                              Column({ space: 8 }) {
                                Row({ space: 8 }) {
                                  Image(each.replyAvatar)
                                    .width(16)
                                    .height(16)
                                    .borderRadius(8)
                                  Text(each.replyName)
                                    .accessibilityText(`昵称${each.replyName}`)
                                    .lineHeight(this.fontModel.getDesFg(16))
                                    .fontSize(this.fontModel.getFg(12))
                                    .fontColor($r('sys.color.font_secondary'))
                                }
                                .width('100%')
                                .height(this.fontModel.getDesFg(16))

                                Row() {
                                  Text() {
                                    if (each.replyPeople !== item.name) {
                                      Span('回复')
                                      Span(`@${each.replyPeople}`)
                                        .fontColor($r('sys.color.font_secondary'))
                                      Span('：')
                                    }
                                    Span(each.replyContent)
                                  }
                                  .accessibilityGroup(true)
                                  .accessibilityText(each.replyPeople !== item.name ?
                                    `${each.replyName}回复${each.replyPeople}说${each.replyContent}` :
                                    `${each.replyName}回复说${each.replyContent}`)
                                  .lineHeight(this.fontModel.getDesFg(19))
                                  .fontSize(this.fontModel.getFg(14))
                                  .fontColor($r('sys.color.font_primary'))
                                }
                                .width('100%')
                                .padding({ left: 24 })

                                Row() {
                                  Row() {
                                    Row({ space: 8 }) {
                                      Text(each.replyTimeAgo < 1 ? '刚刚' : (each.replyTimeAgo >= 60 ?
                                        `${Math.floor(each.replyTimeAgo / 60)}小时前` : `${each.replyTimeAgo}分钟前`))
                                        .accessibilityText(each.replyTimeAgo < 1 ? '回复于刚刚' :
                                          (each.replyTimeAgo >= 60 ?
                                            `回复于${Math.floor(each.replyTimeAgo / 60)}小时前` :
                                            `回复于${each.replyTimeAgo}分钟前`))
                                        .lineHeight(this.fontModel.getDesFg(13))
                                        .fontSize(this.fontModel.getFg(10))
                                        .fontColor($r('sys.color.font_tertiary'))
                                      Text('回复')
                                        .accessibilityText('点击回复')
                                        .lineHeight(this.fontModel.getDesFg(13))
                                        .fontSize(this.fontModel.getFg(10))
                                        .fontColor($r('sys.color.font_tertiary'))
                                        .onClick(() => {
                                          this.commentId = item.id
                                          this.replyPerson = each.replyName
                                          this.replyContent = each.replyContent
                                          if (this.userInfo.isPhoneAssociated) {
                                            this.openReplyDialog()
                                          } else {
                                            this.closeSheet()
                                            WindowManager.setWindowSystemBarProperties({
                                              statusBarContentColor: '#e6000000'
                                            })
                                            appRouter.push({
                                              builderName: NAV_PAGE_NAME.LoginPage.name,
                                              params: { isChange: true }
                                            })
                                          }
                                        })
                                    }

                                    Row({ space: 4 }) {
                                      Image(each.replyIsLike ? getMedia('app.media.thumb_select') :
                                        getMedia('app.media.hand_thumbsup'))
                                        .accessibilityText(each.replyIsLike ? '取消点赞' : '点赞')
                                        .width(16)
                                        .height(16)
                                      Text(`${each.replyLikeCount}`)
                                        .accessibilityText(`有${each.replyLikeCount}人点赞`)
                                        .lineHeight(this.fontModel.getDesFg(13))
                                        .fontSize(this.fontModel.getFg(10))
                                        .fontColor($r('sys.color.font_tertiary'))
                                    }
                                    .onClick(() => {
                                      if (each.replyIsLike) {
                                        this.commentDataList[index].replyList[replyIndex].replyLikeCount--
                                      } else {
                                        this.commentDataList[index].replyList[replyIndex].replyLikeCount++
                                      }
                                      this.commentDataList[index].replyList[replyIndex].replyIsLike =
                                        !this.commentDataList[index].replyList[replyIndex].replyIsLike
                                      container.resolve(RequestAPI).onReplyLike({
                                        id: item.id,
                                        index: replyIndex
                                      })
                                    })
                                  }
                                  .width('100%')
                                  .justifyContent(FlexAlign.SpaceBetween)
                                }
                                .width('100%')
                                .height(16)
                                .padding({ left: 24 })
                              }
                              .width('100%')
                            }
                            .width('100%')
                          },
                          (each: Reply, replyIndex: number) => each.replyContent + '_' + replyIndex.toString()
                        )
                      }
                      .width('100%')
                    }

                    if (item.replyList.length - this.moreList[index] > 0) {
                      Row() {
                        Text(`展开更多${item.replyList.length - this.moreList[index]}条`)
                          .lineHeight(this.fontModel.getDesFg(16))
                          .fontSize(this.fontModel.getFg(12))
                          .fontColor($r('sys.color.font_secondary'))
                        Image(getMedia('app.media.arrow_down_black'))
                          .width(16)
                          .height(16)
                      }
                      .onClick(() => {
                        this.moreList[index] += 5
                      })
                    }
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .padding({ left: 24 })
                }
              }
              .width('100%')
            }
            .width('100%')
          },
          (item: CommentData, index: number) => item.id.toString()
        )
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Text('发表评论')
          .lineHeight(this.fontModel.getDesFg(21))
          .fontSize(this.fontModel.getFg(16))
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height(40)
      .borderRadius(24)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .margin({ top: 17 })
      .padding({ left: 12 })
      .onClick(() => {
        if (this.userInfo.isPhoneAssociated) {
          this.openDialog()
        } else {
          this.closeSheet()
          appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
        }
      })
    }
    .width(this.isTabletLandScape ? '40%' : this.isExpanded ? '50%' : '100%')
    .height(this.isTabletLandScape || this.isExpanded ? '90%' : '60%')
    .padding({
      left: new BreakPointType<number>({ sm: 16, md: 24, lg: 32 }).getValue(this.currentBreakpoint.value),
      top: 8,
      right: new BreakPointType<number>({ sm: 16, md: 24, lg: 32 }).getValue(this.currentBreakpoint.value),
      bottom: 16
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function commentBuilder(commentParam: CommentParam) {
  CommentComp({
    dramaInfo: commentParam.dramaInfo,
    commentNum: commentParam.commentNum,
    closeSheet: commentParam.closeSheet
  })
}

export interface CommentParam {
  dramaInfo: DramaInfo
  commentNum: Function
  closeSheet: Function
}