import { fileIo } from '@kit.CoreFileKit'

/*
 * skipSecond：跳帧系数，降低绘制到画布上的帧数，根据采样率定义实现在buffer上按时间跳帧，最终得到绘制的帧数
 * width:画布宽度，由绘制帧数*每帧占用宽度得到
 * widthPerSec：每秒占用画布宽度，由音频时长/画布宽度得到，实现时间刻度均匀绘制在画布宽度上
 * widthPerScale: 每个时间刻度占用的画布宽度，由secPerScale（刻度占用时长）*widthPerSec得到
 */
const FRAME_PER_WIDTH: number = 2 //每帧所占宽度，用来将帧数均匀绘制在画布上
const SKIP_SECOND: number = 1 //跳帧系数，用来计算跳帧的时间间隔（默认跳1秒的帧数间隔）

export const SCALE_FRAME: number = 20 //刻度间隔（该值的倍数显示时间）

@ObservedV2
export class EditViewModel {
  pcmPath: string = '' //pcm码文件路径
  channelLayout: number = 0 //声道数量
  sampleRate: number = 0 //采样率（每秒采样帧数）
  duration: number = 0 //音频资源时长(毫秒)
  bytesPerSample = 4 // 固定f32le采样格式 每个采样点字节数（16位=2字节）
  bytesPerFrame = 0 //每帧字节数，根据采样格式的采样点字节数*声道数量
  amplitudes: number[] = [] //降频归一化后的音频振幅
  @Trace scales: number[] = [] //时间刻度数组
  @Trace widthPerScale: number = 0 //每个刻度占用画布宽度，根据单位刻度占用时长（秒）*单位时长占用画布宽度得到
  @Trace playStatus: boolean = false //音频播放状态
  @Trace playTime: number = 0 //播放时长(秒)
  size: number = 0 //音频大小（字节）
  playLength: number = 0 //播放长度
  @Trace isOver: boolean = false

  /*初始化参数*/
  initProps(pcmPath: string, channelLayout: number, sampleRate: number, duration: number) {
    this.pcmPath = pcmPath
    this.channelLayout = channelLayout
    this.sampleRate = sampleRate
    this.duration = duration
    this.bytesPerFrame = this.bytesPerSample * this.channelLayout
  }


  init(pcmPath: string, channelLayout: number, sampleRate: number, duration: number) {
    this.initProps(pcmPath, channelLayout, sampleRate, duration)
    this.amplitudes = this.parsePcmFile()

  }

  //从pcm中获取降频后的画布帧
  parsePcmFile() {
    const skipFrames = SKIP_SECOND * this.sampleRate
    const stat = fileIo.statSync(this.pcmPath)
    const file = fileIo.openSync(this.pcmPath)
    const size = stat.size
    this.size = size
    const buffer = new ArrayBuffer(size)
    fileIo.readSync(file.fd, buffer)
    fileIo.close(file.fd)

    const dataView = new DataView(buffer)
    //计算总帧数
    const totalFrames = size / this.bytesPerFrame
    const amplitudes: number[] = [];

    // 3. 遍历每帧，解析所有声道并取平均振幅
    for (let frameIdx = 0; frameIdx < totalFrames; frameIdx += skipFrames) {
      const frameOffset = frameIdx * this.bytesPerFrame; // 当前帧的起始字节偏移
      let totalAmp = 0; // 所有声道的振幅总和

      // 循环读取当前帧内的所有声道
      for (let channelIdx = 0; channelIdx < this.channelLayout; channelIdx++) {
        // 计算当前声道在帧内的字节偏移：声道索引 × 每个采样点字节数
        const channelOffset = frameOffset + (channelIdx * this.bytesPerSample);

        // 读取当前声道的F32LE采样值（-1.0~1.0）
        const sample = dataView.getFloat32(channelOffset, true);
        // 累加当前声道的振幅（取绝对值，0~1）
        totalAmp += Math.abs(sample);
      }

      // 计算当前帧的平均振幅（总和 ÷ 声道数）
      const avgAmp = totalAmp / this.channelLayout;
      amplitudes.push(avgAmp);
    }
    return amplitudes;
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
      tempPlayTime = Math.round(this.duration / 1000)
    }
    this.setPlayTime(tempPlayTime)
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
    this.playStatus = true
  }
  stopCallBack = () => {
    this.playStatus = false
    this.isOver = true
  }
}