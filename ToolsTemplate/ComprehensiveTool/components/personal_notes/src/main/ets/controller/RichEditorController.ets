import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ComponentContent, display, LengthMetrics } from '@kit.ArkUI';
import { taskpool } from '@kit.ArkTS';
import { PickerUtil } from '../utils/PickerUtil';
import { AlignmentInfo } from '../commons/Interface';
import { ChangeRecord } from '../models/ChangeRecord';
import { COLOR_LIST, RICH_ID, RICH_IMAGE_MAX_NUM, RICH_IMAGE_MAX_SIZE } from '../commons/Constant';
import { TextAlignment } from '../commons/Enum';
import { WindowUtil } from '../utils/WindowUtil';
import { loadingViewBuilder } from '../components/LoadingView';
import { DialogUtil } from '../utils/DialogUtil';

@ObservedV2
export class RichEditorController {
  private static _instance: RichEditorController;

  public static get instance() {
    if (!RichEditorController._instance) {
      RichEditorController._instance = new RichEditorController();
    }
    return RichEditorController._instance;
  }

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
  @Trace historyRecordArray: Array<ChangeRecord> = [];
  // 撤销操作记录
  @Trace undoRecordArray: Array<ChangeRecord> = [];
  // 是否全部删除
  @Trace isDeleteAll: boolean = false;
  // 是否展示
  @Trace showMoreFunction: boolean = true;
  // 内容长度
  @Trace contentLength: number = 0;
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

  onDo() {
    if (this.currentIndex < 1) {
      return;
    }
    this.undoRecordArray.push(new ChangeRecord(this.historyRecordArray[this.currentIndex].styledString));
    this.currentIndex--;
    this.controller.setStyledString(this.historyRecordArray[this.currentIndex].styledString);
    if (this.currentIndex === 0) {
      this.historyRecordArray.splice(1)
    }
  }

  reDo() {
    if (this.undoRecordArray.length === 0) {
      return;
    }

    this.controller.setStyledString(this.undoRecordArray[this.undoRecordArray.length - 1].styledString);
    let undoRecordStyled = this.undoRecordArray.pop()
    this.currentIndex++
    this.historyRecordArray.push(new ChangeRecord(undoRecordStyled!.styledString))
  }

