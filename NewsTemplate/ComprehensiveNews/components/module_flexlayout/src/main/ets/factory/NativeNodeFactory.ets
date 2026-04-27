import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI';
import { JSONObject, LayoutParams, LayoutSetting } from '../model/CommonModel';
import { NodeBuilderRegister } from '../utils/NodeBuilderConfig';

export interface NodeParams {
  type: string
  nativeCardData?: JSONObject
  scrollIndex?: number
  extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[] | Function>
  layout: LayoutSetting
}

export const nodeMap: Map<string, NodeControllerFactory | undefined> = new Map();

/*
 * native卡片工厂函数
 * 用来生成FrameNode节点树
 * */
export class NodeControllerFactory extends NodeController {
  private rootNode: FrameNode | null = null;
  private nativeNode: BuilderNode<[LayoutParams]> | null = null;
  private isRemove: boolean = false;
  private uiContext ?: UIContext;

  makeNode(): FrameNode | null {
    if (this.isRemove) {
      return null;
    }
    if (this.rootNode != null) {
      return this.rootNode;
    }
    return null;
  }

  /*
   * 解除引用关系
   * */
  disposeFrameNode() {
    if (this.rootNode !== null && this.nativeNode !== null) {
      this.nativeNode.dispose()
      this.rootNode.dispose();
    }
  }

  /*
   * 初始化节点信息
   * 通过getRenderNode接口获取FrameNode中的RenderNode
   * */
  initData(uiContext: UIContext, nodeParams: NodeParams) {
    this.uiContext = uiContext;
    this.rootNode = new FrameNode(this.uiContext);
    // 获取到本地卡片的WrappedBuilder
    let buildNode = NodeBuilderRegister.instance.getBuilderNode(nodeParams.type)
    this.nativeNode = new BuilderNode(this.uiContext);
    this.nativeNode.build(buildNode, {
      nativeCardData: nodeParams.nativeCardData,
      currentIndex: nodeParams.scrollIndex,
      layout: nodeParams.layout,
      extraInfo: nodeParams.extraInfo,
    });
    this.rootNode.getRenderNode()?.appendChild(this.nativeNode.getFrameNode()?.getRenderNode());
  }
}

/*
 * 通过baseNode.initData动态加载本地卡片节点，并保存在map中
 * @param uiContext 上下文
 * @param nodeParams 文章信息
 * @param baseNode NodeControllerFactory工厂函数
 * @returns NodeControllerFactory
 * */
export const getNativeNodeController =
  (uiContext: UIContext, nodeParams: NodeParams,
    baseNode: NodeControllerFactory): NodeControllerFactory | undefined => {
    nodeMap.set(nodeParams.type, baseNode);
    baseNode.initData(uiContext, nodeParams);
    return nodeMap.get(nodeParams.type);
  }
