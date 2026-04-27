import { BuilderNode, FrameNode, NodeController, typeNode } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { FrameNodeParams } from '../model/Model';
import { ScrollNodeBuilder } from '../builder/scrollNodeBuild/ScrollNodeBuilder';
import { ListNodeBuilder } from '../builder/listNodeBuilder/ListNodeBuilder';
import { getNativeNodeController, NodeControllerFactory } from './NativeNodeFactory';
import { transformLayout } from '../utils/Utils';
import { JSONObject, LayoutSetting } from '../model/CommonModel';

const TAG = '[FrameNodeFactory]';

export const nodeMap: Map<string | number, BuilderNode<[FrameNodeParams]> | undefined> = new Map();

const nodeControllerFactory: NodeControllerFactory = new NodeControllerFactory()

export function setNodeMap(extraInfo: Record<string, number | string | boolean
  | Function | Record<string, string | boolean>[]>,
  nativeNode: BuilderNode<[FrameNodeParams]>) {
  let flowIndex = extraInfo.flowIndex as number
  if (!nodeMap.get(flowIndex)) {
    nodeMap.set(flowIndex, nativeNode)
  }
}

/*
 * 通过递归DSL，拿到布局信息，生成FrameNode节点
 * 根据布局信息中的节点映射成原生节点
 * view -> Column
 * Swiper -> Swiper
 * List -> List
 * Scroll -> Scroll
 * native -> 动态渲染实际的业务卡片
 * */

export function FrameNodeFactory(vm: LayoutSetting, articles: JSONObject[],
  extraInfo: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]>,
  context: UIContext): FrameNode | null {

  try {
    if (vm.type === 'view') {
      let node = typeNode.createNode(context, 'Column');
      setColumnNodeAttr(node, vm.style);
      vm.children?.forEach(kid => {
        let child = FrameNodeFactory(kid, articles, extraInfo, context);
        node.appendChild(child);
      });
      return node;
    }
    if (vm.type === 'Swiper') {
      let node = typeNode.createNode(context, 'Swiper');
      vm.children?.forEach(kid => {
        let child = FrameNodeFactory(kid, articles, extraInfo, context);
        node.appendChild(child);
      });
      return node;
    }
    if (vm.type === 'Scroll') {
      let node = typeNode.createNode(context, 'Column');
      setColumnNodeAttr(node, vm.style);
      let nativeNode: BuilderNode<[FrameNodeParams]> = new BuilderNode(context);
      nativeNode.build(wrapBuilder<[FrameNodeParams]>(ScrollNodeBuilder),
        new FrameNodeParams(vm, articles, vm.style, extraInfo, nodeControllerFactory));
      return nativeNode.getFrameNode()
    }
    if (vm.type === 'List') {
      let node = typeNode.createNode(context, 'Column');
      setColumnNodeAttr(node, vm.style);
      let nativeNode: BuilderNode<[FrameNodeParams]> = new BuilderNode(context);
      // List Scroll Swiper等特殊节点 通过暴露Builder在内部做进一步处理
      nativeNode.build(wrapBuilder<[FrameNodeParams]>(ListNodeBuilder),
        new FrameNodeParams(vm, articles, vm.style, extraInfo, nodeControllerFactory));
      node.appendChild(nativeNode.getFrameNode())
      // 保存组件的节点信息，方便后续对节点的解除引用以及上下树做处理
      setNodeMap(extraInfo, nativeNode)
      return node
    }
    if (vm.type === 'native') {
      let node = typeNode.createNode(context, 'Column');
      setColumnNodeAttr(node, vm.style);
      /*
       * 渲染本地native卡片
       * */
      node.appendChild(getNativeNodeController(context, {
        type: vm.showType,
        extraInfo: extraInfo,
        layout: vm,
        nativeCardData: articles,
      }, nodeControllerFactory)?.makeNode());
      return node;
    }
    return null;
  } catch (e) {
    UtilLog.error(TAG, ' fail, error: ' + JSON.stringify(e));
    return null;
  }
}

/*
 * 通过动态属性添加布局文件的样式
 * */
function setColumnNodeAttr(node: typeNode.Column, style: Record<string, string | number>) {
  node.attribute.borderRadius(transformLayout(style)?.borderRadius)
  node.attribute.backgroundColor($r(`app.sys.${style?.backgroundColor}`))
  node.attribute.padding({
    left: transformLayout(style)?.paddingLeft,
    top: transformLayout(style)?.paddingTop,
    bottom: transformLayout(style)?.paddingBottom,
    right: transformLayout(style)?.paddingRight,
  })
  node.attribute.margin({
    top: transformLayout(style)?.marginTop,
  })
  if (style?.width) {
    node.attribute.width(style.width)
  }
  if (style?.height) {
    node.attribute.height(style.height)
  }
}

export class FrameController extends NodeController {
  setting: LayoutSetting = new LayoutSetting()
  articles: JSONObject[] = []
  extraInfo: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]> = {}
  private rootNode: FrameNode | null = null;

  /*
   * 初始化值
   * @param setting  布局信息文件DSL
   * @param articles 文章详情字段
   * @param extraInfo 额外自定义字段
   * */
  initFrameNode(setting: LayoutSetting, articles: JSONObject[],
    extraInfo: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]>): void {
    this.setting = setting
    this.articles = articles
    this.extraInfo = extraInfo
  }

  /*
   * 解除引用关系，释放节点
   * */
  disposeFrameNode(): void {
    let flowIndex = this.extraInfo.flowIndex as number
    if (this.rootNode !== null && nodeMap.get(flowIndex)) {
      this.rootNode.dispose();
      nodeMap.get(flowIndex)?.dispose()
      nodeControllerFactory.disposeFrameNode()
    }
  }

  /*
   * 通过makeNode回调返回FrameNode节点树的根节点
   * @returns FrameNode
   * */
  makeNode(uiContext: UIContext): FrameNode | null {
    this.rootNode = FrameNodeFactory(this.setting, this.articles, this.extraInfo, uiContext);
    return this.rootNode
  }
}