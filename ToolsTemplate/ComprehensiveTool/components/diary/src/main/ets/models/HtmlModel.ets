import { ImageUtils } from '../utils/ImageUtils';
import { handleTaskPoolDelete } from '../utils/TaskPoolHandle';
import { WindowUtil } from '../utils/WindowUtil';


@ObservedV2
export class HtmlModel {
  @Trace initialHtmlContent: string = ''
  @Trace undoStack: string[] = [];
  @Trace redoStack: string[] = [];
  @Trace htmlContent: string = ''
  @Trace htmlImgSandboxUris: string[] = [];
  htmlMethodList: string[] = ['htmlContentChange', 'undo', 'redo', 'handleTextLength']

  // 内容发生变化
  htmlContentChange(html: string) {
    this.htmlContent = html;
    // 处理图片 删除不在富文本中的图片
    const newImgSrcList: string[] = ImageUtils.findImgSrcList(html);
    handleTaskPoolDelete(this.htmlImgSandboxUris, newImgSrcList)
  }

  // 撤销操作
  undo(currentHtml: string) {
    if (this.undoStack.length > 0) {
      // 当前值放进 redo 栈
      this.redoStack.push(currentHtml);
      this.undoStack.pop();
    }
    if (this.initialHtmlContent === currentHtml) {
      this.undoStack = [];
    }
  }

  // 取消撤销操作
  redo(currentHtml: string) {
    if (this.redoStack.length > 0) {
      // 当前值放进 undo 栈
      this.undoStack.push(currentHtml);
      this.redoStack.pop();
    }
  }

  // 文案超过限制时，提示
  handleTextLength() {
    WindowUtil.uiContext.getPromptAction().showToast({
      message: '已达输入上限',
      alignment: Alignment.Center
    })
  }
}