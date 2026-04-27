import { PersistenceV2 } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { PathInfo } from './PathInfoVM';
import { GlobalContext, TimeUtil } from 'common';
import { CommonConstants } from '../constants/Constant';
import { PhotoUtils } from '../utils/PhotoUtils';
import { DrawingHistoryItem, DrawingHistoryList } from './DrawingHistoryVM';
import { ColorHistoryVM } from './ColorHistoryVM';
import { sheetParam } from '../constants/WindowConstants';

// 路径绘制结果接口
interface PathsToDrawResult {
  paths: Array<PathInfo>;
  shouldDrawImage: boolean;
}

// 画板视图模型类，管理画板的所有状态、绘制逻辑和用户交互
@ObservedV2
export class DrawingBoardVM {
  // 单例实例
  private static _instance: DrawingBoardVM
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  @Trace context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  path2D: Path2D = new Path2D();
  // 画作历史
  drawingHistoryList: DrawingHistoryList =
    PersistenceV2.connect(DrawingHistoryList, 'drawingHistoryList', () => new DrawingHistoryList())!;
  colorHistoryVM: ColorHistoryVM =
    PersistenceV2.connect(ColorHistoryVM, 'colorHistoryVM', () => new ColorHistoryVM())!;
  // 当前选中的底部工具栏索引
  @Trace tabCurrentIndex: number = 0
  // 画笔粗细
  @Trace strokeWidth: number = 3;
  // 当前选中的画笔索引
  @Trace brushSelectIndex: number = 0;
  // 画笔颜色
  @Trace color: string = '#191919';
  // 画笔透明度
  @Trace alpha: number = 1;
  // 橡皮擦大小
  @Trace eraserSize: number = 10;
  // 当前选择的图形类型
  @Trace currentShape: string = 'none'
  // 图形尺寸
  @Trace shapeStrokeWidth: number = 3;
  // 背景类型Tab
  @Trace backgroundSelectType: string = 'SolidColor'
  // 画布背景图片
  @Trace canvasBackgroundImage: ResourceStr = ''
  // 画布背景颜色
  @Trace canvasColor: string = '#ffffff'
  // 画布渐变色
  @Trace gradientColor: Array<[ResourceColor, number]> = []
  // 是否开启橡皮擦
  @Trace eraserMode: boolean = false;
  // 是否处于图形模式
  @Trace shapeMode: boolean = false;
  // 是否正在绘制图形
  @Trace isDrawingShape: boolean = false;
  // 图形起始点X坐标
  @Trace startX: number = 0;
  // 图形起始点Y坐标
  @Trace startY: number = 0;
  // 触摸点坐标
  @Trace touchX: number = 0
  @Trace touchY: number = 0
  // 图像移动
  @Trace isPreview: boolean = false
  @Trace positionX: number = 0
  @Trace positionY: number = 0
  // 上次绘制时间
  private lastDrawTime = 0;
  // 绘制间隔（毫秒）- 橡皮擦使用更大的间隔减少卡顿
  private readonly DRAW_INTERVAL = 16;
  private readonly ERASER_DRAW_INTERVAL = 25; // 橡皮擦降低精度，提升性能
  // 上次预览时间（统一用于图形、橡皮擦、画笔预览）
  private lastPreviewTime = 0;
  // 预览间隔（毫秒）- 图形预览使用更大的间隔减少卡顿
  private readonly PREVIEW_INTERVAL = 16;
  private readonly SHAPE_PREVIEW_INTERVAL = 40;
  // 是否需要使用离屏预览
  private needOffscreenPreview: boolean = false;
  // 图形预览缓存（用于优化图形绘制性能）
  private shapePreviewCache?: ImageBitmap = undefined;
  private shapePreviewCacheInvalidated: boolean = true;
  // 增量渲染快照（用于橡皮擦性能优化）
  private renderedSnapshot?: ImageBitmap = undefined;
  private snapshotInvalidated: boolean = true;
  // 路径合并阈值
  private readonly PATH_MERGE_THRESHOLD: number = 10;
  // 画布内容是否保存
  @Trace isSave: boolean = true;
  // 是否可以撤销
  @Trace unDoDraw: boolean = false;
  // 是否可以重做
  @Trace redoDraw: boolean = false;
  // 最大撤销/重做数量
  private readonly MAX_UNDO_REDO: number = 200
  // 已确定的路径数组（不可撤销的历史路径）
  @Trace confirmedPaths: Array<PathInfo> = []
  // 可撤销的路径数组
  @Trace undoArray: Array<PathInfo> = []
  // 重做路径数组
  @Trace redoArray: Array<PathInfo> = []
  // 组件截图数据
  @Trace pixelMap?: image.PixelMap
  // 是否吸色
  @Trace isColorSampling: boolean = false
  // 画板名称
  @Trace title: string = ''
  // 画作Id
  @Trace drawingId: string = '-1'
  // 吸色RGB
  @Trace rgb: number[] = [255, 255, 255, 1]
  // 吸色颜色
  @Trace selectColor: string = '#ffffff'
  // 加载的图片内容（作为不可撤销的确定路径）
  // 再次编辑时，此内容可以被橡皮擦擦除和清空，但不支持撤销/重做
  loadedImageBitmap?: ImageBitmap = undefined

  // 监听工具栏切换，更新绘制模式
  @Monitor('tabCurrentIndex')
  drawTypeChange() {
    if (this.tabCurrentIndex === 0) {
      this.eraserMode = false
      this.shapeMode = false
      this.context.globalCompositeOperation = 'source-over'
    } else if (this.tabCurrentIndex === 1) {
      this.eraserMode = false
    } else if (this.tabCurrentIndex === 2) {
      this.eraserMode = true
      this.shapeMode = false
      this.context.globalCompositeOperation = 'destination-out'
    } else if (this.tabCurrentIndex === 3) {
      this.eraserMode = false
      this.shapeMode = true
      this.context.globalCompositeOperation = 'source-over'
    }
  }


