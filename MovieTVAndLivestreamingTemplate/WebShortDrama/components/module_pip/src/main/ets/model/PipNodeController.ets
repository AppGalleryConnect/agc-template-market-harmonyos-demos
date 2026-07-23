import { BuilderNode, FrameNode, NodeController, typeNode } from '@kit.ArkUI';
import { PipManager } from './PipManager';

const TAG = 'XCNodeController';

// 创建自定义NodeController
export class PipNodeController extends NodeController {
  xComponent: typeNode.XComponent| null = null;
  private node: FrameNode | null = null;
  private canAddNode: boolean = true;

  // 设置是否可以添加节点
  setCanAddNode(canAddNode: boolean) {
    this.canAddNode = canAddNode;
  }

  // 实现makeNode方法，当自定义NodeController被添加到布局时，该方法会被调用
  makeNode(context: UIContext): FrameNode | null {
    console.info(TAG, 'makeNode');
    this.node = new FrameNode(context);
    try {
      if (this.xComponent === null || this.xComponent === undefined) {
        // 创建XComponent类型的typeNode
        this.xComponent = typeNode.createNode(context, 'XComponent', {
          type: XComponentType.SURFACE, // 类型设置为SURFACE
          controller: PipManager.getInstance().getXComponentController(), // 设置XComponentController
        });
      }
      if (this.canAddNode) {
        try {
          this.xComponent.getParent()?.removeChild(this.xComponent);
        } catch (error) {
          console.error(TAG, 'Failed to removeChild');
        }
        try {
          this.node.appendChild(this.xComponent);
        } catch (error) {
          console.error(TAG, 'Failed to appendChild');
        }
      }
    } catch (e) {
    }
    return this.node;
  }

  // 重新添加typeNode节点
  addNode() {
    if (this.node !== null && this.node !== undefined) {
      console.info(TAG, 'addNode id:'+(this.node?.getUniqueId())+' '+this.xComponent?.getUniqueId());
      try {
        this.node.appendChild(this.xComponent);
      } catch (error) {
        console.error(TAG, 'Failed to appendChild');
      }
    }
  }

  // 移除typeNode节点
  removeNode() {
    if (this.node !== null && this.node !== undefined) {
      console.info(TAG, 'removeNode');

      try {
        this.node.removeChild(this.xComponent);
      } catch (error) {
        console.error(TAG, 'Failed to removeChild');
      }
    }
  }

  getNode(): typeNode.XComponent | null {
    console.info(TAG, 'getNode is null:'+ (this.xComponent === null || this.xComponent === undefined))
    return this.xComponent;
  }
}