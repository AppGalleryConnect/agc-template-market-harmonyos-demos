import { foldTexBuilder, FoldText } from '../component/FoldText'
import { TopBar } from '../component/TopBar'
import { AlertDialog, AppStorageV2, curves } from '@kit.ArkUI'
import { RouterModule } from '@agctemplate/router_module'
import { BarVM } from '@agctemplate/widgets'

@ComponentV2
struct SystemMessagePage {
  @Local isDeleting: boolean = false
  @Local selectCount: number = 0
  @Local isAll: boolean = false
  @Local deleteOnePromptMsg: string | Resource = '此条'
  @Local deleteAllPromptMsg: string | Resource = '全部'
  @Local deleteMultiPromptMsg: string | Resource = `%d条`
  @Local deletePromptMsg: string | Resource = '此条'
  @Local systemMsgList: SystemMsgList = AppStorageV2.connect(SystemMsgList, () => new SystemMsgList())!
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

  aboutToAppear(): void {
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部
        this.topBuilder()
        Column() {
          if (this.systemMsgList.listArr.length > 0) {
            this.SystemMsgItemsBuilder()

          } else {
            Text('当前暂无系统消息。')
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
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })

    }.hideTitleBar(true)
    .onBackPressed(() => {
      RouterModule.pop('result')
      return true
    })

  }

  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          RouterModule.pop('result')
        },
        title: '系统消息'
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
        if (this.systemMsgList.listArr.length > 0) {
          this.isDeleting = !this.isDeleting
          if (!this.isDeleting) {
            this.isAll = false
            this.selectCount = 0
            this.systemMsgList.listArr.forEach((item: SystemMsgItem) => {
              item.isSelectToDelete = false
            })
          }
        }
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  @Builder
  SystemMsgItemsBuilder() {
    List({ space: 12 }) {
      ForEach(this.systemMsgList.listArr, ((item: SystemMsgItem, index: number) => {
        ListItem() {
          Badge({
            value: '',
            position: BadgePosition.RightTop,
            style: {
              badgeSize: item.isRead ? 0 : 6,
              badgeColor: $r('sys.color.warning')
            }
          }) {
            Row() {
              if (this.isDeleting) {
                Checkbox()
                  .selectedColor('#EC6E45')
                  .unselectedColor($r('sys.color.icon_secondary'))
                  .margin({ right: 14 })
                  .onChange((value: boolean) => {
                    item.isSelectToDelete = value
                    item.isSelectToDelete ? this.selectCount++ : this.selectCount--
                    this.isAll = !(this.selectCount < this.systemMsgList.listArr.length)
                  })
              }
              Row() {
                Column() {
                  Row() {
                    Image($r('app.media.icon_envelope'))
                      .width(16)
                      .height(16)
                    Text('系统消息')
                      .height(19)
                      .fontSize(14)
                      .margin({ left: 4 })
                      .fontColor($r('sys.color.font_secondary'))

                    Blank()
                    Text(this.getTimeAgo(item.time))
                      .fontSize(12)
                      .lineHeight(16)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')

                  Text(item.title)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .height(21)
                    .margin({ top: 12, bottom: 4 })
                    .width('100%')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  foldTexBuilder(item.subTitle, () => {
                    item.isRead = true
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start)
              }
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .padding({
                left: 12,
                right: 12,
                top: 16,
                bottom: 16
              })
              .borderRadius(16)
            }
          }

        }
        .onClick(() => {
          item.isRead = true
        })
        .swipeAction({
          end: {
            builder: () => {
              this.delete(index)
            }
          }
        })
        .borderRadius(16)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .backgroundColor($r('sys.color.background_secondary'))
        .margin({ left: 12, right: 12 })
      }), (item: SystemMsgItem, index: number) => item.id + index)
    }
    .height(this.isDeleting ? '85%' : 'auto')
    .margin({ top: 8, bottom: this.isDeleting ? 0 : 40 })
    .width('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  delete(index: number) {
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
    .onClick(() => {
      this.systemMsgList.listArr.splice(index, 1)
      this.getUIContext().getPromptAction().showToast({
        message: '删除成功'
      })
    })
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

  // 转化时间差
  getTimeAgo(date: Date) {
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const seconds = Math.floor(diff / 1000)

    if (seconds < 60) {
      return '刚刚'
    }
    const minutes = Math.floor(seconds / 60)
    if (minutes < 60) {
      return `${minutes}分钟前`
    }
    const hours = Math.floor(minutes / 60)
    if (hours < 24) {
      return `${hours}小时前`
    }
    const days = Math.floor(hours / 24)
    if (days === 1) {
      return '昨天'
    }
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
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

  onDeleteAllData() {
    this.deletePromptMsg = this.deleteAllPromptMsg
    this.systemMsgList.listArr.forEach((item: SystemMsgItem) => {
      item.isSelectToDelete = true
    })
    this.selectCount = this.systemMsgList.listArr.length
    this.deleteDialogController.open()
  }

  // 移除所选中的
  deleteSelectData() {
    this.systemMsgList.listArr = this.systemMsgList.listArr.filter((it: SystemMsgItem) => it.isSelectToDelete === false)
    this.isDeleting = false
    this.selectCount = 0
  }

  // 是否全选
  isAllClick() {
    if (!this.isAll) {
      this.systemMsgList.listArr.forEach((item: SystemMsgItem) => {
        item.isSelectToDelete = true
      })
      this.selectCount = this.systemMsgList.listArr.length
      this.isAll = true
    } else {
      this.systemMsgList.listArr.forEach((item: SystemMsgItem) => {
        item.isSelectToDelete = false
      })
      this.selectCount = 0
      this.isAll = false
    }
  }
}


@ObservedV2
export class SystemMsgList {
  @Trace listArr: SystemMsgItem[] = [
    new SystemMsgItem('1', '用户协议及隐私政策更新通知',
      '这是正文内容', false, new Date()),
    new SystemMsgItem('2', '用户协议及隐私政策更新通知',
      '这是正文内容，默认展示三行，超出三行部分省略展示，点击全文展示全部内容。', false,
      new Date(Date.now() - 2 * 60 * 60 * 1000)),
    new SystemMsgItem('3', '用户协议及隐私政策更新通知',
      '这是正文内容，默认展示三行，超出三行部分省略展示，点击全文展示全部内容。这是正文内容，默认展示三行，超出三行部分省略展示。',
      false, new Date(Date.now() - 24 * 60 * 60 * 1000)),
    new SystemMsgItem('4', '用户协议及隐私政策更新通知',
      'XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的保护措施。  1、我们如何收集和使用您的个人信息 ......  4、对儿童的保护  5、与第三方共享（共享）  6、管理您的数据  7、数据存储地点及期限  8、如何联系我们  华为将始终遵照我们的隐私政策来收集和使用您的信息。有关我们的隐私政策，可参阅华为消费者业务隐私声明。',
      false, new Date('2025-07-08')),
    new SystemMsgItem('5', '用户协议及隐私政策更新通知',
      'XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的保护措施。  1、我们如何收集和使用您的个人信息 ......  4、对儿童的保护  5、与第三方共享（共享）  6、管理您的数据  7、数据存储地点及期限  8、如何联系我们  华为将始终遵照我们的隐私政策来收集和使用您的信息。有关我们的隐私政策，可参阅华为消费者业务隐私声明。',
      false, new Date('2025-07-08')),
    new SystemMsgItem('6', '用户协议及隐私政策更新通知',
      'XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的保护措施。  1、我们如何收集和使用您的个人信息 ......  4、对儿童的保护  5、与第三方共享（共享）  6、管理您的数据  7、数据存储地点及期限  8、如何联系我们  华为将始终遵照我们的隐私政策来收集和使用您的信息。有关我们的隐私政策，可参阅华为消费者业务隐私声明。',
      false, new Date('2025-07-08'))
  ]
}


@ObservedV2
class SystemMsgItem {
  @Trace id: string
  @Trace title: string
  @Trace subTitle: string
  @Trace isSelectToDelete: boolean
  @Trace time: Date
  @Trace isRead: boolean = false

  constructor(id: string, title: string, subTitle: string, isSelectToDelete: boolean = false, time: Date = new Date(),
    isRead: boolean = false) {
    this.id = id
    this.title = title
    this.subTitle = subTitle
    this.isSelectToDelete = isSelectToDelete
    this.time = time
    this.isRead = isRead
  }
}

@Builder
export function SystemMessagePageBuilder() {
  SystemMessagePage()
}