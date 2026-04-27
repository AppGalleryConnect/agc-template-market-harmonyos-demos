/**
 * 自定义音频进度条组件
 */
@ComponentV2
export struct CustomProgressBar {
  @Param currentTime: number = 0
  @Param duration: number = 0
  @Param onSeek: (time: number) => void = () => {
  }
  private isDragging: boolean = false
  private barWidth: number = 0
  private barHeight: number = 2
  private thumbSize: number = 12

  build() {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        // 背景轨道
        Row()
          .width('100%')
          .height(this.barHeight)
          .backgroundColor('rgba(255,255,255,0.2)')
          .borderRadius(this.barHeight / 2)

        // 已播放进度（渐变）
        Row()
          .width(this.getProgressWidth())
          .height(this.barHeight)
          .borderRadius(this.barHeight / 2)
          .linearGradient({
            angle: 90,
            colors: [
              ['#C707FF', 0.0],
              ['#01FCEA', 1.0]
            ]
          })

        // 拖动圆点
        Circle()
          .width(this.thumbSize)
          .height(this.thumbSize)
          .fill('#FFFFFF')
          .margin({ left: this.getThumbPosition() })
      }
      .height(50)
      .layoutWeight(1)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.barWidth = Number(newValue.width)
      })
      .gesture(
        GestureGroup(GestureMode.Parallel,
          // 点击手势
          TapGesture()
            .onAction((event: GestureEvent) => {
              if (this.duration > 0 && this.barWidth > 0) {
                const x = event.fingerList[0].localX
                const progress = Math.max(0, Math.min(1, x / this.barWidth))
                const seekTime = progress * this.duration
                this.onSeek(seekTime)
              }
            }),
          // 拖动手势
          PanGesture()
            .onActionStart(() => {
              this.isDragging = true
            })
            .onActionUpdate((event: GestureEvent) => {
              if (this.duration > 0 && this.barWidth > 0) {
                const x = event.fingerList[0].localX
                const progress = Math.max(0, Math.min(1, x / this.barWidth))
                const seekTime = progress * this.duration
                this.onSeek(seekTime)
              }
            })
            .onActionEnd(() => {
              this.isDragging = false
            })
        )
      )
    }
    .width('100%')
  }

  // 计算进度条宽度
  private getProgressWidth(): string {
    if (this.duration <= 0) {
      return '0%'
    }
    const progress = Math.max(0, Math.min(1, this.currentTime / this.duration))
    return `${progress * 100}%`
  }

  // 计算圆点位置
  private getThumbPosition(): number {
    if (this.duration <= 0 || this.barWidth <= 0) {
      return 0
    }
    const progress = Math.max(0, Math.min(1, this.currentTime / this.duration))
    return progress * this.barWidth - this.thumbSize / 2
  }
}
