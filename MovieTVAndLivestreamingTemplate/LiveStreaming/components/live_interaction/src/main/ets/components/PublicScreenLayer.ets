import { curves } from '@kit.ArkUI'
import { Gift, LiveInteractionMgr } from '../manager/LiveInteractionMgr'
import { GiftInfoClass, Viewer } from '../models/DisplayData'
import { GiftModel } from '../models/GiftGroup'
import { BaseChatMessage } from './public_screen/chat/BaseChatMesage'
import { ChatManager } from './public_screen/chat/ChatManager'
import { ChatView } from './public_screen/chat/ChatView'
import { ChatType } from './public_screen/views/Constans'
import { SimpleChat } from './public_screen/views/NormalChat'
import { normalChatViewBuilder } from './public_screen/views/NormalChatView'
import { RichChat } from './public_screen/views/RichChat'
import { richChatViewBuilder } from './public_screen/views/RichChatView'
import { SystemChat } from './public_screen/views/SystemChat'
import { systemChatViewBuilder } from './public_screen/views/SystemChatView'

@ComponentV2
export struct PublicScreenLayer {
  @Param @Require interactionMgr: LiveInteractionMgr
  @Param chatManager: ChatManager = new ChatManager()
  // 进入直播间动效
  @Local viewer: Viewer = new Viewer(2, '1', '小野今天也很快乐')
  @Local showLiveRoom: boolean = false // 控制进入直播间组件的显示
  @Local liveRoomID: number = -1 // 控制直播间组件的显示
  @Local liveRoomOffsetX: number = -500 // 控制进入直播间组件的X轴偏移量
  @Local addTimer: number = -1
  private addEffect: TransitionEffect =
    // 创建默认透明度转场效果，并指定了springMotion(0.6, 0.8)曲线
    TransitionEffect.OPACITY.animation({
      curve: curves.springMotion(0.6, 0.8)
    })// 添加平移转场效果，动画参数使用指定的springMotion()
      .combine(TransitionEffect.translate({ x: 150 })
        .animation({ curve: curves.springMotion() }))
      .combine(TransitionEffect.move(TransitionEdge.END))
  @Local gift: GiftInfoClass = new GiftInfoClass()
  @Local showGift: boolean = false // 控制礼物的显示
  @Local giftID: number = -1 // 控制礼物组件的显示
  @Local giftTimer: number = -1 // 控制礼物组件的显示
  @Local giftOffsetX: number = -500 // 控制礼物组件的X轴偏移量
  private giftEffect: TransitionEffect =
    // 创建默认透明度转场效果，并指定了springMotion(0.6, 0.8)曲线
    TransitionEffect.OPACITY.animation({
      curve: curves.springMotion(0.6, 0.8)
    })// 添加平移转场效果，这里的动画参数使用指定的springMotion()
      .combine(TransitionEffect.translate({ x: 150 })// 添加move转场效果，这里的动画参数会跟随上面的TransitionEffect，也就是springMotion()
        .animation({ curve: curves.springMotion() }))
      .combine(TransitionEffect.move(TransitionEdge.END))
  private effectCount: TransitionEffect =
    // 创建默认透明度转场效果，并指定了springMotion(0.6, 0.8)曲线
    TransitionEffect.OPACITY.animation({
      curve: curves.springMotion(0.6, 0.8)
    })// 添加平移转场效果，这里的动画参数使用指定的springMotion()
      .combine(TransitionEffect.scale({ x: 10, y: 10 })
        .animation({ curve: curves.springMotion(0.6, 1.2) }))
  private uiContext: UIContext = this.getUIContext();
  aboutToAppear(): void {
    this.addRoom()
    this.interactionMgr.onSendGift = (gift: Gift) => {
      this.sendGift(gift)
    }
  }

