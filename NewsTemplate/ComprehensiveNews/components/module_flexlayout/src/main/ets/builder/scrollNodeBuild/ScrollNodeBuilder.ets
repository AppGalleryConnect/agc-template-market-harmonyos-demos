import { getNativeNodeController, NodeControllerFactory } from '../../factory/NativeNodeFactory'
import { JSONObject, LayoutSetting } from '../../model/CommonModel'
import { FrameNodeParams} from '../../model/Model'


@Builder
export function ScrollNodeBuilder(frameNodeParams: FrameNodeParams) {
  ScrollBuilder({
    articles: frameNodeParams.articles,
    scrollLayout: frameNodeParams.viewLayout,
    style: frameNodeParams.style,
    extraInfo:frameNodeParams.extraInfo
  })
}

@ComponentV2
export struct ScrollBuilder {
  @Param articles: JSONObject[] = []
  @Param scrollLayout: LayoutSetting = new LayoutSetting()
  @Local nativeLeft: number = 0
  @Param style: Record<string, string | number> = {}
  @Param extraInfo: Record<string, number | string | boolean | Function | Record<string, string | boolean>[]> = {}
  @Local nodeControllerFactory: NodeControllerFactory = new NodeControllerFactory()
  @Builder
  scrollVNodeBuilder(children: LayoutSetting [], nativeCardData: JSONObject, scrollIndex: number) {
    if (children) {
      ForEach(children, (item: LayoutSetting, index: number) => {
        if (item.type === 'view') {
          Column() {
            this.scrollVNodeBuilder(item.children as LayoutSetting [], nativeCardData, scrollIndex)
          }
        }
        if (item.type === 'native') {
          NodeContainer(getNativeNodeController(this.getUIContext(), {
            type: item.showType,
            nativeCardData: nativeCardData,
            scrollIndex: scrollIndex,
            layout: item,
            extraInfo:this.extraInfo
          },this.nodeControllerFactory))
        }
      }, (item: LayoutSetting) => JSON.stringify(item))
    }
  }

  @Builder
  scrollBuilder(children: LayoutSetting []) {
    List({ space: this.style.space, initialIndex: 0 }) {
      ForEach(this.articles, (item: JSONObject, index: number) => {
        ListItem() {
          this.scrollVNodeBuilder(children, item, index)
        }
      }, (item: JSONObject) => JSON.stringify(item))
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }

  build() {
    this.scrollBuilder(this.scrollLayout.children as LayoutSetting [])
  }
}
