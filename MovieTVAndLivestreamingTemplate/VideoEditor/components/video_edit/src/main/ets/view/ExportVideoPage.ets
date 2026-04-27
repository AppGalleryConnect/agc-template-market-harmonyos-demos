import { AlertDialog } from '@kit.ArkUI';
import { TransformLoading } from '../components/TransformLoading';
import { ExportVideoPageVM } from '../viewmodel/ExportVideoPageVM';
import { BarVM, TValueType, exportVideo } from 'video_common';

@Builder
export function ExportVideoPageBuilder(name: string, param: TValueType) {
  ExportVideoPage({
    pageParams: param
  });
}


/**
 * @usage: 用于视频导出转换页面，展示视频转换进度和状态。支持停止导出操作。
 * 关键参数：vm.loading加载状态，vm.exportStatus导出状态枚举。
 * 包含if逻辑：当loading为false且exportStatus为unFinish时显示转换失败提示，否则显示转换中提示。
 * @layout: 页面整体采用垂直布局（Column）。顶部为停止按钮（左对齐），
 * 中间为TransformLoading加载动画和状态文案（居中对齐）。
 * @constraints:
 * @zhName: 视频导出页面
 * @fileType: page
 * @isGen: true
 * @component: TransformLoading
 */
@ComponentV2
export struct ExportVideoPage {
  vm: ExportVideoPageVM = ExportVideoPageVM.instance;
  private context: UIContext = this.getUIContext();
  @Param pageParams: TValueType = null
  // 停止导出确认弹框
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '提示',
      content: '确认停止导出吗?',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          // 显示“正在停止导出，请稍候…”状态，并等待 worker 退出后再离开
          this.vm.stopExportAndWait();
        }
      },
    }),
  })

  aboutToAppear(): void {
    const routerParams: exportVideo = this.pageParams as exportVideo;
    this.vm.startExport(this.context, routerParams);
  }

  // 顶部停止按钮
  @Builder
  titleBuilder() {
    Row() {
      Image($r('app.media.page_back'))
        .width(24)
        .height(24)
    }
    .padding({ left: 16 })
    .onClick(() => {
      this.vm.backPage()
    })
  }

  // 状态文案
  @Builder
  tipsBuilder() {
    Column() {
      if (!this.vm.loading && this.vm.exportStatus === 'unFinish') {
        Text('合成失败')
          .margin({ top: 38 })
          .fontSize(24)
          .fontColor('#FFFF4B4B')
      } else if (!this.vm.loading && this.vm.exportStatus === 'finish') {
        Text('合成成功')
          .margin({ top: 38 })
          .fontSize(24)
          .fontColor('#FF01FCEA')
      } else {
        Text('努力合成中...')
          .margin({ top: 38 })
          .fontSize(24)
          .fontColor('#FFFFFF')
        Text('请不要退出应用')
          .margin({ top: 6 })
          .fontSize(14)
          .fontColor('#FF999999')
      }
    }
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      // 左上角返回按钮
      if (!this.vm.loading && this.vm.exportStatus) {
        this.titleBuilder()
      }
      // 加载loading动画组件
      Column() {
        TransformLoading({
          thumbnailImg: this.vm.videoThumbnail,
          rectW: 184,
          rectH: 304,
          radiusW: 24,
          thick: 4,
          loading: this.vm.loading
        })
        // 状态文案
        this.tipsBuilder();
      }
      .width('100%')
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)

      // 跳转按钮
      if (!this.vm.loading && this.vm.exportStatus) {
        Row() {
          Button(this.vm.exportStatus === 'finish' ? '去查看' : '重新合成')
            .width('100%')
            .fontColor($r('sys.color.font_primary'))
            .fontColor(16)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#FF01A8FE', 0.0], ['#FF01FCEA', 1]]
            })
            .align(Alignment.Center)
            .onClick(() => {
              this.vm.exportCompleted(this.context)
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ left: 28, right: 28 })
      }

    }
    .width('100%')
    .height('100%')
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#FF000000', 0.0], ['#FF19283F', 1]]
    })
  }

  build() {
    NavDestination() {
      this.render();
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.vm.backPage()
      return true
    })
    .onReady(async (ctx: NavDestinationContext) => {
      this.vm.stack = ctx.pathStack;
    })
  }
}