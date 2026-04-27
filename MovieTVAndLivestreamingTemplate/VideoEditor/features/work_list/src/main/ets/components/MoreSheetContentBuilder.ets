import { AlertDialog, AppStorageV2, window } from '@kit.ArkUI'
import { BreakpointModel, WindowParam, WindowPopManager } from 'common'
import { WorkViewModel } from 'video_common'
import { moreSheetTitleBuilder } from './ActionSheet'
import { MetaDataSheetContentBuilderView } from './MetaDataSheetContentBuilder'
import { WorkListPageVM } from '../viewmodel/WorkListPageVM'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Builder
export function MoreSheetContentBuilderView(param: WindowParam) {
  MoreSheetContentBuilder({ param: param })
}

/**
 *  更多模态框自定义内容
 */
@ComponentV2
struct MoreSheetContentBuilder {
  @Param @Require param: WindowParam
  @Local workItem?: WorkViewModel
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local openDetail: string = 'moreSheetcontent'
  workListPageVm: WorkListPageVM = WorkListPageVM.instance;
  moreSheetControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '提示',
      content: '确定要删除此作品吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.param.event?.remove()
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.param.event?.remove()
          this.workListPageVm.deleteWork();
          console.info('Callback when the second button is clicked')
        }
      },
    }),
  })

  aboutToAppear(): void {
    this.workItem = this.param.attachParam as WorkViewModel
    this.workListPageVm.deleteId = this.workItem.id as string;
  }

  build() {
    Column() {
      moreSheetTitleBuilder(this.workItem!, this.param)
      Divider()
        .width('100%')
        .strokeWidth('1px')
        .color($r('sys.color.comp_divider'))
      if (this.workItem?.status === 'finish') {
        Row() {
          Image($r('app.media.meta_data_icon')).width(24).height(24)
          Text('元数据')
            .fontSize(16)
            .fontColor('#FF000000')
            .margin({ left: 4 })
        }
        .width('100%')
        .padding({ top: 24 })
        .onClick(async () => {
          this.param.event?.remove()
          // 打开查看元数据模态框
          SheetSubwindow.instance.windowName = this.openDetail;
          SheetSubwindow.instance.params = this.workItem;
          SheetSubwindow.instance.showSheetWindow();
        })
      }
      // 操作项：删除
      Row() {
        Image($r('app.media.delete_icon')).width(24).height(24)
        Text('删除')
          .fontSize(16)
          .fontColor('#FF000000')
          .margin({ left: 4 })
      }
      .padding({ top: this.workItem?.status === 'finish' ? 16 : 24 })
      .width('100%')
      .onClick(async () => {
        await this.moreSheetControllerConfirm.open()
      })
    }
    .width(this.breakPointModel.getWindowWidth())
    .height(this.workItem?.status === 'finish' ? 194 : 154)
    .padding({
      left: 16,
      right: 16,
      bottom: 24
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}

@ObservedV2
export class SheetSubwindow {
  @Trace windowName: string = '';
  @Trace params: WorkViewModel | undefined;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace subWindow?: window.Window;
  private static _instance: SheetSubwindow;

  public static get instance() {
    if (!SheetSubwindow._instance) {
      SheetSubwindow._instance = new SheetSubwindow();
    }
    return SheetSubwindow._instance;
  }

  @Monitor('breakPointModel.currentBreakpoint')
  detailCheckBreakpoint() {
    try {
      if (this.subWindow?.isWindowShowing()) {
        WindowPopManager.destroyWindow(this.windowName).then(() => {
          this.showSheetWindow();
        });
      }
    } catch (err) {
      hilog.error(0x0000, 'SheetSubwindow', 'fold again window popup err = ' + JSON.stringify(err));
    }
  }

  async showSheetWindow() {
    this.subWindow = await WindowPopManager.showWindow({
      name: this.windowName,
      builder: wrapBuilder(MetaDataSheetContentBuilderView),
      showMask: true, // 显示蒙层
      autoCancel: false,
      attachParam: this.params!,
      onBackPress: () => {
        // 拦截返回键
      },
      align: this.breakPointModel.getWindowAlignment()
    })
  }
}