import { BuilderNode, NodeController } from '@kit.ArkUI';
import Logger from './Logger';

const TAG = '[PipUINodeController]';

/**
 * 画中画自定义UI控制器
 */
export class PipUINodeController extends NodeController {
  private message: string = '';
  private visible: boolean = false;
  private node: BuilderNode<[PipUIParams]> | null = null;

  /**
   * 设置文本
   * @param message
   */
  public setMessage(message: string) {
    this.message = message;
  }

  /**
   * 设置显隐状态
   * @param visible
   */
  public setVisible(visible: boolean) {
    this.visible = visible;
  }

  /**
   * 通过BuilderNode加载自定义布局
   * @param context
   * @returns
   */
  public makeNode(context: UIContext): FrameNode | null {
    this.node = new BuilderNode(context);
    this.node.build(wrapBuilder<[PipUIParams]>(pipUIBuilder), new PipUIParams(this.message, this.visible));
    return this.node.getFrameNode();
  }

  /**
   * 更新布局
   * @param message
   */
  public update() {
    Logger.info(TAG, `update message: ${this.message}, visible: ${this.visible}`);
    if (this.node !== null) {
      this.node.update(new PipUIParams(this.message, this.visible));
    }
  }

  /**
   * 注销布局
   */
  public dispose() {
    Logger.info(TAG, 'dispose message: execute node dispose');
    if (this.node !== null) {
      this.node.dispose();
    }
  }
}

export class PipUIParams {
  public text: string = '';
  public isShow: boolean = false;

  constructor(text: string, isShow: boolean) {
    this.text = text;
    this.isShow = isShow;
  }
}

@Builder
export function pipUIBuilder(params: PipUIParams) {
  Column() {
    Text(params.text)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_on_primary'))
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('sys.color.mask_tertiary'))
  .visibility(params.isShow ? Visibility.Visible : Visibility.Hidden)
}