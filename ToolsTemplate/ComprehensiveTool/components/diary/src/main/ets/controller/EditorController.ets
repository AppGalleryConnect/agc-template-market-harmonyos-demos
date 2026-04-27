import { webview } from '@kit.ArkWeb'
import { TextAlignment } from '../commons/Enum';
import { AlignmentInfo } from '../commons/Interface';
import { HtmlModel } from '../models/HtmlModel';

@ObservedV2
export class EditorController {
  webviewController: webview.WebviewController = new webview.WebviewController();
  @Trace htmlModel: HtmlModel = new HtmlModel();
  // 当前文本是否加粗
  @Trace currentBold: boolean = false;
  // 当前文本是否斜体
  @Trace currentItalics: boolean = false;
  // 当前文本是否有阴影
  @Trace currentShadow: boolean = false;
  // 当前文本是否下划线
  @Trace showUnderline: boolean = false;
  // 当前文本是否有删除线
  @Trace showLineThrough: boolean = false;
  // 显示的拓展工具栏索引号 0-关闭扩展工具栏 1-显示调色盘选项栏 2-显示段落样式选项栏
  @Trace showToolBarIndex: number = 0;
  // 当前文本颜色
  @Trace currentColor: number = 0;
  // 字体大小
  @Trace fontSize: number = 2;
  // 当前段落对齐样式
  @Trace currentAlignment: number = TextAlignment.START;
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
        this.setAlignLeft();
        this.currentAlignment = TextAlignment.START;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_center'),
      click: () => {
        this.setAlignCenter();
        this.currentAlignment = TextAlignment.CENTER;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_right'),
      click: () => {
        this.setAlignRight();
        this.currentAlignment = TextAlignment.END;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_justify'),
      click: () => {
        this.setAlignLeft();
        this.currentAlignment = TextAlignment.JUSTIFY;
        this.showToolBarIndex = 0;
      },
    },
  ];

  @Monitor('htmlModel.htmlContent')
  onHtmlContentChange(monitor: IMonitor) {
    let htmlContent: string = monitor.value()?.now as string
    if (this.htmlModel.initialHtmlContent !== htmlContent) {
      this.htmlModel.undoStack.push(this.htmlModel.initialHtmlContent);
    }
  }

  setInitFontSize(isInitFontSize: boolean) {
    this.webviewController.runJavaScript(`RichEditor.isInitFontSize = ${isInitFontSize};`)
  }

  setNewLine() {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.insertHTML('<br></br>');`)
  }
  setAlignRight() {
    this.webviewController.runJavaScript('RichEditor.setJustifyRight();')
  }
  setAlignCenter() {
    this.webviewController.runJavaScript('RichEditor.setJustifyCenter();')
  }
  setAlignLeft() {
    this.webviewController.runJavaScript('RichEditor.setJustifyLeft();')
  }

  undo() {
    this.webviewController.runJavaScript('RichEditor.undo();')
  }

  redo() {
    this.webviewController.runJavaScript('RichEditor.redo();')
  }

  focus() {
    this.webviewController.runJavaScript('RichEditor.focus();')
  }

  setNoteContent(content: string = '') {
    if(!content) {
      return
    }
    this.webviewController.runJavaScript(`RichEditor.setHtml(${JSON.stringify(content.replace(/%/g, '%25'))});`)
  }

  bold() {
    this.webviewController.runJavaScript('RichEditor.setBold();');
  }

  italic() {
    this.webviewController.runJavaScript('RichEditor.setItalic();');
  }

  underline() {
    this.webviewController.runJavaScript('RichEditor.setUnderline();');
  }

  strikethrough() {
    this.webviewController.runJavaScript('RichEditor.setStrikeThrough();');
  }

  changeFontSize(size: number) {
    this.webviewController.runJavaScript(`RichEditor.setFontSize('${size}');`);
  }

  changeFontColor(color: string) {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.setTextColor('${color}');`)
  }

  changeFontBgColor(color: string) {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.setTextBackgroundColor('${color}');`)
  }

  changeFontName(fontName: string) {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.setFontName('${fontName}');`)
  }


  insertImage(imageUri: string) {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.insertImage('${imageUri}', 'picvision', 'margin-top:10px;max-width:100%;');`)
  }

  insertTable(tableBodyHtml: string) {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.insertTable('${tableBodyHtml}');`)
  }

  insertAudio(audioFileUri: string) {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.insertAudio('${audioFileUri}', 'controls="controls" height="300" style="margin-top:10px;max-width:100%;"');`)
  }

  insertTodo() {
    this.webviewController.runJavaScript('RichEditor.prepareInsert();')
    this.webviewController.runJavaScript(`RichEditor.setTodo('${new Date().getTime()}');`)
  }

  setReadOnly(isReadOnly: boolean) {
    this.webviewController.runJavaScript(`RichEditor.setReadOnly(${isReadOnly});`)
  }

  parseHtmlContent(contentHtml: string): string {
    // 1. 将<br> 或 <br/> 标签替换成 \n
    let text = contentHtml.replace(/<br\s*\/?>/g, '');
    // 2. 使用正则表达式移除所有HTML标签
    text = text.replace(/<\/?[^>]+>/g, '');
    // 3. 解码HTML实体
    text = this.decodeHtmlEntities(text);
    return text;
  }

  // HTML实体解码函数
  decodeHtmlEntities(text: string): string {
    const entities: Map<string, string> = new Map([
      ['&lt;', '<'], ['&gt;', '>'], ['&amp;', '&'],
      ['&quot;', '"'], ['&nbsp;', ' '], ['&copy;', '©']
    // 可以添加更多实体...
    ]);
    entities.forEach((value, key) => {
      text = text.replace(new RegExp(key, 'g'), value);
    });
    return text;
  }
}