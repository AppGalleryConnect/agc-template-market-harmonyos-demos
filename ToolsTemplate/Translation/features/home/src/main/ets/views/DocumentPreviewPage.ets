import { promptAction } from '@kit.ArkUI';
import { OHPage, phoneRouterControl } from 'oh_router';
import { TranslationDataStore } from '../utils/TranslationDataStore';
import { pdfService, pdfViewManager, PdfView } from '@kit.PDFKit';
import { DocumentTranslateViewModel } from '../viewmodel/DocumentTranslateViewModel';

@Builder
export function DocumentPreviewPageBuilder(param: Object) {
  DocumentPreviewPage({ paramsStr: param as string })
}

export interface DocumentPreviewParams {
  fileName: string;
  originalText: string;
  translatedText: string;
  sourceLang: string;
  targetLang: string;
  downloadUrl?: string;
}

@ComponentV2
export struct DocumentPreviewPage {
  @Param paramsStr: string = '';
  @Local params: DocumentPreviewParams | null = null;
  @Local currentLang: string = 'zh';
  @Local isPdfFile: boolean = false;
  @Local isPdfLoading: boolean = false;
  @Local isPdfReady: boolean = false;
  @Local showOriginal: boolean = false; // 是否显示原文
  @Local originalText: string = ''; // 原文内容
  @Local originalFileUri: string = ''; // 原始文件URI
  @Local originalPdfCachePath: string = ''; // 原文PDF缓存路径
  @Local isOriginalPdfLoading: boolean = false;
  @Local isOriginalPdfReady: boolean = false;
  @Local textScale: number = 1.0; // 文本缩放比例
  @Local lastScale: number = 1.0; // 上次缩放比例
  // 译文PDF控制器
  private translatedPdfController: pdfViewManager.PdfController = new pdfViewManager.PdfController();
  // 原文PDF控制器
  private originalPdfController: pdfViewManager.PdfController = new pdfViewManager.PdfController();
  private viewModel: DocumentTranslateViewModel = new DocumentTranslateViewModel();

  // 获取语言显示名称（中英互译）
  private getLanguageDisplayName(lang: string | undefined): string {
    if (!lang) {
      return '中文';
    }
    const langLower = lang.toLowerCase();
    if (langLower === 'zh' || langLower === 'chi' || langLower.startsWith('zh-') || langLower === 'cht') {
      return '中文';
    }
    if (langLower === 'en' || langLower === 'eng' || langLower.startsWith('en-')) {
      return '英文';
    }
    return lang;
  }

  aboutToAppear(): void {
    if (this.paramsStr) {
      this.params = JSON.parse(this.paramsStr) as DocumentPreviewParams;

      // 从全局存储中获取完整数据
      const dataStore = TranslationDataStore.getInstance();
      const downloadUrl = dataStore.getDownloadUrl();
      const fullTranslatedText = dataStore.getTranslatedText();
      this.originalText = dataStore.getOriginalText();
      this.originalFileUri = dataStore.getOriginalFileUri();
      this.originalPdfCachePath = dataStore.getOriginalPdfCachePath();

      if (this.params) {
        this.params.downloadUrl = downloadUrl;
        this.params.translatedText = fullTranslatedText;
        this.isPdfFile = this.params.fileName.toLowerCase().endsWith('.pdf');
      }

      this.currentLang = this.params?.targetLang || 'zh';

      // 如果是PDF文件，同时加载原文和译文PDF
      if (this.isPdfFile && this.params?.downloadUrl) {
        this.loadTranslatedPdf();
        this.loadOriginalPdf();
      }
    }
  }

  // 加载译文PDF
  private loadTranslatedPdf(): void {
    this.viewModel.loadPdfForPreview(
      this.translatedPdfController,
      (loading: boolean) => {
        this.isPdfLoading = loading;
      },
      (ready: boolean) => {
        this.isPdfReady = ready;
      }
    );
  }

  // 加载原文PDF
  private async loadOriginalPdf(): Promise<void> {
    if (!this.originalPdfCachePath) {
      return;
    }
    this.isOriginalPdfLoading = true;
    try {
      const loadResult: pdfService.ParseResult =
        await this.originalPdfController.loadDocument(this.originalPdfCachePath);
      if (loadResult === pdfService.ParseResult.PARSE_SUCCESS) {
        this.isOriginalPdfReady = true;
      }
    } catch (error) {
      this.isOriginalPdfReady = false;
    } finally {
      this.isOriginalPdfLoading = false;
    }
  }

  // 切换原文/译文显示
  private toggleContent(): void {
    this.showOriginal = !this.showOriginal;
  }

