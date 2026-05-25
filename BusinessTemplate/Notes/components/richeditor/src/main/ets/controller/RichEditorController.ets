import { AlignmentInfo } from '../model/AlignmentInfo';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { PickerUtil } from '../utils/PickerUtil';
import { camera, cameraPicker } from '@kit.CameraKit';
import hilog from '@ohos.hilog';
import { COLOR_LIST } from '../common/Constants';
import { ChangeRecord } from '../model/ChangeRecord';
import { display, LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class RichEditorController {
  private static _instance: RichEditorController;

  public static get instance() {
    if (!RichEditorController._instance) {
      RichEditorController._instance = new RichEditorController();
    }
    return RichEditorController._instance;
  }

  private static readonly MAX_IMAGE_COUNT: number = 20;
  private static readonly MAX_IMAGE_SIZE_BYTES: number = 20 * 1024 * 1024;

  textInputController: TextInputController = new TextInputController();
  controller: RichEditorStyledStringController = new RichEditorStyledStringController();
  options: RichEditorStyledStringOptions = { controller: this.controller };
  // 当前文本是否加粗
  @Trace currentBold: boolean = false;
  // 当前文本是否斜体
  @Trace currentItalics: boolean = false;
  // 是否手写笔模式
  @Trace isHandwriteMode: boolean = false;
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
  @Trace currentAlignment: number = 0;
  // 指向当前操作记录
  @Trace currentIndex: number = -1;
  // 操作记录
  @Trace historyRecordArray: Array<ChangeRecord> = [];
  // 是否展示
  @Trace showMoreFunction: boolean = true;
  // 段落对齐样式以及点击回调
  paragraphAlignments: AlignmentInfo[] = [
    {
      icon: $r('app.media.ic_alignment_left'),
      click: () => {
        this.setParagraphAlignment(TextAlign.Start);
        this.currentAlignment = 0;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_center'),
      click: () => {
        this.setParagraphAlignment(TextAlign.Center);
        this.currentAlignment = 1;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_right'),
      click: () => {
        this.setParagraphAlignment(TextAlign.End);
        this.currentAlignment = 2;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_justify'),
      click: () => {
        this.setParagraphAlignment(TextAlign.JUSTIFY);
        this.currentAlignment = 3;
        this.showToolBarIndex = 0;
      },
    },
  ];

  onDo() {
    if (this.currentIndex < 1) {
      return;
    }

    this.controller.setStyledString(this.historyRecordArray[--this.currentIndex].styledString);
  }

  reDo() {
    if (this.currentIndex >= this.historyRecordArray.length - 1) {
      return;
    }

    this.controller.setStyledString(this.historyRecordArray[++this.currentIndex].styledString);
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
        case 0:
          textAlign = TextAlign.Start;
          break;
        case 1:
          textAlign = TextAlign.Center;
          break;
        case 2:
          textAlign = TextAlign.End;
          break;
        case 3:
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

      this.addHistoryRecord(richEditorStyledString);
    }
  }

  /**
   * 增加历史记录
   * @param styledString
   */
  addHistoryRecord(styledString: MutableStyledString) {
    this.currentIndex++;
    this.historyRecordArray.push(new ChangeRecord(styledString));
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
    this.reSelect(selectRange.start, selectRange.end);
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
    let selectRange: Range = { start: -1, end: -1 };
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
    this.isHandwriteMode = false;
    this.currentShadow = false;
    this.currentDecoration = TextDecorationType.None;
    this.showToolBarIndex = 0;
    this.currentColor = 0;
    this.currentAlignment = 0;
    this.showMoreFunction = true;
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
            if (richEditorStyledString.length === 0) {
              return;
            }
            richEditorStyledString.removeString(0, richEditorStyledString.length);
            this.controller.setStyledString(richEditorStyledString);
            this.initState();
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

  insertScannedUris(uiContext: UIContext, uris: string[], maxWidthVp?: number): ScanInsertResult {
    const result: ScanInsertResult = {
      insertedImageCount: 0,
      pdfCount: 0,
      unsupportedCount: 0
    };
    if (!uris || uris.length === 0) {
      return result;
    }

    let richEditorStyledString: MutableStyledString = this.controller.getStyledString();
    let currentOffset = this.controller.getCaretOffset();
    let currentImageCount = this.getImageCount();

    for (let uri of uris) {
      if (!uri) {
        continue;
      }

      // 当前富文本仅支持图片附件；PDF 仅保留在系统中
      if (this.isPdfUri(uri)) {
        result.pdfCount++;
        continue;
      }

      if (currentImageCount >= RichEditorController.MAX_IMAGE_COUNT) {
        result.unsupportedCount++;
        continue;
      }

      try {
        const stat = fileIo.statSync(uri);
        if (stat && stat.size > RichEditorController.MAX_IMAGE_SIZE_BYTES) {
          result.unsupportedCount++;
          continue;
        }
      } catch (err) {
        hilog.error(0x0001, 'RichEditor', `获取图片大小失败: ${JSON.stringify(err)}`);
        result.unsupportedCount++;
        continue;
      }

      let pixelMap: image.PixelMap;
      try {
        pixelMap = RichEditorController.loadImage(uri);
      } catch (err) {
        result.unsupportedCount++;
        continue;
      }

      const info = pixelMap.getImageInfoSync();
      // 统一使用 vp 计算尺寸，避免 px/vp 混用导致在分栏/竖屏下溢出被裁切
      let widthVp = uiContext.px2vp(info.size.width);
      let heightVp = uiContext.px2vp(info.size.height);
      const baseWidthVp = typeof maxWidthVp === 'number' && maxWidthVp > 0
        ? maxWidthVp
        : uiContext.px2vp(display.getDefaultDisplaySync().width);
      const displayWidthVp = baseWidthVp * 0.9;
      // 仅在图片过宽时按编辑区缩放；较小图片保持原尺寸
      if (widthVp > displayWidthVp) {
        const ratio = displayWidthVp / widthVp;
        widthVp = displayWidthVp;
        heightVp = heightVp * ratio;
      }

      let imageStyledString = new MutableStyledString(new ImageAttachment({
        value: pixelMap,
        objectFit: ImageFit.Auto,
        size: { width: widthVp, height: heightVp },
      }));
      richEditorStyledString.insertStyledString(currentOffset, imageStyledString);
      richEditorStyledString.insertString(currentOffset + 1, '\n');
      currentOffset += 2;
      currentImageCount++;
      result.insertedImageCount++;
    }

    this.controller.setStyledString(richEditorStyledString);
    this.controller.setCaretOffset(currentOffset);
    return result;
  }

  private isPdfUri(uri: string): boolean {
    const lower = uri.toLowerCase();
    return lower.endsWith('.pdf') || lower.indexOf('.pdf?') > -1 || lower.indexOf('.pdf#') > -1;
  }

  private insertImagesFromUris(uiContext: UIContext, uris: string[], maxWidthVp?: number): void {
    const insertResult = this.insertScannedUris(uiContext, uris, maxWidthVp);
    if (insertResult.insertedImageCount <= 0 && uris && uris.length > 0) {
      uiContext.getPromptAction().showToast({
        message: `最多只能插入${RichEditorController.MAX_IMAGE_COUNT}张图片`,
        duration: 1500
      });
    }
  }

  private getImageCount(): number {
    const styledString = this.controller.getStyledString();
    const content = styledString.getString();
    if (!content || content.length === 0) {
      return 0;
    }
    const styles: Array<SpanStyle> = styledString.getStyles(0, content.length);
    let count = 0;
    for (let style of styles) {
      if (style.styledKey === StyledStringKey.IMAGE) {
        count++;
      }
    }
    return count;
  }

  /**
   * 当编辑区宽度变化（如横竖屏切换/分栏变化）时，将已插入的图片附件按当前宽度重新自适应：
   * - 变窄：必要时缩小，避免右侧溢出
   * - 变宽：在不超过图片原始尺寸的前提下恢复放大
   */
  reflowImagesToFitWidth(uiContext: UIContext, maxWidthVp: number): void {
    if (!uiContext || !(maxWidthVp > 0)) {
      return;
    }
    const styledString: MutableStyledString = this.controller.getStyledString();
    const content = styledString.getString();
    if (!content || content.length === 0) {
      return;
    }

    const displayWidthVp = maxWidthVp * 0.9;
    const styles: Array<SpanStyle> = styledString.getStyles(0, content.length);
    let changed = false;

    for (const style of styles) {
      if (style.styledKey !== StyledStringKey.IMAGE) {
        continue;
      }

      const s: ImageSpanStyle = style as ImageSpanStyle;
      const start: number = s.start;
      const length: number = s.length;
      const attachment: ImageAttachment = s.styledValue;
      if (!(length > 0) || !attachment || !attachment.size) {
        continue;
      }

      // 以图片原始像素尺寸为基准，重算到 vp，确保变宽时可以恢复到原始大小
      const pixelMap = attachment.value as PixelMap;
      if (!pixelMap) {
        continue;
      }
      const info = pixelMap.getImageInfoSync();
      const origW = uiContext.px2vp(info.size.width);
      const origH = uiContext.px2vp(info.size.height);
      if (!(origW > 0) || !(origH > 0)) {
        continue;
      }

      const targetW = Math.min(origW, displayWidthVp);
      const ratio = targetW / origW;
      const newW = targetW;
      const newH = origH * ratio;

      const currentW = attachment.size.width as number | undefined;
      const currentH = attachment.size.height as number | undefined;
      if (typeof currentW === 'number' && typeof currentH === 'number') {
        // 尽量避免无意义的重复 setStyledString 导致光标闪烁
        if (Math.abs(currentW - newW) < 0.5 && Math.abs(currentH - newH) < 0.5) {
          continue;
        }
      }

      const newAttachment = new ImageAttachment({
        value: attachment.value,
        objectFit: attachment.objectFit,
        size: { width: newW, height: newH },
      });

      styledString.setStyle({
        start,
        length,
        styledKey: StyledStringKey.IMAGE,
        styledValue: newAttachment,
      });
      changed = true;
    }

    if (changed) {
      this.controller.setStyledString(styledString);
    }
  }

  /**
   * 选择图片
   */
  selectImage(uiContext: UIContext, maxWidthVp?: number) {
    const currentImageCount = this.getImageCount();
    if (currentImageCount >= RichEditorController.MAX_IMAGE_COUNT) {
      uiContext.getPromptAction().showToast({
        message: `最多只能插入${RichEditorController.MAX_IMAGE_COUNT}张图片`,
        duration: 1500
      });
      return;
    }

    PickerUtil.selectPhoto({
      maxSelectNumber: 1,
    }).then((uris) => {
      hilog.info(0x0001, 'RichEditor', 'select photo successfully, uris: %{public}s', JSON.stringify(uris));
      this.insertImagesFromUris(uiContext, uris, maxWidthVp);
    });
  }

  /**
   * 拍照：系统相机拍照后，将照片插入当前光标位置
   */
  takePhoto(uiContext: UIContext, maxWidthVp?: number) {
    const ctx = uiContext.getHostContext() as common.UIAbilityContext;
    if (!ctx) {
      hilog.error(0x0001, 'RichEditor', 'takePhoto: UIAbilityContext is null');
      return;
    }

    const mediaTypes: Array<cameraPicker.PickerMediaType> = [cameraPicker.PickerMediaType.PHOTO];
    const profile: cameraPicker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED,
    };

    cameraPicker.pick(ctx, mediaTypes, profile)
      .then((result: cameraPicker.PickerResult) => {
        if (!result || result.resultCode !== 0 ||
          !result.resultUri || result.mediaType !== cameraPicker.PickerMediaType.PHOTO) {
          return;
        }
        hilog.info(0x0001, 'RichEditor', 'take photo successfully, uri: %{public}s', result.resultUri);
        this.insertImagesFromUris(uiContext, [result.resultUri], maxWidthVp);
      }).catch((error: BusinessError) => {
        hilog.error(0x0001, 'RichEditor', 'take photo failed, code: %{public}d, message: %{public}s',
          error.code, error.message);
      });
  }

  /**
   * 从相册选择图片（支持多选，按选择顺序插入）
   */
  selectImages(uiContext: UIContext, maxWidthVp?: number) {
    PickerUtil.selectPhoto({
      isPhotoTakingSupported: false
    }).then((uris) => {
      hilog.info(0x0001, 'RichEditor', 'select images successfully, uris: %{public}s', JSON.stringify(uris));
      this.insertImagesFromUris(uiContext, uris, maxWidthVp);
    });
  }

  private static loadImage(name: string): image.PixelMap {
    let imageSource: image.ImageSource;
    let fileSource = fileIo.openSync(name, fileIo.OpenMode.READ_ONLY);
    try {
      imageSource = image.createImageSource(fileSource.fd);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0001, 'RichEditor', `创建ImageSource失败 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error(`创建ImageSource失败: ${error.message}`);
    }
    return imageSource.createPixelMapSync();
  }
}

interface Range {
  start: number;
  end: number;
}

interface ScanInsertResult {
  insertedImageCount: number;
  pdfCount: number;
  unsupportedCount: number;
}

interface ImageSpanStyle extends SpanStyle {
  start: number;
  length: number;
  styledValue: ImageAttachment;
}