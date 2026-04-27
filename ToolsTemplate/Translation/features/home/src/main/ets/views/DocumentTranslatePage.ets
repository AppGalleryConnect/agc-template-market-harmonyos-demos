import { DocumentTranslateViewModel } from '../viewmodel/DocumentTranslateViewModel';
import { UploadedFileInfo } from '../types/DocumentTranslateTypes';
import { DocumentTranslateUploadCard } from '../comp/DocumentTranslateUploadCard';
import { OHPage, phoneRouterControl } from 'oh_router';
import { BreakpointModel, RouterMap } from 'common';
import { DocumentPreviewPageBuilder, DocumentPreviewParams } from './DocumentPreviewPage';
import { DocumentTranslateUploadSheet } from '../comp/DocumentTranslateUploadSheet';
import { DocumentTranslateProgressDialog } from '../comp/DocumentTranslateProgressDialog';
import { DocumentTranslateFileItem } from '../comp/DocumentTranslateFileItem';
import { AppStorageV2 } from '@kit.ArkUI';


@Builder
export function DocumentTranslatePageBuilder(_param: Object) {
  DocumentTranslatePage()
}

/**
 * @usage: 文档翻译页面，支持上传doc、docx、pdf格式文档进行翻译。仅支持中英互译，文件大小限制10MB，最多上传指定数量文件。
 * 主要数据结构包括DocumentTranslateViewModel（文档翻译视图模型）、UploadedFileInfo（上传文件信息）。
 * 包含if逻辑判断显示上传弹窗、翻译进度弹窗和翻译按钮。
 * @layout: 页面采用OHPage包装，内部为Stack堆叠布局。主体Column包含：顶部导航栏Row（返回按钮、标题、重新上传按钮），
 * 上传卡片DocumentTranslateUploadCard（语言选择和上传区域），文件数量统计Row，已上传文件列表List（支持左滑删除）。
 * 底部为立即翻译按钮Column。弹窗层包含DocumentTranslateUploadSheet和DocumentTranslateProgressDialog。
 * @constraints: 仅支持中英互译，文件格式限制doc/docx/pdf，单文件大小不超过10MB
 * @domain: 翻译工具
 * @zhName: 文档翻译页面
 * @fileType: page
 * @isGen: true
 * @subPage: DocumentPreviewPage
 * @component: DocumentTranslateUploadCard,DocumentTranslateUploadSheet,DocumentTranslateProgressDialog,
 DocumentTranslateFileItem
 * @image: screenshot/home/DocumentTranslatePage.jpg
 */
@ComponentV2
export struct DocumentTranslatePage {
  private viewModel: DocumentTranslateViewModel = new DocumentTranslateViewModel()
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    // 设置翻译完成回调
    this.viewModel.onTranslationComplete = (result) => {
      const params: DocumentPreviewParams = {
        fileName: result.fileName,
        originalText: result.originalText,
        translatedText: result.translatedText,
        sourceLang: result.sourceLang,
        targetLang: result.targetLang
      };
      phoneRouterControl.jumpPage({
        pageName: RouterMap.DOCUMENT_PREVIEW_PAGE,
        builder: wrapBuilder(DocumentPreviewPageBuilder),
        param: JSON.stringify(params)
      });
    };
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: false,
      pageBackgroundColor: '#F5F6FA'
    })
  }

  @Builder
  render() {
    Stack() {
      Column() {
        // 顶部导航栏
        this.buildNavigationBar()

        // 主内容区域
        Column() {
          // 上传卡片（包含语言选择）
          DocumentTranslateUploadCard({ viewModel: this.viewModel })

          // 文件数量统计
          this.buildFileCountHeader()

          // 已上传文件列表
          this.buildFileList()
        }
        .layoutWeight(1)
        .width('100%')

        // 底部立即翻译按钮
        if (this.viewModel.uploadedFiles.length > 0) {
          this.buildTranslateButton()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F6FA')

      // 底部上传文件弹窗
      if (this.viewModel.showUploadSheet) {
        DocumentTranslateUploadSheet({ viewModel: this.viewModel })
      }

      // 翻译进度弹窗
      if (this.viewModel.showTranslatingDialog) {
        DocumentTranslateProgressDialog({
          progress: this.viewModel.translationProgress,
          currentStep: this.viewModel.translationStep
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildNavigationBar() {
    Row() {
      // 返回按钮
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        phoneRouterControl.popPage();
      })

      // 标题
      Text('文档翻译')
        .fontSize(18)
        .fontColor('#1A1A1A')
        .fontWeight(500)
        .margin({ left: 12 })

      Blank()

      // 重新上传按钮
      if (this.viewModel.uploadedFiles.length > 0) {
        Text('重新上传')
          .fontSize(14)
          .fontColor('#4A90E2')
          .onClick(() => {
            this.viewModel.reupload();
            this.viewModel.selectFile();
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding })
  }

  @Builder
  buildFileCountHeader() {
    // 底部文件数量提示
    Row() {
      Text(`最多上传${this.viewModel.maxFiles}个`)
        .fontSize(14)
        .fontColor('#666666')

      Blank()

      Text(`${this.viewModel.uploadedFiles.length}/${this.viewModel.maxFiles}`)
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }

  @Builder
  buildFileList() {
    List() {
      // 文件项
      ForEach(this.viewModel.uploadedFiles, (file: UploadedFileInfo, index: number) => {
        ListItem() {
          DocumentTranslateFileItem({ file: file, viewModel: this.viewModel })
        }
        .width('100%')
        .padding({ left: this.breakpointModel.pagePadding, right: this.breakpointModel.pagePadding })
        .swipeAction({
          end: {
            builder: () => {
              this.buildSwipeAction(index)
            }
          }
        })
      })
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  buildSwipeAction(index: number) {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(24)
          .fontColor([Color.White])
      }
      .width(60)
      .height(72)
      .backgroundColor('#FF4D4F')
      .borderRadius({ topRight: 12, bottomRight: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        this.viewModel.deleteFile(index);
      })
    }
    .margin({ right: 16, bottom: 12, left: -16 })
  }

  @Builder
  buildTranslateButton() {
    Column() {
      Button('立即翻译')
        .width('100%')
        .height(48)
        .backgroundColor('#4A90E2')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(500)
        .fontColor($r('sys.color.comp_background_list_card'))
        .borderRadius(24)
        .onClick(() => {
          this.viewModel.translateDocument();
        })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 24
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: -2 })
  }
}
