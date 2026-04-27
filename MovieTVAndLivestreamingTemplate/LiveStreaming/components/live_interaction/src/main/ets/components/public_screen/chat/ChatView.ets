import { SimpleChat } from '../views/NormalChat'
import { BaseChatMessage } from './BaseChatMesage'
import { ChatManager } from './ChatManager'
import { ChatViewVM } from './ChatViewVM'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'ChatView'

@ComponentV2
export struct ChatView {
  @Local vm: ChatViewVM = new ChatViewVM()
  @Param @Require chatMgr: ChatManager
  private scroller: Scroller = new Scroller();
  @Param @Require builder:WrappedBuilder<[BaseChatMessage]>
  @Local scrollForward:NestedScrollMode = NestedScrollMode.SELF_ONLY
  aboutToAppear(): void {
    this.vm = this.chatMgr.getVM()
    this.chatMgr.setScroller(this.scroller)
  }

  @Builder
  overlayBuilder() {
    Stack()
      .height('100%')
      .width('100%')
      .linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向
        colors: [['#00FFFFFF', 0.0], ['#FFFFFFFF', 0.1]] // 数组末尾元素占比小于1时满足重复着色效果
      })
      .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
      .hitTestBehavior(HitTestMode.None)
  }

  build() {
    Stack(){
      List({ space: 10, scroller: this.scroller }) {
        LazyForEach(this.vm.dataSource, (item: BaseChatMessage, index: number) => {
          ListItem() {
            this.builder.builder(item);
          }
        },
          (item: string) => JSON.stringify(item) + Math.random())
      }
      // .stackFromEnd(true)   // api19 设置末尾开始渲染,效果更佳
      .height('100%')
      .width('100%')
      .overlay(this.overlayBuilder())
      .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: this.scrollForward,
        scrollBackward: NestedScrollMode.SELF_ONLY
      })
      .onAppear(()=>{
        this.scroller.scrollEdge(Edge.Bottom)
      })
      .onScrollStop(()=>{
        let mode:string = this.scrollForward === NestedScrollMode.PARENT_FIRST?'parent first':'child first'
        hilog.debug(0x000, TAG, `onScrollStop, before mode:${mode}`)
        if(this.scroller.isAtEnd()){
          this.scrollForward = NestedScrollMode.PARENT_FIRST
        } else {
          this.scrollForward = NestedScrollMode.SELF_ONLY
        }
        let mode1:string = this.scrollForward === NestedScrollMode.PARENT_FIRST?'parent first':'child first'
        hilog.debug(0x000, TAG, `onScrollStop, after mode:${mode1}`)
      })

      if(this.vm.isShowTips){
        Button('有更多消息')
          .height(20)
          .onClick(()=>{
            this.scroller.scrollEdge(Edge.Bottom)
            this.vm.isShowTips = false;
            this.scrollForward = NestedScrollMode.PARENT_FIRST
          })
          .zIndex(100)
          .backgroundColor('#E84026')
      }
    }.alignContent(Alignment.BottomStart)
  }
}