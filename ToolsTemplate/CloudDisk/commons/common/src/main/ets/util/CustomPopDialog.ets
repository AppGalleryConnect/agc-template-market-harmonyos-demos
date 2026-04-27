/**
 * @fileType: common
 * @zhName: 自定义弹框工具类
 */
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { TCLogger } from '../basic/TCLogger';

const TAG: string = 'CustomPopDialog'

// 自定义弹框
export class CustomPopDialog {
  // 上下文
  private ctx: UIContext;
  // 内容
  private contentNode: ComponentContent<Object>;
  // 参数
  private options: promptAction.BaseDialogOptions;

  // 构造函数
  constructor(ctx: UIContext, contentNode: ComponentContent<object>, options: promptAction.BaseDialogOptions) {
    this.ctx = ctx
    this.contentNode = contentNode
    this.options = options
  }

  // 弹出弹框
  public openDialog() {
    this.ctx.getPromptAction()
      .openCustomDialog(this.contentNode, this.options)
      .then(() => {
        TCLogger.info(TAG, 'openDialog completed.')
      })
      .catch((error: BusinessError) => {
        TCLogger.error(TAG, `openDialog error code is ${error.code}, message is ${error.message}`);
      })
  }

  // 关闭弹框
  public closeDialog() {
    this.ctx.getPromptAction()
      .closeCustomDialog(this.contentNode)
      .then(() => {
        TCLogger.info(TAG, 'closeDialog completed.')
      })
      .catch((error: BusinessError) => {
        TCLogger.error(TAG, `closeDialog error code is ${error.code}, message is ${error.message}`);
      })
  }

  // 更新内容
  public updateDialog(options: promptAction.BaseDialogOptions) {
    this.ctx.getPromptAction()
      .updateCustomDialog(this.contentNode, options)
      .then(() => {
        TCLogger.info(TAG, 'updateDialog completed.')
      })
      .catch((error: BusinessError) => {
        TCLogger.error(TAG, `updateDialog error code is ${error.code}, message is ${error.message}`);
      })
  }
}
