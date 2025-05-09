import { TabSwiperContext } from '../../model/TabSwiperContext';
import { TabsNodeController } from '../TabsNodeController';

@ComponentV2
struct Track {

  @Param
  public ctx: TabSwiperContext = new TabSwiperContext();

  private readonly tabsNodeController = new TabsNodeController(this.ctx);

  build() {
    Scroll() {
      NodeContainer(this.tabsNodeController)
        .width('auto')
        .height('auto')
    }
    .width(this.ctx.attr.trackWidth)
    .height(this.ctx.attr.trackHeight)
    .clip(true)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(this.ctx.attr.trackEdgeEffectMode, this.ctx.attr.trackEdgeEffectOptions)
    .enableScrollInteraction(true)
  }
}

@Builder
export function buildTrack(context: TabSwiperContext) {
  Track({ ctx: context })
}
