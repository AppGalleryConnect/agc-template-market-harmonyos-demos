import {
  BLACK_ICON_COLOR_FILTER,
  COLOR_LIST,
  HIGHLIGHT_COLOR_FILTER,
  ORIGIN_COLOR_FILTER,
  RICH_ID
} from '../common/Constants';
import { AlignmentInfo } from '../model/AlignmentInfo';
import { RichEditorController } from '../controller/RichEditorController';
import { SnapShotController } from '../controller/SnapShotController';
import { SnapshotPreview } from './SnapshotPreview';
import { LengthMetrics } from '@kit.ArkUI';
import { HandwriteController, HandwriteComponent, PenHspInfo, PenType } from '@kit.Penkit';
import common from '@ohos.app.ability.common';
import { DocumentScanner, DocumentScannerConfig, DocType, SaveOption } from '@kit.VisionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ComponentV2
export struct RichEditorArea {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private richEditorController: RichEditorController = RichEditorController.instance;
  @Param snapShotController: SnapShotController = new SnapShotController('', new Scroller(), this.getUIContext());
  @Local richEditorLayoutWeight: number = 0;
  @Param @Once @Require noteTitle: string;
  @Param @Once @Require noteContent: MutableStyledString;
  @Param @Once @Require noteId: string;
  /** 点击底部“录音”工具按钮 */
  @Event tapRecord: () => void = () => {
  };
  @Event titleChange: (title: string) => void = () => {
  };

  @Local isEditing: boolean = false;
  private readonly MAX_TEXT_LENGTH: number = 20000;

  // 手写相关状态
  @Local penWidth: number = 5;
  @Local penColor: ResourceColor = Color.Black;
  ballpointPenWidth: number = 6;

  // 文档扫描
  @Local showDocScanner: boolean = false;

  /** 由外部传入时与编辑页共用同一控制器，便于保存笔记时一并保存画布 */
  @Param handwriteController: HandwriteController = new HandwriteController();
  private handwritePath: string = '';
  private uiContext: UIContext = this.getUIContext() as UIContext;
  private hostContext: common.Context = this.uiContext.getHostContext() as Context;
  @Local private isHandwriteDirty: boolean = false;

