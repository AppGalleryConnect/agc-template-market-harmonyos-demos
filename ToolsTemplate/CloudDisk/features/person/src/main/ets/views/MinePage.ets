import { PersistenceV2 } from '@kit.ArkUI'
import { BarVM, Constants, FileInfo, GlobalContext, MockService, RouterMap, TCLogger, UserInfo } from 'common'
import { MineItem } from '../viewmodel/MineModel'
import { OHPage, phoneRouterControl } from 'oh_router'
import { MyselfSpacePageBuilder } from '../../../../Index'
import { SetUpPageBuilder } from './SetupPage'
import { EditPersonalCenterBuilder } from './EditPersonalCenterPage'
import { BuildFeedbackSubmitPage } from 'feedback'
import { LoginPageBuilder } from './LoginPage'
import { RecycleBinPageBuilder } from './RecycleBinPage'
import { MyCollectPageBuilder } from './MyCollectPage'
import { VipCenterPageBuilder } from 'collect_personal_info'
import { FileTransferManagerPageVM } from 'clouddisk_file'
import { MenusSelectView } from '../comp/MenusSelectView'
import { SpaceView } from '../comp/SpaceView'
import { MySharePageBuilder, MySharePageViewModel, ShareDetailPageBuilder, ShareDetailPageViewModel } from 'cloud_share'
import { FileBaseInfo, FileBaseInfoPlain } from 'cloud_file_base'
import {
  PopViewUtils,
  SetUseFullTimeBuilder,
  ShareOptions,
  ShareSheetParams,
  ShareUsefullTimeParam
} from 'module_share'
import { FirstPosterShareBuilder } from 'module_share/src/main/ets/buider/FirstPosterShareBuilder'
import { image } from '@kit.ImageKit'

/**
 * @usage: 用于展示个人中心页面的主页面。提供用户信息展示、登录状态管理、个人空间管理、功能菜单导航等核心功能。
 * 关键数据结构包括UserInfo（用户信息模型，支持PersistenceV2持久化，包含isLogin、nickName、avatarUrl、isVip、introDesc等字段）、
 * MineItem（菜单项模型，包含titleName、icon、builder、url等字段）、menusArray（个人功能菜单数组）、SetArray（设置菜单数组）。
 * 包含if逻辑：根据userInfo.isLogin判断显示登录入口或用户信息，根据userInfo.isVip显示VIP图标和会员卡片，
 * 根据登录状态显示不同的SpaceView组件。
 * @layout: 页面采用List垂直布局，包含多个ListItem（间距12vp）。第一个ListItem是个人信息区域perMine（包含背景图、用户头像60x60、
 * 昵称、VIP图标、个人简介、VIP会员卡片54vp高），第二个ListItem是个人空间组件SpaceView（已登录56vp高、未登录78vp高，
 * 显示存储空间使用情况和进度条），第三个ListItem是功能菜单MenusSelectView（收藏、下载、分享、回收站，每项60vp高），
 * 第四个ListItem是设置菜单MenusSelectView（意见反馈、设置，每项60vp高）。每个菜单项使用RowItem组件展示，左对齐标题和右对齐箭头图标。
 * @constraints: UserInfo使用PersistenceV2持久化存储不可修改；个人信息区域的背景图片mine_top_bg和渐变样式固定；
 * VIP会员卡片的渐变色彩（#29211C到#1D1310）和布局不可变更；个人空间进度条的宽度15%和样式参数固定；
 * 菜单项的路由映射关系（RouterMap）不可修改。
 * @isGen: true
 * @domain: 云存储
 * @fileType: page
 * @zhName: 个人中心页面
 * @subPage: LoginPage,EditPersonalCenter,VipCenterPage,MyselfSpacePage,MyCollectPage,
 * FileTransferManagerPage,MySharePage,RecycleBinPage,FeedbackPage,SetUpPage
 * @component: OHPage,SpaceView,MenusSelectView,RowItem,HeaderView
 * @image: screenshot/person.jpg
 */

@ComponentV2
export struct MinePage {
  logTag: string = 'MinePage';
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local menusArray: MineItem[] = [
    new MineItem('我的收藏', undefined, wrapBuilder(MyCollectPageBuilder),
      RouterMap.MY_COLLECT_PAGE),
    new MineItem('我的下载', undefined, undefined,
      RouterMap.FILE_TRANSFER_MANAGER_PAGE),
    new MineItem('我的分享', undefined, wrapBuilder(MySharePageBuilder), RouterMap.MY_SHARE_PAGE),
    new MineItem('回收站', undefined, wrapBuilder(RecycleBinPageBuilder), RouterMap.RECYCLE_BIN_PAGE)
  ]
  @Local setArray: MineItem[] = [
    new MineItem('意见反馈', $r('app.media.icon_feedback'), wrapBuilder(BuildFeedbackSubmitPage),
      RouterMap.FEEDBACK_PAGE),
    new MineItem('设置', $r('app.media.icon_Setting'), wrapBuilder(SetUpPageBuilder), RouterMap.SET_UP_PAGE)
  ]
  sharepageViewModel?: MySharePageViewModel
  shareDetailPageViewModel?: ShareDetailPageViewModel
  fileInfo: FileInfo = new FileInfo()

