/**
 * @usage: 用于提词器应用中的倒计时功能，在开始提词前进行倒计时提醒。组件包含关键数据结构：time（倒计时时长）、timeText（当前显示时间）、
 * countdownTimer（定时器ID）。当timeText为0时触发onFinish回调事件。
 * @layout: 组件采用Stack布局，居中对齐。内部包含一个Row容器，Row内放置Text文本显示倒计时数字。Text文本居中显示，
 * 外层Row设置为圆形背景。整个组件在父容器中居中对齐。
 * @constraints: time参数为必需参数，不允许为负数。倒计时过程中不可暂停或重置。
 * @domain: 工具
 * @zhName: 倒计时组件
 * @fileType: component
 * @isGen: true
 * @component:
 * @modifiable: 倒计时时长可定制
 * @image: screenshot/screenshot01.jpg
 */
@ComponentV2
export struct Countdown {
  @Local countdownTimer: number = -1
  @Local timeText: number = 0
  @Local timeTextList: number[] = []
  @Param @Require time: number = 3;
  @Event onFinish: () => void = () => {
  }

  aboutToAppear(): void {
    this.startCountDown()
  }

  startCountDown() {
    this.timeText = this.time
    for (let i = 0; i <= this.time; i++) {
      this.timeTextList.push(i)
    }
    this.countdownTimer = setInterval(() => {
      if (this.timeText === 0) {
        this.onFinish()
        clearInterval(this.countdownTimer)
      }
      this.timeText -= 1
    }, 1000)
  }

  build() {
    if (this.timeText >= 0) {
      Stack() {
        ForEach(this.timeTextList, (item: number) => {
          Text(item.toString())
            .fontSize(160)
            .height(160)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .visibility(item === this.timeText ? Visibility.Visible : Visibility.Hidden)
            .transition(TransitionEffect.OPACITY.animation({ duration: 500, curve: Curve.Ease }).combine(
              TransitionEffect.scale({ x: 0.3, y: 0.3 })
            ))
        })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Center)
      .backgroundColor('rgba(0,0,0,0.5)')
    }
  }
}
