import { FileBaseSelectListView, FileBaseCheckViewModelSource, FileBaseCheckViewModel } from 'cloud_file_base'
import { OperationItemViewModel, OperationItemType, OperationItemView } from 'cloud_operation_item'
import { pasteboard } from '@kit.BasicServicesKit'
import { MySharePageViewModel } from '../viewmodel/MySharePageViewModel'
import { ShareDetailPageViewModel } from '../viewmodel/ShareDetailPageViewModel'

/**
 * @usage: 用于分享文件列表展示和管理场景。提供分享文件列表选择、取消分享、复制链接、重新分享等功能。
 * 关键数据结构：FileListSelectViewVM（文件列表选择视图模型）、tabsname（标签名称字符串，
 * 包含"分享过期"等）、FileOperationType（操作类型枚举，包含CancleShare取消分享、Share分享、
 * CopyLink复制链接）、ShareOptions（分享选项）、ShareDetailPageParam（分享详情页参数，
 * 包含fileInfo文件信息、tabsname标签名称、cancelShareAction取消分享回调）。
 * 包含if逻辑：根据tabsname判断显示不同的操作按钮（分享过期显示取消分享和分享，其他显示取消分享和复制链接），
 * 根据操作类型执行不同操作。
 * @layout: 垂直布局。主体为FileListSelectView文件列表选择视图（占据全部空间），
 * 底部绑定操作弹框（选中文件时显示，根据tabsname显示不同操作按钮）。
 * @constraints: tabsname标签名称不能为空，fileListSelectViewVM文件列表视图模型必须正确初始化，
 * 操作回调函数必须正确处理
 * @isGen: true
 * @fileType: component
 * @zhName: 分享列表视图组件
 * @subPage: ShareDetailPage
 * @component: FileListSelectView,OperationSelect
 * @image：screenshot/Person/shareList.jpg
 */
@ComponentV2
export struct ShareListView {
  @Param @Require currentIndex: number
  @Param @Require fileListSelectViewVM: FileBaseCheckViewModel
  @Param @Require vm: MySharePageViewModel
  operationVM: OperationItemViewModel = new OperationItemViewModel([OperationItemType.CANCELSHARE,
    OperationItemType.COPYLINK])

  aboutToAppear(): void {
    this.fileListSelectViewVM.listSource = FileBaseCheckViewModelSource.SHARE
    this.fileListSelectViewVM.didSelectedAtIndexAction = (_: number) => {
      // 控制底部弹框是否出现
      const isVisible: boolean = (this.fileListSelectViewVM.selectedIndexes.size > 0) ? true : false
      if (isVisible !== this.vm.isShowList[this.currentIndex]) {
        this.vm.isShowList[this.currentIndex] = isVisible
      }

      if (isVisible) {
        const tmpList = this.fileListSelectViewVM.getAllSelected()
        this.operationVM.operationList = MySharePageViewModel.getAllOperation(tmpList, this.currentIndex)
      }
    }

    this.fileListSelectViewVM.switchAllSelectedAction = (isAllSelected: boolean) => {
      this.vm.isShowList[this.currentIndex] = isAllSelected
      if (isAllSelected) {
        const tmpList = this.fileListSelectViewVM.getAllSelected()
        this.operationVM.operationList = MySharePageViewModel.getAllOperation(tmpList, this.currentIndex)
      }
    }
    //跳转分享文件详情页面
    this.fileListSelectViewVM.didClickAtIndexAction = (index: number) => {
      this.vm.isShowList[this.vm.fileTypeIndex] = false
      this.vm.tabListVM[this.vm.fileTypeIndex].selectedIndexes.clear()
      this.vm.checkShareDetail(this.fileListSelectViewVM.fileList[index])
    }

    this.operationVM.didSelectedItemAction = (operationType: OperationItemType) => {
      if (operationType === OperationItemType.COPYLINK) {
        this.showAlertDialog('', '是否开启自动填充提取码？', '确定', operationType)
      } else if (operationType === OperationItemType.CANCELSHARE) {
        this.showAlertDialog('确认取消分享？', '取消后分享的额链接及文件无法继续由其他用户访问', '确认', operationType)
      } else {
        this.vm.shareAgain(this.fileListSelectViewVM.getAllSelected()[0])
      }
    }
  }

  @Builder
  dealwithFileSheet() {
    OperationItemView({
      vm: this.operationVM
    })
  }

  showToast() {
    this.getUIContext().getPromptAction().showToast({
      message: '内容已复制到剪贴板',
      duration: 2000,
      textColor: $r('sys.color.font_on_primary'),
      backgroundColor: '#CC202C3B',
      bottom: 136 + 24,
      backgroundBlurStyle: BlurStyle.NONE
    })
  }

  showAlertDialog(title: string, message: ResourceStr, sureBtnText: string, type: OperationItemType) {
    this.getUIContext().showAlertDialog({
      title: title,
      message: message,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: sureBtnText,
          action: () => {
            if (type === OperationItemType.CANCELSHARE) {
              for (let i = 0; i < this.fileListSelectViewVM.getAllSelected().length; i++) {
                this.fileListSelectViewVM.getAllSelected()[i].expireTime = 3
              }
            } else if (type === OperationItemType.COPYLINK) {
              for (let i = 0; i < this.fileListSelectViewVM.getAllSelected().length; i++) {
                this.copyPastBoard(this.fileListSelectViewVM.fileList[i].downloadUrl ?
                this.fileListSelectViewVM.fileList[i].downloadUrl
                  : ''
                )
              }
            }
            this.vm.isShowList[this.currentIndex] = false
            this.fileListSelectViewVM.selectedIndexes.clear()
          }
        }
      ]
    })
  }

  async copyPastBoard(text: string) {
    try {
      let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      // 获取系统剪贴板
      let systemPasteboard = pasteboard.getSystemPasteboard();
      // 将数据写入剪贴板
      await systemPasteboard.setData(data);
      this.showToast()
    } catch (e) {
    }
  }

  build() {
    Column() {
      if (this.fileListSelectViewVM.fileList.length !== 0) {
        FileBaseSelectListView({ vm: this.fileListSelectViewVM })
          .width('100%')
          .layoutWeight(1)
          .margin({ bottom: 60 })
      } else {
        this.NoFileList()
      }
    }
    .bindSheet($$this.vm.isShowList[this.currentIndex], this.dealwithFileSheet(),
      {
        showClose: false,
        height: 40 + 48,
        maskColor: Color.Transparent,
        enableOutsideInteractive: true,
        radius: { topLeft: 0, topRight: 0 },
        preferType: SheetType.BOTTOM
      })
  }

  @Builder
  NoFileList() {
    Column() {
      Image($r('app.media.share_content_empty'))
        .width(120)
        .height(120)
      Text('暂无文件')
        .fontColor('#9DA3AA')
        .fontSize(12)
        .lineHeight(14)
        .margin({ top: 18 })
        .margin({bottom : 170})
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}
