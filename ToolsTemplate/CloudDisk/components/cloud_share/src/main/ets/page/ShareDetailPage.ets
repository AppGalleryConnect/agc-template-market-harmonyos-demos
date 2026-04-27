import { ShareDetailPageViewModel } from '../viewmodel/ShareDetailPageViewModel';
import { FileBaseCheckViewModel } from 'cloud_file_base';
import { copyPastBoard, RowView } from '../components/RowView';
import { CopyView } from '../components/CopyView';

/**
 * @usage: 用于展示分享详情页面。提供单个分享文件的详细信息展示和管理功能，支持查看下载浏览次数、修改有效期、复制提取码、
 * 取消分享、再次分享等操作。
 * @layout: 顶部导航栏 + 文件信息卡 + 统计区 + 设置项列表（有效期、提取码）+ 底部操作按钮区。
 * @constraints: vm.fileInfo获取不可修改；下载次数5和浏览次数180为固定展示值；
 * @isGen: true
 * @fileType: page
 * @domain: 云存储
 * @zhName: 分享详情页面
 * @component: CopyView,RowView
 * @image: screenshots/sharedetail.jpg
 */
@ComponentV2
struct ShareDetailPage {
  @Require @Param vm: ShareDetailPageViewModel
  private navPathStack: NavPathStack = new NavPathStack();

  @Computed
  get expireFireTime() {
    if (this.vm.fileInfo.expireTime === 0) {
      return '永久有效'
    }

    return this.vm.fileInfo.checkShareExpireTime()
  }

  showAlertDialog(title: string, message: ResourceStr, sureBtnText: string) {
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
        }, {
        value: sureBtnText,
        action: () => {
          this.vm.fileInfo.expireTime = 3
          this.navPathStack.pop()
        }
      }
      ]
    })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.STANDARD)
    .padding(this.vm.contentPadding)
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack
    })
    .backgroundColor('#F1F3F5')
  }

  @Builder
  render() {
    Column() {
      this.buildHeader()

      this.shareTopView()

      Row() {
        Row() {
          this.downLoadAndReadView('下载', '5')
          this.downLoadAndReadView('浏览', '100')
        }
        .height(72)
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_primary_contrary'))
      }
      .height(72)
      .width('100%')
      .padding({ left: 16, right: 16 })

      Column() {
        Column() {
          RowView({
            fileInfo: this.vm.fileInfo,
            shareExtureInfoVM: this.vm.shareExtureInfoVM,
            subTitle: '有效期',
            title: this.expireFireTime,
            change: true,
            shareAction: () => {
              this.vm.changeExpiretime(this.vm.fileInfo, this.vm.blockUsefullTime,
                this.vm.shareExtureInfoVM.usefullTimeId)
            }
          })
          this.line()
          CopyView({
            fileInfo: this.vm.fileInfo,
            shareExtureInfoVM: this.vm.shareExtureInfoVM,
            subTitle: '提取码',
            title: 'kdje',
            change: false
          })
        }
        .height(120)
        .padding({ left: 16, right: 16 })
        .width('100%')
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_primary_contrary'))
      }
      .margin({ top: 12 })
      .height(120)
      .width('100%')
      .padding({ left: 16, right: 16 })

      Blank()
      if (this.vm.fileInfo.expireTime === 3) {
        Row({ space: 12 }) {
          Text('再次分享')
            .textAlign(TextAlign.Center)
            .font({
              size: $r('sys.float.Body_L'),
              weight: 400
            })
            .onClick(() => {
              this.vm.shareAgains(this.vm.fileInfo)
            })
            .width(ShareDetailPageViewModel.getButtonWidth())
            .borderRadius(24)
            .height(44)
            .fontColor('#FF2FAFFF')
            .backgroundColor('#FFD2EEFF')
        }
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })
      } else if (this.vm.fileInfo.expireTime === 2) {
        Row({ space: 12 }) {
          Text('取消分享')
            .textAlign(TextAlign.Center)
            .font({
              size: $r('sys.float.Body_L'),
              weight: 400
            })
            .width(ShareDetailPageViewModel.getButtonWidth())
            .backgroundColor($r('sys.color.comp_background_primary_contrary'))
            .borderRadius(24)
            .height(44)
            .fontColor('#B2000000')
            .onClick(() => {
              this.showAlertDialog('取消分享', '取消后分享的额链接及文件无法继续由其他用户访问', '确认')
            })
          Text('再次分享')
            .textAlign(TextAlign.Center)
            .font({
              size: $r('sys.float.Body_L'),
              weight: 400
            })
            .onClick(() => {
              this.vm.shareAgains(this.vm.fileInfo)
            })
            .width(ShareDetailPageViewModel.getButtonWidth())
            .borderRadius(24)
            .height(44)
            .fontColor('#FF2FAFFF')
            .backgroundColor('#FFD2EEFF')
        }
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 + 24 })
      } else {
        Row({ space: 12 }) {
          Text('取消分享')
            .textAlign(TextAlign.Center)
            .font({
              size: $r('sys.float.Body_L'),
              weight: 400
            })
            .width(ShareDetailPageViewModel.getButtonWidth())
            .backgroundColor($r('sys.color.comp_background_primary_contrary'))
            .borderRadius(24)
            .height(44)
            .fontColor('#B2000000')
            .onClick(() => {
              this.showAlertDialog('取消分享', '取消后分享的额链接及文件无法继续由其他用户访问', '确认')
            })
          Text('复制链接')
            .textAlign(TextAlign.Center)
            .font({
              size: $r('sys.float.Body_L'),
              weight: 400
            })
            .onClick(() => {
              copyPastBoard(this.getUIContext(), this.vm.fileInfo.downloadUrl, '内容已复制到剪贴板！')
            })
            .width(ShareDetailPageViewModel.getButtonWidth())
            .borderRadius(24)
            .height(44)
            .fontColor('#FF2FAFFF')
            .backgroundColor('#FFD2EEFF')
        }
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 + 24 })
      }

    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.share_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.navPathStack.pop()
        })

      Text('分享详情')
        .margin({left: 8, right: 8})
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
  }

  @Builder
  shareTopView() {
    Column() {
      Image(FileBaseCheckViewModel.getImageSource(this.vm.fileInfo.fileType, this.vm.fileInfo.name))
        .width(72)
        .height(72)
        .margin({ top: 48 })
      Text(this.vm.fileInfo.name)
        .textAlign(TextAlign.Center)
        .font({
          size: $r('sys.float.Body_M'),
          weight: FontWeight.Medium
        })
        .height(16)
        .fontColor('#B2000000')
        .margin({ top: 12 })

      Text('分享时间 ' + this.vm.fileInfo.createTime)
        .textAlign(TextAlign.Center)
        .font({
          size: $r('sys.float.Body_S'),
        })
        .height(14)
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ top: 6, bottom: 16 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  downLoadAndReadView(title: string, sum: string) {
    Column({ space: 4 }) {
      Text(sum)
        .textAlign(TextAlign.Center)
        .font({
          size: $r('sys.float.Title_S'),
          weight: FontWeight.Medium
        })
        .height(23)
        .fontColor('#B2000000')
      Text(title)
        .textAlign(TextAlign.Center)
        .font({
          size: $r('sys.float.Body_S'),
        })
        .height(14)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .height(40)
    .alignItems(HorizontalAlign.Center)
  }
}

@Builder
export function ShareDetailPageBuilder(params: Object) {
  ShareDetailPage({ vm: params as ShareDetailPageViewModel })
}

