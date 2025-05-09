import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI';
import { WindowUtils } from 'common';

export class TextNodeController extends NodeController {
  private rootNode: FrameNode | null = null;
  private isAppear: boolean = false;

  makeNode(uiContext: UIContext): FrameNode {
    this.rootNode = new FrameNode(uiContext)
    if (this.rootNode == null) {
      return this.rootNode
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      renderNode.frame = {
        x: 0,
        y: 0,
        width: WindowUtils.getWindowWidth(),
        height: WindowUtils.getWindowHeight()
      }
    }

    return this.rootNode
  }

  aboutToAppear(): void {
    // 根节点渲染时，加载首页，通知
    console.log('read node is appear')
    this.isAppear = true;
  }

  aboutToDisappear(): void {
    console.log('read node is disappear')
    this.isAppear = false;
    this.clearNodes();
  }

  addNode(node: RenderNode): void {
    if (this.rootNode == null) {
      return
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      renderNode.appendChild(node);
    }
  }

  clearNodes(): void {
    if (this.rootNode == null) {
      return
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      renderNode.clearChildren()
    }
  }

  getNodeStatus(): boolean {
    return this.isAppear;
  }

  getRenderNode(): RenderNode | undefined {
    if (this.rootNode == null) {
      return undefined
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      return renderNode;
    }

    return undefined
  }
}