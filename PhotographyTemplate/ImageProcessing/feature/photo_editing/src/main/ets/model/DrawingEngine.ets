import { DRAW_INTERVAL, STROKE_RENDER_THRESHOLD } from '../constant/Constants';
import { DrawPath } from './DrawPaintModel';

class CanvasSize {
  width: number = 0;
  height: number = 0;
}

export class DrawInvoker {
  private undoStack: DrawPath[] = [];
  private redoStack: DrawPath[] = [];

  add(path: DrawPath): void {
    this.undoStack.push(path);
    this.redoStack = [];
  }

  undo(): void {
    if (this.undoStack.length > 0) {
      const path = this.undoStack.pop();
      if (path) {
        this.redoStack.push(path);
      }
    }
  }

  public hasPaths(): boolean {
    return this.undoStack.length > 0;
  }

  redo(): void {
    if (this.redoStack.length > 0) {
      const path = this.redoStack.pop();
      if (path) {
        this.undoStack.push(path);
      }
    }
  }

  clear(): void {
    this.undoStack = [];
    this.redoStack = [];
  }

  execute(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D): void {
    this.undoStack.forEach((element: DrawPath) => {
      element.draw(context);
    });
  }

  public getAllPaths(): DrawPath[] {
    return [...this.undoStack];
  }

  public loadPaths(paths: DrawPath[]): void {
    this.undoStack = [...paths];
    this.redoStack = [];
  }

  canUndo(): boolean {
    return this.undoStack.length > 0;
  }

  canRedo(): boolean {
    return this.redoStack.length > 0;
  }
}

export class DrawingEngine {
  private offscreenCanvas: OffscreenCanvas | null = null;
  private offscreenCtx: OffscreenCanvasRenderingContext2D | null = null;
  private cacheDirty: boolean = true;
  private setting: RenderingContextSettings;
  private lastDrawTime: number = 0;
  private cacheImage: ImageBitmap | null = null;

  readonly drawInvoker: DrawInvoker = new DrawInvoker();

  constructor(setting: RenderingContextSettings) {
    this.setting = setting;
  }

  private getCanvasSize(context: CanvasRenderingContext2D): CanvasSize {
    const size = new CanvasSize();
    size.width = context.width;
    size.height = context.height;
    return size;
  }

  private ensureOffscreenCache(context: CanvasRenderingContext2D): void {
    if (!this.offscreenCanvas || !this.offscreenCtx || this.cacheDirty) {
      this.rebuildOffscreenCache(context);
    }
  }

  private rebuildOffscreenCache(context: CanvasRenderingContext2D): void {
    const size = this.getCanvasSize(context);
    if (size.width === 0 || size.height === 0) {
      return;
    }
    if (!this.offscreenCanvas) {
      this.offscreenCanvas = new OffscreenCanvas(size.width, size.height);
      this.offscreenCtx = this.offscreenCanvas.getContext('2d', this.setting);
    }
    if (this.offscreenCtx) {
      this.offscreenCtx.clearRect(0, 0, size.width, size.height);
      this.drawInvoker.execute(this.offscreenCtx);
    }
    if (this.offscreenCanvas) {
      this.cacheImage = this.offscreenCanvas.transferToImageBitmap();
    }
    this.cacheDirty = false;
  }

  commitLatestStrokeToCache(context: CanvasRenderingContext2D): void {
    this.ensureOffscreenCache(context);
    if (!this.offscreenCtx) {
      return;
    }
    const allPaths = this.drawInvoker.getAllPaths();
    if (allPaths.length > 0) {
      allPaths[allPaths.length - 1].draw(this.offscreenCtx);
    }
    if (this.offscreenCanvas) {
      this.cacheImage = this.offscreenCanvas.transferToImageBitmap();
    }
    this.cacheDirty = false;
  }

  invalidateCache(): void {
    this.cacheDirty = true;
  }

  renderWithCache(context: CanvasRenderingContext2D, currentPath?: DrawPath, strokeCount: number = 0): void {
    this.ensureOffscreenCache(context);
    context.clearRect(0, 0, context.width, context.height);
    if (this.cacheImage) {
      context.drawImage(this.cacheImage, 0, 0);
    }
    if (currentPath && strokeCount > STROKE_RENDER_THRESHOLD) {
      currentPath.draw(context);
    }
  }

  renderCachedOnly(context: CanvasRenderingContext2D): void {
    this.ensureOffscreenCache(context);
    context.clearRect(0, 0, context.width, context.height);
    if (this.cacheImage) {
      context.drawImage(this.cacheImage, 0, 0);
    }
  }

  drawCacheOver(context: CanvasRenderingContext2D): void {
    this.ensureOffscreenCache(context);
    if (this.cacheImage) {
      context.drawImage(this.cacheImage, 0, 0);
    }
  }

  shouldDraw(now: number): boolean {
    return now - this.lastDrawTime > DRAW_INTERVAL;
  }

  updateDrawTime(): void {
    this.lastDrawTime = Date.now();
  }

  resetOffscreenCache(): void {
    this.offscreenCanvas = null;
    this.offscreenCtx = null;
    this.cacheImage = null;
    this.cacheDirty = true;
  }

  clear(): void {
    this.drawInvoker.clear();
    this.invalidateCache();
  }
}