  aboutToAppear(): void {
    this.handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.noteId}`;
  }

  // 保存手写内容
  private async saveHandwriteData(): Promise<void> {
    if (!this.handwriteController) {
      return;
    }
    try {
      await this.handwriteController.save(this.handwritePath);
      hilog.info(0x0000, 'RichEditorArea', `手写内容已保存到: ${this.handwritePath}`);
      this.setHandwriteDirty(false);
    } catch (error) {
      hilog.error(0x0000, 'RichEditorArea', `保存手写内容失败: ${JSON.stringify(error)}`);
    }
  }

  // 加载手写内容（手写数据文件）
  private async loadHandwriteData(): Promise<void> {
    if (!this.handwriteController) {
      return;
    }
    try {
      if (this.handwritePath) {
        await this.handwriteController.load(this.handwritePath);
        hilog.info(0x0000, 'RichEditorArea', `手写内容已从 ${this.handwritePath} 加载`);
      }
      this.setHandwriteDirty(false);
    } catch (error) {
      hilog.info(0x0000, 'RichEditorArea', '无手写历史记录或文件不存在，将创建新手写数据');
      this.setHandwriteDirty(false);
    }
  }

  private setHandwriteDirty(dirty: boolean): void {
    if (this.isHandwriteDirty === dirty) {
      if (dirty) {
        AppStorage.setOrCreate('handwrite_dirty_note_id', this.noteId);
        AppStorage.setOrCreate('handwrite_dirty', true);
      }
      return;
    }
    this.isHandwriteDirty = dirty;
    AppStorage.setOrCreate('handwrite_dirty_note_id', this.noteId);
    AppStorage.setOrCreate('handwrite_dirty', dirty);
  }

  // 调色盘选项栏
  @Builder
  colorPalette() {
    Column(){
      Row() {
        Text('A')
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'));
        Blank();
        Row() {
          Slider({
            value: this.richEditorController.fontSize.value,
            min: 14, //滑动最小值
            max: 30, //滑动最大值
            step: 4, //步长
            style: SliderStyle.InSet,
          })
            .trackThickness(20)
            // 刻度颜色
            .stepColor($r('sys.color.comp_background_secondary'))
            // 滑轨背景色
            .trackColor($r('sys.color.comp_background_secondary'))
            // 以滑动部分颜色
            .selectedColor($r('sys.color.comp_background_emphasize'))
            // 显示步长刻度
            .showSteps(true)
            .blockStyle({ type: SliderBlockType.IMAGE, image: $r('app.media.font_setting') })
            .blockSize({ width: 12, height: 12 })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.richEditorController.fontSize = LengthMetrics.vp(value);
              this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
                fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
                fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
                fontColor: COLOR_LIST[this.richEditorController.currentColor],
                fontSize: this.richEditorController.fontSize
              }));
            })
        }
        .width('90%')

        Blank();

        Text('A')
          .fontSize(16)
          .fontColor($r('sys.color.font_secondary'));
      }
      .width('100%')
      .height(50)
      .padding({
        left: '4%',
        right: '4%'
      })

      Flex({
        justifyContent: FlexAlign.SpaceAround,
        alignItems: ItemAlign.Center,
      }) {
        ForEach(COLOR_LIST, (color: ResourceColor, index: number) => {
          Stack() {
            Circle({ width: 16, height: 16 })
              .fill(color);

            Circle({ width: 24, height: 24 })
              .fillOpacity(0)
              .borderWidth(2)
              .borderRadius(12)
              .borderColor(this.richEditorController.currentColor === index ? Color.Red : Color.Black);
          }
          .onClick(() => {
            this.richEditorController.showToolBarIndex = 0;
            this.richEditorController.currentColor = index;
            this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
              fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
              fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
              fontColor: COLOR_LIST[this.richEditorController.currentColor],
              fontSize: this.richEditorController.fontSize
            }));
          });
        }, (color: ResourceColor) => JSON.stringify(color));
      }
      .width('100%')
      .height(50);
    }
    .width('100%')
    .height(100);
  }

  // 编辑工具栏
  @Builder
  toolBar() {
    Flex({
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
    }) {
      Image($r('app.media.font_color_size'))
        .width(24)
        .fillColor(COLOR_LIST[this.richEditorController.currentColor])
        .onClick(() => {
          if (this.richEditorController.showToolBarIndex !== 1) {
            this.richEditorController.showToolBarIndex = 1;
          } else {
            this.richEditorController.showToolBarIndex = 0;
          }
        });

      Image(this.richEditorController.paragraphAlignments[this.richEditorController.currentAlignment].icon)
        .width(24)
        .onClick(() => {
          if (this.richEditorController.showToolBarIndex !== 2) {
            this.richEditorController.showToolBarIndex = 2;
          } else {
            this.richEditorController.showToolBarIndex = 0;
          }
        });

      Image($r('app.media.ic_bold'))
        .width(24)
        .colorFilter(this.richEditorController.currentBold ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          this.richEditorController.currentBold = !this.richEditorController.currentBold;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
            fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
            fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
            fontColor: COLOR_LIST[this.richEditorController.currentColor],
            fontSize: this.richEditorController.fontSize
          }));
        });

      Image($r('app.media.ic_notepad_texttilt'))
        .width(24)
        .colorFilter(this.richEditorController.currentItalics ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          this.richEditorController.currentItalics = !this.richEditorController.currentItalics;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
            fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
            fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
            fontColor: COLOR_LIST[this.richEditorController.currentColor],
            fontSize: this.richEditorController.fontSize
          }));
        });

      Image($r('app.media.ic_underline'))
        .width(24)
        .colorFilter(this.richEditorController.currentDecoration === TextDecorationType.Underline ?
          HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          let isUnderline = this.richEditorController.currentDecoration === TextDecorationType.Underline;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.DECORATION,
            new DecorationStyle({
              type: this.richEditorController.currentDecoration =
                isUnderline ? TextDecorationType.None : TextDecorationType.Underline
            }));
        });

      Image($r('app.media.ic_deleteline'))
        .width(24)
        .colorFilter(this.richEditorController.currentDecoration === TextDecorationType.LineThrough ?
          HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          let isLineThrough = this.richEditorController.currentDecoration === TextDecorationType.LineThrough;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.DECORATION,
            new DecorationStyle({
              type: this.richEditorController.currentDecoration =
                isLineThrough ? TextDecorationType.None : TextDecorationType.LineThrough
            }));
        });

      Image($r('app.media.ic_shadow'))
        .width(24)
        .colorFilter(this.richEditorController.currentShadow ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          this.richEditorController.currentShadow = !this.richEditorController.currentShadow;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.TEXT_SHADOW,
            this.richEditorController.currentShadow ?
              new TextShadowStyle({ radius: 2, type: ShadowType.BLUR, offsetX: 3, offsetY: 3, }) :
              new TextShadowStyle({ radius: 0 }));
        });

      Image(this.richEditorController.isHandwriteMode ? $r('app.media.ic_keyboard') : $r('app.media.ic_handwrite'))
        .width(24)
        .height(24)
        .colorFilter(this.richEditorController.isHandwriteMode ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(async () => {
          // 展示态（右上角为“更多”三点）时，点击画笔：直接切到编辑态 + 开启手写模式
          if (this.richEditorController.showMoreFunction && !this.richEditorController.isHandwriteMode) {
            this.richEditorController.showMoreFunction = false;
            this.handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.noteId}`;
            this.richEditorController.isHandwriteMode = true;
            return;
          }

          // 编辑态下原有的“手写 <-> 键盘”切换逻辑
          this.richEditorController.showMoreFunction = false;
          if (this.richEditorController.isHandwriteMode) {
            await this.saveHandwriteData();
            this.showToast('手写内容已保存');
            this.richEditorController.isHandwriteMode = false;
            this.richEditorController.showToolBarIndex = 0;
          } else {
            this.handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.noteId}`;
            this.richEditorController.isHandwriteMode = true;
          }
        });

      SymbolGlyph($r('sys.symbol.picture_fill'))
        .fontSize(24)
        .bindMenu(this.imageOptionsMenu, {
          placement: Placement.Top,
          offset: { x: 0, y: -8 }
        });

      Image($r('app.media.ic_tap_record'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.tapRecord();
        });

      // 清除所有文本图标
      Image($r('app.media.ic_public_delete'))
        .width(24)
        .onClick(() => {
          this.richEditorController.clearAllContent(this.getUIContext());
        });
    }
    .height(60)
    .width('100%')
    .padding({
      left: 16,
      right: 16,
    })
    .backgroundColor('#EDEFF5');
  }

  @Builder
  private imageOptionsMenu() {
    Column() {
      Row() {
        Image($r('app.media.ic_pic_camera'))
          .width(24)
          .height(24)
          .colorFilter(BLACK_ICON_COLOR_FILTER)
          .margin({ left: 12, right: 8 });
        Text('拍照')
          .fontSize(14)
          .fontColor('#000000')
          .layoutWeight(1);
      }
      .width('100%')
      .height(48)
      .padding({ right: 12 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        const wVp = this.snapShotController.listComponentWidth || 0;
        this.richEditorController.takePhoto(this.uiContext, wVp);
      });
      Divider().width('100%').height(0.5).color($r('sys.color.comp_divider'));
      Row() {
        Image($r('app.media.ic_pic_picture'))
          .width(24)
          .height(24)
          .colorFilter(BLACK_ICON_COLOR_FILTER)
          .margin({ left: 12, right: 8 });
        Text('选择图片')
          .fontSize(14)
          .fontColor('#000000')
          .layoutWeight(1);
      }
      .width('100%')
      .height(48)
      .padding({ right: 12 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        const wVp = this.snapShotController.listComponentWidth || 0;
        this.richEditorController.selectImages(this.uiContext, wVp);
      });
      Divider().width('100%').height(0.5).color($r('sys.color.comp_divider'));
      Row() {
        Image($r('app.media.ic_line_viewfinder'))
          .width(24)
          .height(24)
          .colorFilter(BLACK_ICON_COLOR_FILTER)
          .margin({ left: 12, right: 8 });
        Text('文档扫描')
          .fontSize(14)
          .fontColor('#000000')
          .layoutWeight(1);
      }
      .width('100%')
      .height(48)
      .padding({ right: 12 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.showDocScanner = true;
      });
    }
    .width(200)
    .backgroundColor($r('app.color.bg_more_function'))
    .margin({ top: 4, bottom: 4 });
  }

  // 显示提示
  private showToast(message: string): void {
    this.uiContext.getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
      duration: 1500
    });
  }

  // 文档扫描组件（结果保存到系统，相册/文件中可见）
  private buildDocScannerConfig(): DocumentScannerConfig {
    const scannerConfig: DocumentScannerConfig = new DocumentScannerConfig();
    scannerConfig.supportType = [DocType.DOC];
    scannerConfig.saveOptions = [SaveOption.JPG, SaveOption.PDF];
    return scannerConfig;
  }

  @Builder
  docScannerLayer() {
    if (this.showDocScanner) {
      Column() {
        DocumentScanner({
          scannerConfig: this.buildDocScannerConfig(),
          onResult: (_code: number, saveOption: SaveOption, uris: Array<string>) => {
            this.showDocScanner = false;
            if (!uris || uris.length === 0) {
              this.showToast('文档扫描已取消');
              return;
            }

            const wVp = this.snapShotController.listComponentWidth || 0;
            const result = this.richEditorController.insertScannedUris(this.uiContext, uris, wVp);
            if (saveOption === SaveOption.PDF && result.insertedImageCount === 0 && result.pdfCount > 0) {
              this.showToast('已保存为PDF，当前富文本不支持PDF内嵌');
              return;
            }
            if (result.insertedImageCount > 0 && result.pdfCount > 0) {
              this.showToast('图片已插入笔记，PDF已保存到系统');
              return;
            }
            if (result.insertedImageCount > 0) {
              this.showToast('文档图片已插入笔记');
              return;
            }
            if (result.pdfCount > 0) {
              this.showToast('当前富文本不支持PDF内嵌，PDF已保存到系统');
              return;
            }
            this.showToast('扫描结果未能插入笔记');
          }
        })
      }
      .width('100%')
      .height('100%');
    }
  }

  @Builder
  previewWindowComponent() {
    Column() {
      SnapshotPreview({
        context: this.getUIContext().getHostContext(),
        mergedImage: this.snapShotController.mergedImage,
        snapPopupPosition: this.snapShotController.snapPopupPosition,
        isLargePreview: this.snapShotController.isLargePreview,
        isShowPreview: this.snapShotController.isShowPreview,
        changeMergedImage: (mergedImage: PixelMap | undefined) => {
          this.snapShotController.mergedImage = mergedImage;
        },
        changeSnapPopupPosition: (snapPopupPosition) => {
          this.snapShotController.snapPopupPosition = snapPopupPosition;
        },
        changeIsShowPreview: (showPreview: boolean) => {
          this.snapShotController.isShowPreview = showPreview;
        },
        changeIsLargePreview: (largePreview: boolean) => {
          this.snapShotController.isLargePreview = largePreview;
        },
      });
    };
  }

  // 段落样式选项栏
  @Builder
  paragraphFormat() {
    Flex({
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
    }) {
      ForEach(this.richEditorController.paragraphAlignments, (item: AlignmentInfo, index: number) => {
        Image(item.icon)
          .width(24)
          .colorFilter(this.richEditorController.currentAlignment === index ? HIGHLIGHT_COLOR_FILTER :
            ORIGIN_COLOR_FILTER)
          .onClick(item.click);
      }, (item: AlignmentInfo) => JSON.stringify(item));
    }
    .width('100%')
    .height(56);
  }

  // 文本内容变化回调
  contentChangedListener: StyledStringChangedListener = {
    onWillChange: (value: StyledStringChangeValue) => {
      return true;
    },
    onDidChange: (rangeBefore, rangeAfter) => {
      this.richEditorController.onDidChange(rangeAfter.start, rangeAfter.end);
      // 平板/PC 嵌入编辑器：标记当前笔记未保存（供切换笔记/返回二次确认使用）
      AppStorage.setOrCreate('notes_embed_dirty_note_id', this.noteId);
      AppStorage.setOrCreate('notes_embed_dirty', true);
      const styledString = this.richEditorController.controller.getStyledString();
      const content = styledString.getString();
      if (content.length > this.MAX_TEXT_LENGTH) {
        const extraLength = content.length - this.MAX_TEXT_LENGTH;
        styledString.removeString(this.MAX_TEXT_LENGTH, extraLength);
        this.richEditorController.controller.setStyledString(styledString);
        this.richEditorController.controller.setCaretOffset(this.MAX_TEXT_LENGTH);
        this.showToast(`已超出最大字数限制（${this.MAX_TEXT_LENGTH}字）`);
      }
    }
  }

  build() {
    Column() {
      Stack() {
        // 富文本编辑区（标题+正文）
        Column() {
          Scroll(this.snapShotController.scroller) {
            Column() {
              // 标题
              TextInput({
                placeholder: '标题',
                text: this.noteTitle,
                controller: this.richEditorController.textInputController
              })
                .placeholderColor($r('sys.color.font_secondary'))
                .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Bold })
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .height(40)
                .backgroundColor(Color.Transparent)
                .borderRadius(0)
                .onChange((value: string) => {
                  this.noteTitle = value;
                  this.titleChange(value);
                  // 标题变更同样视为未保存
                  AppStorage.setOrCreate('notes_embed_dirty_note_id', this.noteId);
                  AppStorage.setOrCreate('notes_embed_dirty', true);
                })
                .margin({ top: 12 })
                .onClick(() => {
                  this.richEditorController.showMoreFunction = false;
                })

              // 正文
              RichEditor(this.richEditorController.options)
                .placeholder('开始书写你的笔记', { fontColor: $r('sys.color.font_tertiary'), font: { size: 14 } })
                .barState(BarState.Off)
                .id(RICH_ID)
                .onReady(() => {
                  this.richEditorController.controller.onContentChanged(this.contentChangedListener);
                  this.richEditorController.controller.setStyledString(this.noteContent)
                })
                .width('100%')
                .onEditingChange((editingStatus) => {
                  this.isEditing = editingStatus;
                  this.richEditorController.showMoreFunction = false;
                  if (editingStatus) {
                    this.richEditorLayoutWeight = 1;
                    // 键盘弹出后延迟滚动，使光标所在内容上移、不被键盘遮挡
                    setTimeout(() => {
                      const scroller = this.snapShotController.scroller;
                      const cur = scroller.currentOffset();
                      const liftVp = 220;
                      scroller.scrollTo({
                        xOffset: cur.xOffset,
                        yOffset: cur.yOffset + liftVp,
                        animation: { duration: 250, curve: Curve.EaseOut }
                      });
                    }, 280);
                  } else {
                    this.richEditorLayoutWeight = 0;
                  }
                })
                .layoutWeight(this.richEditorLayoutWeight)
                .onSelectionChange((range) => {
                  let content = this.richEditorController.controller.getStyledString().getString();
                  if (content === '' || range.end === content.length) {
                    return;
                  }
                  if (range.start === undefined || range.end === undefined) {
                    return;
                  }
                  setTimeout(() => {
                    let styleString = this.richEditorController.controller
                      .getStyledString().subStyledString(range.start, 1);
                    let styles = styleString.getStyles(0, 1, StyledStringKey.PARAGRAPH_STYLE);
                    if (styles.length > 0) {
                      let paragraphStyle = styles[0].styledValue as ParagraphStyle;
                      let textAlign = paragraphStyle.textAlign;
                      switch (textAlign) {
                        case TextAlign.Center:
                          this.richEditorController.currentAlignment = 1;
                          break;
                        case TextAlign.End:
                          this.richEditorController.currentAlignment = 2;
                          break;
                        case TextAlign.JUSTIFY:
                          this.richEditorController.currentAlignment = 3;
                          break;
                        case TextAlign.Start:
                          this.richEditorController.currentAlignment = 0;
                      }
                    }
                  }, 100);
                })
                .onClick(() => {
                  // 手写模式下不允许编辑笔记，这里点击时直接退出手写模式
                  if (this.richEditorController.isHandwriteMode) {
                    this.richEditorController.isHandwriteMode = false;
                  }
                })
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .id(this.snapShotController.snapShotId)
          .align(Alignment.Top)
          .width('100%')
          .height('100%')
          .onAreaChange((oldValue, newValue) => {
            this.snapShotController.listComponentWidth = newValue.width as number;
            this.snapShotController.listComponentHeight = newValue.height as number;
            this.snapShotController.scrollHeight = newValue.height as number;

            // 编辑区宽度变化（横竖屏/分栏）：重算图片附件尺寸，变窄会缩小，变宽会恢复到原始大小（不超过编辑区）
            const oldW = oldValue.width as number;
            const newW = newValue.width as number;
            if (typeof oldW === 'number' && typeof newW === 'number' && newW > 0 && oldW > 0 && newW !== oldW) {
              this.richEditorController.reflowImagesToFitWidth(this.uiContext, newW);
            }
          })
          .onDidScroll(() => {
            this.snapShotController.curYOffset = this.snapShotController.scroller.currentOffset().yOffset;
          });
        }
        .layoutWeight(1)
        .zIndex(this.richEditorController.isHandwriteMode ? 0 : 1)

        // 手写层：编辑模式下在底层仅展示；手写模式下在上层可画画
        HandwriteComponent({
          handwriteController: this.handwriteController,
          defaultPenType: PenType.PEN,
          defaultPenInfo: [{ penType: PenType.PEN, penWidth: this.penWidth },
            { penType: PenType.BALLPOINT_PEN, penWidth: this.ballpointPenWidth }] as PenHspInfo[],
          widthRatio: 1,
          heightRatio: 1,
          onInit: () => {
            this.loadHandwriteData();
          }
        })
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
          .zIndex(this.richEditorController.isHandwriteMode && !this.richEditorController.showMoreFunction ? 1 : 0)
          .onTouch((event) => {
            // 仅在编辑态 + 手写模式下才标记画布已修改
            if (!this.richEditorController.isHandwriteMode || this.richEditorController.showMoreFunction) {
              return;
            }
            this.setHandwriteDirty(true);
          })
      }
      .layoutWeight(1)

      // 底部工具栏
      if (this.richEditorController.isHandwriteMode) {
        // 手写笔模式：只显示当前工具栏（含切回键盘按钮），不能编辑文本
        this.toolBar();
      } else {
        // 编辑模式：正常的文本编辑工具栏
        if (this.richEditorController.showToolBarIndex === 1) {
          this.colorPalette();
        } else if (this.richEditorController.showToolBarIndex === 2) {
          this.paragraphFormat();
        }
        this.toolBar();
      }

      // 文档扫描覆盖层（在当前页顶层全屏展示）
      this.docScannerLayer();
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.snapShotController.isShowPreview, this.previewWindowComponent(), {
      modalTransition: ModalTransition.NONE,
      onWillDismiss: (action: DismissContentCoverAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
        }
      },
    });
  }
}
