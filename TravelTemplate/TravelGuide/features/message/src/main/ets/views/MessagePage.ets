/**
 * @usage: 消息模块，用于展示订单出行消息和系统通知，提供开启推送通知提示功能
 * @layout: 页面整体采用垂直布局（Column），顶部是标题栏，下方是可滚动区域，包含推送提示卡片、订单出行消息列表、系统通知列表
 * @constraints: messageList数据分为orderMessageList（订单出行）和sysMessageList（系统通知）两类；
 * showPushTip根据系统通知权限状态显示
 * @isGen: true
 * @fileType: page
 * @zhName: 消息
 * @domain: 旅游
 * @image: screenshots/message.jpg
 * @component: CommonEmpty
 */
import { CommonEmpty, GlobalContext } from 'common';
import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { OHPage } from 'oh_router'
import { MessageVM } from '../viewmodel/MessageVM';
import { MessageItem } from 'common_travel_guide';

@Builder
export function MessagePageBuilder() {
  MessagePage();
}

@ComponentV2
export struct MessagePage {
  vm: MessageVM = new MessageVM();

  aboutToAppear() {
    this.vm.showPushTip = !notificationManager.isNotificationEnabledSync()
    this.vm.initData()
  }

  @Monitor('vm.messageList.list.length')
  listChange() {
    this.vm.initData()
  }

  @Builder
  pushTipBuilder() {
    Row() {
      Column({ space: 4 }) {
        Text('开启推送通知')
          .fontColor('#333333')
          .fontSize(13)
          .fontWeight(500)
        Text('及时接受订单信息及出行提醒')
          .fontColor('rgba(0, 0, 0, 0.50)')
          .fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)

      Row({ space: 10 }) {
        Text('立即开启')
          .fontSize(12)
          .fontWeight(500)
          .fontColor('#333333')
          .padding({
            left: 10,
            right: 10,
            top: 4,
            bottom: 4
          })
          .borderRadius(11)
          .linearGradient({
            angle: 306,
            colors: [['#FECC41', 0.0], ['#FEE641', 1.0]]
          })
          .onClick(() => {
            let context = GlobalContext.getUIAbilityContext() as common.UIAbilityContext;
            this.vm.requestEnableNotification(context)
          })

        Image($r('app.media.ic_close'))
          .width(14)
          .height(14)
          .onClick(() => {
            this.vm.showPushTip = false
          })
      }
    }
    .width('100%')
    .padding(12)
    .borderRadius(12)
    .linearGradient({
      angle: 180,
      colors: [['#FFF5D5', 0.0], ['#F6F8F9', 1.0]]
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  listItemHeader(type: string, img: Resource) {
    Row({ space: 6 }) {
      Image(img)
        .width(20)
        .height(20)
      Text(type)
        .fontSize(16)
        .fontColor('#000')
        .fontWeight(500)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  messageItem(data: MessageItem) {
    Column({ space: 8 }) {
      Row() {
        Text(data.title)
          .fontSize(14)
          .fontColor('#000')
          .fontWeight(500)
        Text(data.time)
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.40)')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(data.content)
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.70)')
        .width('100%')
    }
    .width('100%')
    .backgroundColor('#fff')
    .padding(12)
    .borderRadius(16)
  }

  @Builder
  orderListBuilder() {
    Column() {
      this.listItemHeader('订单出行', $r('app.media.ic_order'))
      Column({ space: 10 }) {
        ForEach(this.vm.orderMessageList, (item: MessageItem) => {
          this.messageItem(item)
        },(item: MessageItem)=>JSON.stringify(item))
      }
      .margin({ top: 13 })
    }
  }

  @Builder
  sysListBuilder() {
    Column() {
      this.listItemHeader('系统通知', $r('app.media.ic_sys'))
      Column({ space: 10 }) {
        ForEach(this.vm.sysMessageList, (item: MessageItem) => {
          this.messageItem(item)
        },(item: MessageItem) => JSON.stringify(item))
      }
      .margin({ top: 13 })
    }
  }

  @Builder
  pageHeader(){
    Row() {
      Text('消息')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height(36)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      this.pageHeader()
      Scroll() {
        Column({ space: 22 }) {
          if (this.vm.showPushTip) {
            this.pushTipBuilder()
          }
          if (this.vm.messageList.list.length) {
            if(this.vm.orderMessageList.length){
              this.orderListBuilder()
            }
            if(this.vm.sysMessageList.length){
              this.sysListBuilder()
            }
          } else {
            CommonEmpty()
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 8 })
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
    })
  }
}

