/**
 * @usage: 作品列表页面,作为作品列表模块的一级页面,展示用户已编辑的音频作品。
 * 支持单个删除、批量删除、批量保存、全选/取消全选等操作。提供滑动删除和编辑模式两种交互方式。
 * 点击作品项可跳转到作品详情页查看和播放音频。
 * @layout: 页面采用Column垂直布局,顶部为WorkerEditHeader头部组件(显示标题和编辑按钮),
 * 中间为作品列表区域(List组件,支持滑动删除),列表为空时显示NoMusicData空状态组件。
 * 编辑模式下底部弹出BottomDialog操作栏(包含全选、删除、保存按钮)。
 * @constraints: 需要登录才能查看作品列表,未登录时列表为空。编辑模式下可批量操作,
 * 删除操作需要二次确认(DelDialog弹窗)。保存到相册需要系统权限。
 * @domain: 音频编辑
 * @zhName: 作品列表页面
 * @isGen: true
 * @fileType: page
 * @subPage: WorkDetailPage
 * @component: WorkerEditHeader,BottomDialog,DelDialog,MusicItem,NoMusicData
 * @image: screenshots/audioWorkList.jpg
 */
import { FileUtil, PersistenceV2Util, PromptActionClass } from 'audio_common'
import { LISTMODE, MusicItem } from 'common_view/src/main/ets/components/MusicItem'
import { MusicListViewModel, MusicViewModelArray } from 'common_view/src/main/ets/viewModel/MusicListViewModel'
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel'
import { WorkerEditHeader } from '../components/WorkerEditHeader'
import { ComponentContent, PersistenceV2 } from '@kit.ArkUI'
import { BottomDialog, BottomDialogController, BottomDialogParams } from '../components/BottomDialog'
import { DelDialog } from '../components/DelDialog'
import { AudioUtil } from 'audio_common/src/main/ets/util/AudioUtil'
import { common } from '@kit.AbilityKit'
import { getNamesFromPath } from '../util/utils'
import { phoneRouterControl } from 'oh_router'
import { BarVM, RouterMap, UserInfo } from 'common'
import { WorkDetailPageBuilder } from './WorkDetailPage'
import { MusicParam, NoMusicData } from 'common_view'
import { RenameDialog, RenameDialogParams } from '../components/RenameDialog'

const TAG = 'WorkListPage'


//编辑弹窗-底部
@Builder
function bottomDialog(params: BottomDialogParams) {
  BottomDialog({ params: params })
}

//重命名弹窗-底部
@Builder
function renameDialog(params: RenameDialogParams) {
  RenameDialog({ params: params })
}

