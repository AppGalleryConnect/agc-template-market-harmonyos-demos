import { AlertDialog, AppStorageV2, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointModel, TValueType, WindowPopManager } from 'common';
import { OHPage } from 'oh_router';
import { WorkListPageVM } from '../viewmodel/WorkListPageVM';
import { WorkDetailPageVM } from '../viewmodel/WorkDetailPageVM';
import { VideoPlayerComp } from '../components/VideoPlayerComp';
import { MetaDataSheetContentBuilderView } from '../components/MetaDataSheetContentBuilder';

@Builder
export function WorkDetailPageBuilder(param: TValueType) {
  WorkDetailPage({
    pageParams: param
  });
}


/**
 * @usage: 用于展示视频作品详情页面，提供视频播放、元数据查看、保存到相册和删除功能。关键参数：
 * pageParams页面参数（作品ID），workDetailPageVM.isShowDetail元数据弹窗状态，dialogControllerConfirm删除确认弹框。
 * @layout: 页面整体采用垂直布局（Column）。顶部为标题栏（横向排列，包含返回按钮、日期时间和保存按钮），
 * 中间为视频播放区域（居中对齐），底部为删除按钮（居中对齐）。
 * @zhName: 作品详情页
 * @fileType: page
 * @isGen: true
 * @domain: 视频
 * @image: screenshot/work/play.jpg
 * @component: VideoPlayerComp, OHPage
 */
@ComponentV2
export struct WorkDetailPage {
  @Param pageParams: TValueType = null
  // 获取UI上下文
  uiContext: UIContext = this.getUIContext();
  workListPageVm: WorkListPageVM = WorkListPageVM.instance;
  workDetailPageVM: WorkDetailPageVM = WorkDetailPageVM.instance;
  // 删除确认弹框
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '提示',
      content: '确定要删除此作品吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.workListPageVm.deleteWork();
          this.workDetailPageVM.backPage();
        }
      },
    }),
  })
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local openDetail: string = 'workDetail'
  @Local subWindow?: window.Window;

  aboutToAppear() {
    this.workListPageVm.deleteId = this.pageParams as string;
    this.workDetailPageVM.initData()
  }

  @Monitor('breakPointModel.currentBreakpoint')
  detailCheckBreakpoint() {
    try {
      if (this.subWindow?.isWindowShowing()) {
        WindowPopManager.destroyWindow(this.openDetail).then(() => {
          this.showDetailWindow();
        });
      }
    } catch (err) {
      hilog.error(0x0000, 'WorkDetailPage', 'fold again window popup err = ' + JSON.stringify(err));
    }
  }

  async showDetailWindow() {
    this.subWindow = await WindowPopManager.showWindow({
      name: this.openDetail,
      builder: wrapBuilder(MetaDataSheetContentBuilderView),
      showMask: true, // 显示蒙层
      autoCancel: false,
      attachParam: this.workDetailPageVM.videoWork,
      onBackPress: () => {
        // 拦截返回键
      },
      align: this.breakPointModel.getWindowAlignment()
    })
  }

  // 标题栏
  @Builder
  headerTitleBuilder() {
    Row() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .aspectRatio(1)
          .onClick(() => {
            this.workDetailPageVM.backPage();
          })
        Column() {
          Row() {
            Text(this.workDetailPageVM.videoWork.createDate)
              .fontColor('#FF000000')
              .fontSize(18)
              .margin({ right: 6 })
              .fontWeight(FontWeight.Regular)
            Image($r('app.media.look_detail_icon'))
              .width(24)
              .height(24)
              .onClick(() => {
                this.showDetailWindow();
              })
          }

          Text(this.workDetailPageVM.videoWork.createTime)
            .fontColor('#99000000')
            .fontSize(12)
        }
        .margin({ left: 16 })
        .alignItems(HorizontalAlign.Start)
      }

      Text('保存')
        .fontColor('#99000000')
        .fontSize(14)
        .onClick(() => {
          this.workDetailPageVM.saveToAlbum(this.uiContext);
        })
    }
    .width('100%')
    .height(56)
    .padding({
      left: 16,
      right: 16
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  // 底部删除
  @Builder
  bottomDeleteBuilder() {
    Column() {
      Image($r('app.media.delete_icon'))
        .width(24)
        .height(24)
      Text('删除')
        .fontColor('#FF000000')
        .fontSize(10)
        .padding({ top: 7 })
    }
    .width('100%')
    .padding({ top: 13 })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.dialogControllerConfirm.open()
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      // 顶部标题
      this.headerTitleBuilder()
      // 视频播放
      Column() {
        VideoPlayerComp({
          videoWork: this.workDetailPageVM.videoWork
        })
      }
      .width('100%')
      .layoutWeight(1)
      // .height('calc(100% - 122vp)')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 底部删除
      this.bottomDeleteBuilder()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true
    })
  }
}
