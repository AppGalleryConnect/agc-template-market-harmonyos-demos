/**
 * @usage: 个人中心模块，用于展示用户信息、订单管理入口、常用服务入口，提供登录/注册、个人资料编辑、
 * 订单管理、收藏管理、发布帖子、设置等功能
 * @layout: 页面整体采用Stack布局，背景图片在底层，上方是可滚动区域，包含标题、用户信息卡片、订单快捷入口、我的收藏、常用服务列表
 * @constraints: mineTabArr包含获赞、帖子、全部订单、待付款、未出行五个快捷入口；mineArr包含常用信息、发布帖子、
 * 设置三个服务入口；未登录状态下除设置外其他功能需跳转登录页
 * @isGen: true
 * @fileType: page
 * @zhName: 个人中心
 * @domain: 旅游
 * @image: screenshots/person.jpg
 * @subPage: LoginPage,EditPersonalCenterPage,SetupPage,CommonInfoPage,PublishPostPage,
 * MyLikesPage,MyPostPage,MyOrderPage,MyCollectPage
 * @component: UserItem,OuterFrameCard
 */
import { common } from '@kit.AbilityKit'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import {
  BarVM, BreakpointModel, RouterMap, Constants, UserInfo, GlobalContext
} from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { phoneRouterControl } from 'oh_router'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { LoginPageBuilder } from './LoginPage'
import { UserItem } from '../comp/UserItem'
import { OuterFrameCard } from '../comp/OuterFrameCard'
import { MyLikesPageBuilder } from './MyLikesPage'
import { MyPostPageBuilder } from './MyPostPage'
import { MyOrderPageBuilder } from './MyOrderPage'
import { CommonInfoPageBuilder } from './CommonInfoPage'
import { PublishPostPageBuilder } from './PublishPostPage'
import { MyOrderList } from 'common_travel_guide'
import { MyCollectPageBuilder } from './MyCollectPage'
import { PublishPageType } from '../constants/PostPageType'

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local mineArr: MineItem[] = [
    new MineItem('常用信息', '', wrapBuilder(CommonInfoPageBuilder),
      RouterMap.COMMON_INFO_PAGE),
    new MineItem('发布帖子', '', wrapBuilder(PublishPostPageBuilder),
      RouterMap.PUBLISH_POST_PAGE, PublishPageType.POST),
    new MineItem('设置', '', wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE)
  ]
  @Local mineTabArr: MineItem[] = [
    new MineItem('获赞', $r('app.media.ic_likes'), wrapBuilder(MyLikesPageBuilder),
      RouterMap.MY_LIKES_PAGE),
    new MineItem('帖子', $r('app.media.ic_post'), wrapBuilder(MyPostPageBuilder),
      RouterMap.MY_POST_PAGE),
    new MineItem('全部订单', $r('app.media.ic_all_order'), wrapBuilder(MyOrderPageBuilder),
      RouterMap.ORDER_MANAGEMENT_PAGE, Constants.TAB_INDEX_ZERO),
    new MineItem('待付款', $r('app.media.ic_pending_order'), wrapBuilder(MyOrderPageBuilder),
      RouterMap.ORDER_MANAGEMENT_PAGE, Constants.TAB_INDEX_ONE),
    new MineItem('未出行', $r('app.media.ic_not_traveled_order'), wrapBuilder(MyOrderPageBuilder),
      RouterMap.ORDER_MANAGEMENT_PAGE, Constants.TAB_INDEX_TWO),
  ]
  @Local myOrderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Local pendingOrderNum: number = 0
  @Local untraveledOrderNum: number = 0
  context: common.UIAbilityContext = GlobalContext.getUIAbilityContext()

  @Monitor('userInfo.isLogin')
  onLoginChange() {
    this.pendingOrderNum = this.myOrderList.getPendingOrderNum()
    this.untraveledOrderNum = this.myOrderList.getUntraveledOrderNum()
  }

  @Monitor('myOrderList.list.length')
  onOrderListChange() {
    this.pendingOrderNum = this.myOrderList.getPendingOrderNum()
    this.untraveledOrderNum = this.myOrderList.getUntraveledOrderNum()
  }

  aboutToAppear(): void {
    this.context.eventHub.on('orderStatusChange', () => {
      this.pendingOrderNum = this.myOrderList.getPendingOrderNum()
      this.untraveledOrderNum = this.myOrderList.getUntraveledOrderNum()
    })
  }

  jumpPage(item: MineItem) {
    // 设置多个点击
    if (this.userInfo?.isLogin && item.url) {
      phoneRouterControl.jumpPage({
        pageName: item.url,
        param: item.params,
        builder: item.builder
      })
    } else {
      if (item.url && item.url === RouterMap.SET_UP_PAGE) {
        // 设置页面不登录也可进入
        phoneRouterControl.jumpPage({
          pageName: item.url,
          param: item.params,
          builder: item.builder
        })
      } else {
        // 非设置页面需要登录
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      }
    }
  }

  getBadgeNum(item: MineItem): number {
    if (!this.userInfo.isLogin) {
      return 0
    }
    if (item.params && item.params > 0) {
      if (item.params === Constants.TAB_INDEX_ONE) {
        return this.myOrderList.getPendingOrderNum()
      }
      if (item.params === Constants.TAB_INDEX_TWO) {
        return this.myOrderList.getUntraveledOrderNum()
      }
      return 0
    } else {
      return 0
    }
  }

  @Builder
  perMine() {
    Row() {
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl :
          $r('app.media.path2x') :
        $r('app.media.person'))
        .borderRadius(40)
        .width(48)
        .aspectRatio(1)

      Row() {
        Column() {
          Text(this.userInfo?.isLogin ? this.userInfo?.nickName : '点击登录')
            .height(24)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16, bottom: 2, right: 6 })

          if (this.userInfo?.isLogin) {
            Text(`ID：${this.userInfo?.id.toString().padStart(7, '0')}`)
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
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PERSONAL_CENTER_PAGE,
          builder: wrapBuilder(EditPersonalCenterBuilder)
        })
      }
    })
    .width('100%')
    .height(72)
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }

  @Builder
  MyTabRow() {
    Row() {
      ForEach(this.mineTabArr, (item: MineItem) => {
        Badge({
          count: this.getBadgeNum(item),
          style: {},
          position: BadgePosition.RightTop,
        }) {
          Column({ space: 4 }) {
            Image(item.icon)
              .width(24)
              .height(24)
            Text(item.titleName)
              .fontSize(11)
              .fontColor('#333')
          }
          .layoutWeight(1)
          .onClick(() => {
            this.jumpPage(item)
          })
        }
      }, (item: MineItem) => JSON.stringify(item))
    }
    .padding(12)
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor('#fff')
    .borderRadius(16)
  }

  build() {
    Stack() {
      Image($r('app.media.mine_back'))
        .width('100%')
        .position({ top: 0, left: 0 })
      Scroll() {
        Column({ space: 12 }) {
          Row() {
            Text('我的')
              .fontSize($r('sys.float.Title_M'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
          .height(36)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          this.perMine()
          this.MyTabRow()

          OuterFrameCard() {
            UserItem({
              title: '我的收藏',
              image: '',
              isLine: false
            })
              .padding({
                top: 4,
                bottom: 4,
                left: 4,
                right: 4
              })
              .onClick(() => {
                if (!this.userInfo?.isLogin) {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.LOGIN_PAGE,
                    builder: wrapBuilder(LoginPageBuilder)
                  })
                } else {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.MY_COLLECT_PAGE,
                    builder: wrapBuilder(MyCollectPageBuilder)
                  })
                }
              })
          }

          OuterFrameCard() {
            List() {
              ForEach(this.mineArr, (item: MineItem, index: number) => {
                UserItem({
                  title: item.titleName,
                  image: item.icon,
                  url: item.url,
                  isLine: !(index === this.mineArr.length - 1),
                  messageNum: item.messageNum
                })
                  .onClick(() => {
                    this.jumpPage(item)
                  })
              }, (item: MineItem) => JSON.stringify(item))
            }
            .width('100%')
            .height('auto')
            .lanes(1)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .divider({
              strokeWidth: 0.5,
              color: $r('sys.color.comp_divider'),
              startMargin: 12,
              endMargin: 12,
            })
            .padding({
              left: 4,
              right: 4,
              top: 4,
              bottom: 4,
            })
          }
        }
      }
      .align(Alignment.TopStart)
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding,
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#f2f3f5')
  }
}