  // 获取单例实例
  public static get instance() {
    if (!DrawingBoardVM._instance) {
      DrawingBoardVM._instance = new DrawingBoardVM()
    }
    return DrawingBoardVM._instance
  }

  // 重置绘制相关状态
  private resetDrawingState(): void {
    this.confirmedPaths = []
    this.undoArray = []
    this.redoArray = []
    this.unDoDraw = false
    this.redoDraw = false
    this.loadedImageBitmap = undefined
  }

  // 重置模式状态
  private resetModeState(): void {
    this.tabCurrentIndex = 0
    this.eraserMode = false
    this.shapeMode = false
    this.isDrawingShape = false
    this.currentShape = 'none'
    this.isColorSampling = false
  }

  // 重置背景状态
  private resetBackgroundState(): void {
    this.backgroundSelectType = 'SolidColor'
    this.canvasBackgroundImage = ''
    this.canvasColor = '#ffffff'
    this.gradientColor = []
  }

  // 初始化画布上下文
  private initCanvasContext(): void {
    this.context.strokeStyle = this.color
    this.context.lineWidth = this.strokeWidth
    this.context.lineCap = 'round'
    this.context.globalCompositeOperation = 'source-over'
    if (this.context.width > 0 && this.context.height > 0) {
      this.context.clearRect(0, 0, this.context.width, this.context.height)
    }
  }

  // 初始化画布（新建画作时调用）
  init() {
    this.title = ''
    this.drawingId = '-1'
    this.isSave = true
    this.resetDrawingState()
    this.resetModeState()
    this.resetBackgroundState()
    this.pixelMap = undefined
    this.touchX = 0
    this.touchY = 0
    // 清理快照
    this.renderedSnapshot = undefined
    this.snapshotInvalidated = true
    this.initCanvasContext()
  }

  // 处理触摸事件
  onTouch(event: TouchEvent) {
    if (event.touches.length > 1) {
      return
    }
    if (!event.touches[0]) {
      return
    }
    if (this.isColorSampling) {
      this.handleColorSampling(event)
      return
    }
    this.handleDrawing(event)
  }

  // 获取组件截图
  async getPixelMap() {
    const pixelMap = await GlobalContext.getUIContext().getComponentSnapshot()
      .get(CommonConstants.DRAW_BOARD_ID, { scale: 1, waitUntilRenderFinished: true })
    if (pixelMap !== undefined) {
      this.pixelMap = pixelMap
    }
  }