  build() {
    Stack() {
      Column({ space: 10 }) {
        if (this.showGift) {
          Row({ space: 4 }) {
            Row() {
              Image(this.gift.senderAvatar)
                .width(32)
                .aspectRatio(1)
                .borderRadius(16)
                .margin({ right: 8 })

              Column({ space: 2 }) {
                Text(this.gift.senderNickname)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .lineHeight(19)
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_on_primary'))

                Text(this.gift.giftName)
                  .fontSize(10)
                  .fontWeight(500)
                  .lineHeight(13)
                  .fontColor($r('sys.color.ohos_id_color_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
              .width(70)
              .margin({ right: 4 })

              Image(this.gift.giftImage)
                .width(40)
                .aspectRatio(1)
            }
            .linearGradient({
              angle: 90,
              colors: [
                ['rgba(0,0,0,0.4)', 0.5],
                ['rgba(0,0,0,0.05)', 1]
              ]
            })
            .borderRadius(20)
            .height(40)
            .padding({ left: 4, right: 4 })

            Text('x')
              .fontFamily('Roboto')
              .fontWeight(700)
              .fontSize(18)
              .lineHeight(21)
              .fontColor($r('sys.color.font_on_primary'))

            Text(`${this.gift.quantity}`)
              .fontFamily('Roboto')
              .fontWeight(700)
              .fontSize(24)
              .lineHeight(28)
              .fontColor($r('sys.color.font_on_primary'))
              .transition(this.effectCount)
          }
          .translate({ x: this.giftOffsetX }) // 应用X轴偏移量
          .transition(this.giftEffect)
        }

        if (this.showLiveRoom) {
          Row() {
            Text(`榜${this.viewer.rank}`)
              .fontSize(10)
              .lineHeight(13)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundImage($r('app.media.enter_the_live_room_num'))
              .backgroundImageSize(ImageSize.FILL)
              .margin({ right: 6 })
              .borderRadius(9)
              .padding({
                left: 6,
                top: 2,
                right: 6,
                bottom: 2
              })

            Text(this.viewer.name)
              .width(112)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize(14)
              .fontWeight(500)
              .fontColor($r('sys.color.font_on_primary'))
              .lineHeight(19)
              .margin({ right: 4 })

            Text('加入直播间')
              .fontSize(14)
              .fontWeight(500)
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(19)

          }
          .translate({ x: this.liveRoomOffsetX }) // 应用X轴偏移量
          .transition(this.addEffect)
          .padding({
            left: 6,
            right: 8,
            top: 4,
            bottom: 4
          })
          .alignItems(VerticalAlign.Center)
          .borderRadius(13)
          .backgroundImageSize(ImageSize.FILL)
          .backgroundImage($r('app.media.enter_the_live_room_bg'))
        }

        ChatView({ chatMgr: this.chatManager, builder: wrapBuilder(chatMessageBuilder) })
      }
      .height(296)
      .width(308)
      .padding({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .position({ bottom:95})
  }

  sendGift(gift: Gift) {
    this.gift.senderNickname = gift.sender
    this.gift.senderAvatar = gift.senderAvatar
    this.gift.quantity = 1
    let giftModel = this.interactionMgr.giftData.filter((value: GiftModel) => (value.id === gift.giftId))
    this.gift.giftName = giftModel[0].name
    this.gift.giftImage = giftModel[0].icon
    clearTimeout(this.giftID)
    clearTimeout(this.giftTimer)
    this.showGift = false
    this.giftTimer = setTimeout(() => {
      this.showGift = true
    }, 100)
    this.giftOffsetX = -100
    this.uiContext.animateTo({
      duration: 300,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.giftID = setTimeout(() => {
          this.uiContext.animateTo({
            duration: 300,
            curve: Curve.EaseInOut
          }, () => {
            this.showGift = false
          })
        }, 3000)
      }
    }, () => {
      this.giftOffsetX = 0 // 动画结束时将X轴偏移量设置为0
      clearTimeout(this.giftID)
    })
  }

  addRoom() {
    clearTimeout(this.liveRoomID)
    clearTimeout(this.addTimer)
    this.showLiveRoom = false
    this.addTimer = setTimeout(() => {
      this.showLiveRoom = true
    }, 100)
    this.liveRoomOffsetX = -100
    this.uiContext.animateTo({
      duration: 300,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.liveRoomID = setTimeout(() => {
          this.uiContext.animateTo({
            duration: 300,
            curve: Curve.EaseInOut
          }, () => {
            this.showLiveRoom = false
          })
        }, 2000)
      }
    }, () => {
      this.liveRoomOffsetX = 0 // 动画结束时将X轴偏移量设置为0
      clearTimeout(this.liveRoomID)
    })
  }
}

@Builder
function chatMessageBuilder(item: BaseChatMessage) {
  if (item.type === ChatType.NORMAL_CHAT) {
    normalChatViewBuilder(item as SimpleChat)
  } else if (item.type === ChatType.RICH_CHAT) {
    richChatViewBuilder(item as RichChat)
  } else {
    systemChatViewBuilder(item as SystemChat)
  }
}