  // 获取左侧语言（原文语言）
  private getLeftLang(): string {
    return this.params?.sourceLang || 'zh';
  }

  // 获取右侧语言（译文语言）
  private getRightLang(): string {
    return this.params?.targetLang || 'en';
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: false,
      pageBackgroundColor: Color.White
    })
  }

  @Builder
  render() {
    Column() {
      this.buildNavigationBar()
      if (this.isPdfFile) {
        this.buildPdfContent()
      } else {
        this.buildDocumentContent()
      }
      this.buildDownloadButton()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildNavigationBar() {
    Row() {
      // 左侧区域
      Row() {
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

        Text('预览')
          .fontSize(17)
          .fontColor('#1A1A1A')
          .fontWeight(500)
          .margin({ left: 12 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)

      // 中间语言选择器
      Row() {
        Text(this.getLanguageDisplayName(this.getLeftLang()))
          .fontSize(15)
          .fontColor(this.showOriginal ? '#1A1A1A' : '#666666')
          .fontWeight(this.showOriginal ? 500 : 400)
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4
          })
          .onClick(() => {
            if (!this.showOriginal) {
              this.toggleContent();
            }
          })

        Image($r('app.media.switch'))
          .width(20)
          .height(20)
          .margin({ left: 8, right: 8 })
          .fillColor('#4A90E2')
          .onClick(() => {
            this.toggleContent();
          })

        Text(this.getLanguageDisplayName(this.getRightLang()))
          .fontSize(15)
          .fontColor(this.showOriginal ? '#666666' : '#1A1A1A')
          .fontWeight(this.showOriginal ? 400 : 500)
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4
          })
          .onClick(() => {
            if (this.showOriginal) {
              this.toggleContent();
            }
          })
      }

      // 右侧占位区域
      Row()
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildPdfContent() {
    Stack() {
      // 译文PDF
      Column() {
        if (this.isPdfLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('sys.color.icon_on_primary'))
            Text('正在加载译文PDF...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.isPdfReady) {
          PdfView({
            controller: this.translatedPdfController,
            pageFit: pdfService.PageFit.FIT_WIDTH,
            showScroll: true,
            isContinuous: true
          })
            .width('100%')
            .height('100%')
        } else {
          Column() {
            Text('译文PDF加载失败')
              .fontSize(15)
              .fontColor('#999999')
            Text('请点击下方按钮下载查看')
              .fontSize(13)
              .fontColor('#BBBBBB')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .visibility(this.showOriginal ? Visibility.Hidden : Visibility.Visible)

      // 原文PDF
      Column() {
        if (this.isOriginalPdfLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color($r('sys.color.icon_on_primary'))
            Text('正在加载原文PDF...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.isOriginalPdfReady) {
          PdfView({
            controller: this.originalPdfController,
            pageFit: pdfService.PageFit.FIT_WIDTH,
            showScroll: true,
            isContinuous: true
          })
            .width('100%')
            .height('100%')
        } else {
          Column() {
            Text('原文PDF加载失败')
              .fontSize(15)
              .fontColor('#999999')
            Text('请查看原文档')
              .fontSize(13)
              .fontColor('#BBBBBB')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .visibility(this.showOriginal ? Visibility.Visible : Visibility.Hidden)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(Color.White)
  }

  @Builder
  buildDocumentContent() {
    Scroll() {
      Column() {
        if (this.params) {
          Text(this.showOriginal ? (this.originalText || '暂无原文内容') :
            (this.params.translatedText || '暂无译文内容'))
            .fontSize(15 * this.textScale)
            .fontColor('#333333')
            .lineHeight(24 * this.textScale)
            .width('100%')
        } else {
          Text('加载中...')
            .fontSize(15)
            .fontColor('#999999')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .backgroundColor(Color.White)
    .gesture(
      PinchGesture({ fingers: 2 })
        .onActionStart(() => {
          this.lastScale = this.textScale;
        })
        .onActionUpdate((event: GestureEvent) => {
          const newScale = this.lastScale * event.scale;
          // 限制缩放范围 0.5 - 3.0
          this.textScale = Math.max(0.5, Math.min(3.0, newScale));
        })
    )
  }

  @Builder
  buildDownloadButton() {
    Column() {
      Button('立即下载')
        .width('100%')
        .height(48)
        .backgroundColor('#4A90E2')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(500)
        .fontColor($r('sys.color.comp_background_list_card'))
        .borderRadius(24)
        .onClick(() => {
          if (this.params) {
            this.viewModel.downloadTranslatedFileToLocal(this.params.fileName);
          } else {
            promptAction.showToast({ message: '参数错误，无法下载' });
          }
        })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor(Color.White)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: -2 })
  }
}
