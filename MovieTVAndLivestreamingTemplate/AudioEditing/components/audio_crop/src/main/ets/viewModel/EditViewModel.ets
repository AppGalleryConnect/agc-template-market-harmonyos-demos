import { fileIo } from '@kit.CoreFileKit'
import { WorkerModel } from 'audio_worker/src/main/ets/model/WorkerModel'

const TAG = 'EditViewModel'

/*
 * skipSecond：跳帧系数，降低绘制到画布上的帧数，根据采样率定义实现在buffer上按时间跳帧，最终得到绘制的帧数
 * width:画布宽度，由绘制帧数*每帧占用宽度得到
 * widthPerSec：每秒占用画布宽度，由音频时长/画布宽度得到，实现时间刻度均匀绘制在画布宽度上
 * widthPerScale: 每个时间刻度占用的画布宽度，由secPerScale（刻度占用时长）*widthPerSec得到
 */
const FRAME_PER_WIDTH: number = 2 //每帧所占宽度，用来将帧数均匀绘制在画布上
const SEC_PER_SCALE: number = 5 //每个时间刻度占用时长（秒），用来将刻度均匀绘制在画布上

export const SCALE_FRAME: number = 20 //刻度间隔（该值的倍数显示时间）

@ObservedV2
export class EditViewModel {
  @Trace canvasHeight: number = 300 //画布高度
  @Trace canvasWidth: number = 0 //画布宽度
  @Trace editHeight: number = 56 //画布高度
  pcmPath: string = '' //pcm码文件路径
  channelLayout: number = 0 //声道数量
  sampleRate: number = 0 //采样率（每秒采样帧数）
  duration: number = 0 //音频资源时长(毫秒)
  bytesPerSample = 4 // 固定f32le采样格式 每个采样点字节数（16位=2字节）
  bytesPerFrame = 0 //每帧字节数，根据采样格式的采样点字节数*声道数量
  @Trace amplitudes: number[] = [] //降频归一化后的音频振幅
  @Trace scales: number[] = [] //时间刻度数组
  @Trace widthPerScale: number = 0 //每个刻度占用画布宽度，根据单位刻度占用时长（秒）*单位时长占用画布宽度得到
  @Trace playStatus: boolean = false //音频播放状态
  @Trace playTime: number = 0 //播放时长(秒)
  size: number = 0 //音频大小（字节）
  playLength: number = 0 //播放长度
  scroller?: Scroller
  workerModel: WorkerModel | undefined = undefined

  /*初始化参数*/
  initProps(pcmPath: string, channelLayout: number, sampleRate: number, duration: number) {
    this.pcmPath = pcmPath
    this.channelLayout = channelLayout
    this.sampleRate = sampleRate
    this.duration = duration
    this.bytesPerFrame = this.bytesPerSample * this.channelLayout
  }

  /*
   * 计算每个刻度占用画布宽度，由secPerScale（刻度占用时长）*widthPerSec得到
   */
  setWidthPerScale() {
    //每秒占用多长的画布宽度
    const widthPerSec = this.canvasWidth / this.duration * 1000
    this.widthPerScale = SEC_PER_SCALE * widthPerSec
  }

  /*
   * 根据音频时长/每个刻度占用的时长（秒），得到刻度数组
   */
  setScales() {
    if ((this.duration / 1000) > (3600 + 30)) {
      return
    }
    //刻度数量向下取整，超出不足单位刻度部分不考虑
    const count = Math.ceil(this.duration / 1000 / SEC_PER_SCALE)
    for (let i = 0; i < count; i++) {
      this.scales.push(i * SEC_PER_SCALE)
    }
  }

  setScroller(scroller: Scroller) {
    this.scroller = scroller
  }

  /*
   * 初始化参数
   * 启用线程执行抽帧任务
   */
  init(pcmPath: string, channelLayout: number, sampleRate: number, duration: number) {
    this.initProps(pcmPath, channelLayout, sampleRate, duration)
    this.setScales()
    const stat = fileIo.statSync(this.pcmPath)
    this.size = stat.size
    this.workerModel = new WorkerModel()
    this.workerModel.messageHandle = this.messageHandle
    // 发送消息给Worker线程
    this.workerModel.workerInstance?.postMessage({
      action: 'amplitudes',
      workerId: 'EditViewModel',
      params: JSON.stringify({
        bytesPerFrame: this.bytesPerFrame,
        sampleRate: this.sampleRate,
        pcmPath: this.pcmPath,
        size: this.size,
        channelLayout: this.channelLayout,
        bytesPerSample: this.bytesPerSample
      })
    });
  }

  messageHandle = (data: string) => {
    this.amplitudes = JSON.parse(data) as number[]
    this.canvasWidth = this.amplitudes.length * FRAME_PER_WIDTH
    this.setWidthPerScale()
    //任务结束，销毁线程
    this.destroyWoker()
  }

  /*
   * 销毁线程
   */
  destroyWoker() {
    //任务结束，销毁线程
    this.workerModel?.terminateWorker()
    this.workerModel = undefined
  }

  getFormatTime(totalSeconds: number) {
    // 处理异常值：负数转为0，非数字转为0
    const sec = Math.max(Math.floor(Number(totalSeconds) || 0), 0);
    // 计算分钟和剩余秒数
    const minutes = Math.floor(sec / 60);
    const seconds = sec % 60;
    // 补零函数：确保数字为两位
    const padZero = (num: number) => num.toString().padStart(2, '0');
    return `${padZero(minutes)}:${padZero(seconds)}`;
  }

  //快进快退
  skipSecond(second: number) {
    let tempPlayTime = this.playTime + second
    if (tempPlayTime < 0) { //小于0
      tempPlayTime = 0
    }
    if (tempPlayTime > (this.duration / 1000)) { //超出音频时长
      tempPlayTime = this.duration / 1000
    }
    this.setPlayTime(tempPlayTime)
  }

  scollerTo(xOffset: number) {
    this.scroller?.scrollTo({ xOffset: xOffset, yOffset: 0, animation: false })
  }

  //执行滚动
  startScroll() {
    const velocity = this.canvasWidth / (this.duration / 1000)
    this.scroller?.scrollEdge(Edge.End, { velocity: velocity });
  }

  //停止滚动
  stopScroll() {
    this.scroller?.fling(0.1)
  }

  //获取画布滚动距离对应的播放时间
  getXoffsetOfTime(xOffset: number) {
    return Math.floor(this.duration / 1000 * (xOffset / this.canvasWidth))
  }

  setPlayTime(second: number) {
    this.playTime = second
  }

  onDurationCallBack = (bufferSize: number) => {
    this.playLength = bufferSize
    const tempTime = this.duration * (this.playLength / this.size) / 1000
    if (Math.floor(tempTime) !== this.playTime) {
      this.setPlayTime(Math.floor(tempTime))
    }
  }
  stopCallBack = () => {
    this.setPlayTime(0)
    this.playStatus = false //复位播放状态
    this.playLength = 0 //播放长度归0
    this.scollerTo(0) //滚动条复位
  }
}