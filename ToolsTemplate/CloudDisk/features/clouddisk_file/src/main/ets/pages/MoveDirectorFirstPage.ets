import { VipCenterPageBuilder } from 'collect_personal_info';
import { FileType, PreferenceUtil, GlobalContext, TCLogger, PreferenceConstant, RouterMap,
  TValueType, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { MoveDirectorListView } from '../components/MoveDirectorListView';
import { MoveDirectorFirstPageVM, moveDirectorRouterName } from '../viewmodel/MoveDirectorFirstPageVM';
import { MoveDirectorSecondPageBuilder } from './MoveDirectorSecondPage';
import { SettingPrivateSpacePasswordPageBuilder } from './SettingPrivateSpacePasswordPage';
import { PersistenceV2 } from '@kit.ArkUI';

const TAG: string = 'MoveDirectorFirstPage'

/**
 * @usage: 用于展示移动文件选择目标目录的第一级页面。提供文件移动目标目录选择功能，支持选择我的云盘、隐私空间等一级目录。
 * 关键数据结构包括MoveDirectorFirstPageParam（移动文件页面参数，包含fileIds文件ID数组和completeAction完成回调）、
 * MoveDirectorFirstPageVM（移动目录视图模型，包含fileList文件列表、filterIds过滤ID数组、filterDataSourceBy过滤数据方法、
 * jumpToNextlevelDirector跳转下一级目录方法、checkMoveFileList检查移动文件列表方法）、UserInfo（用户信息模型）。
 * 包含if逻辑：根据文件类型判断是否为隐私空间，如果是隐私空间则检查是否已开启，未开启则弹出开启提示对话框。
 * @layout: 页面采用RelativeContainer相对布局。顶部是标题Text"移动文件"（居中对齐、上边距25vp、下边距16vp），
 * 右上角是关闭按钮Image（右边距24vp、上边距24vp、20x20），中间是Navigation导航容器（包含MoveDirectorListView文件列表视图，
 * 高度calc(100% - 60vp)），底部是"移动到此"按钮Text（居中对齐、底部边距64vp、宽度144vp、高度44vp、圆角22vp、蓝色背景#2FAFFF）。
 * @constraints: 文件列表通过filterDataSourceBy方法过滤不可修改；隐私空间开启检查逻辑固定；
 * 未开启隐私空间时需要弹出确认对话框；VIP用户可直接开启隐私空间，非VIP用户需要跳转到VIP_CENTER_PAGE升级；
 * 移动完成后调用completeAction回调并返回上一页。
 * @isGen: true
 * @fileType: page
 * @subPage: MoveFileSecondPage
 * @domain: 云存储
 * @zhName: 移动文件选择目录页面（一级）
 * @component: OHPage,MoveDirectorListView
 * @image: screenshot/file/move_first.jpg
 */

// 选择移动文件弹框
@ComponentV2
struct MoveDirectorFirstPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  private pageStack: NavPathStack = new NavPathStack()
  vm: MoveDirectorFirstPageVM = new MoveDirectorFirstPageVM()
  @Require @Param params: MoveDirectorFirstPageParam

  @Builder
  pageStackMap(name: string, _param: string) {
    phoneRouterControl.getPageBuilder(name)?.builder(_param)
  }

  aboutToAppear() {
    phoneRouterControl.createRouter(this.pageStack, moveDirectorRouterName)
    this.vm.filterIds = this.params.fileIds
    this.vm.filterDataSourceBy()
  }

  @Builder
  render() {
    RelativeContainer() {
      Text($r('app.string.move_file'))
        .fontSize($r('app.float.vp_16'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .alignRules({
          middle: { align: HorizontalAlign.Center, anchor: '__container__' },
          top: { align: VerticalAlign.Top, anchor: '__container__' }
        })
        .margin({ top: 25, bottom: 16 })

      Image($r('app.media.delete_icon'))
        .width($r('app.float.vp_20'))
        .height($r('app.float.vp_20'))
        .onClick(() => {
          if (this.params.backDirectionAction !== undefined) {
            this.params.backDirectionAction()
          }
          phoneRouterControl.popPage()
        })
        .alignRules({
          right: { align: HorizontalAlign.End, anchor: '__container__' },
          top: { align: VerticalAlign.Top, anchor: '__container__' }
        })
        .margin({ right: $r('app.float.vp_24'), top: $r('app.float.vp_24') })

      Navigation(this.pageStack) {
        MoveDirectorListView({
          fileList: this.vm.fileList, didSelectAction: (index: number) => {
            const fileInfo = this.vm.fileList[index]
            if (fileInfo.fileType === FileType.PrivateSpace) {
              if (!this.openPrivateSpace()) {
                TCLogger.warn(TAG, 'privatespace not opened, goto open')
                return
              }
            }

            this.vm.jumpToNextlevelDirector(index)
            phoneRouterControl.jumpPage({
              routerName: moveDirectorRouterName,
              pageName: RouterMap.MOVE_FILE_SECOND_PAGE,
              builder: wrapBuilder(MoveDirectorSecondPageBuilder),
              param: this.vm
            })
          }
        })
          .width('100%')
          .layoutWeight(1)
      }
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageStackMap)
      .id(moveDirectorRouterName)
      .alignRules({
        left: { align: HorizontalAlign.Start, anchor: '__container__' },
        right: { align: HorizontalAlign.End, anchor: '__container__' },
        bottom: { align: VerticalAlign.Bottom, anchor: '__container__' }
      })
      .height(`calc(100% - 60vp)`)

      Text($r('app.string.move_here'))
        .backgroundColor('#2FAFFF')
        .width(144)
        .height(44)
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .borderRadius(22)
        .alignRules({
          middle: { align: HorizontalAlign.Center, anchor: '__container__' },
          bottom: { align: VerticalAlign.Bottom, anchor: '__container__' }
        })
        .margin({ bottom: 64 })
        .onClick(() => {
          this.params.completeAction(this.vm.checkMoveFileList())
          phoneRouterControl.popPage()
        })
    }
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: $r('app.float.vp_32'), topRight: $r('app.float.vp_32') })
    .width('100%')
    .height(`calc(100% - 147vp)`)
    .margin({ top: 147 })
  }

  build() {
    OHPage({
      pageBackgroundColor: '#4C000000',
      navMode: NavDestinationMode.DIALOG,
      childBuilder: () => {
        this.render()
      }
    })
  }

  // 弹出对话框
  private popTipDialog(msg: ResourceStr, sureText: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: sureText,
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  // 开启隐私空间
  private openPrivateSpace(): boolean {
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      this.popTipDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'), () => {
        if (this.userInfo.isVip) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
            builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          })
        } else {
          this.popTipDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'), () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            })
          })
        }
      })
      return false
    }

    return true
  }
}

export interface MoveDirectorFirstPageParam {
  fileIds: number[],
  completeAction: (fileids: number[]) => void,
  backDirectionAction?: () => void
}

@Builder
export function MoveDirectorFirstPageBuilder(param: TValueType) {
  MoveDirectorFirstPage({ params: param as MoveDirectorFirstPageParam })
}