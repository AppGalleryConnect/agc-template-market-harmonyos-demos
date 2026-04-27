import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { TopBar } from '../component/TopBar'
import { AlertDialog } from '@kit.ArkUI'
import { GetLiveListRes, LiveInfoModel } from '@agctemplate/server/src/main/ets/bean/response/GetLiveInfoRes'
import { getMedia } from '@agctemplate/resources'
import { BarVM } from '@agctemplate/widgets'
import { container } from '@agctemplate/utils'
import { RequestAPI } from '@agctemplate/server'

@ComponentV2
export struct WatchRecordPage {
  @Local isDeleting: boolean = false
  @Local selectCount: number = 0
  @Local isAll: boolean = false
  @Local deleteOnePromptMsg: string | Resource = '此条'
  @Local deleteAllPromptMsg: string | Resource = '全部'
  @Local deleteMultiPromptMsg: string | Resource = `%d条`
  @Local deletePromptMsg: string | Resource = '此条'
  @Local watchRecordList: WatchRecordItem[] = []
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.delete_message_prompt', this.deletePromptMsg.toString()),
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: $r('sys.color.ohos_id_color_warning'),
        action: () => {
          if (this.selectCount > 0) {
            // 删除选中
            this.deleteSelectData()
          }
        },
      },
    }),
  })

  async aboutToAppear() {
    // 模拟
    const liveInfoListRes = await container.resolve(RequestAPI).getMyWatchRecord()
    this.watchRecordList = (liveInfoListRes.getBody() as GetLiveListRes).liveList.map(liveInfo => {
      return new WatchRecordItem(
        liveInfo.id,
        liveInfo.url,
        liveInfo.cover,
        liveInfo.status === '直播中' ? Status.Live : Status.Ended,
        liveInfo.title,
        liveInfo.streamer.nickName,
        liveInfo.category,
        new Date(liveInfo.watchTime),
        liveInfo.watching,
        getMedia('app.media.avatar'),
        false,
        0
      )
    })

    this.watchRecordList.sort((a, b) => {
      if (a.status !== b.status) {
        return a.status === Status.Live ? -1 : 1;
      }
      return b.watchTime.getTime() - a.watchTime.getTime();
    })
  }

  aboutToDisappear(): void {
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部
        this.topBuilder()
        Column() {
          if (this.watchRecordList.length > 0) {
            this.WatchRecordItemsBuilder()
          } else {
            Text('暂无观看记录')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width('100%')

        Blank()
        this.footItemBuilder()
      }
      .width('100%')
      .height('100%')
      .padding({
        left: $r('app.float.vp_16'),
        right: $r('app.float.vp_16'),
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
      .backgroundColor($r('sys.color.background_secondary'))

    }
    .hideTitleBar(true)
  }

  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          RouterModule.pop()
        },
        title: '观看记录'
      })
      Row() {
        Button(this.isDeleting ? '取消' : '编辑')
          .margin({ left: $r('app.float.vp_8') })
          .height($r('app.float.vp_40'))
          .borderRadius(20)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .onClick(() => {
        if (this.watchRecordList.length > 0) {
          this.isDeleting = !this.isDeleting
          if (!this.isDeleting) {
            this.isAll = false
            this.selectCount = 0
            this.watchRecordList.forEach((item: WatchRecordItem) => {
              item.isSelectToDelete = false
            })
          }
        }
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.vp_56'))
    .width('100%')
  }

  @Builder
  delete(index: number) {
    Column(){
      Column() {
        Image($r('app.media.icon_delete_2'))
          .width(16)
      }
      .justifyContent(FlexAlign.Center)
      .width(40)
      .aspectRatio(1)
      .borderRadius(20)
      .backgroundColor($r('sys.color.warning'))
      .margin({
        right: 16,
        left: 16
      })
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      let ids: string[] = [this.watchRecordList[index].id]
      this.deleteRemoteData(ids)
      this.watchRecordList.splice(index, 1)

      this.getUIContext().getPromptAction().showToast({
        message: '删除成功'
      })
    })
  }

  @Builder
  WatchRecordItemsBuilder() {
    List() {
      ForEach(this.watchRecordList, ((item: WatchRecordItem, index: number) => {
        ListItem() {
          Row() {
            if (this.isDeleting) {
              Checkbox()
                .selectedColor('#EC6E45')
                .unselectedColor($r('sys.color.icon_secondary'))
                .margin({ right: 14 })
                .onChange((value: boolean) => {
                  item.isSelectToDelete = value
                  if (item.isSelectToDelete) {
                    this.selectCount++
                  } else {
                    this.selectCount--
                  }
                  if (this.selectCount < this.watchRecordList.length) {
                    this.isAll = false
                  } else {
                    this.isAll = true
                  }
                })
            }

            Row() {
              Stack({ alignContent: Alignment.TopStart }) {
                Image(getMedia(item.cover))
                  .width(96)
                  .height(54)
                  .borderRadius(8)

                Text(item.status)
                  .textAlign(TextAlign.Center)
                  .fontWeight(500)
                  .fontSize(10)
                  .lineHeight(13)
                  .fontColor($r('sys.color.font_on_primary'))
                  .borderRadius({ topLeft: 8, bottomRight: 8 })
                  .backgroundColor(item.status === '直播中' ? $r('sys.color.multi_color_08') : 'rgba(0,0,0,0.4)')
                  .width(38)
                  .height(16)
              }
              .margin({ right: 12 })

              Column() {
                Column() {
                  Text(item.title)
                    .width('100%')
                    .maxLines(2)
                    .lineHeight(19)
                    .fontSize(14)
                    .fontWeight(500)
                    .fontColor($r('sys.color.font_primary'))
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .onClick(() => {
                      this.goToLive(item.title, item.status, item.id)
                    })

                  Text() {
                    Span(item.streamer)
                      .onClick(() => {
                        this.goToLiver(item.streamer)
                      })
                    Span(' | ')
                    Span(this.getDisplayTime(item.watchTime))
                  }
                  .fontSize(12)
                  .fontWeight(400)
                  .lineHeight(16)
                  .fontColor($r('sys.color.font_tertiary'))
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceBetween)
                .height(56)
                .width(220)

              }
              .justifyContent(FlexAlign.Center)
              .height(88)
              .border({ width: { bottom: 0.5 }, color: $r('sys.color.comp_divider') })
            }
            .onClick(() => {
              this.goToLive(item.url, item.status, item.id)
            })
          }
        }
        .swipeAction({
          end: {
            builder: () => {
              this.delete(index)
            }
          }
        })
        .width('100%')
        .transition({ type: TransitionType.Delete, opacity: 0 })
      }), (item: WatchRecordItem, index: number) => item.id + index)
    }
    .lanes({minLength:328,maxLength:692},32)
    .margin({ bottom: this.isDeleting ? 0 : 60 })
    .height(this.isDeleting ? '85%' : 'auto')
    .width('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  footItemBuilder() {
    if (this.isDeleting) {
      Row() {
        Column() {
          Image($r('app.media.ic_public_delete_all'))
            .width(22)
            .height(22)
          Text('一键清空')
            .height(14)
            .fontSize(13)
            .margin({ top: 5.36 })
        }
        .width('50%')
        .onClick(() => {
          this.onDeleteAllData()
        })

        Column() {
          Image($r('app.media.ic_public_delete'))
            .width(22)
            .height(22)
          Text('删除')
            .height(14)
            .fontSize(13)
            .margin({ top: 5.36 })
        }
        .width('50%')
        .opacity(this.selectCount > 0 ? 1 : 0.4)
        .onClick(() => {
          this.onDeleteData()
        })
      }
      .width('100%')
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8') })
    }
  }


  goToLive(url: string, status: Status, id: string) {
    if (!this.isDeleting) {
      if (status === Status.Live) {
        RouterModule.stack.pushPathByName(RouterMap.DETAIL_PAGE, Number(id))
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '直播已结束' })
      }
    }
  }

  goToLiver(streamer: string) {
    if (!this.isDeleting) {
      this.getUIContext().getPromptAction().showToast({
        message: `去主播主页${streamer}`
      })
    }
  }

  // 返回时间
  getDisplayTime(watchTime: Date): string {
    const now = new Date();
    const watchDate = new Date(watchTime);
    if (watchDate.toDateString() === now.toDateString()) {
      return watchDate.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false });
    }
    const yesterday = new Date(now);
    yesterday.setDate(now.getDate() - 1);
    if (watchDate.toDateString() === yesterday.toDateString()) {
      return `昨天 ${watchDate.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false })}`;
    }
    return `${watchDate.toLocaleDateString('zh-CN',
      { month: '2-digit', day: '2-digit' })} ${watchDate.toLocaleTimeString('zh-CN',
      { hour: '2-digit', minute: '2-digit', hour12: false })}`;
  }

  onDeleteData() {
    if (this.selectCount < 1) {
      return
    }
    if (this.selectCount === 1) {
      this.deletePromptMsg = this.deleteOnePromptMsg
    } else {
      this.deletePromptMsg = (this.selectCount + '条')
    }
    this.deleteDialogController.open()
  }

  deleteRemoteData(deleteIds: string[]): void {
    this.watchRecordList.map((value: WatchRecordItem) => {
      if (value.isSelectToDelete) {
        deleteIds.push(value.id)
      }
    })
    container.resolve(RequestAPI).removeMyWatchRecord(deleteIds)
  }

  onDeleteAllData() {
    this.deletePromptMsg = this.deleteAllPromptMsg
    let ids: string[] = []
    this.watchRecordList.forEach((item: WatchRecordItem) => {
      item.isSelectToDelete = true
    })
    this.selectCount = this.watchRecordList.length
    this.deleteDialogController.open()
  }

  // 移除所选中的
  deleteSelectData() {
    let ids: string[] = []
    this.watchRecordList.map((value: WatchRecordItem) => {
      if (value.isSelectToDelete) {
        ids.push(value.id)
      }
    })
    this.watchRecordList =
      this.watchRecordList.filter((it: WatchRecordItem) => it.isSelectToDelete === false)
    this.deleteRemoteData(ids)
    this.isDeleting = false
    this.selectCount = 0
  }

  // 是否全选
  isAllClick() {
    if (!this.isAll) {
      this.watchRecordList.forEach((item: WatchRecordItem) => {
        item.isSelectToDelete = true
      })
      this.selectCount = this.watchRecordList.length
      this.isAll = true
    } else {
      this.watchRecordList.forEach((item: WatchRecordItem) => {
        item.isSelectToDelete = false
      })
      this.selectCount = 0
      this.isAll = false
    }
  }
}


// 定义直播状态的枚举
enum Status {
  Live = '直播中',
  Ended = '已结束'
}

@ObservedV2
export class WatchRecordItem {
  @Trace id: string
  @Trace url: string
  @Trace cover: string
  @Trace title: string
  @Trace streamer: string
  @Trace category: string
  @Trace status: Status
  @Trace watchTime: Date
  @Trace watching: number
  @Trace avatar: ResourceStr
  @Trace isSelectToDelete: boolean = false
  @Trace preferType: number

  constructor(
    id: string,
    url: string,
    cover: string,
    status: Status,
    title: string,
    streamer: string,
    category: string,
    watchTime: Date,
    watching: number,
    avatar: ResourceStr,
    isSelectToDelete: boolean = false,
    preferType: number = 0
  ) {
    this.id = id
    this.url = url
    this.cover = cover
    this.status = status
    this.title = title
    this.streamer = streamer
    this.category = category
    this.watchTime = watchTime
    this.watching = watching
    this.avatar = avatar
    this.isSelectToDelete = isSelectToDelete
    this.preferType = preferType
  }
}

@Builder
export function WatchRecordPageBuilder() {
  WatchRecordPage();
}