import { WorkerModel } from 'audio_worker/src/main/ets/model/WorkerModel';

const TAG = 'CanvasViewModel'

@ObservedV2
export class CanvasViewModel {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @Trace height: number = 0 //画布高度
  @Trace width: number = 0 //画布宽度
  @Trace amplitudes: number[] = [] //降频归一化后的音频振幅

  @Trace editWidth: number = 100
  @Trace editHeight: number = 0
  @Trace translateX: number = 0
  lineX: number = 0 //绘制的横轴起点

  workerId = ''
  workerModel: WorkerModel | undefined = undefined

  init(width: number, height: number, workerId: string) {
    this.width = width
    this.height = height
    this.editWidth = width
    this.editHeight = height
    this.workerId = workerId
  }

  /*
   * 设置抽帧数据
   */
  setAmplitudes(amplitudes: number[]) {
    this.amplitudes = amplitudes
  }

  /*
   * 启用线程
   */
  startWorker() {
    this.workerModel = new WorkerModel()
    this.workerModel.workerInstance.registerGlobalCallObject(this.workerId, this);
    // 发送消息给Worker线程
    this.workerModel.workerInstance?.postMessage({
      action: 'start',
      workerId: this.workerId
    });
  }

  /*
   * 销毁线程
   */
  destroyWoker() {
    //任务结束，销毁线程
    this.workerModel?.terminateWorker()
    this.workerModel = undefined
  }

  /*
   * worker线程执行函数
   */
  onStart() {
    this.drawAudio()
    //任务结束，销毁线程
    this.destroyWoker()
  }

  cleanCanvas() {
    this.lineX = 0
    // 清空画布（避免重复绘制）
    this.context.clearRect(0, 0, this.width, this.height);
  }

  drawAudio() {
    this.cleanCanvas()
    const totalSmaples = this.amplitudes.length
    const framePerWidth = this.width / totalSmaples //每帧所占宽度
    const centerY = this.height / 2; // 画布中线（波形对称中心）
    const waveScale = 0.8; // 波形高度缩放比例（避免顶满画布）

    // 设置画笔样式
    this.context.strokeStyle = '#01FCEA'; // 波形颜色（可自定义）
    this.context.lineCap = 'round'; // 竖线端点圆润，避免锯齿
    for (let sampleIndex = 0; sampleIndex < totalSmaples; sampleIndex++) {
      const amplitude = this.amplitudes[sampleIndex];
      const waveHeight = amplitude * this.height * waveScale;
      const topY = centerY - waveHeight / 2;
      const bottomY = centerY + waveHeight / 2;

      // 绘制上半部分竖线（中线→上端点）
      this.context.beginPath(); // 重置路径，确保竖线独立不相连
      this.context.moveTo(this.lineX, centerY);
      this.context.lineTo(this.lineX, topY);
      this.context.stroke();

      // 绘制下半部分竖线（中线→下端点）
      this.context.beginPath(); // 重置路径，确保竖线独立不相连
      this.context.moveTo(this.lineX, centerY);
      this.context.lineTo(this.lineX, bottomY);
      this.context.stroke();
      this.lineX = this.lineX + framePerWidth;
    }
    const lineWidth = 2
    this.context.lineWidth = lineWidth
    this.context.beginPath(); // 重置路径，确保竖线独立不相连
    this.context.moveTo(0, centerY - lineWidth / 2);
    this.context.lineTo(this.width, centerY - lineWidth / 2);
    this.context.stroke();
  }
}