  aboutToAppear(): void {
    TCLogger.info(this.logTag, 'aboutToAppear ' + JSON.stringify(this.userInfo));
    FileTransferManagerPageVM.rootInstance.selectedTabTitle = '下载'
    FileTransferManagerPageVM.rootInstance.downloadSelectedCompleteStatus = '全部'

    // 分享模块初始化
    const currentStr: string = JSON.stringify(MockService.allFileList.map(item => item.toJSON()))
    const currentArr: FileBaseInfoPlain[] = JSON.parse(currentStr) as FileBaseInfoPlain[]
    let fileBaseList: FileBaseInfo[] = currentArr.map(item => FileBaseInfo.fromPlain(item))
    const contentPadding: Padding | Length | LocalizedPadding =
      { top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH }
    this.sharepageViewModel =
      new MySharePageViewModel(fileBaseList, contentPadding)
    this.shareAgain(this.sharepageViewModel)
    this.sharepageViewModel.checkShareDetail = (fileBaseInfo: FileBaseInfo) => {
      //分享详情模块初始化
      this.shareDetailPageViewModel = new ShareDetailPageViewModel(fileBaseInfo, contentPadding)
      this.shareAgains(this.shareDetailPageViewModel)
      this.changeExpiretime(this.shareDetailPageViewModel)
      //分享跳转详情页方法
      phoneRouterControl.jumpPage({
        pageName: RouterMap.SHARE_DETAIL_PAGE,
        param: this.shareDetailPageViewModel,
        builder: wrapBuilder(ShareDetailPageBuilder)
      })
    }

  }

  //分享一级页面分享功能
  shareAgain(sharepageViewModel: MySharePageViewModel) {
    sharepageViewModel.shareAgain = (fileBaseInfo: FileBaseInfo): void => {
      const qrCodeInfo: ShareOptions = new ShareOptions()
      let param: ShareSheetParams = {
        onPost: (isOpen: boolean, pixmap: image.PixelMap) => {
        },
        qrCodeInfo: qrCodeInfo,
      }
      PopViewUtils.showSheet<ShareSheetParams>(wrapBuilder(FirstPosterShareBuilder), {
        showClose: true,
        title: {
          title: '分享到',
        },
        backgroundColor: $r('sys.color.background_secondary'),
        detents: [SheetSize.FIT_CONTENT],
      }, param);
    }
  }

  //分享详情页分享功能
  shareAgains(shareDetailPageViewModel: ShareDetailPageViewModel) {
    shareDetailPageViewModel.shareAgains = (fileBaseList: FileBaseInfo): void => {
      const qrCodeInfo: ShareOptions = new ShareOptions()
      let param: ShareSheetParams = {
        onPost: (isOpen: boolean, pixmap: image.PixelMap) => {
        },
        qrCodeInfo: qrCodeInfo,
      }
      PopViewUtils.showSheet<ShareSheetParams>(wrapBuilder(FirstPosterShareBuilder), {
        showClose: true,
        title: {
          title: '分享到',
        },
        backgroundColor: $r('sys.color.background_secondary'),
        detents: [SheetSize.FIT_CONTENT],
      }, param);
    }
  }

  //分享详情页修改分享时间功能
  changeExpiretime(shareDetailPageViewModel: ShareDetailPageViewModel) {
    shareDetailPageViewModel.changeExpiretime = (fileBaseInfo: FileBaseInfo,
      blockUsefullTime: (id: number, value: string | Resource) => void, usefullTimeId?: number): void => {
      let params: ShareUsefullTimeParam = {
        blockUsefullTime: blockUsefullTime,
        blockUsefullTimeId: usefullTimeId,
        fileInfo: fileBaseInfo
      }
      PopViewUtils.showSheet<ShareUsefullTimeParam>(wrapBuilder(SetUseFullTimeBuilder), {
        backgroundColor: $r('sys.color.background_secondary'),
        detents: [SheetSize.FIT_CONTENT],
        showClose: false
      }, params)
    }
  }

