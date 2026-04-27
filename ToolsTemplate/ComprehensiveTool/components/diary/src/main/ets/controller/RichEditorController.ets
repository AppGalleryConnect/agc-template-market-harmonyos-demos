import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { PickerUtil } from '../utils/PickerUtil';
import { LengthMetrics } from '@kit.ArkUI';
import { AlignmentInfo } from '../commons/Interface';
import { ChangeDiaryRecord } from '../models/ChangeRecord';
import { COLOR_LIST } from '../commons/Constant';
import { TextAlignment } from '../commons/Enum';
import { UtilLog } from '@hw-agconnect/util-log';

@ObservedV2
export class RichEditorController {
  textInputController: TextInputController = new TextInputController();
  controller: RichEditorStyledStringController = new RichEditorStyledStringController();
  options: RichEditorStyledStringOptions = { controller: this.controller };

  // 当前文本是否加粗
  @Trace currentBold: boolean = false;
  // 当前文本是否斜体
  @Trace currentItalics: boolean = false;
  // 当前文本是否有阴影
  @Trace currentShadow: boolean = false;
  // 当前文本装饰线
  @Trace currentDecoration: TextDecorationType = TextDecorationType.None;
  // 显示的拓展工具栏索引号 0-关闭扩展工具栏 1-显示调色盘选项栏 2-显示段落样式选项栏
  @Trace showToolBarIndex: number = 0;
  // 当前文本颜色
  @Trace currentColor: number = 0;
  // 字体大小
  @Trace fontSize: LengthMetrics = LengthMetrics.vp(18);
  // 当前段落对齐样式
  @Trace currentAlignment: number = TextAlignment.START;

  // 指向当前操作记录
  @Trace currentIndex: number = -1;
  // 操作记录
  @Trace historyRecordArray: Array<ChangeDiaryRecord> = [];
  // 撤销操作记录
  @Trace undoRecordArray: Array<ChangeDiaryRecord> = [];
  // 是否全部删除
  @Trace isDeleteAll: boolean = false;
  // 是否保存
  @Trace isSave: boolean = false;
  // 富文本的文本内容
  @Trace richTextContent: string = '';
  // 富文本内容的长度不包含换行、图片
  @Trace textCount: number = 0;

