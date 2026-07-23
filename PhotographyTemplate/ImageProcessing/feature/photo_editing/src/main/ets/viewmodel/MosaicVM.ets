import { DRAW_INTERVAL } from '../constant/Constants';
import { DrawHistoryItem, PathPoint } from '../model/DrawPaintModel';


@ObservedV2
export class MosaicVM {
  public renderSettings: RenderingContextSettings = new RenderingContextSettings(true);
  public drawContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderSettings);
  // 当前马赛克资源路径
  @Trace mosaicSource: string = '';
  // 马赛克线条宽度
  @Trace lineWidth: number = 8;
  @Trace mosaicIndex: number = -1;
  // 马赛克的类型
  private pattern: CanvasPattern | null = null;
  private points: PathPoint[] = [];
  // 绘制历史记录（用于undo/redo）
  @Trace drawHistory: DrawHistoryItem[] = [];
  @Trace historyIndex: number = -1;
  // 当前绘制使用的样式
  private currentPattern: CanvasPattern | null = null;
  private drawPath = new Path2D();

  // 是否选择vip马赛克
  @Trace isVipMosaic: boolean = false;
  // 是否绘制了vip马赛克
  @Trace hasDrawVip: boolean = false;

  public canvasHeight: number = 0;
  public canvasWidth: number = 0;
  private offscreenCanvas: OffscreenCanvas | null = null;
  private offscreenContext: OffscreenCanvasRenderingContext2D | null = null;
  private cacheDirty: boolean = true;
  private cacheImage: ImageBitmap | null = null;
  private lastDrawTime: number = 0;

  // 获取canvas画布大小
  canvasAreaChange(area: Area) {
    this.canvasHeight = area.height as number;
    this.canvasWidth = area.width as number;
    this.offscreenCanvas = new OffscreenCanvas(this.canvasWidth, this.canvasHeight);
    this.offscreenContext = this.offscreenCanvas.getContext('2d');
    this.cacheDirty = true;
    this.cacheImage = null;
  }

  // 创造马赛克样式
  createPattern() {
    const img = new ImageBitmap(this.mosaicSource);
    this.pattern = this.drawContext.createPattern(img, 'repeat');
  }

  moveStart(x: number, y: number) {
    if (this.historyIndex < this.drawHistory.length - 1) {
      this.drawHistory = this.drawHistory.slice(0, this.historyIndex + 1);
    }
    this.drawPath = new Path2D();
    this.currentPattern = this.pattern;
    this.points.push({ x: x, y: y });
    this.drawPath.moveTo(x, y);
    this.renderCachedOnly();
    if (this.isVipMosaic) {
      this.hasDrawVip = true;
    }
  }

  moveUpdate(x: number, y: number) {
    let lastPoint = this.points[this.points.length - 1];
    const point = { x: x, y: y } as PathPoint;
    this.points.push(point);
    this.drawPath.quadraticCurveTo((x + lastPoint.x) / 2, (y + lastPoint.y) / 2, x, y);
    let now = Date.now();
    if (this.shouldDraw(now)) {
      this.drawCurrentPathModel();
      this.updateDrawTime();
    }
    if (this.isVipMosaic) {
      this.hasDrawVip = true;
    }
  }

  moveEnd() {
    if (this.points.length > 0) {
      let pointsCopy: PathPoint[] = [];
      for (let i = 0; i < this.points.length; i++) {
        pointsCopy.push({ x: this.points[i].x, y: this.points[i].y });
      }
      let historyItem = new DrawHistoryItem(pointsCopy, this.currentPattern, this.lineWidth);
      this.drawHistory.push(historyItem);
      this.historyIndex = this.drawHistory.length - 1;
      this.commitStrokeToCache();
    }

    this.commitStrokeToCache();

    this.points = [];
    this.drawPath = new Path2D();
    if (this.isVipMosaic) {
      this.hasDrawVip = true;
    }
    this.renderCachedOnly();
  }

  // 清空马赛克
  clearPath() {
    this.mosaicSource = '';
    this.mosaicIndex = -1;
    this.points = [];
    this.drawPath = new Path2D();
    this.drawHistory = [];
    this.historyIndex = -1;
    this.drawContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.invalidateCache();
    this.hasDrawVip = false;
    this.isVipMosaic = false;
  }

  // 绘制撤销undo
  undoDraw() {
    if (this.historyIndex < 0) {
      return;
    }
    this.historyIndex--;
    this.invalidateCache();
    this.renderCachedOnly();
  }

  // 绘制重做redo
  redoDraw() {
    if (this.historyIndex >= this.drawHistory.length - 1) {
      return;
    }
    this.historyIndex++;
    this.invalidateCache();
    this.renderCachedOnly();
  }

  // 绘制当前路径
  private drawCurrentPathModel() {
    this.drawContext.globalCompositeOperation = 'source-over';
    this.drawContext.lineWidth = this.lineWidth;
    if (this.currentPattern) {
      this.drawContext.strokeStyle = this.currentPattern;
    }
    this.drawContext.lineJoin = 'round';
    this.drawContext.stroke(this.drawPath);
  }

  // 提交当前笔画到离屏缓存
  private commitStrokeToCache() {
    if (this.offscreenContext) {
      this.offscreenContext.globalCompositeOperation = 'source-over';
      this.offscreenContext.lineWidth = this.lineWidth;
      if (this.currentPattern) {
        this.offscreenContext.strokeStyle = this.currentPattern;
      }
      this.offscreenContext.lineJoin = 'round';
      this.offscreenContext.stroke(this.drawPath);
    }
    if (this.offscreenCanvas) {
      this.cacheImage = this.offscreenCanvas.transferToImageBitmap();
    }
    this.cacheDirty = false;
  }

  // 重建离屏缓存
  private rebuildOffscreenCache() {
    if (this.canvasWidth === 0 || this.canvasHeight === 0) {
      return;
    }
    if (!this.offscreenCanvas) {
      this.offscreenCanvas = new OffscreenCanvas(this.canvasWidth, this.canvasHeight);
      this.offscreenContext = this.offscreenCanvas.getContext('2d');
    }
    if (this.offscreenContext) {
      this.offscreenContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
      for (let i = 0; i <= this.historyIndex; i++) {
        let item = this.drawHistory[i];
        this.offscreenContext.lineWidth = item.lineWidth;
        if (item.pattern) {
          this.offscreenContext.strokeStyle = item.pattern;
        }
        this.offscreenContext.lineJoin = 'round';
        this.offscreenContext.stroke(item.toPath2D());
      }
    }
    if (this.offscreenCanvas) {
      this.cacheImage = this.offscreenCanvas.transferToImageBitmap();
    }
    this.cacheDirty = false;
  }

  // 使缓存失效
  private invalidateCache() {
    this.cacheDirty = true;
  }

  // 是否应该绘制（节流）
  private shouldDraw(now: number): boolean {
    return now - this.lastDrawTime > DRAW_INTERVAL;
  }

  // 更新绘制时间
  private updateDrawTime() {
    this.lastDrawTime = Date.now();
  }

  // 使用缓存渲染（仅离屏内容）
  private renderCachedOnly() {
    if (this.cacheDirty) {
      this.rebuildOffscreenCache();
    }
    this.drawContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    if (this.cacheImage) {
      this.drawContext.drawImage(this.cacheImage, 0, 0);
    }
  }
}