import { CanvasViewModel } from '../viewModel/CanvasViewModel'

enum CommonSize {
  HAND_WIDTH = 14,
  EDGE_HEIGHT = 2,
  MIN_WIDTH = 20
}

const TAG = 'CanvasComponent'

@ComponentV2
export struct CanvasComponent {
  @Local canvasViewModel: CanvasViewModel = new CanvasViewModel()
  @Param @Require canvasWidth: number = 0
  @Param @Require canvasHeight: number = 0
  @Param @Require amplitudes: number[] = []

  @Monitor('amplitudes.length')
  amplitudesChange(monitor: IMonitor) {
    this.aboutToAppear()
    //设置抽帧数据
    this.canvasViewModel.setAmplitudes(this.amplitudes)
    //通知线程开始工作
    this.canvasViewModel.startWorker()

  }

  @Param isNeedEdit: boolean = true
  @Local offsetWidth: number = 0
  @Local translateX: number = 0
  //左手柄滑动回调事件
  @Param leftHandleCallBack: (translateX: number, offsetWidth: number) => void =
    (translateX: number, offsetWidth: number) => {
    }
  //右手柄滑动回调事件
  @Param rightHandleCallBack: (translateX: number, offsetWidth: number) => void =
    (translateX: number, offsetWidth: number) => {
    }

  aboutToAppear(): void {
    this.canvasViewModel.init(this.canvasWidth, this.canvasHeight, this.getUniqueId().toString())
    this.offsetWidth = this.canvasWidth
  }

  aboutToDisappear(): void {
    this.canvasViewModel.destroyWoker()
  }

  @Builder
  TextBuilder(i: number) {
    Row() {
      Divider().color('rgba(0,0,0,0.2)').strokeWidth(2).height(12).vertical(true)
    }
    .visibility(this.isNeedEdit ? Visibility.Visible : Visibility.Hidden)
    .width(CommonSize.HAND_WIDTH)
    .height(this.canvasViewModel.editHeight)
    .backgroundColor(this.isNeedEdit ? '#FFFFFF' : Color.White)
    .justifyContent(FlexAlign.Center)
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent | undefined) => {
          if (event) {
            const offsetX = event.offsetX
            if (i < 0) { //左手柄
              this.canvasViewModel.translateX = this.translateX + offsetX
              this.canvasViewModel.editWidth = this.offsetWidth - offsetX
              if (this.canvasViewModel.translateX < 0) { //左手柄超出左边界
                this.canvasViewModel.translateX = 0
                this.canvasViewModel.editWidth = this.offsetWidth + this.translateX
                return
              }
              if (this.canvasViewModel.editWidth < CommonSize.MIN_WIDTH) { //触发最小宽度
                this.canvasViewModel.editWidth = CommonSize.MIN_WIDTH
                this.canvasViewModel.translateX = this.translateX + (this.offsetWidth - CommonSize.MIN_WIDTH)
                return
              }
            }

            if (i > 0) {
              this.canvasViewModel.editWidth = this.offsetWidth + offsetX
              if (this.canvasViewModel.editWidth + this.translateX > this.canvasViewModel.width) {
                this.canvasViewModel.editWidth = (this.canvasViewModel.width - this.translateX)
              }
              // 右手柄往左拉时的最小间距限制
              if (this.canvasViewModel.editWidth < CommonSize.MIN_WIDTH) {
                this.canvasViewModel.editWidth = CommonSize.MIN_WIDTH
              }
            }
          }
        })
        .onActionEnd(() => {
          this.offsetWidth = this.canvasViewModel.editWidth
          this.translateX = this.canvasViewModel.translateX
          if (i < 0) { //左手柄事件
            this.leftHandleCallBack(this.translateX, this.offsetWidth)
          }
          if (i > 0) { //右手柄事件
            this.rightHandleCallBack(this.translateX, this.offsetWidth)
          }
        })
    )
  }

  getFatherWidth() {
    return this.canvasViewModel.editWidth + CommonSize.HAND_WIDTH * 2
  }

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row() {
        Canvas(this.canvasViewModel.context)
          .width(this.canvasViewModel.width).height(this.canvasViewModel.height)
          .backgroundColor('#0A0D1E')
          .onReady(() => {
          })
      }
      .width(this.canvasViewModel.width + CommonSize.HAND_WIDTH * 2)
      .padding({
        top: CommonSize.EDGE_HEIGHT,
        bottom: CommonSize.EDGE_HEIGHT,
        left: CommonSize.HAND_WIDTH,
        right: CommonSize.HAND_WIDTH
      })
      .translate({ x: -this.canvasViewModel.translateX })

      Row() {
        this.TextBuilder(-1)
        Row().width(this.canvasViewModel.editWidth).borderRadius(4)
          .clip(true)
        this.TextBuilder(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(this.canvasViewModel.editHeight)
      .borderWidth({ top: CommonSize.EDGE_HEIGHT, bottom: CommonSize.EDGE_HEIGHT })
      .borderColor(this.isNeedEdit ? '#FFFFFF' : Color.Transparent)
      .borderRadius(4)
      .zIndex(1)
      .clip(true)
    }.margin({ left: -CommonSize.HAND_WIDTH + 1 })
    .translate({ x: this.canvasViewModel.translateX })
    .width(this.getFatherWidth())
  }
}