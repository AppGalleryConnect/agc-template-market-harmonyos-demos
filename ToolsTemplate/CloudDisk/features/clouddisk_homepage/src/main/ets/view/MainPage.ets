import { OHPage, phoneRouterControl } from 'oh_router';
import { BarVM, Constants, EmitterUtil, FileInfo, FileType, GlobalContext, RouterMap, TimeUtil } from 'common';
import { MainPageVM } from '../viewmodel/MainPageVM';
import { SearchPageBuilder } from '../../../../Index';
import { DirectorDetailJumpHandle, FileManagerPageVM, FileTransferManagerPageVM,
  FileTransferUploadPageVM } from 'clouddisk_file';
import {
  NewFileFolderOperationSelect,
  NewFileFolderOperationSelectVM,
  NewFolderInputSelect
} from 'clouddisk_file_operation';
import { FileTransferView } from '../components/FileTransferView';
import { LookAD, LookADViowModel } from 'look_ad';
import { emitter } from '@kit.BasicServicesKit';
import { FileOperationUtil } from 'module_cloud_upload';
import { VipCenterPageBuilder } from 'collect_personal_info';
import { promptAction } from '@kit.ArkUI';


/**
 * @usage: 用于展示云盘首页的主页面。提供文件分类展示、文件搜索、广告、文件操作等核心功能。关键数据结构包括MainPageVM（主页视图模型）、
 * OperationSelectVM（文件操作视图模型）、NewFileFolderOperationSelectVM（新建文件夹操作视图模型）。页面支持文件类型筛选（Tabs切换）、
 * 文件多选操作、全选/取消全选、文件详情查看等功能。通过TabsController控制文件类型切换，支持下载、删除、分享、重命名、移动、收藏等文件操作。
 * @layout: 页面采用Stack布局，主体是垂直Column布局。顶部包含标题栏（Row，左侧"首页"标题，右侧传输图标）、搜索栏（TopBar组件）、
 * 广告卡片（welfare组件）。中间是文件内容区域（content组件），使用Tabs组件进行文件类型切换，
 * 每个TabContent包含文件选择状态栏和文件列表（List）。右下角固定位置放置上传悬浮按钮。页面底部绑定文件操作面板（OperationSelect）。
 * @constraints:
 * @isGen: true
 * @fileType: page
 * @domain: 云存储,
 * @zhName: 云存储首页
 * @subPage: FileTransferManagerPage,SearchPage,VipCenterPage,LoginPage
 * @component: OHPage,OperationSelect
 * @image: screenshot/homepage.jpg
 */