  @Builder
  perMine() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.mine_top_bg'))
        .width(Constants.FULL_SIZE)
        .height($r('app.float.vp_197'))
      Column() {
        Row() {
          Text('我的')
            .size({ width: '100%', height: $r('app.float.vp_32') })
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .alignItems(VerticalAlign.Center)
        .margin({ top: BarVM.instance.aiBarH })
        .height($r('app.float.vp_58'))

        this.userinfoBuider()

        this.vipRowBuilder()
      }
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  userinfoBuider() {
    Row() {
      Image(this.userInfo.isLogin ?
        (this.userInfo.avatarUrl && this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl :
        $r('app.media.path2x') :
      $r('app.media.person'))
        .borderRadius($r('app.float.vp_30'))
        .width($r('app.float.vp_60'))
        .aspectRatio(1)

      Row() {
        Column() {
          Row({ space: 6 }) {
            Text(this.userInfo?.isLogin ? this.userInfo?.nickName ? this.userInfo?.nickName : '华为用户' :
              '点击登录')
              .height(24)
              .fontSize($r('sys.float.Subtitle_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: 8 })
            if (this.userInfo?.isLogin) {
              Image(this.userInfo.isVip ? $r('app.media.icon_vip') : $r('app.media.ic_novip_image'))
                .width($r('app.float.vp_23'))
                .height($r('app.float.vp_13'))
            }
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          Text(this.userInfo?.isLogin ? this.userInfo?.introDesc ? this.userInfo?.introDesc : `这是一段个人简介` :
            '')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 6, left: 8 })

        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
      }
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
    .margin({ top: $r('app.float.vp_16'), left: '11%' })
    .width('100%')
    .height($r('app.float.vp_60'))
  }

  @Builder
  vipRowBuilder() {
    Row({ space: 14 }) {
      Image($r('app.media.ic_vip'))
        .width($r('app.float.vp_42'))
        .height($r('app.float.vp_42'))
      Column({ space: 5 }) {
        Text('云盘VIP会员')
          .font({
            size: $r('sys.float.Body_M'),
            weight: FontWeight.Medium
          })
          .fontColor($r('app.color.orange_color_FFFFD8BF'))
          .height($r('app.float.vp_16'))
          .textAlign(TextAlign.Start)
        Text('享受会员专属福利')
          .font({
            size: $r('sys.float.Caption_M'),
          })
          .fontColor($r('app.color.orange_color_FFE58A50'))
          .height($r('app.float.vp_12'))
          .textAlign(TextAlign.Start)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text(this.userInfo.isVip ? '会员续费' : '立即开通')
        .font({
          size: $r('sys.float.Body_S'),
          weight: FontWeight.Medium
        })
        .borderRadius($r('app.float.vp_15'))
        .textAlign(TextAlign.Center)
        .width($r('app.float.vp_80'))
        .height($r('app.float.vp_26'))
        .fontColor($r('app.color.dark_color_FF221915'))
        .linearGradient({
          angle: 90,
          direction: GradientDirection.Left,
          colors: [[$r('app.color.orange_color_FEE6C2'), 0], [$r('app.color.orange_color_FFBC93'), 1]]
        })

    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .padding({ left: $r('app.float.vp_20'), right: $r('app.float.vp_24') })
    .width(Constants.FULL_SIZE)
    .height($r('app.float.vp_54'))
    .borderRadius($r('app.float.vp_16'))
    .margin({ top: $r('app.float.vp_40') })
    .linearGradient({
      angle: 90,
      direction: GradientDirection.Left,
      colors: [[$r('app.color.dark_color_29211C'), 0], [$r('app.color.dark_color_1D1310'), 1]]
    })
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.VIP_CENTER_PAGE,
          builder: wrapBuilder(VipCenterPageBuilder)
        })
      }
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      List({ space: 12 }) {
        ListItem() {
          this.perMine()
        }

        if (this.userInfo?.isLogin) {
          ListItem() {
            SpaceView({
              isVip: this.userInfo.isVip,
              userInfo: this.userInfo,
              blockClick: () => {
                phoneRouterControl.jumpPage({
                  param: this.userInfo,
                  pageName: RouterMap.MYSELF_SPACE_PAGE,
                  builder: wrapBuilder(MyselfSpacePageBuilder)
                })
              }
            })
          }
          .padding({left: 16, right: 16})
        } else {
          ListItem() {
            SpaceView({ isLogin: this.userInfo.isLogin, isVip: this.userInfo.isVip , userInfo : this.userInfo})
          }
          .padding({left: 16, right: 16})
        }

        ListItem() {
          MenusSelectView({
            menusArray: this.menusArray, blockClickItem: (item: MineItem) => {
              this.clickItem(item)
            }
          })
            .padding({ left: 16, right: 16 })
        }

        ListItem() {
          MenusSelectView({
            menusArray: this.setArray, blockClickItem: (item: MineItem) => {
              this.clickItem(item)
            }
          })
            .padding({ left: 16, right: 16 })
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .backgroundColor($r('app.color.dark_color_F1F3F5'))
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  clickItem(item: MineItem) {
    // 设置多个点击
    if (this.userInfo?.isLogin && item.url) {
      if (item.titleName === '我的下载') {
        GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.JUMPTO_FILETRANSFERMANAGERPAGE_KEY)
      } else {
        phoneRouterControl.jumpPage({
          pageName: item.url,
          param: (item.titleName === '我的分享') ? this.sharepageViewModel : item.params,
          builder: item.builder
        })
      }

    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: false
    })
  }
}