  // 处理颜色采样
  private async handleColorSampling(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      this.touchX = this.clampX(event.touches[0].x)
      this.touchY = this.clampY(event.touches[0].y)
    }
    if (event.type === TouchType.Move) {
      this.touchX = this.clampX(event.touches[0].x)
      this.touchY = this.clampY(event.touches[0].y)
    }
    if (event.type === TouchType.Up) {
      sheetParam.event?.show()
      this.isColorSampling = false
    }
  }


  // 限制X坐标在画布范围内
  private clampX(x: number): number {
    return Math.max(0, Math.min(x, this.context.width))
  }

  // 限制Y坐标在画布范围内
  private clampY(y: number): number {
    return Math.max(0, Math.min(y, this.context.height))
  }

  /**
   * 处理触摸开始事件
   */
  private handleTouchDown(x: number, y: number): void {
    this.context.save()
    this.context.beginPath()
    this.path2D = new Path2D()
    this.positionX = x
    this.positionY = y
    this.isPreview = true
    this.path2D.moveTo(x, y)
    this.colorHistoryVM.addColor(this.color)

    // 判断是否需要使用离屏预览
    this.needOffscreenPreview = !this.eraserMode && this.alpha < 1

    if (this.eraserMode) {
      this.context.globalCompositeOperation = 'destination-out'
      this.context.lineCap = 'round'
      this.context.lineJoin = 'round'
      this.context.lineWidth = this.eraserSize
      this.context.globalAlpha = 1
    } else {
      this.context.globalCompositeOperation = 'source-over'
      this.context.strokeStyle = this.color
      this.context.lineWidth = this.strokeWidth
      this.context.globalAlpha = this.alpha
    }
  }

  /**
   * 处理触摸移动事件
   */
  private handleTouchMove(x: number, y: number): void {
    const now = Date.now()
    const interval = this.eraserMode ? this.ERASER_DRAW_INTERVAL : this.DRAW_INTERVAL

    if (now - this.lastDrawTime > interval) {
      this.positionX = x
      this.positionY = y
      this.path2D.lineTo(x, y)

      if (this.needOffscreenPreview) {
        this.drawOffscreenPreview()
      } else {
        this.context.stroke(this.path2D)
      }
      this.lastDrawTime = now
    }
  }

  /**
   * 处理触摸结束事件
   */
  private handleTouchUp(): void {
    this.context.restore()
    this.isPreview = false
    this.redoArray = []
    this.redoDraw = false
    this.unDoDraw = true

    let pathInfo: PathInfo
    if (this.eraserMode) {
      pathInfo = new PathInfo(this.path2D, this.color, this.eraserSize, 1, true)
    } else {
      pathInfo = new PathInfo(this.path2D, this.color, this.strokeWidth, this.alpha, false,
        this.context.lineCap, this.context.lineJoin)
    }

    this.addPathWithLimit(pathInfo)
    this.context.closePath()

    // 透明度画笔需要重绘
    if (this.needOffscreenPreview) {
      this.execute(this.context)
      this.createSnapshot() // 创建快照
    } else if (this.eraserMode) {
      // 橡皮擦模式：使用增量渲染优化
      // 不调用 execute()，直接创建快照
      this.createSnapshot()

      // 检查是否需要合并路径
      this.mergePathsToSnapshot()
    } else {
      // 普通画笔：创建快照
      this.createSnapshot()
    }

    this.needOffscreenPreview = false
    this.invalidateAllCaches()
  }

  /**
   * 处理绘制操作
   */
  private handleDrawing(event: TouchEvent) {
    this.isSave = false
    if (this.shapeMode && this.currentShape !== 'none') {
      this.shapeDrawing(event, event.touches[0].x, event.touches[0].y)
      return
    }
    if (event.type === TouchType.Down) {
      this.handleTouchDown(event.touches[0].x, event.touches[0].y)
    } else if (event.type === TouchType.Move) {
      this.handleTouchMove(event.touches[0].x, event.touches[0].y)
    } else if (event.type === TouchType.Up) {
      this.handleTouchUp()
    }
  }

  /**
   * 创建临时Canvas并绘制当前路径
   */
  private createTempCanvasWithCurrentPath(): ImageBitmap {
    const tempCanvas = new OffscreenCanvas(this.context.width, this.context.height)
    const tempContext = tempCanvas.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D
    // 绘制所有已确认的路径
    this.executeOnContext(tempContext, true)
    // 添加当前正在绘制的路径
    tempContext.save()
    tempContext.globalCompositeOperation = 'source-over'
    tempContext.strokeStyle = this.color
    tempContext.lineWidth = this.strokeWidth
    tempContext.globalAlpha = this.alpha
    tempContext.lineCap = this.context.lineCap
    tempContext.lineJoin = this.context.lineJoin
    tempContext.stroke(this.path2D)
    tempContext.restore()
    return tempCanvas.transferToImageBitmap()
  }

  /**
   * 离屏预览方法（优化版）
   * 只用于透明度画笔的实时预览，避免路径内部透明度叠加
   */
  private drawOffscreenPreview(): void {
    const savedCompositeOperation = this.context.globalCompositeOperation
    const savedGlobalAlpha = this.context.globalAlpha
    try {
      this.context.clearRect(0, 0, this.context.width, this.context.height)
      const tempImage = this.createTempCanvasWithCurrentPath()
      this.context.globalCompositeOperation = 'source-over'
      this.context.globalAlpha = 1
      this.context.drawImage(tempImage, 0, 0)
    } catch (err) {
      this.context.stroke(this.path2D)
    } finally {
      this.context.globalCompositeOperation = savedCompositeOperation
      this.context.globalAlpha = savedGlobalAlpha
    }
  }

  // 处理图形绘制
  shapeDrawing(event: TouchEvent, x: number, y: number): void {
    if (event.type === TouchType.Down) {
      this.startX = x
      this.startY = y
      this.isDrawingShape = true
    } else if (event.type === TouchType.Move) {
      if (this.isDrawingShape) {
        this.drawShapePreview(x, y)
      }
    } else if (event.type === TouchType.Up) {
      if (this.isDrawingShape) {
        this.finishShapeDrawing(x, y)
      }
    }
  }

  /**
   * 获取或创建图形预览缓存
   */
  private getOrCreateShapePreviewCache(): ImageBitmap {
    if (this.shapePreviewCache && !this.shapePreviewCacheInvalidated) {
      return this.shapePreviewCache
    }
    // 重新绘制基础内容
    this.execute(this.context)
    // 创建缓存
    const cacheCanvas = new OffscreenCanvas(this.context.width, this.context.height)
    const cacheContext = cacheCanvas.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D
    this.executeOnContext(cacheContext, true)
    this.shapePreviewCache = cacheCanvas.transferToImageBitmap()
    this.shapePreviewCacheInvalidated = false
    return this.shapePreviewCache
  }

  /**
   * 绘制图形虚线预览
   */
  private drawShapeDashedPreview(endX: number, endY: number): void {
    this.context.save()
    this.context.setLineDash([this.shapeStrokeWidth, 2 * this.shapeStrokeWidth])
    this.context.strokeStyle = this.color
    this.context.lineWidth = this.shapeStrokeWidth
    this.context.globalAlpha = this.alpha * 0.7
    this.context.beginPath()
    this.drawShapeByType(this.context, this.startX, this.startY, endX, endY, this.currentShape)
    this.context.stroke()
    this.context.restore()
  }

  /**
   * 绘制图形预览（优化版：使用缓存避免重复绘制所有路径）
   */
  private drawShapePreview(endX: number, endY: number): void {
    try {
      const now = Date.now()
      if (now - this.lastPreviewTime < this.SHAPE_PREVIEW_INTERVAL) {
        return
      }
      this.lastPreviewTime = now
      this.context.clearRect(0, 0, this.context.width, this.context.height)
      // 使用缓存的基础内容
      const cache = this.getOrCreateShapePreviewCache()
      this.context.drawImage(cache, 0, 0)
      // 绘制虚线预览
      this.drawShapeDashedPreview(endX, endY)
    } catch (err) {
      this.execute(this.context)
      this.drawShapeDashedPreview(endX, endY)
    }
  }

  // 完成图形绘制
  private finishShapeDrawing(endX: number, endY: number): void {
    this.path2D = new Path2D()
    this.drawShapeToPath(this.path2D, this.startX, this.startY, endX, endY, this.currentShape)
    this.redoArray = []
    this.redoDraw = false
    this.unDoDraw = true
    const pathInfo = new PathInfo(this.path2D, this.color, this.shapeStrokeWidth, this.alpha)
    this.addPathWithLimit(pathInfo)
    this.isDrawingShape = false
    // 标记缓存失效
    this.invalidateAllCaches()
    // 重绘画布
    this.execute(this.context)
  }

  // 根据类型在上下文中绘制图形
  private drawShapeByType(ctx: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D,
    startX: number, startY: number, endX: number, endY: number, shapeType: string): void {
    const width = endX - startX
    const height = endY - startY
    switch (shapeType) {
      case 'circle':
        const radius = Math.sqrt(width * width + height * height) / 2
        const centerX = startX + width / 2
        const centerY = startY + height / 2
        ctx.arc(centerX, centerY, Math.abs(radius), 0, Math.PI * 2)
        break
      case 'rectangle':
        ctx.rect(startX, startY, width, height)
        break
      case 'line':
        ctx.lineCap = 'round'
        ctx.moveTo(startX, startY)
        ctx.lineTo(endX, endY)
        break
    }
  }

  // 将图形绘制到Path2D对象
  private drawShapeToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number,
    shapeType: string): void {
    const width = endX - startX
    const height = endY - startY
    switch (shapeType) {
      case 'circle':
        const radius = Math.sqrt(width * width + height * height) / 2
        const centerX = startX + width / 2
        const centerY = startY + height / 2
        path.arc(centerX, centerY, Math.abs(radius), 0, Math.PI * 2)
        break
      case 'rectangle':
        path.rect(startX, startY, width, height)
        break
      case 'line':
        path.moveTo(startX, startY)
        path.lineTo(endX, endY)
        break
    }
  }

  // 取消图形绘制

  cancelShapeDrawing(): void {
    this.isDrawingShape = false
    this.shapeMode = false
    this.currentShape = 'none'
    // 重绘画布以移除预览
    this.execute(this.context)
  }

  /**
   * 设置背景类型
   * @param type 背景类型：Album(相册)、SolidColor(纯色)、Gradient(渐变)
   */
  setBackgroundType(type: string) {
    this.backgroundSelectType = type
    if (type === 'Album') {
      this.gradientColor = []
      this.canvasColor = '#00000000'
    } else if (type === 'SolidColor') {
      this.canvasBackgroundImage = ''
      this.gradientColor = []
    } else if (type === 'Gradient') {
      this.canvasBackgroundImage = ''
      this.canvasColor = '#00000000'
    }
    // 修改背景后标记为未保存
    this.isSave = false
  }

  // 使用画笔绘制
  drawWithPen(type: string, index: number) {
    this.switchBrushType(type, index);
  }

  // 应用画笔配置
  private applyBrushConfig(strokeWidth: number, alpha: number, lineCap: CanvasLineCap,
    lineJoin: CanvasLineJoin): void {
    this.strokeWidth = strokeWidth
    this.alpha = alpha
    this.context.lineCap = lineCap
    this.context.lineJoin = lineJoin
    this.context.strokeStyle = this.color
    this.context.lineWidth = this.strokeWidth
    this.context.globalAlpha = this.alpha
  }

  // 切换画笔类型
  switchBrushType(brushType: string, index: number): void {
    this.brushSelectIndex = index;
    switch (brushType) {
      case 'ballpoint':
        this.applyBrushConfig(3, 1, 'round', 'round')
        break
      case 'pencil':
        this.applyBrushConfig(2, 0.7, 'round', 'round')
        break
      case 'fountain':
        this.applyBrushConfig(1.5, 1, 'round', 'miter')
        break
      case 'marker':
        this.applyBrushConfig(10, 0.6, 'butt', 'miter')
        break
      case 'pixel':
        this.applyBrushConfig(6, 1, 'square', 'miter')
        break
      case 'charcoal':
        this.applyBrushConfig(8, 0.8, 'round', 'round')
        break
      case 'crayon':
        this.applyBrushConfig(12, 0.75, 'round', 'round')
        break
      case 'watercolor':
        this.applyBrushConfig(20, 0.5, 'round', 'round')
        break
      default:
        this.applyBrushConfig(3, 1, 'round', 'round')
    }
  }

  // 添加路径并检查是否超出限制
  private addPathWithLimit(pathInfo: PathInfo): void {
    this.undoArray.push(pathInfo)
    if (this.undoArray.length > this.MAX_UNDO_REDO) {
      const oldestPath = this.undoArray.shift()
      if (oldestPath) {
        this.confirmedPaths.push(oldestPath)
      }
    }
    // 路径变化，标记缓存失效
    this.invalidateAllCaches()
  }

  // 统一的缓存失效方法
  private invalidateAllCaches(): void {
    this.shapePreviewCacheInvalidated = true
    this.snapshotInvalidated = true
    // 清空缓存对象，释放内存
    this.shapePreviewCache = undefined
    // 注意：不清空 renderedSnapshot，它会在需要时更新
  }

  /**
   * 创建当前Canvas的快照
   * 用于增量渲染优化
   */
  private createSnapshot(): void {
    if (this.context.width <= 0 || this.context.height <= 0) {
      return
    }
    const snapshotCanvas = new OffscreenCanvas(this.context.width, this.context.height)
    const snapshotContext = snapshotCanvas.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D

    // 使用 getImageData 复制当前Canvas内容
    const imageData = this.context.getImageData(0, 0, this.context.width, this.context.height)
    snapshotContext.putImageData(imageData, 0, 0)

    this.renderedSnapshot = snapshotCanvas.transferToImageBitmap()
    this.snapshotInvalidated = false
  }

  /**
   * 从快照恢复Canvas内容
   */
  private restoreFromSnapshot(): boolean {
    try {
      if (!this.renderedSnapshot || this.snapshotInvalidated) {
        return false
      }
      this.context.clearRect(0, 0, this.context.width, this.context.height)
      this.context.drawImage(this.renderedSnapshot, 0, 0)
      return true
    } catch (err) {
      return false
    }
  }

  /**
   * 合并路径到快照（增量渲染优化）
   * 当 undoArray 路径过多时，将前面的路径合并到快照中
   */
  private mergePathsToSnapshot(): void {
    if (this.undoArray.length <= this.PATH_MERGE_THRESHOLD) {
      return
    }
    // 计算要合并的路径数量（合并一半）
    const mergeCount = Math.floor(this.undoArray.length / 2)
    const pathsToMerge = this.undoArray.splice(0, mergeCount)
    // 将这些路径移动到 confirmedPaths
    this.confirmedPaths.push(...pathsToMerge)
    // 重新渲染并创建新快照
    this.execute(this.context)
    this.createSnapshot()
  }

  // 获取所有路径
  private getAllPaths(): Array<PathInfo> {
    return [...this.confirmedPaths, ...this.undoArray]
  }

  // 判断画布是否有内容
  hasContent(): boolean {
    return this.confirmedPaths.length > 0 || this.undoArray.length > 0 || this.loadedImageBitmap !== undefined
  }

  // 判断是否需要重绘画布
  needsRedraw(): boolean {
    return this.confirmedPaths.length > 0 ||
      this.undoArray.length > 0 ||
      this.redoArray.length > 0 ||
      this.loadedImageBitmap !== undefined
  }

  // 获取总路径数量
  getTotalPathCount(): number {
    return this.confirmedPaths.length + this.undoArray.length
  }

  // 判断是否为新建画作
  isNewDrawing(): boolean {
    return this.drawingId === '-1'
  }

  // 判断是否为编辑已有画作
  isEditingExisting(): boolean {
    return this.drawingId !== '-1' && this.drawingHistoryList.isItemExistById(this.drawingId)
  }

  /**
   * 撤销操作
   */
  drawOperateUndo(): void {
    if (this.undoArray.length > 0) {
      const path = this.undoArray.pop()
      if (path) {
        this.redoArray.push(path)
      }
    }

    // 检查撤销后的状态
    if (this.undoArray.length === 0 && this.confirmedPaths.length === 0) {
      // 撤销到只剩载入的图像（没有新内容），不可继续撤销
      this.unDoDraw = false
    } else {
      this.unDoDraw = this.undoArray.length > 0
    }

    this.redoDraw = this.redoArray.length > 0

    // 撤销操作改变了画布内容，标记为未保存
    // 但如果撤销到只剩载入的图像，则标记为已保存
    if (this.undoArray.length === 0 && this.confirmedPaths.length === 0 && this.loadedImageBitmap) {
      this.isSave = true
    } else {
      this.isSave = false
    }

    // 标记所有缓存失效
    this.invalidateAllCaches()

    // 重绘画布（撤销必须重绘）
    this.execute(this.context)
    this.createSnapshot() // 创建新快照
  }

  /**
   * 重做操作
   */
  drawOperateRedo(): void {
    if (this.redoArray.length > 0) {
      const path = this.redoArray.pop()
      if (path) {
        this.undoArray.push(path)
      }
    }
    if (this.redoArray.length === 0) {
      this.redoDraw = false
    }
    this.unDoDraw = this.undoArray.length > 0
    // 重做操作改变了画布内容，标记为未保存
    this.isSave = false
    // 标记所有缓存失效
    this.invalidateAllCaches()

    // 重绘画布（重做必须重绘）
    this.execute(this.context)
    this.createSnapshot() // 创建新快照
  }

  /**
   * 查找最后一个清空操作的索引
   * @param paths 路径数组
   * @returns 最后一个清空操作的索引，如果没有则返回-1
   */
  private findLastClearIndex(paths: Array<PathInfo>): number {
    for (let i = paths.length - 1; i >= 0; i--) {
      if (paths[i].isClearAction) {
        return i
      }
    }
    return -1
  }

  /**
   * 计算需要绘制的路径和是否需要绘制载入的图像
   * @returns 包含路径数组和是否绘制图像的对象
   */
  private calculatePathsToDraw(): PathsToDrawResult {
    const allPaths = this.getAllPaths()
    const lastClearIndex = this.findLastClearIndex(allPaths)

    if (lastClearIndex >= 0) {
      // 有清空操作：只绘制清空操作之后的路径
      const result: PathsToDrawResult = {
        paths: allPaths.slice(lastClearIndex + 1),
        shouldDrawImage: false
      }
      return result
    } else {
      // 没有清空操作：绘制所有路径
      const result: PathsToDrawResult = {
        paths: allPaths,
        shouldDrawImage: true
      }
      return result
    }
  }

  /**
   * 使用分层绘制方式（用于有橡皮擦的场景）
   * @param context 目标上下文
   * @param pathsToDraw 需要绘制的路径
   * @param shouldDrawLoadedImage 是否绘制载入的图像
   */
  private executeWithLayerDrawing(context: CanvasRenderingContext2D,
    pathsToDraw: Array<PathInfo>, shouldDrawLoadedImage: boolean): void {
    // 创建内容层
    const contentLayer = new OffscreenCanvas(context.width, context.height)
    const contentContext = contentLayer.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D
    // 先在内容层绘制载入的图像（如果需要）
    if (shouldDrawLoadedImage && this.loadedImageBitmap) {
      contentContext.drawImage(this.loadedImageBitmap, 0, 0, context.width, context.height)
    }
    // 在内容层绘制路径
    this.drawPathsOnContext(contentContext, pathsToDraw)
    // 将内容层绘制到主Canvas
    const contentImage = contentLayer.transferToImageBitmap()
    context.drawImage(contentImage, 0, 0)
  }

  /**
   * 使用直接绘制方式（用于无橡皮擦的场景）
   * @param context 目标上下文
   * @param pathsToDraw 需要绘制的路径
   * @param shouldDrawLoadedImage 是否绘制载入的图像
   */
  private executeWithDirectDrawing(context: CanvasRenderingContext2D,
    pathsToDraw: Array<PathInfo>, shouldDrawLoadedImage: boolean): void {
    // 先绘制载入的图像
    if (shouldDrawLoadedImage && this.loadedImageBitmap) {
      context.drawImage(this.loadedImageBitmap, 0, 0, context.width, context.height)
    }
    // 直接绘制路径（跳过清空操作）
    pathsToDraw.forEach((pathInfo: PathInfo) => {
      if (pathInfo && pathInfo.path && !pathInfo.isClearAction) {
        this.drawSinglePath(context, pathInfo, false)
      }
    })
  }

  /**
   * 在指定上下文上绘制路径数组
   */
  private drawPathsOnContext(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D,
    paths: Array<PathInfo>): void {
    paths.forEach((pathInfo: PathInfo) => {
      if (pathInfo && pathInfo.path && !pathInfo.isClearAction) {
        this.drawSinglePath(context, pathInfo, true)
      }
    })
  }

  /**
   * 绘制单个路径
   */
  private drawSinglePath(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D,
    pathInfo: PathInfo, supportEraser: boolean): void {
    try {
      context.save()
      if (supportEraser && pathInfo.isEraser) {
        context.globalCompositeOperation = 'destination-out'
        context.strokeStyle = 'rgba(0,0,0,1)'
        context.globalAlpha = 1
      } else {
        context.globalCompositeOperation = 'source-over'
        context.strokeStyle = pathInfo.color
        context.globalAlpha = pathInfo.alpha ?? 1
      }
      context.lineWidth = pathInfo.strokeWidth
      context.lineCap = pathInfo.lineCap ?? 'round'
      context.lineJoin = pathInfo.lineJoin ?? 'round'
      context.stroke(pathInfo.path)
      context.restore()
    } catch (err) {
      context.restore()
    }
  }

  /**
   * 重绘画布
   * 清除画布后重新绘制所有已保存的路径
   * 支持清空操作：遇到清空标记时，清除之前的所有内容
   */
  execute(context: CanvasRenderingContext2D): void {
    // 边界检查
    if (!context || context.width <= 0 || context.height <= 0) {
      return
    }

    // 重置Canvas状态，避免之前的橡皮擦模式影响重绘
    context.globalCompositeOperation = 'source-over'
    context.globalAlpha = 1
    context.clearRect(0, 0, context.width, context.height)

    // 计算需要绘制的路径
    const result = this.calculatePathsToDraw()
    const pathsToDraw = result.paths
    const shouldDrawImage = result.shouldDrawImage

    // 检查是否有橡皮擦路径
    const hasEraserPaths = pathsToDraw.some(p => p.isEraser)

    if (hasEraserPaths) {
      // 有橡皮擦时使用分层绘制
      this.executeWithLayerDrawing(context, pathsToDraw, shouldDrawImage)
    } else {
      // 没有橡皮擦时使用直接绘制
      this.executeWithDirectDrawing(context, pathsToDraw, shouldDrawImage)
    }
  }

  /**
   * 在指定上下文上执行路径绘制（用于离屏预览和保存）
   * @param context 目标上下文
   * @param includeLoadedImage 是否包含载入的图像
   */
  private executeOnContext(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D,
    includeLoadedImage: boolean = false): void {
    const allPaths = this.getAllPaths()
    const lastClearIndex = this.findLastClearIndex(allPaths)

    // 计算需要绘制的路径和是否绘制图像
    let pathsToDraw: Array<PathInfo>
    let shouldDrawLoadedImage = includeLoadedImage

    if (lastClearIndex >= 0) {
      pathsToDraw = allPaths.slice(lastClearIndex + 1)
      shouldDrawLoadedImage = false // 清空操作会清除载入的图像
    } else {
      pathsToDraw = allPaths
      shouldDrawLoadedImage = includeLoadedImage
    }

    // 检查是否需要分层支持
    const hasEraserPaths = pathsToDraw.some(p => p.isEraser)
    const needLayerSupport = hasEraserPaths || (shouldDrawLoadedImage && this.loadedImageBitmap !== undefined)

    if (needLayerSupport) {
      this.drawWithLayerSupportForPaths(context, shouldDrawLoadedImage, pathsToDraw)
    } else {
      this.drawPathsDirectlyForPaths(context, pathsToDraw)
    }
  }

  // 直接绘制路径（无背景图、无橡皮擦的简单场景）
  private drawPathsDirectly(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D): void {
    const allPaths = this.getAllPaths()
    if (allPaths && allPaths.length > 0) {
      allPaths.forEach((pathInfo: PathInfo) => {
        // 跳过清空操作
        if (pathInfo && pathInfo.path && !pathInfo.isClearAction) {
          try {
            context.save()
            context.globalCompositeOperation = 'source-over'
            context.strokeStyle = pathInfo.color
            context.globalAlpha = pathInfo.alpha ?? 1
            context.lineWidth = pathInfo.strokeWidth
            context.lineCap = pathInfo.lineCap ?? 'round'
            context.lineJoin = pathInfo.lineJoin ?? 'round'
            context.stroke(pathInfo.path)
            context.restore()
          } catch (err) {
            context.restore()
          }
        }
      })
    }
  }

  // 直接绘制指定的路径数组（用于executeOnContext）
  private drawPathsDirectlyForPaths(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D,
    paths: Array<PathInfo>): void {
    if (paths && paths.length > 0) {
      paths.forEach((pathInfo: PathInfo) => {
        // 跳过清空操作
        if (pathInfo && pathInfo.path && !pathInfo.isClearAction) {
          try {
            context.save()
            context.globalCompositeOperation = 'source-over'
            context.strokeStyle = pathInfo.color
            context.globalAlpha = pathInfo.alpha ?? 1
            context.lineWidth = pathInfo.strokeWidth
            context.lineCap = pathInfo.lineCap ?? 'round'
            context.lineJoin = pathInfo.lineJoin ?? 'round'
            context.stroke(pathInfo.path)
            context.restore()
          } catch (err) {
            context.restore()
          }
        }
      })
    }
  }

  // 分层绘制指定的路径数组（用于executeOnContext）
  private drawWithLayerSupportForPaths(context: CanvasRenderingContext2D | OffscreenCanvasRenderingContext2D,
    includeLoadedImage: boolean, paths: Array<PathInfo>): void {
    try {
      // 创建内容层Canvas（包含载入的图像 + 所有路径）
      const contentCanvas = new OffscreenCanvas(this.context.width, this.context.height)
      const contentContext = contentCanvas.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D

      // 1. 绘制载入的图像（如果有且需要包含）
      if (includeLoadedImage && this.loadedImageBitmap) {
        contentContext.drawImage(this.loadedImageBitmap, 0, 0, this.context.width, this.context.height)
      }

      // 2. 在内容层上绘制指定的路径（橡皮擦会擦除所有内容）
      if (paths && paths.length > 0) {
        paths.forEach((pathInfo: PathInfo) => {
          // 跳过清空操作
          if (pathInfo && pathInfo.path && !pathInfo.isClearAction) {
            try {
              contentContext.save()
              if (pathInfo.isEraser) {
                // 橡皮擦：擦除内容层（包括载入的图像）
                contentContext.globalCompositeOperation = 'destination-out'
                contentContext.strokeStyle = 'rgba(0,0,0,1)'
                contentContext.globalAlpha = 1
              } else {
                // 普通画笔：叠加到内容层
                contentContext.globalCompositeOperation = 'source-over'
                contentContext.strokeStyle = pathInfo.color
                contentContext.globalAlpha = pathInfo.alpha ?? 1
              }
              contentContext.lineWidth = pathInfo.strokeWidth
              contentContext.lineCap = pathInfo.lineCap ?? 'round'
              contentContext.lineJoin = pathInfo.lineJoin ?? 'round'
              contentContext.stroke(pathInfo.path)
              contentContext.restore()
            } catch (err) {
              contentContext.restore()
            }
          }
        })
      }

      // 3. 将内容层绘制到目标Canvas（即使没有路径，也要绘制载入的图像）
      const contentImage = contentCanvas.transferToImageBitmap()
      context.drawImage(contentImage, 0, 0)
    } catch (err) {
    }
  }


  // 验证并生成画本名称
  titleValidate() {
    if (!this.title) {
      const d = new Date
      const p = (n: number) => n.toString().padStart(2, '0');
      const dateNum =
        Number(d.getFullYear() + p(d.getMonth() + 1) + p(d.getDate()) + p(d.getHours()) + p(d.getMinutes()));
      this.title = '自由画' + dateNum
    }
  }

  // 保存绘画内容到临时Canvas
  private async saveDrawingContent(): Promise<string | null> {
    const tempCanvas = new OffscreenCanvas(this.context.width, this.context.height)
    const tempContext = tempCanvas.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D

    // 绘制所有路径（包括载入的图像和橡皮擦效果）
    // 注意：传入 true，让 executeOnContext 内部处理 loadedImageBitmap
    // 这样清空操作可以正确清除 loadedImageBitmap
    this.executeOnContext(tempContext, true)

    const drawingDataUrl = tempContext.toDataURL()
    return await PhotoUtils.saveDrawingToBox(drawingDataUrl)
  }

  // 保存画板截图
  private async saveDrawingBoard(): Promise<string | null> {
    await this.getPixelMap()
    if (!this.pixelMap) {
      return null
    }
    return await PhotoUtils.savePixelMapToBox(this.pixelMap)
  }

  // 更新已有画作
  updateExistingDrawing(drawingBoardPath: string, drawingPath: string, now: number): void {
    const existingItem = this.drawingHistoryList.drawingList.find(item => item.id === this.drawingId)!
    existingItem.drawingName = this.title
    existingItem.drawingBoardPath = drawingBoardPath
    existingItem.drawingPath = drawingPath
    existingItem.backgroundSelectType = this.backgroundSelectType
    existingItem.canvasColor = this.canvasColor
    existingItem.canvasBackgroundImage = this.canvasBackgroundImage
    existingItem.gradientColor = [...this.gradientColor]
    existingItem.lastEditTime = TimeUtil.formatDate(now, TimeUtil.PATTERN_DATE_TIME_HYPHEN_HM)
    this.drawingHistoryList.replaceItemById(this.drawingId, existingItem)
  }

  // 合并路径到背景图片
  private mergePathsToBackground(): void {
    if (this.context.width <= 0 || this.context.height <= 0) {
      return
    }
    const mergedCanvas = new OffscreenCanvas(this.context.width, this.context.height)
    const mergedContext = mergedCanvas.getContext('2d', this.settings) as OffscreenCanvasRenderingContext2D
    // 绘制所有内容（包括载入的图像和所有路径）
    this.executeOnContext(mergedContext, true)
    // 合并后的结果作为新的背景图层
    this.loadedImageBitmap = mergedCanvas.transferToImageBitmap()
    this.confirmedPaths = []
    this.undoArray = []
    this.redoArray = []
    this.unDoDraw = false
    this.redoDraw = false
  }

  /**
   * 保存画作（内部方法）
   * 执行实际的保存操作，不包含UI交互
   */
  private async saveDrawingInternal(): Promise<boolean> {
    try {
      // 1. 保存绘画内容
      const drawingPath = await this.saveDrawingContent()
      if (!drawingPath) {
        return false
      }
      // 2. 保存画板截图
      const drawingBoardPath = await this.saveDrawingBoard()
      if (!drawingBoardPath) {
        return false
      }
      // 3. 保存或更新历史记录
      const now = TimeUtil.getTodayTime()
      const timeStr = now.toString()
      if (this.drawingId === '-1') {
        this.addHistory(timeStr, drawingBoardPath, drawingPath, now)
        this.drawingId = timeStr
      } else {
        this.updateExistingDrawing(drawingBoardPath, drawingPath, now)
      }
      // 4. 合并路径到背景
      this.mergePathsToBackground()
      // 5. 标记为已保存
      this.isSave = true
      return true
    } catch (err) {
      return false
    }
  }

  /**
   * 保存新画作
   * @param titleInput 用户输入的标题（可选）
   * @returns 保存是否成功
   */
  async saveNewDrawing(titleInput?: string): Promise<boolean> {
    try {
      // 如果提供了标题，使用用户输入的标题
      if (titleInput) {
        this.title = titleInput
      }
      // 验证并生成标题
      this.titleValidate()
      // 执行保存
      const success = await this.saveDrawingInternal()
      if (success) {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存成功' })
      } else {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存失败,请重试' })
      }
      return success
    } catch (err) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存失败,请重试' })
      return false
    }
  }

  /**
   * 保存已有画作（更新）
   * @returns 保存是否成功
   */
  async saveExistingDrawing(): Promise<boolean> {
    try {
      const success = await this.saveDrawingInternal()
      if (success) {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存成功' })
      } else {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存失败,请重试' })
      }
      return success
    } catch (err) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存失败,请重试' })
      return false
    }
  }

  /**
   * 统一的保存入口
   * 根据当前状态自动判断是新建还是更新
   * @param titleInput 用户输入的标题（仅用于新建画作）
   * @returns 保存是否成功
   */
  async saveDrawing(titleInput?: string): Promise<boolean> {
    if (this.isNewDrawing()) {
      return await this.saveNewDrawing(titleInput)
    } else {
      return await this.saveExistingDrawing()
    }
  }

  addHistory(timeStr: string, drawingBoardPath: string, drawingPath: string, now: number) {
    const history = new DrawingHistoryItem();
    history.id = timeStr;
    history.drawingName = this.title;
    history.drawingBoardPath = drawingBoardPath;
    history.drawingPath = drawingPath;
    history.backgroundSelectType = this.backgroundSelectType;
    history.canvasColor = this.canvasColor;
    history.canvasBackgroundImage = this.canvasBackgroundImage;
    history.gradientColor = [...this.gradientColor];
    history.lastEditTime = TimeUtil.formatDate(now, TimeUtil.PATTERN_DATE_TIME_HYPHEN_HM);
    // 添加到历史列表
    this.drawingHistoryList.addItem(history);
  }

  // 加载画作
  loadDrawing(param: DrawingHistoryItem) {
    try {
      this.drawingId = param.id
      this.title = param.drawingName
      this.backgroundSelectType = param.backgroundSelectType
      this.canvasColor = param.canvasColor
      this.canvasBackgroundImage = param.canvasBackgroundImage
      this.gradientColor = [...param.gradientColor]
      this.loadedImageBitmap = new ImageBitmap(param.drawingPath)
      this.confirmedPaths = []
      this.undoArray = []
      this.redoArray = []
      this.unDoDraw = false
      this.redoDraw = false
      this.tabCurrentIndex = 0
      this.eraserMode = false
      this.shapeMode = false
      this.isDrawingShape = false
      this.currentShape = 'none'
      this.isColorSampling = false
      // 清理缓存和快照
      this.invalidateAllCaches()
      this.renderedSnapshot = undefined
      this.snapshotInvalidated = true
      this.context.strokeStyle = this.color
      this.context.lineWidth = this.strokeWidth
      this.context.lineCap = 'round'
      this.context.globalCompositeOperation = 'source-over'
      if (this.context.width > 0 && this.context.height > 0) {
        this.context.clearRect(0, 0, this.context.width, this.context.height)
      }
      this.execute(this.context)
      this.createSnapshot() // 创建初始快照
      this.isSave = true
    } catch (err) {
    }
  }

  // 清空画布（作为可撤销的操作）
  clearCanvas(): void {
    try {
      // 创建一个特殊的'清空'路径信息
      const clearPath = new Path2D()
      const clearPathInfo = new PathInfo(clearPath, '#000000', 0, 1, false, 'round', 'round',
        true// 标记为清空操作
      )

      // 将清空操作添加到撤销数组（作为可撤销的操作）
      this.redoArray = [] // 清空重做数组
      this.redoDraw = false
      this.unDoDraw = true // 可以撤销
      this.addPathWithLimit(clearPathInfo)
      // 标记所有缓存失效
      this.invalidateAllCaches()
      // 清空画布并重绘（execute会识别清空操作）
      this.execute(this.context)
      this.createSnapshot() // 创建新快照
      this.isSave = false
    } catch (err) {
    }
  }

  // 重置所有状态
  resetAllState(): void {
    this.title = ''
    this.drawingId = '-1'
    this.isSave = true
    this.resetDrawingState()
    this.resetModeState()
    this.resetBackgroundState()
    this.pixelMap = undefined
    this.touchX = 0
    this.touchY = 0
    this.context.globalCompositeOperation = 'source-over'
  }

  // 恢复画布上下文状态
  private restoreCanvasContextState(): void {
    this.context.strokeStyle = this.color
    this.context.lineWidth = this.eraserMode ? this.eraserSize : this.strokeWidth
    this.context.globalAlpha = this.eraserMode ? 1 : this.alpha
    this.context.globalCompositeOperation = this.eraserMode ? 'destination-out' : 'source-over'
    this.context.lineCap = this.context.lineCap || 'round'
    this.context.lineJoin = this.context.lineJoin || 'round'
  }

  // 重绘画布,Canvas 组件重新加载（折叠屏展开/折叠、小窗、分屏等）
  redrawCanvas(): void {
    if (!this.context || this.context.width <= 0 || this.context.height <= 0) {
      return
    }
    // 清除所有缓存（Canvas尺寸可能变化）
    this.invalidateAllCaches()
    this.renderedSnapshot = undefined
    this.snapshotInvalidated = true

    this.context.clearRect(0, 0, this.context.width, this.context.height)
    this.execute(this.context)
    this.createSnapshot() // 创建新快照
    this.restoreCanvasContextState()

  }
}