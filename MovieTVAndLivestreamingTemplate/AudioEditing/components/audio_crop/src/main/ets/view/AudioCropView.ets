import { CanvasComponent } from '../components/CanvasComponent'
import { ScaleComponent } from '../components/ScaleComponent'
import { getDisplayWidthOfVp } from '../utils/CommonUtil'
import { PCMPlayer, PlayCallBack } from 'audio_common'
import { EditViewModel } from '../viewModel/EditViewModel'


const TAG = 'AudioEditPage'
const SKIP_SECOND = 5
const LEFT_WIDTH = getDisplayWidthOfVp() / 2

@ComponentV2
export struct AudioCropView {
  @Local editViewModel: EditViewModel = new EditViewModel()
  private pcmPlayer?: PCMPlayer
  scroller: Scroller = new Scroller()
  //该宽度用来增加scroll宽度，解决画布无法滑动到右侧边缘的问题
  rightWidth = getDisplayWidthOfVp() - LEFT_WIDTH
  @Local startTime: number = 0 //剪裁起始时间/秒
  @Local endTime: number = 0 //剪裁结束时间/秒
  @Param @Require musicTitle: string //音频名称
  @Param @Require pcmPath: string //pcm文件路径
  @Param @Require channelLayout: number //声道数量
  @Param @Require sampleRate: number //采样率
  @Param @Require duration: number //音频时长（毫秒）
  @Param @Require onChange: (startTime: number, endTime: number) => void //音频时长（毫秒）
  //左手柄滑动回调事件
  leftHandleCallBack = (translateX: number, offsetWidth: number) => {
    let tempSize = (translateX / this.editViewModel.canvasWidth) * this.editViewModel.size
    this.pcmPlayer?.setStartSize(tempSize)
    this.startTime = ((translateX / this.editViewModel.canvasWidth) * this.duration) / 1000;
    this.onChange(this.startTime, this.endTime)
  }
  //右手柄滑动回调事件
  rightHandleCallBack = (translateX: number, offsetWidth: number) => {
    let tempSize = ((translateX + offsetWidth) / this.editViewModel.canvasWidth) * this.editViewModel.size
    this.pcmPlayer?.setMaxSize(tempSize)
    this.endTime = (((translateX + offsetWidth) / this.editViewModel.canvasWidth) * this.duration) / 1000
    this.onChange(this.startTime, this.endTime)
  }
  stopCallBack = () => {
    this.pcmPlayer?.resetBufferSize()
    this.editViewModel.stopCallBack()
  }

  aboutToAppear(): void {
    this.endTime = this.duration / 1000;
    const playCallBack: PlayCallBack = {
      onDurationCallBack: this.editViewModel.onDurationCallBack,
      stopCallBack: this.stopCallBack
    }
    this.pcmPlayer = new PCMPlayer(this.pcmPath, this.sampleRate, this.channelLayout, 4)
    this.pcmPlayer.initCallBack(playCallBack)
    this.pcmPlayer.init()

    this.editViewModel.setScroller(this.scroller)
    this.editViewModel.init(this.pcmPath, this.channelLayout, this.sampleRate, this.duration)
  }

  aboutToDisappear(): void {
    this.pcmPlayer?.stop()
    this.pcmPlayer?.release()
    this.editViewModel.destroyWoker()
  }

  skip(skipSecond: number, isScrollTo = true) {
    //处理音频跳帧播放
    const skipBuffer =
      skipSecond * this.editViewModel.sampleRate * this.editViewModel.channelLayout * this.editViewModel.bytesPerSample
    this.pcmPlayer?.skipPlay(skipBuffer, this.editViewModel.size)

    //处理播放时间跳帧
    this.editViewModel.skipSecond(skipSecond)
    //滚动scroll
    if (isScrollTo) {
      const xOffset =
        this.editViewModel.playTime * (this.editViewModel.canvasWidth / (this.editViewModel.duration / 1000))
      this.editViewModel.scollerTo(xOffset)
    }
    //保持画布滚动状态
    if (this.editViewModel.playStatus) {
      this.editViewModel.startScroll()
    }
  }

