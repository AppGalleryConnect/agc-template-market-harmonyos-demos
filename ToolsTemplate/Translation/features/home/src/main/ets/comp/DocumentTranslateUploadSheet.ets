import { DocumentTranslateViewModel } from '../viewmodel/DocumentTranslateViewModel';
import { BarVM } from 'common';

/**
 * 文档上传弹窗组件
 */
@ComponentV2
export struct DocumentTranslateUploadSheet {
  @Param viewModel: DocumentTranslateViewModel = new DocumentTranslateViewModel();

  build() {
    Column() {
      Blank()
        .onClick(() => {
          this.viewModel.showUploadSheet = false;
        })

      // 底部弹窗
      Column() {
        // 标题
        Text('上传文件')
          .fontSize(17)
          .fontColor('#1A1A1A')
          .fontWeight(500)
          .margin({ top: 24, left: 20, bottom: 16 })
          .width('100%')
          .textAlign(TextAlign.Start)

        // 本地文件选项
        Column() {
          Column() {
            // 图标
            Image($r('app.media.ic_local_file'))
              .width(48)
              .height(48)

            Text('本地文件')
              .fontSize(13)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .padding(16)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(12)
          .onClick(() => {
            this.viewModel.selectFile();
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .alignItems(HorizontalAlign.Start)

        // 取消按钮
        Text('取消')
          .fontSize(17)
          .fontColor('#666666')
          .width('calc(100% - 32vp)')
          .height(50)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
          .borderRadius(25)
          .margin({
            left: 16,
            right: 16,
            top: 16,
            bottom: 20
          })
          .onClick(() => {
            this.viewModel.showUploadSheet = false;
          })
      }
      .width('100%')
      .backgroundColor('#F0F0F0')
      .borderRadius({ topLeft: 24, topRight: 24 })
      .padding({ bottom: BarVM.instance.aiBarH })
    }
    .width('100%')
    .height(`calc(100% + ${BarVM.instance.staBarH + BarVM.instance.aiBarH}vp)`)
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .margin({ top: -BarVM.instance.staBarH, bottom: -BarVM.instance.aiBarH })
  }
}
