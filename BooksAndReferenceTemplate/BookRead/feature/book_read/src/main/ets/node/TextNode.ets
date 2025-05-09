import { RenderNode } from '@kit.ArkUI';
import { WindowUtils } from 'common';
import { EpubParser } from 'parse';

export class NativeTextNode extends RenderNode {
  private pageNum: number
  private name: string

  constructor(pageNum: number, name: string) {
    super();
    this.pageNum = pageNum;
    this.name = name;
    this.frame = {
      x: 20,
      y: 20,
      width: WindowUtils.getWindowWidth(),
      height: WindowUtils.getWindowHeight()
    };
  }

  async draw(context: DrawContext) {
    // 直接调用 native 层绘制
    EpubParser.drawEpubPage(this.name, this.pageNum, context);
  }
}