  build() {
    Column() {
      Row() {
        Divider()
          .vertical(true)
          .width(1)
          .height(300)
          .borderStyle(BorderStyle.Dashed)
          .borderWidth({ left: 1 })
          .borderColor('#99FFFFFF')
          .position({ x: LEFT_WIDTH, y: 32 })
          .zIndex(1)

        Divider()
          .vertical(true)
          .width(1)
          .height(214)
          .borderWidth({ left: 1 })
          .borderColor('#99FFFFFF')
          .position({ x: LEFT_WIDTH, y: 423 })
          .zIndex(1)

        Row() {
          Row() {
            Image(this.editViewModel.playStatus ? $r('app.media.ic_play_status') : $r('app.media.ic_pause_status'))
              .width(24).height(24).margin({ left: 16 })
              .onClick(() => {
                if (this.editViewModel.playStatus) {
                  this.pcmPlayer?.pause()
                  this.editViewModel.stopScroll()
                } else {
                  this.pcmPlayer?.start()
                  this.editViewModel.startScroll()
                }
                this.editViewModel.playStatus = !this.editViewModel.playStatus
              })
          }.width(LEFT_WIDTH)
          .justifyContent(FlexAlign.Start)

          Row() {
            Image($r('app.media.ic_sub_white')).width(16).height(16)
              .onClick(() => {
                this.skip(-SKIP_SECOND)
              })
            Text(this.editViewModel.getFormatTime(this.editViewModel.playTime))
              .fontSize(14).fontColor('#FFFFFF')
            Image($r('app.media.ic_add_white')).width(16).height(16)
              .onClick(() => {
                this.skip(SKIP_SECOND)
              })
          }.width(110).justifyContent(FlexAlign.SpaceBetween)
          .translate({ x: -55 })
        }
        .height(24)
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .position({ x: 0, y: 348 })
        .zIndex(1)

        Scroll(this.scroller) {
          Row() {
            Blank().width(LEFT_WIDTH)
            Column() {
              Row() {
                ForEach(this.editViewModel.scales, (item: number) => {
                  ScaleComponent({
                    scaleVal: item
                  })
                    .width(this.editViewModel.widthPerScale)
                },(item: number)=>item.toString())
              }.justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Top)

              CanvasComponent({
                amplitudes: this.editViewModel.amplitudes,
                canvasWidth: this.editViewModel.canvasWidth,
                canvasHeight: this.editViewModel.canvasHeight,
                isNeedEdit: false
              }).margin({ top: 15 })
              Column() {
                List() {
                  ListItem() {
                    Column() {
                      Row() {
                        Image($r('app.media.ic_music')).width(12).height(12)
                        Text(this.musicTitle)
                          .margin({ left: 6 })
                          .fontSize(10)
                          .fontColor('#FFFFFF')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .wordBreak(WordBreak.BREAK_ALL)
                          .layoutWeight(1)
                      }
                      .padding({
                        left: 6,
                        top: 4,
                        right: 6,
                        bottom: 4
                      })
                      .backgroundColor('#19FFFFFF')
                      .margin({ bottom: 4 })
                      .borderRadius(4)
                      .constraintSize({ maxWidth: this.editViewModel.canvasWidth })

                      CanvasComponent({
                        amplitudes: this.editViewModel.amplitudes,
                        canvasWidth: this.editViewModel.canvasWidth,
                        canvasHeight: this.editViewModel.editHeight,
                        leftHandleCallBack: this.leftHandleCallBack,
                        rightHandleCallBack: this.rightHandleCallBack
                      })
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                }
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
                .scrollBar(BarState.Off)
                .clip(false)
              }.margin({ top: 96 })
              .alignItems(HorizontalAlign.Start)
            }.alignItems(HorizontalAlign.Start)
            .width(this.editViewModel.canvasWidth + this.rightWidth)
          }
          .height('100%')
          .alignItems(VerticalAlign.Top)
        }
        .height('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .onScrollStop(() => {
          let xOffset = this.scroller?.currentOffset().xOffset
          if (xOffset > this.editViewModel.canvasWidth) { //拖动距离不能超过画布宽度
            xOffset = this.editViewModel.canvasWidth
          }
          const tempTime = this.editViewModel.getXoffsetOfTime(xOffset)
          const subTime = tempTime - this.editViewModel.playTime
          if (Math.abs(subTime) > 1) { //大于是解决快进快退触发stop事件
            this.skip(subTime, false) //此行为画布无需在scrollTo，否则会引起函数循环跳转
          }
        })

      }.padding({ top: 16 })
      .height('100%')
    }.layoutWeight(1)
  }
}