  /**
   * 编辑区域发生变化时调用方法
   * @param start
   * @param end
   */
  onDidChange(start: number | undefined, end: number | undefined) {
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
        new TextShadowStyle({
          radius: 2,
          type: ShadowType.BLUR,
          offsetX: 3,
          offsetY: 3,
        })
        : new TextShadowStyle({ radius: 0 });

      let textAlign = TextAlign.Start;
      switch (this.currentAlignment) {
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
  addHistoryRecord(styledString: MutableStyledString) {
    if (this.currentIndex === 0) {
      this.undoRecordArray = []
    }
    this.currentIndex++;
    this.historyRecordArray.push(new ChangeRecord(styledString))
  }

  /**
   * 选中样式发生变化时调用方法
   * @param styledKey
   * @param styledValue
   */
  onSelectionStyleChange(styledKey: StyledStringKey, styledValue: StyledStringValue) {
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
      styledValue: styledValue,
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
    let selectRange: Range = { start: -1, end: -1 }
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

    if (start === undefined || end === undefined) {
      selectRange.start = 0;
      selectRange.end = content.length;
      return { start: 0, end: content.length };
    }

    // 光标所在位置
    selectRange.start = start;
    selectRange.end = end;

    // 中间独占一行
    if (start === end && content.charAt(start - 1) === '\n' && content.charAt(end) === '\n') {
      return { start: start, end: start + 1 };
    }
    // 末尾独占一行
    if (start === end && content.charAt(start - 1) === '\n' && end === content.length) {
      return { start: start - 1, end: start };
    }

    // 找到段落起始位置
    while (content.charAt(start - 1) !== '\n' && start !== 0) {
      start--;
    }
    // 找到段落结束位置
    while (content.charAt(end) !== '\n' && end < content.length) {
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
    this.showMoreFunction = true;
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
            this.addHistoryRecord(richEditorStyledString)
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

  // 找出富文本中的图片
  findImgSrcList(htmlStr: string): string[] {
    const regx = /<img[^>]+src=["']\s*([^"']+)\s*["']/g;
    const matches = htmlStr.matchAll(regx);
    let imgSrcList: string[] = [];
    for (const match of matches) {
      const imgSrc = match[1];
      imgSrcList.push(imgSrc.trim());
    }
    return imgSrcList;
  }

  showToast(message: string) {
    WindowUtil.uiContext.getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
    })
  }

  showLoading() {
    let contentNode: ComponentContent<object> =
      new ComponentContent(WindowUtil.uiContext, wrapBuilder(loadingViewBuilder));
    DialogUtil.openDialog(WindowUtil.uiContext, contentNode);
  }

  closeLoading() {
    DialogUtil.closeDialog();
  }

  /**
   * 选择图片
   */
  selectImage(uiContext: UIContext) {
    PickerUtil.selectPhoto({
      maxSelectNumber: 1,
    }).then(async (uris) => {
      let imageUri = uris[0];

      if (!imageUri) {
        return;
      }

      this.showLoading();

      // 校验图片个数
      let imgSrcList: string[] = []
      try {
        const newHtml = StyledString.toHtml(this.controller.getStyledString());
        imgSrcList = this.findImgSrcList(newHtml);
      } catch (e) {
        UtilLog.error('[RichEditorController]', `styleString to html failed. error: ${JSON.stringify(e)}`)
      }
      if (imgSrcList.length >= RICH_IMAGE_MAX_NUM) {
        this.showToast(`图片总数超过${RICH_IMAGE_MAX_NUM}个，已达上限`)
        return;
      }
      // 校验图片总大小
      let size: number = 0;
      try {
        for (let i = 0; i < imgSrcList.length; i++) {
          const filePath = imgSrcList[i].replace('file://', '');
          const stat = fileIo.statSync(filePath);
          if (stat) {
            size += stat.size;
          }
        }
      } catch (e) {
        UtilLog.error('[RichEditorController]', `get file stat failed. error: ${JSON.stringify(e)}`)
      }
      const sizeGB = size / 1024 / 1024 / 1024;
      if (sizeGB >= RICH_IMAGE_MAX_SIZE) {
        this.showToast(`图片总大小超过${RICH_IMAGE_MAX_SIZE}GB，已达上限`)
        return
      }

      let pixelMap: image.PixelMap | undefined = await handleTaskPoolLoadImage(imageUri);
      if (pixelMap) {
        let info = pixelMap.getImageInfoSync();
        let width = info.size.width;
        let height = info.size.height;
        // 宽度超过最大尺寸时，等比例缩放 占屏幕的90%
        let displayWidth = uiContext.px2vp(display.getDefaultDisplaySync().width) * 0.9;
        if (width > displayWidth) {
          width = displayWidth;
          height = width / info.size.width * height;
        }

        let imageStyledString = new MutableStyledString(new ImageAttachment({
          value: pixelMap,
          objectFit: ImageFit.Auto,
          size: { width: width, height: height },
        }));
        let richEditorStyledString: MutableStyledString = this.controller.getStyledString();
        let currentOffset = this.controller.getCaretOffset()
        richEditorStyledString.insertStyledString(currentOffset, imageStyledString);
        // 添加图片后自动向下插入一行
        richEditorStyledString.insertString(currentOffset + 1, '\n');
        // 使插入图片后的属性字符串展示在组件上
        this.controller.setStyledString(richEditorStyledString);
        // 关闭loading
        this.closeLoading();
        this.controller.setCaretOffset(currentOffset + 2)
        // 如果输入之前是全部删除操作，则进行重置
        this.resetDeleteAllState()
        this.addHistoryRecord(richEditorStyledString);
        // 获取内容长度
        this.contentLength = this.controller.getStyledString().length;
        try {
          WindowUtil.uiContext.getFocusController().requestFocus(RICH_ID);
        } catch (error) {
          UtilLog.error('[RichEditorController]', `requestFocus failed. error: ${JSON.stringify(error)}`)
        }
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
}

interface Range {
  start: number;
  end: number
}

@Concurrent
async function compressImage(name: string) {
  try {
    let fileSource = fileIo.openSync(name, fileIo.OpenMode.READ_ONLY);
    let imgFileSize = fileIo.statSync(fileSource.fd).size;
    let imageSource: image.ImageSource = image.createImageSource(fileSource.fd);
    fileIo.closeSync(fileSource);
    if (imgFileSize > 10 * 1024 * 1024) {
      const decodingOptions: image.DecodingOptions = { editable: true };
      let imgPixel: image.PixelMap = imageSource.createPixelMapSync(decodingOptions);
      let imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 40 }
      const arrayBuffer = await imagePackerApi.packToData(imgPixel, packOpts);
      imagePackerApi.release();
      const newImgSource = image.createImageSource(arrayBuffer);
      return newImgSource.createPixelMapSync();
    }
    return imageSource.createPixelMapSync();
  } catch (e) {
    UtilLog.error('[RichEditorController]', `loadImage failed. error: ${JSON.stringify(e)}`)
    return undefined
  }
}

// 将大图进行压缩
export async function handleTaskPoolLoadImage(name: string): Promise<image.PixelMap | undefined> {
  // 创建task并传入函数compressImage
  let task: taskpool.Task = new taskpool.Task(compressImage, name);
  let pixelMap: image.PixelMap | undefined = undefined
  // 执行task任务
  try {
    pixelMap = await taskpool.execute(task) as image.PixelMap | undefined;
  } catch (e) {
    UtilLog.error(
      '[RichEditorController]',
      `handleTaskPoolLoadImage failed. error: ${JSON.stringify(e)}`
    )
  }
  return pixelMap;
}