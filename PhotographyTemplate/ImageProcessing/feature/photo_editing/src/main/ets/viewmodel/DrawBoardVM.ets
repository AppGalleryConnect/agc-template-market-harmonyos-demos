import { IBrush, NormalBrush } from '../model/Brush';
import { DrawingEngine } from '../model/DrawingEngine';
import { DrawPath, Paint } from '../model/DrawPaintModel';
import { display } from '@kit.ArkUI';
import { Logger } from 'commonlib';

@ObservedV2
export class DrawBoardVM {
  public setting: RenderingContextSettings = new RenderingContextSettings(true);
  @Trace scrawlContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
  @Trace mPaint: Paint = new Paint(0, '', 1);
  @Trace mBrush: IBrush = new NormalBrush();
  @Trace isDrawing: boolean = false;
  @Trace scaleValueX: number = 1;
  @Trace scaleValueY: number = 1;
  @Trace pinchValueX: number = 1;
  @Trace pinchValueY: number = 1;
  @Trace unDoDraw: boolean = false;
  @Trace redoDraw: boolean = false;
  public mPath: DrawPath = new DrawPath(this.mPaint, new Path2D());
  private engine: DrawingEngine = new DrawingEngine(this.setting);
  // 涂鸦
  @Trace scrawlIndex: number = 0;
  @Trace brushLineWidth: number = 8;
  @Trace brushWidthRatio: number = 1;
  @Trace brushAlpha: number = 1;
  @Trace brushColor: string = '#000000';
  @Trace brushShadowBlur: number = 0;
  @Trace lineCap: string = 'round';
  @Trace lineDash: number[] = [];

  private strokeCount: number = 0;

  get drawInvoker() {
    return this.engine.drawInvoker;
  }

  @Monitor('isDrawing')
  createDraw() {
    if (this.isDrawing) {
      this.engine.renderCachedOnly(this.scrawlContext);
      this.isDrawing = false;
    }
  }

  initDrawBoard() {
    this.applyBrushSettings();
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        if (data === 2) {
          this.scaleValueX = 0.5;
          this.scaleValueY = 0.5;
          this.pinchValueX = 0.5;
          this.pinchValueY = 0.5;
        } else if (data === 1) {
          this.scaleValueX = 1;
          this.scaleValueY = 1;
          this.pinchValueX = 1;
          this.pinchValueY = 1;
        }
        this.engine.invalidateCache();
      })
    } catch (e) {
      Logger.error(`initDrawBoard failed with error ${JSON.stringify(e)}`);
    }
  }

  // 设置笔刷样式
  applyBrushSettings() {
    this.mPaint = new Paint(0, '', 1);
    this.mPaint.setStrokeWidth(this.brushLineWidth * this.brushWidthRatio);
    this.mPaint.setColor(this.brushColor);
    this.mPaint.setGlobalAlpha(this.brushAlpha)
    this.mPaint.setShadowBlur(this.brushShadowBlur)
    this.mPaint.setLineDash(this.lineDash);
    this.mPaint.lineCap = this.lineCap;
  }

  handleTouch(event: TouchEvent) {
    if (event.touches.length > 1) {
      return;
    }
    if (event.touches[0].id !== 0) {
      return;
    }
    const x = event.touches[0].x;
    const y = event.touches[0].y;
    if (event.type === TouchType.Down) {
      this.mPath = new DrawPath(this.mPaint.clone(), new Path2D());
      this.mPath.canvasWidth = this.scrawlContext.width;
      this.mPath.canvasHeight = this.scrawlContext.height;
      this.mBrush.down(this.mPath.path, x, y);
      this.mPath.addPoint(x, y);
      this.engine.renderCachedOnly(this.scrawlContext);
    } else if (event.type === TouchType.Move) {
      const now = Date.now();
      if (this.engine.shouldDraw(now)) {
        this.mBrush.move(this.mPath.path, x, y);
        this.mPath.addPoint(x, y);
        this.strokeCount++;
        this.engine.renderWithCache(this.scrawlContext, this.mPath, this.strokeCount);
        this.engine.updateDrawTime();
      }
    } else if (event.type === TouchType.Up) {
      this.drawInvoker.add(this.mPath);
      this.strokeCount = 0;
      this.redoDraw = false;
      this.unDoDraw = true;
      this.engine.commitLatestStrokeToCache(this.scrawlContext);
      this.engine.renderCachedOnly(this.scrawlContext);
    }
  }

  renderWithCache(): void {
    this.engine.renderCachedOnly(this.scrawlContext);
  }

  drawOperateUndo(): void {
    this.drawInvoker.undo();
    this.engine.invalidateCache();
    this.isDrawing = true;
    if (!this.drawInvoker.canUndo()) {
      this.unDoDraw = false;
    }
    this.redoDraw = true;
  }

  drawOperateRedo(): void {
    this.drawInvoker.redo();
    this.engine.invalidateCache();
    this.isDrawing = true;
    if (!this.drawInvoker.canRedo()) {
      this.redoDraw = false;
    }
    this.unDoDraw = true;
  }
}