@ComponentV2
export struct WorkListPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local workListVM: MusicListViewModel = new MusicListViewModel()
  @Local title: string = '作品'
  @Local btnText: string = '编辑'
  @Local listMode: LISTMODE = 'click'
  private ctx: UIContext = this.getUIContext();
  checkRes: MusicViewModelArray = []
  persistenceV2Util = new PersistenceV2Util()
  delDialogController: CustomDialogController = new CustomDialogController({
    builder: DelDialog({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    backgroundColor: '#202E3E',
    backgroundBlurStyle: BlurStyle.NONE
  });
  //删除弹窗取消按钮回调
  onCancel = () => {
    this.delDialogController.close()
  }
  //删除弹窗确定按钮回调
  onAccept = () => {
    this.workListVM.delData(this.checkRes)
    this.checkRes = []
    this.delDialogController.close()
    this.ctx.getPromptAction().showToast({ message: '删除成功' })
    // 如果删除后列表为空，退出编辑模式并关闭底部弹窗
    if (this.workListVM.list.length === 0) {
      this.closeEditDialogHandle()
    } else {
      // 如果还有数据，更新标题显示选择数量（此时为0）
      this.title = `已选择${this.checkRes.length}个音频`
    }
  }
  //弹窗全选回调事件
  checkAllHandle = (status: boolean) => {
    if (status) {
      this.checkRes = this.workListVM.list
      this.workListVM.checkedAll()
    } else {
      this.checkRes = []
      this.workListVM.unCheckAll()
    }
    this.title = `已选择${this.checkRes.length}个音频`
  }
  //弹窗删除按钮事件
  delHandle = () => {
    if (this.checkRes.length > 0) {
      this.delDialogController.open();
    } else {
      this.ctx.getPromptAction().showToast({ message: '请先选择要删除的作品' })
    }
  }
  bdController = new BottomDialogController()
  //弹窗保存按钮事件
  saveHandle = async () => {
    let context = this.ctx.getHostContext() as common.UIAbilityContext
    const nameArr: string[] = []
    if (this.checkRes.length > 0) {
      this.checkRes.forEach((item) => {
        nameArr.push(item.title)
      })
      const audioSaveResult: string[] = await AudioUtil.save(context, nameArr)
      if (!audioSaveResult.length) {
        this.ctx.getPromptAction().showToast({ message: '保存失败' })
        return
      }
      let i = 0;
      this.checkRes.forEach(async (item, index) => {
        let res = await FileUtil.copyFileToDestPath(item.sourcePath, audioSaveResult[index])
        if (res) {
          i++
        } else {
          i--
          this.ctx.getPromptAction().showToast({ message: '保存失败' })
        }
        if (i === this.checkRes.length) {
          this.ctx.getPromptAction().showToast({ message: '保存成功' })
        }
      })
    } else {
      this.ctx.getPromptAction().showToast({ message: '请先选择要保存的作品' })
    }
  }
  //编辑弹窗参数
  bottomDialogPamras: BottomDialogParams = {
    checkAllHandle: this.checkAllHandle,
    delHandle: this.delHandle,
    saveHandle: this.saveHandle,
    bdController: this.bdController
  }

  //准备编辑弹窗容器
  readyBottomDialog() {
    let contentNode: ComponentContent<Object> =
      new ComponentContent(this.ctx, wrapBuilder(bottomDialog), this.bottomDialogPamras);
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(contentNode);
    PromptActionClass.setOptions({ alignment: DialogAlignment.Bottom, offset: { dx: 0, dy: 0 }, isModal: false });
  }

  //编辑/取消编辑按钮点击事件
  btnClick = () => {
    if (this.listMode === 'click') {
      this.openEditDialogHandle()
    } else {
      this.closeEditDialogHandle()
    }
  }

  //开启编辑弹窗事件
  openEditDialogHandle() {
    this.closeRenameDialog()
    this.closeDialog()
    this.listMode = 'checkBox'
    this.btnText = '取消编辑'
    this.title = `已选择${this.checkRes.length}个音频`
    this.readyBottomDialog()
    PromptActionClass.openDialog()
  }

  //关闭编辑弹窗事件
  closeEditDialogHandle() {
    this.closeDialog()
    this.checkRes = []
    this.checkAllHandle(false)
    this.listMode = 'click'
    this.btnText = '编辑'
    this.title = '作品'

  }

  closeDialog() {
    PromptActionClass.closeDialog()
  }

  //作品列表点击事件
  musicItemOnclick = (item: MusicViewModel) => {
    const param: MusicParam = {
      uri: item.uri,
      title: item.title,
      duration: item.duration,
      size: item.size,
      format: item.format,
      path: item.sourcePath
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.WORK_DETAIL_PAGE,
      builder: wrapBuilder(WorkDetailPageBuilder),
      param: param
    })
  }
  //作品列表选中/取消事件
  musicItemOnChange = (item: MusicViewModel, checkBoxStatus: boolean) => {
    if (checkBoxStatus) {
      this.checkRes.push(item)
      if (this.checkRes.length === this.workListVM.list.length) {
        this.bdController.changeStatus(true)
      }
    } else {
      this.checkRes = this.checkRes.filter(val => val.title !== item.title)
      this.bdController.changeStatus(false)
    }
    this.title = `已选择${this.checkRes.length}个音频`
  }
  //重命名弹窗参数
  renameDialogParams: RenameDialogParams = {
    musicName: '',
    index: -1,
    nameCancelHandle: () => {
      this.closeRenameDialog()
    },
    nameSaveHandle: (index: number, musicName: string) => {
      this.workListVM.setTitle(index, musicName)
      const tempStr = JSON.stringify(this.workListVM.list)
      this.persistenceV2Util.setData(tempStr, 'work')
      this.closeRenameDialog()
    }
  }

  //准备重命名弹窗容器
  readyRenameDialog() {
    let contentNode: ComponentContent<Object> =
      new ComponentContent(this.ctx, wrapBuilder(renameDialog), this.renameDialogParams);
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(contentNode);
    PromptActionClass.setOptions({ alignment: DialogAlignment.Bottom, offset: { dx: 0, dy: 0 }, isModal: false });
  }

  //作品列表编辑按钮点击事件
  musicItemEditOnclick = (index: number) => {

    this.openRenameDialogHandle(index)
  }

  //打开重命名弹窗
  openRenameDialogHandle(index: number) {
    this.closeEditDialogHandle()
    this.renameDialogParams.index = index
    this.renameDialogParams.musicName = this.workListVM.list[index].title
    this.readyRenameDialog()
    PromptActionClass.openDialog()
  }

  //关闭重命名弹窗
  closeRenameDialog() {
    this.closeDialog()
  }

  @Builder
  itemEnd(index: number) {
    Row() {
      Text('删除')
        .margin({ left: 8 })
        .fontSize(16)
        .backgroundColor('#19FFFFFF')
        .fontColor(Color.White)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .width(70)
        .height(70)
        .onClick(() => {
          this.workListVM.delData([this.workListVM.list[index]])
          this.ctx.getPromptAction().showToast({ message: '删除成功' })
        });
    }.padding(4).justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    Column() {
      WorkerEditHeader({
        title: this.title,
        btnText: this.btnText,
        btnClick: this.btnClick,
        isHideBtn: !this.workListVM.list.length
      })

      Blank().width('100%').height(8)
      if (!this.workListVM.list.length) {
        NoMusicData()
      }
      List() {
        ForEach(this.workListVM.list, (item: MusicViewModel, index: number) => {
          ListItem() {
            MusicItem({
              item: item,
              index: index,
              musicItemOnChange: this.musicItemOnChange,
              musicItemOnclick: this.musicItemOnclick,
              listMode: this.listMode,
              isEdit: true,
              musicItemEditOnclick: this.musicItemEditOnclick
            })
          }.margin({ top: 12 })
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd(index)
              },
              onAction: () => {

              },
              actionAreaDistance: 300,
            },
            edgeEffect: SwipeEdgeEffect.Spring
          });
        }, (item: MusicViewModel) => JSON.stringify(item))
      }.layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: BarVM.instance.staBarH })
    .backgroundColor('#0A0D1E')
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      // 页面不可见时（离开页面），如果处于编辑模式，则重置为非编辑状态
      if (!isExpanding && currentRatio <= 0) {
        this.closeEditDialogHandle()
        this.closeRenameDialog()
        //页面退出时必须清空列表数据，否则再次进入重新加载数据后，如果数据前后没变化，则foreach不会重新渲染，
        // 此时可能时由于重新加载数据（this.workListVM.loadData('work')），list的代理应该是发生了变更，
        // 导致跟foreach失去绑定，此时变更list属性UI不发生变化
        this.workListVM.clear()
      }

      if (isExpanding && currentRatio >= 1.0) { // 页面完全可见
        if (!this.userInfo.isLogin) {
          this.workListVM = new MusicListViewModel()
        } else {
          //重新加载数据后，变量的代理发生了变化，但是如果前后数据没变化，则foreach不会重新渲染，
          // 从而导致foreach和数据变量失去了联系，此时更改数据变量的属性，UI不会发生改变，
          // 故需要在页面隐藏时变更数据变量，使其数据发生变化，从而促使foreach重新渲染
          this.workListVM.loadData('work')
        }
      }
    })
  }
}