@ComponentV2
export struct MainPage {
  vm: MainPageVM = new MainPageVM()
  @Local offsetX: number = 0
  @Local offsetY: number = 0
  @Local imageWidth: number = 62
  @Local imageHeight: number = 62
  @Local screenWidth: number = 0
  @Local screenHeight: number = 0
  @Local fileFolderName: string = ''
  // 记录拖拽开始时的位置
  private startX: number = 0
  private startY: number = 0
  private isDragging: boolean = false
  // 吸附距离阈值
  private snapThreshold: number = 50
  newFileFolderVm: NewFileFolderOperationSelectVM = new NewFileFolderOperationSelectVM()
  logTag: string = 'MainPage';
  controller: TabsController = new TabsController();
  fileManagerPageVm: FileManagerPageVM = FileManagerPageVM.rootInstance
  fileTransferVm: FileTransferManagerPageVM = FileTransferManagerPageVM.rootInstance
  fileOperationUtil: FileOperationUtil = new FileOperationUtil()
  @Event handleIconClick: (index: number) => void = () => {
  };
  lookADViowModel: LookADViowModel = new LookADViowModel()

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageBackgroundColor: $r('sys.color.background_primary')
    })
  }

  @Monitor('vm.fileList.length')
  onChange(monitor: IMonitor) {
    this.vm.filterListBySelectedType(this.vm.fileTypeIndex)
  }

  aboutToAppear(): void {
    DirectorDetailJumpHandle.rootInstance.initalWithContext()
    EmitterUtil.on('fileId', (eventData: emitter.EventData) => {
      this.vm.fileList = this.vm.fileList.filter(item => item.fileId !== eventData.data?.fileId);
      this.vm.filterListBySelectedType(0)
    })
    // 初始化云存储登录
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        FileOperationUtil.isInitSuccess = true
      })
    }

    this.lookADViowModel.BannerOnClick = (index: number): void => {
      if (index === 0) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.VIP_CENTER_PAGE,
          builder: wrapBuilder(VipCenterPageBuilder)
        })
      } else {
        //ToDo 广告目前没有连接
      }
    }
  }

  aboutToDisappear(): void {
    EmitterUtil.off('fileId', (eventData: emitter.EventData) => {
    })
  }

  @Builder
  newFilefolderSheet() {
    NewFileFolderOperationSelect({
      vm: this.newFileFolderVm,
      selectFile: (type: string) => {
        FileTransferUploadPageVM.rootInstance.selectUploadFileTask(type, this.newFileFolderVm)
      },
      jumpVip: () => {
        if (!this.newFileFolderVm.userInfo?.isLogin) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.LOGIN_PAGE,
          })
        } else {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.VIP_CENTER_PAGE,
            builder: wrapBuilder(VipCenterPageBuilder)
          })
        }
      }
    })
  }

  @Builder
  inputCustomDialog() {
    NewFolderInputSelect({
      closeWithResult: (text?: string) => {
        if (text !== undefined) {
          this.fileFolderName = text
          // 添加到文件列表中
          const fileInfo: FileInfo = new FileInfo(FileType.Director, this.fileFolderName,
            `${TimeUtil.getCurDate(TimeUtil.PATTERN_DATE_HYPHEN)} ${TimeUtil.getCurTime(TimeUtil.PATTERN_TIME_COLON)}`)
          fileInfo.fileId = Date.now()

          FileManagerPageVM.rootInstance.addFileToCurrentList([fileInfo])
        }
        promptAction.closeCustomDialog(this.fileManagerPageVm.newFolderDialogId)
      }
    })
  }

  @Monitor('newFileFolderVm.isShowInput')
  openInputDialog() {
    promptAction.openCustomDialog({
      builder: () => {
        this.inputCustomDialog()
      },
      alignment: DialogAlignment.Center,
      width: '90%'
    })
      .then((id) => {
        this.fileManagerPageVm.newFolderDialogId = id
      })
  }

  private snapToEdge(x: number, y: number): Position {
    let snapX = x
    let snapY = y

    // 检查是否靠近左边缘
    if (x <= 0) {
      snapX = 0
    }
    // 检查是否靠近右边缘
    else if (x >= this.screenWidth - this.imageWidth) {
      snapX = this.screenWidth - this.imageWidth
    }

    // 检查是否靠近上边缘
    if (y <= this.snapThreshold) {
      snapY = 0
    }
    // 检查是否靠近下边缘
    else if (y >= this.screenHeight - this.imageHeight) {
      snapY = this.screenHeight - this.imageHeight
    }

    return { x: snapX, y: snapY }
  }

  // 页面内容渲染
  @Builder
  render() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 12 }) {
        Row() {
          Text('首页')
            .fontSize($r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))

          Image($r('app.media.ic_transfer')).width(24).height(24)
            .onClick(() => {
              GlobalContext.getUIContext().getHostContext()?.eventHub.emit(Constants.JUMPTO_FILETRANSFERMANAGERPAGE_KEY)
            })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 15, bottom: 3 })
        .padding({ left: 16, right: 16 })
        .width('100%')

        Scroll() {
          Column() {
            // 首页搜索
            this.TopBar()

            // 广告
            this.welfare()

            this.content()
          }
          .width('100%')
          .height('100%')

        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
      }
      .backgroundColor($r('sys.color.background_primary'))
      .backgroundImageSize(ImageSize.FILL)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('100%')

      Image($r('app.media.ic_upload'))
        .width(this.imageWidth)
        .height(this.imageHeight)
        .position({ x: this.offsetX, y: this.offsetY })
        .gesture(
          PanGesture()
            .onActionStart((event: GestureEvent) => {
              // 记录开始拖拽时的位置
              this.startX = this.offsetX
              this.startY = this.offsetY
              this.isDragging = true
            })
            .onActionUpdate((event: GestureEvent) => {
              if (!this.isDragging) {
                return
              }
              let newX = this.startX + event.offsetX
              let newY = this.startY + event.offsetY

              newX = Math.max(0, Math.min(newX, this.screenWidth))
              newY = Math.max(0, Math.min(newY, this.screenHeight - (150 - BarVM.instance.aiBarH * 2)))

              this.offsetX = newX
              this.offsetY = newY
            })
            .onActionEnd(() => {
              this.isDragging = false
              const snappedPosition = this.snapToEdge(this.offsetX, this.offsetY)
              this.offsetX = snappedPosition.x as number
              this.offsetY = snappedPosition.y as number
            })
            .onActionCancel(() => {
              this.isDragging = false
            })

        )
        .onClick(() => {
          this.newFileFolderVm.isShow = !this.newFileFolderVm.isShow
        })
        .bindSheet($$this.newFileFolderVm.isShow, this.newFilefolderSheet(),
          {
            showClose: false,
            height: 384,
            enableOutsideInteractive: false,
            radius: { topLeft: 24, topRight: 24 },
            preferType: SheetType.BOTTOM
          })
    }.padding({ top: BarVM.instance.aiBarH })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.screenWidth = newValue.width as number
      this.screenHeight = newValue.height as number
      this.offsetX = this.screenWidth - 32 - this.imageWidth
      this.offsetY = this.screenHeight - (100 - BarVM.instance.aiBarH) - this.imageHeight
    })
  }

  @Builder
  TopBar() {
    Column() {
      Row() {
        Text('搜索文件')
          .fontSize(14)
          .fontColor('#999EA2')
          .borderRadius(24)
          .height(50)
          .layoutWeight(1)

        // 搜索图标
        Row() {
          Image($r('app.media.icon_search'))
            .width(28)
            .height(28)
        }
        .width(50)
        .height(50)
        .justifyContent(FlexAlign.Center)
      }
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.SEARCH_PAGE,
          builder: wrapBuilder(SearchPageBuilder)
        })
      })
      .width('100%')
      .height(44)
      .backgroundColor('#F0F3F7')
      .borderRadius(12)
      .padding({ left: 16, right: 12 })
    }.padding({ left: 16, right: 16 })
  }

  @Builder
  welfare() {
    LookAD({ award: '领现金', lookADViowModel: this.lookADViowModel }).margin({ left: 16, right: 16 })
  }

  @Builder
  content() {
    // 文件筛选类型列表
    Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.vm.fileTypeIndex }) {
      ForEach(this.vm.fileTypeTitles, (item: string, index: number) => {
        TabContent() {
          if (this.vm.selectVM.fileList.length > 0) {
            FileTransferView({
              vm: this.vm
            }).layoutWeight(1)
          } else {
            Column() {
              Image($r('app.media.ic_nodata')).width(120).height(120)
              Text('暂无文件')
                .fontColor('rgba(0, 0, 0, 0.4)')
                .fontSize($r('app.float.fontsize_12'))
                .lineHeight(14)
                .margin({ top: 18 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
        }.tabBar(this.tabBuilder(item, index))
      }, (item: string) => item)
    }
    .layoutWeight(1)
    .barHeight(40)
    .onChange((index: number) => {
      this.vm.fileTypeIndex = index;
      this.vm.selectVM.selectedIndexes.clear()
      this.vm.isShowOperation = false
      this.vm.filterListBySelectedType(this.vm.fileTypeIndex)
    })
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor('#000000')
        .fontWeight(this.vm.fileTypeIndex === index ? 500 : 400)
        .opacity(this.vm.fileTypeIndex === index ? 1 : 0.4)
      Divider()
        .width(12)
        .margin({ top: 7 })
        .strokeWidth(2)
        .color($r('sys.color.comp_background_emphasize'))
        .opacity(this.vm.fileTypeIndex === index ? 1 : 0)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.vm.fileTypeIndex === index) {
        return
      }
      this.vm.fileTypeIndex = index;
    })
  }
}