  // 段落对齐样式以及点击回调
  paragraphAlignments: AlignmentInfo[] = [
    {
      icon: $r('app.media.ic_alignment_left'),
      click: () => {
        this.setParagraphAlignment(TextAlign.Start);
        this.currentAlignment = TextAlignment.START;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_center'),
      click: () => {
        this.setParagraphAlignment(TextAlign.Center);
        this.currentAlignment = TextAlignment.CENTER;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_right'),
      click: () => {
        this.setParagraphAlignment(TextAlign.End);
        this.currentAlignment = TextAlignment.END;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_justify'),
      click: () => {
        this.setParagraphAlignment(TextAlign.JUSTIFY);
        this.currentAlignment = TextAlignment.JUSTIFY;
        this.showToolBarIndex = 0;
      },
    },
  ];

  undo() {
    if (this.currentIndex < 1) {
      return;
    }
    this.undoRecordArray.push(new ChangeDiaryRecord(this.historyRecordArray[this.currentIndex].styledString));
    this.currentIndex--;
    this.controller.setStyledString(this.historyRecordArray[this.currentIndex].styledString);
    if (this.currentIndex === 0) {
      this.historyRecordArray.splice(1)
    }
  }

  redo() {
    if (this.undoRecordArray.length === 0) {
      return;
    }

    this.controller.setStyledString(this.undoRecordArray[this.undoRecordArray.length - 1].styledString);
    let undoRecordStyled = this.undoRecordArray.pop()
    this.currentIndex++
    this.historyRecordArray.push(new ChangeDiaryRecord(undoRecordStyled!.styledString))
  }


  /**
   * 编辑区域发生变化时调用方法
   * @param start
   * @param end
   */
  onDidChange(start: number | undefined, end: number | undefined){
    if (start !== undefined && end !== undefined) {
      if (end - start <= 0) {
        return;
      }
      // 设置文本字体样式
      const textStyle: TextStyle = new TextStyle({
        fontWeight: this.currentBold ? FontWeight.Bold : FontWeight.Normal,
        fontStyle: this.currentItalics ? FontStyle.Italic : FontStyle.Normal,
        fontSize: this.fontSize,
        fontColor: COLOR_LIST[this.currentColor],
      });
      // 设置文本装饰线样式
      let decorationStyle = new DecorationStyle({
        type: this.currentDecoration,
      });
      // 设置文本阴影
      let textShadowStyle = this.currentShadow ?
        new TextShadowStyle({ radius: 2, type: ShadowType.BLUR, offsetX: 3, offsetY: 3, })
        : new TextShadowStyle({ radius: 0 });

      let textAlign = TextAlign.Start;
      switch (this.currentAlignment){
        case TextAlignment.START:
          textAlign = TextAlign.Start;
          break;
        case TextAlignment.CENTER:
          textAlign = TextAlign.Center;
          break;
        case TextAlignment.END:
          textAlign = TextAlign.End;
          break;
        case TextAlignment.JUSTIFY:
          textAlign = TextAlign.JUSTIFY;
          break;
      }
      let paragraphStyle = new ParagraphStyle({
        textAlign: textAlign,
      });
      // 获取富文本组件显示的属性字符串
      const richEditorStyledString = this.controller.getStyledString();
      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.FONT,
        styledValue: textStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.DECORATION,
        styledValue: decorationStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.TEXT_SHADOW,
        styledValue: textShadowStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.PARAGRAPH_STYLE,
        styledValue: paragraphStyle,
      });

      // 使变更样式后的属性字符串展示在组件上
      this.controller.setStyledString(richEditorStyledString);
      this.controller.setCaretOffset(end);
      // 如果输入之前是全部删除操作，则进行重置
      this.resetDeleteAllState()
      this.addHistoryRecord(richEditorStyledString);
    }
  }

  /**
   * 增加历史记录
   * @param styledString
   */
  addHistoryRecord(styledString: MutableStyledString){
    if (this.currentIndex === 0) {
      this.undoRecordArray = []
    }
    this.currentIndex++;
    this.historyRecordArray.push(new ChangeDiaryRecord(styledString))
  }

  /**
   * 选中样式发生变化时调用方法
   * @param styledKey
   * @param styledValue
   */
  onSelectionStyleChange(styledKey: StyledStringKey, styledValue: StyledStringValue){
    let richEditorSelection = this.controller.getSelection();
    let start = richEditorSelection.start ? richEditorSelection.start : 0;
    let end = richEditorSelection.end ? richEditorSelection.end : 0;
    if (start < 0 || end <= start) {
      return;
    }

    // 获取组件展示的属性字符串
    let richEditorStyledString: MutableStyledString = this.controller.getStyledString();
    richEditorStyledString.setStyle({
      start: start,
      length: end - start,
      styledKey: styledKey,
      styledValue: styledValue
    });

    // 获取选中范围，用于视图渲染后重新选中
    let selectRange = this.controller.getSelection();
    // 使变更样式后的属性字符串展示在组件上
    this.controller.setStyledString(richEditorStyledString);
    this.currentIndex++;
    this.addHistoryRecord(richEditorStyledString);
    this.reSelect(selectRange.start, selectRange.end)
  }

  /**
   * 设置段落对齐样式
   * @param textAlign
   */
  setParagraphAlignment(textAlign: TextAlign) {
    let paragraphStyle = new ParagraphStyle({
      textAlign: textAlign,
    });
    const richEditorStyledString = this.controller.getStyledString();
    if (richEditorStyledString.length === 0) {
      return;
    }
    // 光标选中范围
    let selectRange: Range = {start: -1, end: -1}
    // 段落移动范围
    let range = this.getParagraphRange(selectRange);

    richEditorStyledString.setStyle({
      start: range.start,
      length: range.end - range.start,
      styledKey: StyledStringKey.PARAGRAPH_STYLE,
      styledValue: paragraphStyle,
    });
    this.controller.setStyledString(richEditorStyledString);
    // 设置光标位置
    this.controller.setCaretOffset(selectRange.start);
    // 设置选中区域
    this.controller.setSelection(selectRange.start, selectRange.end);
    this.addHistoryRecord(richEditorStyledString);
  }

  /**
   * 获取选中范围和段落移动范围
   * @param selectRange 选中范围，为选中范围赋值
   * @returns 段落移动范围
   */
  getParagraphRange(selectRange: Range): Range {
    // 获取文本内容
    let content: string = this.controller.getStyledString().getString();
    // 获取光标所在位置
    let start = this.controller.getSelection().start;
    let end = this.controller.getSelection().end;

    if (start === undefined || end === undefined){
      selectRange.start = 0;
      selectRange.end = content.length;
      return { start: 0, end: content.length };
    }

    // 光标所在位置
    selectRange.start = start;
    selectRange.end = end;

    // 中间独占一行
    if (start === end && content.charAt(start-1) === '\n' && content.charAt(end) === '\n'){
      return { start: start, end: start + 1 };
    }
    // 末尾独占一行
    if (start === end && content.charAt(start-1) === '\n' && end === content.length){
      return { start: start-1, end: start };
    }

    // 找到段落起始位置
    while (content.charAt(start - 1) !== '\n' && start !== 0){
      start--;
    }
    // 找到段落结束位置
    while (content.charAt(end) !== '\n' && end < content.length){
      end++;
    }
    return { start: start, end: end };
  }

  /**
   * 重新选中状态
   * @param start
   * @param end
   */
  reSelect(start: number | undefined, end: number | undefined) {
    if (start !== undefined && end !== undefined) {
      if (end - start <= 0) {
        return;
      }
      this.controller.setSelection(start, end);
    }
  }

  /**
   * 恢复初始状态
   */
  initState() {
    this.currentBold = false;
    this.currentItalics = false;
    this.currentShadow = false;
    this.currentDecoration = TextDecorationType.None;
    this.showToolBarIndex = 0;
    this.currentColor = 0;
    this.currentAlignment = TextAlignment.START;
    this.undoRecordArray = []
    this.isDeleteAll = false
  }

  /**
   * 清除所有内容
   * @param context
   */
  clearAllContent(context: UIContext) {
    context.showAlertDialog(
      {
        message: '是否确认删除所有文字?',
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: '取消',
          action: () => {
          },
        },
        secondaryButton: {
          enabled: true,
          defaultFocus: true,
          style: DialogButtonStyle.DEFAULT,
          fontColor: Color.Red,
          value: '确认',
          action: () => {
            const richEditorStyledString = this.controller.getStyledString();
            richEditorStyledString.removeString(0, richEditorStyledString.length);
            this.controller.setStyledString(richEditorStyledString);
            this.initState();
            // 全部删除时，将删除前的内容保存在历史记录的第二条，其它的记录都删除
            let lastHisRecord = this.historyRecordArray.pop();
            this.historyRecordArray.splice(1);
            this.historyRecordArray.push(lastHisRecord)
            this.currentIndex = 1
            this.undoRecordArray = [];
            this.isDeleteAll = true;
            this.addHistoryRecord(richEditorStyledString);
            this.richTextContent = this.controller.getStyledString().getString();
            this.textCount = this.richTextContent.replace(/\n/g, '').length;
          },
        },
        cancel: () => {
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason === DismissReason.PRESS_BACK ||
            dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
            dismissDialogAction.dismiss();
          }
        },
      },
    );
  }

  /**
   * 选择图片
   */
  selectImage() {
    PickerUtil.selectPhoto({
      maxSelectNumber: 1,
    }).then((uris) => {
      let imageUri = uris[0];
      let pixelMap: image.PixelMap | undefined = RichEditorController.loadImage(imageUri);
      if (pixelMap) {
        let imageStyledString = new MutableStyledString(new ImageAttachment({
          value: pixelMap,
          objectFit: ImageFit.Auto,
        }));
        let richEditorStyledString: MutableStyledString = this.controller.getStyledString();
        let currentOffset = this.controller.getCaretOffset()
        richEditorStyledString.insertStyledString(currentOffset, imageStyledString);
        // 添加图片后自动向下插入一行
        richEditorStyledString.insertString(currentOffset + 1, '\n');
        // 使插入图片后的属性字符串展示在组件上
        this.controller.setStyledString(richEditorStyledString)
        this.controller.setCaretOffset(currentOffset+2)
        // 如果输入之前是全部删除操作，则进行重置
        this.resetDeleteAllState()
        this.addHistoryRecord(richEditorStyledString);
        this.richTextContent = this.controller.getStyledString().getString();
      }
    });
  }

  resetDeleteAllState() {
    if (this.isDeleteAll) {
      this.historyRecordArray.splice(1);
      this.isDeleteAll = false;
      this.currentIndex = 0;
      this.undoRecordArray = [];
    }
  }

  private static loadImage(name: string): image.PixelMap | undefined {
    let imageSource: image.ImageSource;
    try {
      let fileSource = fileIo.openSync(name, fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(fileSource.fd);
      return imageSource?.createPixelMapSync();
    } catch (e) {
      UtilLog.error(`loadImage failed with error ${JSON.stringify(e)}`)
      return undefined
    }
  }
}

interface Range {
  start: number;
  end: number
}