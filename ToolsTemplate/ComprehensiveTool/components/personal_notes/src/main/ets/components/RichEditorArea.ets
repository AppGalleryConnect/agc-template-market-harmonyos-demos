import { LengthMetrics } from '@kit.ArkUI';
import { COLOR_LIST, HIGHLIGHT_COLOR_FILTER, ORIGIN_COLOR_FILTER, RICH_ID,
  RICH_TEXT_MAX_LENGTH } from '../commons/Constant';
import { TextAlignment } from '../commons/Enum';
import { AlignmentInfo } from '../commons/Interface';
import { RichEditorController } from '../controller/RichEditorController';
import { SnapShotController } from '../controller/SnapShotController';
import { SnapshotPreview } from './SnapshotPreview';

@ComponentV2
export struct RichEditorArea {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private richEditorController: RichEditorController = RichEditorController.instance;
  @Param snapShotController: SnapShotController = new SnapShotController('', new Scroller());
  // 需要分享截图时设为0，否则设为1即可
  @Local richEditorLayoutWeight: number = 0;
  @Param @Once @Require noteTitle: string;
  @Param @Once @Require noteContent: MutableStyledString;
  @Event titleChange: (title: string) => void = () => {
  };

  // 是否处于编辑状态
  @Local isEditing: boolean = false;

