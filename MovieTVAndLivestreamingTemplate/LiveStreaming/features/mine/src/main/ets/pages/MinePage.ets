import { AppStorageV2 } from '@kit.ArkUI'
import { call } from '@kit.TelephonyKit'
import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { NumbObj } from '../viewModel/MessageModel'
import { MineItem } from '../viewModel/MineModel'
import { AccountUtil, BarVM, ColorMode } from '@agctemplate/widgets'
import { getMedia } from '@agctemplate/resources'
import { NewFansList } from './NewFansMessagePage'
import { SystemMsgList } from './SystemMessagePage'
import { ConfigurationConstant } from '@kit.AbilityKit'
import { DialPanel } from 'dial_panel'
import { UserInfo } from 'live_interaction'

@Builder
export function MinePageBuilder() {
  MinePage()
}

@ComponentV2
struct OuterFrameCard {
  @BuilderParam content: () => void
  @Param title: string = '常用服务'

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(700)
        .lineHeight(24)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 24, bottom: 8 })
        .width('100%')

      if (this.content) {
        this.content()
      }
    }
    .size({ width: '100%' })
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }
}


@ComponentV2
struct UserItem {
  @Param title: string = ''
  @Param image: ResourceStr = ''
  @Param url: string = ''
  @Param isLine: boolean = true
  @Param @Once messageNum: number = 0

  build() {
    Row() {
      Image(this.image)
        .size({ width: 24, height: 24 })
        .fillColor($r('sys.color.icon_secondary'))
      Row() {
        Text(this.title)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank()
        if (this.messageNum > 0) {
          Text(this.messageNum > 99 ? '99+' : this.messageNum.toString())
            .textAlign(TextAlign.Center)
            .backgroundColor($r('sys.color.warning'))
            .borderRadius(8)
            .size({ width: 30, height: 16 })
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10)
            .fontWeight(400)
            .margin({ right: 4 })
        }
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_fourth')])
      }
      .margin({ left: 16 })
      .padding({
        top: 17,
        bottom: 17,
        left: 0,
        right: 0
      })
      .layoutWeight(1)
      .border({ width: { bottom: this.isLine ? 0.5 : 0 }, color: $r('sys.color.comp_divider') })

    }
    .size({ width: '100%' })
    .alignItems(VerticalAlign.Center)
  }
}

@ComponentV2
export struct MinePage {
  @Local isOpen: boolean = false
  @Local logoUser: UserInfo = AccountUtil.getUserInfo();
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local propNumber: NumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
  @Local systemMsgList: SystemMsgList = AppStorageV2.connect(SystemMsgList, () => new SystemMsgList())!
  @Local newFansList: NewFansList = AppStorageV2.connect(NewFansList, () => new NewFansList())!
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local mineArr: MineItem[] = [
    new MineItem('观看记录', $r('app.media.icon_history'), RouterMap.WATCH_RECORD),
    new MineItem('消息通知', $r('app.media.icon_message2'), RouterMap.MESSAGE_CENTER_PAGE),
    new MineItem('意见反馈', $r('app.media.icon_feedback'), RouterMap.FEEDBACK_PAGE),
    new MineItem('联系客服', $r('app.media.ic_public_headphones_mic'), ''),
    new MineItem('设置', $r('app.media.icon_Setting'), RouterMap.SET_UP_PAGE)
  ]
  private uiContext: UIContext = this.getUIContext();

  private dialPanel: DialPanel = new DialPanel(this.uiContext)
    .onMakeCall((e: BusinessError<void>): void => {
      if (e.code) {
        this.showToast(`拨号页面跳转失败 -> code: ${e.code}, msg: ${e.message}`);
      }
    })

  @Monitor('logoUser.isLogin', 'propNumber.totalUnreadCount')
  onStrChange(monitor: IMonitor) {
    if (this.logoUser.isLogin) {
      this.propNumber.listArr[0].count = this.systemMsgList.listArr.filter(item => !item.isRead).length
      this.propNumber.listArr[1].count = this.newFansList.listArr.filter(item => !item.isRead).length
      monitor.dirty.forEach(() => {
        this.mineArr[1] =
          new MineItem('消息通知', $r('app.media.icon_message2'), RouterMap.MESSAGE_CENTER_PAGE, this.propNumber,
            this.propNumber.totalUnreadCount)
      })
    } else {
      this.mineArr[1] =
        new MineItem('消息通知', $r('app.media.icon_message2'), RouterMap.MESSAGE_CENTER_PAGE)
    }

  }

  @Builder
  perMine() {
    Row() {
      if (this.logoUser.isLogin) {
        Image((this.logoUser.avatar && this.logoUser.avatar !== '') ? this.logoUser.avatar : $r('app.media.path2x'))
          .borderRadius(40)
          .width(48)
          .aspectRatio(1)
      } else {
        SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
          .fontSize(48)
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
          .fontColor([$r('sys.color.comp_background_tertiary'), $r('sys.color.icon_tertiary')])
      }

      Row() {
        Column() {
          Text(this.logoUser.isLogin ? this.logoUser.name : '点击登录')
            .height(24)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16, bottom: 2 })

          if (this.logoUser.isLogin) {
            Text(`ID：${this.logoUser?.id.toString().padStart(7, '0')}`)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ left: 16 })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Image($r('app.media.iconRight'))
          .width(18)
          .aspectRatio(1)
          .margin({ right: 2 })
      }
      .layoutWeight(1)
    }
    .onClick(() => {
      if (!this.logoUser.isLogin) {
        RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true })
      } else {
        RouterModule.push({ url: RouterMap.PROFILE_PAGE, param: this.logoUser })
      }
    })
    .width('100%')
    .height(72)
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row() {
          Text('我的')
            .size({ width: 328, height: 32 })
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 12, bottom: 12 })
        }

        this.perMine()

        OuterFrameCard() {
          GridRow({
            columns: { sm: 1, md: 2 },
            gutter: { x: 48 }
          }) {
            ForEach(this.mineArr, (item: MineItem, index: number) => {
              GridCol() {
                if (item.titleName === '联系客服') {
                  UserItem({
                    title: item.titleName,
                    image: item.icon,
                    url: item.url,
                    isLine: !(index === this.mineArr.length - 1),
                    messageNum: item.messageNum
                  })
                    .onClick(() => {
                      this.dialPanel
                        .setTitle('联系客服')
                        .setPhoneNumber('12345678901')
                        .setAutoClosePanel(false) // 成功跳转后不自动关闭模态窗
                        .open();
                    })
                } else {
                  UserItem({
                    title: item.titleName,
                    image: item.icon,
                    url: item.url,
                    isLine: !(index === this.mineArr.length - 1),
                    messageNum: item.messageNum
                  })
                    .onClick(() => {
                      if (this.logoUser.isLogin && item.url) {
                        RouterModule.push({ url: item.url, param: item.params });
                      } else {
                        RouterModule.push({ url: RouterMap.LOGIN_PAGE })
                      }
                    })
                }
              }
            }, (item: MineItem) => JSON.stringify(item))
          }

        }
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .backgroundImage(this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '' :
        getMedia('app.media.profile_background'))
      .backgroundImageSize(ImageSize.FILL)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: BarVM.instance.staBarH })
    }.hideTitleBar(true)
  }

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }
}

