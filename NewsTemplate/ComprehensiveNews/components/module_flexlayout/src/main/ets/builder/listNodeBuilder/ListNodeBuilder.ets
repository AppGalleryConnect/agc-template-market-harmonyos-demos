import { getNativeNodeController, NodeControllerFactory } from '../../factory/NativeNodeFactory'
import { JSONObject, LayoutSetting } from '../../model/CommonModel'
import { FlexLayoutBreakPointVM } from '../../model/FlexLayoutBreakPointVM'
import { BreakpointNameEnum, FrameNodeParams } from '../../model/Model'

@Builder
export function ListNodeBuilder(frameNodeParams: FrameNodeParams) {
  ListBuilder({
    articles: frameNodeParams.articles,
    viewLayout: frameNodeParams.viewLayout,
    style: frameNodeParams.style,
    extraInfo: frameNodeParams.extraInfo,
    nodeControllerFactory: frameNodeParams.nodeControllerFactory,
  })
}

@ComponentV2
export struct ListBuilder {
  @Param articles: JSONObject[] = []
  @Param viewLayout: LayoutSetting = new LayoutSetting()
  @Param style: Record<string, string | number> = {}
  @Param extraInfo: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]> = {}
  @Param nodeControllerFactory: NodeControllerFactory = new NodeControllerFactory()
  @Local flexLayoutBreakPointVM: FlexLayoutBreakPointVM | undefined = undefined

  @Computed
  get getLanes() {
    return this.extraInfo?.hotList ?
      FlexLayoutBreakPointVM.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 1 : 2 : 1
  }

  @Builder
  viewVNodeBuilder(children: LayoutSetting [], nativeCardData: JSONObject, scrollIndex: number) {
    if (children) {
      ForEach(children, (item: LayoutSetting, index: number) => {
        if (item.type === 'view') {
          this.viewVNodeBuilder(item.children as LayoutSetting [], nativeCardData, scrollIndex)
        }
        if (item.type === 'native') {
          /*
           * getNativeNodeController函数返回的是本地卡片的FrameNode
           * 将该节点挂载至NodeContainer
           * */
          NodeContainer(getNativeNodeController(this.getUIContext(), {
            type: item.showType,
            nativeCardData: nativeCardData,
            scrollIndex: scrollIndex,
            layout: item,
            extraInfo: this.extraInfo,
          },this.nodeControllerFactory))
        }
      }, (item: LayoutSetting) => JSON.stringify(item))
    }
  }

  @Builder
  viewBuilder(children: LayoutSetting []) {
    List({ space: 12 }) {
      ForEach(this.articles, (item: JSONObject, index: number) => {
        ListItem() {
          this.viewVNodeBuilder(children, item, index)
        }
      }, (item: JSONObject) => JSON.stringify(item.id))
    }
    .lanes(this.getLanes, 16)
  }

  build() {
    this.viewBuilder(this.viewLayout.children as LayoutSetting [])
  }
}
