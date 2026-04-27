import { promptAction } from '@kit.ArkUI';
import { DocumentTranslateViewModel } from '../viewmodel/DocumentTranslateViewModel';

/**
 * 文档上传卡片组件
 */
@ComponentV2
export struct DocumentTranslateUploadCard {
  @Param viewModel: DocumentTranslateViewModel = new DocumentTranslateViewModel();

  private onUploadClick(): void {
    if (this.viewModel.uploadedFiles.length >= this.viewModel.maxFiles) {
      promptAction.showToast({ message: '上传上限' });
      return;
    }
    this.viewModel.showUploadSheet = true;
  }

  build() {
    Column() {
      Column() {
        // 上传区域（点击触发上传）
        Column() {
          // 上传图标
          Image($r('app.media.ic_upload'))
            .width(40)
            .height(40)

          // 上传文字
          Text('上传文档')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(500)
            .margin({ top: 12 })

          // 支持格式说明
          Text('支持doc、docx、pdf格式，文件大小不超过10MB\n文档翻译仅支持中译英互译')
            .fontSize(11)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .lineHeight(16)
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ top: 32 })
        .onClick(() => {
          this.onUploadClick();
        })

        // 语言选择区域（不触发上传）
        Row({ space: 12 }) {
          // 源语言（标签和语言名称都在灰色底色内）
          Column({ space: 4 }) {
            Text('文档语言')
              .fontSize(12)
              .fontColor('#999999')

            Text(this.viewModel.getLanguageDisplayName(this.viewModel.sourceLanguage))
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .layoutWeight(1)
          .height(64)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F6FA')
          .borderRadius(24)

          // 交换按钮
          Column() {
            Image($r('app.media.ic_public_shuffle'))
              .width(24)
              .height(24)
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#E3F2FD')
          .borderRadius(24)
          .onClick(() => {
            this.viewModel.swapLanguages();
          })

          // 目标语言
          Column({ space: 4 }) {
            Text('翻译语言')
              .fontSize(12)
              .fontColor('#999999')

            Text(this.viewModel.getLanguageDisplayName(this.viewModel.targetLanguage))
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .layoutWeight(1)
          .height(64)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F6FA')
          .borderRadius(24)
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 20,
          bottom: 24
        })
      }
      .width('90%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
  }
}
