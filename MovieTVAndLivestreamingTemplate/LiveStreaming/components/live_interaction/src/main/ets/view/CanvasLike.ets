import { CanvasViewModel } from '../viewModels/CanvasViewModel'

@ComponentV2
export struct CanvasLike {
  @Event onLike:Function=()=>{}
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private viewModel: CanvasViewModel = new CanvasViewModel()
  private longPressIntervalId: number | null = null // 用于存储长按定时器ID
  private lastPanUpdate: number = 0 // 记录上一次更新点赞效果的时间
  @Local isLongPressActive: boolean = false // 标记长按是否激活

  aboutToAppear(): void {
  }
  aboutToDisappear() {
    this.viewModel.stopAnimation()
    if (this.longPressIntervalId !== null) {
      clearInterval(this.longPressIntervalId)
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {


        Canvas(this.context)
          .width('100%')
          .height('100%')
          .onReady(() => {
            this.viewModel.startAnimation(this.context)
          })// 使用手势组来同时监听双击、长按和拖动事件
          .gesture(
            GestureGroup(GestureMode.Parallel,
              TapGesture({ count: 2 })
                .onAction((event: GestureEvent) => {
                  const x = event.fingerList[0].localX
                  const y = event.fingerList[0].localY
                  this.viewModel.addLikeIcon(x, y)
                  this.onLike();
                }),
              GestureGroup(GestureMode.Parallel,
                LongPressGesture()
                  .onAction((event: GestureEvent) => {
                    const x = event.fingerList[0].localX
                    const y = event.fingerList[0].localY
                    this.handleLongPress(x, y)
                    this.isLongPressActive = true
                  })
                  .onActionEnd(() => {
                    this.stopLongPressHandler()
                    this.isLongPressActive = false
                  }),
                PanGesture({ direction: PanDirection.All, distance: 10 })
                  .onActionStart((event: GestureEvent) => {
                    if (this.isLongPressActive) {
                      // 停止长按定时器
                      this.stopLongPressHandler()
                      const x = event.fingerList[0].localX
                      const y = event.fingerList[0].localY
                      this.viewModel.addLikeIcon(x, y)
                      this.onLike();
                      this.lastPanUpdate = Date.now()
                    }
                  })
                  .onActionUpdate((event: GestureEvent) => {
                    if (this.isLongPressActive) {
                      const currentTime = Date.now()
                      if (currentTime - this.lastPanUpdate > 500) { // 设置最小更新间隔为500毫秒
                        const x = event.fingerList[0].localX
                        const y = event.fingerList[0].localY
                        this.viewModel.addLikeIcon(x, y)
                        this.onLike();
                        this.lastPanUpdate = currentTime
                      }
                    }
                  })
                  .onActionEnd(() => {
                    this.stopLongPressHandler()
                    this.isLongPressActive = false
                  })
              )
            )
          )
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea()
  }

  // 处理长按事件，启动定时器
  handleLongPress(x: number, y: number) {
    if (this.longPressIntervalId) {
      clearInterval(this.longPressIntervalId)
    }
    this.longPressIntervalId = setInterval(() => {
      this.viewModel.addLikeIcon(x, y)
      this.onLike();
    }, 500)
  }

  // 停止长按事件处理
  stopLongPressHandler() {
    if (this.longPressIntervalId !== null) {
      clearInterval(this.longPressIntervalId)
      this.longPressIntervalId = null
    }
  }
}