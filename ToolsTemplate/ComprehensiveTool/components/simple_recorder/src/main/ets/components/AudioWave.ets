import { fileIo as fs } from '@kit.CoreFileKit';
import { parseWavePCM } from '../util/DrawUtil';
import { Logger } from '../util/Logger';
import { AudioWaveController } from '../model/Index';

@ComponentV2
export struct AudioWavePage {
  @Param inputAudioPath: string = '';
  @Param controller: AudioWaveController = new AudioWaveController();
  @Local colorChangeX: number = 12; // 变色线X坐标（柱子超过此位置后变色）
  @Local currentStartIndex: number = 0; // 当前显示数据的起始索引（控制左移）
  @Local maxVisibleBars: number = 0; // 当前页最多显示的柱子数量
  @Local centerX: number = 0; // 画布中间位置
  private timer: number | null = null; // 滚动定时器
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  // 基础配置
  private waveData: number[] = []; // 完整音频时域数据
  private barWidth = 2; // 柱子宽度
  private barGap = 4; // 柱子间隔
  private scrollSpeed = 1; // 每次滚动的柱子数量（越大越快）
  private scrollInterval = 40; // 滚动间隔（ms，越小越快）
  private canvasHeight: number = 224; // 画布高度
  private marginRatio: number = 0.9; // 高度留边比例（避免柱子超出画布，0.8=留20%空白）
  private normalColor: string = '#2070F3'; // 未过线时柱子颜色
  private highlightColor: string = '#662070F3'; // 过线后柱子颜色
  // 临时PCM文件地址
  private outputFilePath: string = '';

  @Monitor('inputAudioPath')
  onchange() {
    this.initData();
  }

  aboutToAppear(): void {
    this.controller.start = this.start;
    this.controller.stop = this.stop;
    this.controller.reset = this.reset;
    this.controller.seek = this.seek;
  }

  aboutToDisappear(): void {
    this.waveData = [];
  }

  build() {
    Column() {
      // 画布：绘制动态柱形图
      Canvas(this.canvasCtx)
        .width('100%')
        .height(this.canvasHeight)
        .borderRadius(16)
        .backgroundColor($r('sys.color.background_primary'))
        .onAppear(() => {
          this.initData();
        })
        .onDisAppear(() => {
          this.stopScroll(); // 组件消失时停止定时器，避免内存泄漏
        })
        .onSizeChange((oldSize: SizeOptions, newSize: SizeOptions) => {
          const width = newSize.width as number;
          this.centerX = width / 2;
        });
    };

  }

  private start = () => {
    this.startScroll();
  };
  private stop = () => {
    this.stopScroll();
  };
  private reset = () => {
    this.resetScroll();
  };
  private seek = (duration: number) => {
    this.seekScroll(duration);
  };

  // 1. 初始化：FFmpeg生成PCM+解析数据
  private async initData() {
    try {
      this.waveData = await parseWavePCM(this.inputAudioPath);
      // 初始起始索引重置为0
      this.currentStartIndex = 0;
      // 首次绘制（仅展示部分柱子）
      this.drawDynamicBars();
      this.removeFile();
    } catch (e) {
      Logger.error('初始化失败');
    }
  }

  // 4. 开始匀速左移（定时器控制）
  private startScroll() {
    // 先停止已有定时器，避免重复
    if (this.timer) {
      clearInterval(this.timer);
    }
    // 定时更新起始索引，实现左移
    this.timer = setInterval(() => {
      // 当起始索引超过数据长度时，停止滚动（避免空数据）
      if (this.currentStartIndex >= this.waveData.length) {
        this.stopScroll();
        return;
      }

      if (this.colorChangeX < this.centerX) {
        // 每次让分割线移动
        this.colorChangeX += 2;
      } else {
        // 每次让起始索引递增（控制滚动速度）
        this.currentStartIndex += this.scrollSpeed;
      }

      // 重新绘制
      this.drawDynamicBars();
    }, this.scrollInterval);
  }

  // 5. 停止滚动
  private stopScroll() {
    if (this.timer !== null) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  // 6. 重置为初始位置
  private resetScroll() {
    if (this.timer !== null) {
      clearInterval(this.timer);
      this.timer = null;
    }
    this.colorChangeX = 12;
    this.currentStartIndex = 0;
    // 重新绘制
    this.drawDynamicBars();
  }

  // 7.跳转指定位置
  private seekScroll(duration: number) {
    this.currentStartIndex = Math.floor(duration / 20); // 20为当前采样率下，音频长度ms和柱子数量的比值
    this.drawDynamicBars();
  }

  private removeFile() {
    if (this.outputFilePath) {
      try {
        fs.unlinkSync(this.outputFilePath);
      } catch (e) {
        Logger.error(JSON.stringify(e));
      }
    }
  }

  private drawDynamicBars() {
    const ctx = this.canvasCtx;
    const canvasWidth = ctx.width;
    const totalPerBar = this.barWidth + this.barGap; // 单根柱子总占用宽度（宽+间隔）
    this.maxVisibleBars = Math.floor(canvasWidth / totalPerBar); // 画布可容纳最大柱子数
    const centerY = this.canvasHeight / 2; // 画布中线（柱子延伸基准，仅用于计算，不绘制）
    const maxSingleSideHeight = (this.canvasHeight * this.marginRatio) / 2; // 单边最大高度（上下各占一半）

    // 1. 清空画布
    ctx.clearRect(0, 0, canvasWidth, this.canvasHeight);

    // 2. 仅绘制变色线
    ctx.strokeStyle = '#E84026';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(this.colorChangeX, 16);
    ctx.lineTo(this.colorChangeX, this.canvasHeight - 12);
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(this.colorChangeX, 16, 2, 0, 2 * Math.PI);
    ctx.fillStyle = '#E84026';
    ctx.fill();
    ctx.stroke();


    // 3. 计算当前需绘制的数据段（避免数组越界）
    const endIndex = Math.min(this.currentStartIndex + this.maxVisibleBars, this.waveData.length);

    // 4. 遍历绘制柱子（从中间向上下延伸）
    for (let i = this.currentStartIndex; i < endIndex; i++) {
      const amplitudeAbs = Math.abs(this.waveData[i]); // 取振幅绝对值
      const visibleIndex = i - this.currentStartIndex;
      const barX = visibleIndex * totalPerBar;

      // 振幅归一化（映射到单边最大高度）
      const maxAbs = this.waveData.reduce((max,num)=>Math.max(max,Math.abs(num)),0)

      const normalizedSingleHeight = Math.min(
        (amplitudeAbs / maxAbs) * maxSingleSideHeight,
        maxSingleSideHeight,
      );

      // 选择柱子颜色（过线变色）
      ctx.fillStyle = barX > this.colorChangeX ? this.highlightColor : this.normalColor;

      // 绘制从中间向上下延伸的柱子
      const barTopY = centerY - normalizedSingleHeight;
      const barTotalHeight = normalizedSingleHeight * 2; // 总高度=上下单边高度之和
      ctx.fillRect(barX, barTopY, this.barWidth, barTotalHeight);
    }
  }
}