  // 处理调色盘变化
  handleColorSliderChange(value: number) {
    this.richEditorController.fontSize = LengthMetrics.vp(value);
    this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
      fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
      fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
      fontColor: COLOR_LIST[this.richEditorController.currentColor],
      fontSize: this.richEditorController.fontSize
    }));
  }

  // 选择颜色
  selectedColor(index: number) {
    this.richEditorController.showToolBarIndex = 0;
    this.richEditorController.currentColor = index;
    this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
      fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
      fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
      fontColor: COLOR_LIST[this.richEditorController.currentColor],
      fontSize: this.richEditorController.fontSize
    }));
  }

  // 调色盘选项栏
  @Builder
  colorPalette() {
    Column(){
      Row() {
        Text('A').fontSize(10).fontColor($r('sys.color.font_secondary'));
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
            // 以滑动部分颜色
            .selectedColor($r('sys.color.comp_background_emphasize'))
            // 显示步长刻度
            .showSteps(true)
            .blockStyle({ type: SliderBlockType.IMAGE, image: $r('app.media.font_setting') })
            .blockSize({
              width: $r('app.float.rich_editor_block_size'),
              height: $r('app.float.rich_editor_block_size')
            })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.handleColorSliderChange(value)
            })
        }
        .width('90%')

        Blank();

        Text('A').fontSize(16).fontColor($r('sys.color.font_secondary'));
      }
      .width('100%')
      .height(50)
      .padding({ left: '4%', right: '4%' })

      Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
        ForEach(COLOR_LIST, (color: ResourceColor, index: number) => {
          Stack() {
            Circle({ width: 16, height: 16 }).fill(color);

            Circle({ width: 24, height: 24 })
              .fillOpacity(0)
              .borderWidth(2)
              .borderRadius(12)
              .borderColor(this.richEditorController.currentColor === index ? Color.Red : Color.Black);
          }
          .onClick(() => {
            this.selectedColor(index)
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
    Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      // 调色盘图标
      Image($r('app.media.font_color_size'))
        .width(24)
        .fillColor(COLOR_LIST[this.richEditorController.currentColor])
        .onClick(() => {
          if (this.richEditorController.showToolBarIndex !== 1) {
            this.richEditorController.showToolBarIndex = 1;
          } else {
            this.richEditorController.showToolBarIndex = 0;
          }
        })

      // 段落对齐图标
      Image(this.richEditorController.paragraphAlignments[this.richEditorController.currentAlignment].icon)
        .width(24)
        .onClick(() => {
          if (this.richEditorController.showToolBarIndex !== 2) {
            this.richEditorController.showToolBarIndex = 2;
          } else {
            this.richEditorController.showToolBarIndex = 0;
          }
        });

      // 文本加粗图标
      Image($r('app.media.ic_bold'))
        .width(24)
        .colorFilter(this.richEditorController.currentBold ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)// 当前图标高亮
        .onClick(() => {
          this.richEditorController.currentBold = !this.richEditorController.currentBold;

          this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
            fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
            fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
            fontColor: COLOR_LIST[this.richEditorController.currentColor],
            fontSize: this.richEditorController.fontSize
          }));
        });

      // 文本斜体图标
      Image($r('app.media.ic_notepad_italic'))
        .width(24)
        .colorFilter(this.richEditorController.currentItalics ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)// 当前图标高亮
        .onClick(() => {
          this.richEditorController.currentItalics = !this.richEditorController.currentItalics;

          this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
            fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
            fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
            fontColor: COLOR_LIST[this.richEditorController.currentColor],
            fontSize: this.richEditorController.fontSize
          }));
        });

      // 文本下划线图标
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

      // 文本删除线图标
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

      // 文本阴影图标
      Image($r('app.media.ic_shadow'))
        .width(24)
        .colorFilter(this.richEditorController.currentShadow ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)// 当前图标高亮
        .onClick(() => {
          this.richEditorController.currentShadow = !this.richEditorController.currentShadow;

          this.richEditorController.onSelectionStyleChange(StyledStringKey.TEXT_SHADOW,
            this.richEditorController.currentShadow ?
              new TextShadowStyle({ radius: 2, type: ShadowType.BLUR, offsetX: 3, offsetY: 3, }) :
              new TextShadowStyle({ radius: 0 }));
        });

      // 选择图片图标
      SymbolGlyph($r('sys.symbol.picture_fill'))
        .fontSize(24)
        .onClick(() => {
          this.richEditorController.selectImage(this.getUIContext());
        });

      // 清除所有文本图标
      Image($r('app.media.ic_public_delete'))
        .width(24)
        .onClick(() => {
          const richEditorStyledString = this.richEditorController.controller.getStyledString();
          if (richEditorStyledString.length === 0) {
            return;
          }
          this.richEditorController.clearAllContent(this.getUIContext());
        });
    }
    .height(60)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#EDEFF5');
  }

  @Builder
  previewWindowComponent() {
    Column() {
      SnapshotPreview({
        mergedImage: this.snapShotController.mergedImage,
        snapPopupPosition: this.snapShotController.snapPopupPosition,
        isLargePreview: this.snapShotController.isLargePreview,
        isShowPreview: this.snapShotController.isShowPreview,
        changeMergedImage: (mergedImage) => {
          this.snapShotController.mergedImage = this.snapShotController.mergedImage;
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
            ORIGIN_COLOR_FILTER)// 当前段落样式高亮
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
      // 判断是否是删除
      let beforeEnd = rangeBefore?.end
      let afterEnd = rangeAfter?.end
      if (typeof beforeEnd === 'number' && typeof afterEnd === 'number' && beforeEnd > afterEnd) {
        let hisRecordIdx = this.richEditorController.historyRecordArray.length - 1;
        let latestHisRecordStr = this.richEditorController.historyRecordArray[hisRecordIdx].styledString.getString();
        let richEditorStr = this.richEditorController.controller.getStyledString().getString();
        // 内容发生变化，但是文字文案没有变，说明删除图片操作
        if (latestHisRecordStr !== richEditorStr) {
          this.richEditorController.addHistoryRecord(this.richEditorController.controller.getStyledString());
        }
      }
      this.richEditorController.onDidChange(rangeAfter.start, rangeAfter.end);
      this.richEditorController.contentLength = this.richEditorController.controller.getStyledString().length;
    }
  }

  handleRichEditorChange(range: RichEditorRange) {
    // 光标移动时，更新编辑栏状态显示
    let content = this.richEditorController.controller.getStyledString().getString();
    if (content === '' || range.end === content.length) {
      return;
    }
    if (!range.start || !range.end){
      return;
    }
    // 更新段落样式
    setTimeout(() => {
      let styleString = this.richEditorController.controller
        .getStyledString().subStyledString(range.start, 1);
      let styles = styleString.getStyles(0, 1, StyledStringKey.PARAGRAPH_STYLE)
      if (styles.length > 0) {
        let paragraphStyle = styles[0].styledValue as ParagraphStyle;
        let textAlign = paragraphStyle.textAlign;
        switch (textAlign) {
          case TextAlign.Center:
            this.richEditorController.currentAlignment = TextAlignment.CENTER;
            break;
          case TextAlign.End:
            this.richEditorController.currentAlignment = TextAlignment.END;
            break;
          case TextAlign.JUSTIFY:
            this.richEditorController.currentAlignment = TextAlignment.JUSTIFY;
            break;
          case TextAlign.Start:
            this.richEditorController.currentAlignment = TextAlignment.START;
        }
      }
    }, 100);
  }

  handleEditChange(editingStatus: boolean) {
    this.isEditing = editingStatus;
    this.richEditorController.showMoreFunction = false;
    if (editingStatus) {
      this.richEditorLayoutWeight = 1;
    } else {
      this.richEditorLayoutWeight = 0;
    }
  }

  build() {
    Column() {
      Column() {
        Scroll(this.snapShotController.scroller) {
          Stack({alignContent: Alignment.Top}) {
            Column() {
              this.titleInputView()

              RichEditor(this.richEditorController.options)
                .placeholder('开始书写你的笔记', { fontColor: $r('sys.color.font_tertiary'), font: { size: 14 } })
                .barState(BarState.Off)
                .id(RICH_ID)
                .maxLength(RICH_TEXT_MAX_LENGTH)
                .onReady(() => {
                  // 注册文本变化回调
                  this.richEditorController.controller.onContentChanged(this.contentChangedListener);
                  // 设定组件展示的属性字符串
                  this.richEditorController.controller.setStyledString(this.noteContent)
                  this.richEditorController.contentLength =
                    this.richEditorController.controller.getStyledString().length;
                })
                .width('100%')
                .onEditingChange((editingStatus) => {
                  this.handleEditChange(editingStatus)
                })
                .layoutWeight(this.richEditorLayoutWeight)
                .onSelectionChange((range: RichEditorRange) => {
                  this.handleRichEditorChange(range)
                })
            }
            .width('100%')
            .margin({bottom: 16})

            Row() {
              Text(`${this.richEditorController.contentLength} / ${RICH_TEXT_MAX_LENGTH}字`)
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .padding({left: 8, top: 4, right: 8, bottom: 4})
            .borderRadius(4)
            .position({ bottom: 4, right: 20 })
          }
          .width('100%')
          .height('100%')
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
        })
        .onDidScroll(() => {
          this.snapShotController.curYOffset = this.snapShotController.scroller.currentOffset().yOffset;
        })
        .onClick(() => {
          // 点击空白出RichEditor自动聚焦
          this.getUIContext().getFocusController().requestFocus(RICH_ID);
        });
      }
      .layoutWeight(1)

      if (this.isEditing) {
        if (this.richEditorController.showToolBarIndex === 1) {
          this.colorPalette();
        } else if (this.richEditorController.showToolBarIndex === 2) {
          this.paragraphFormat();
        }
        this.toolBar();
      }
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

  @Builder
  titleInputView() {
    TextInput({
      placeholder: '标题',
      text: this.noteTitle,
      controller: this.richEditorController.textInputController
    })
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({
        size: $r('sys.float.Body_L'),
        weight: FontWeight.Bold
      })
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .width('100%')
      .height(40)
      // 设置透明背景色
      .backgroundColor(Color.Transparent)
      .borderRadius(0)
      .onChange((value: string) => {
        this.noteTitle = value;
        this.titleChange(value);
      })
      .margin({ top: 12, })
      .onClick(() => {
        this.richEditorController.showMoreFunction = false;
      })
  }
}