import { UtilLog } from '@hw-agconnect/util-log';
import { display, PersistenceV2, promptAction } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import DrawInvoker from './DrawInvoker';
import NormalBrush, { IBrush } from './IBrush';
import DrawPath from './IDraw';
import Paint from './Paint';
import { CanvasState, DrawHistory, DrawPos, Pos, SerializedPath, ShapePos, ShapeType } from '../model/Model';
import { PhotoUtils } from '../utils/PhotoUtils';
import { baseToast } from '../components/ConfirmDialog';

@ObservedV2
export class DrawBoardVM {
  private static _instance: DrawBoardVM
  pathStack: NavPathStack = new NavPathStack()
  @Trace tabCurrentIndex: number = 0
  @Trace unDoDraw: boolean = false;
  @Trace redoDraw: boolean = false;
  private paths: DrawPath[] = [];
  @Trace isPaint: boolean = true;
  @Trace isShow: boolean = false;
  @Trace penSelectIndex: number = 0;
  @Trace colorSelectIndex: number = 7;
  @Trace scaleValueX: number = 1;
  @Trace scaleValueY: number = 1;
  @Trace pinchValueX: number = 1;
  @Trace pinchValueY: number = 1;
  @Trace strokeWidth: number = 3;
  @Trace alpha: number = 1;
  @Trace backgroundAlpha: number = 1;
  @Trace eraserSize: number = 15;
  @Trace color: string = '#191919';
  @Trace thicknessesValue: number = 10;
  @Trace index: number = -1;
  @Trace clean: boolean = false;
  @Trace percent: string = '100';
  @Trace mPaint: Paint = new Paint(0, '', 1);
  @Trace mBrush: IBrush = new NormalBrush();
  @Trace canvasBackgroundImage: ResourceStr = ''
  @Trace canvasColor: string = '#ffffff'
  public setting: RenderingContextSettings = new RenderingContextSettings(true);
  @Trace context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
  public drawInvoker: DrawInvoker = new DrawInvoker();
  public path2Db: Path2D = new Path2D();
  public mPath: DrawPath = new DrawPath(this.mPaint, this.path2Db);
  public arr: number[] = [];
  @Trace isDrawing: boolean = false;
  @Trace sprayDensity: number = 30; // 喷笔密度（点数量）
  @Trace sprayRadius: number = 1; // 喷笔影响半径
  @Trace shapeMode: boolean = false; // 是否处于图形模式
  @Trace currentShape: ShapeType = ShapeType.NONE; // 当前选择的图形类型
  @Trace startX: number = 0; // 图形起始点X坐标
  @Trace startY: number = 0; // 图形起始点Y坐标
  @Trace isDrawingShape: boolean = false; // 是否正在绘制图形
  @Trace title: string = ''
  @Trace isOnSave: boolean = true
  @Trace drawHistory: DrawHistory = PersistenceV2.connect(DrawHistory, () => new DrawHistory())!;
  private lastDrawTime = 0;
  private readonly DRAW_INTERVAL = 16;
  @Trace currentEditIndex: number = -1

  @Monitor('isDrawing')
  createDraw() {
    if (this.isDrawing) {
      this.context.fillStyle = Color.Transparent;
      this.context.fillRect(CommonConstants.ZERO, CommonConstants.ZERO, this.context.width, this.context.height);
      this.drawInvoker.execute(this.context);
      this.isDrawing = false;
    }
  }

  @Monitor('canvasColor')
  createDrawColor() {
    this.context.fillStyle = this.canvasColor;
    this.context.fillRect(CommonConstants.ZERO, CommonConstants.ZERO, this.context.width, this.context.height);
    this.drawInvoker.execute(this.context);
  }

  public static get instance() {
    if (!DrawBoardVM._instance) {
      DrawBoardVM._instance = new DrawBoardVM()
    }
    return DrawBoardVM._instance
  }

  initDrawBord() {
    this.mPaint = new Paint(CommonConstants.THREE, CommonConstants.COLOR_STRING, CommonConstants.ONE);
    this.mPaint.setStrokeWidth(CommonConstants.THREE);
    this.mPaint.setColor(CommonConstants.BLACK);
    this.mPaint.setGlobalAlpha(CommonConstants.ONE);
    this.mBrush = new NormalBrush();
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        if (data === 2) {
          this.scaleValueX = 0.5;
          this.pinchValueX = 0.5;
          this.scaleValueY = 1;
          this.pinchValueY = 1;
          this.context.clearRect(0, 0, this.context.width, this.context.height);
          this.drawInvoker.execute(this.context);
        } else if (data === 1) {
          this.scaleValueX = 1;
          this.scaleValueY = 1;
          this.pinchValueX = 1;
          this.pinchValueY = 1;
          this.context.clearRect(0, 0, this.context.width, this.context.height);
          this.drawInvoker.execute(this.context);
        }
      })
    } catch (e) {
      UtilLog.error(`initDrawBord failed with error ${JSON.stringify(e)}`);
    }
  }

  handleTouch(event: TouchEvent) {
    this.clean = false;
    this.isOnSave = true
    if (event.touches.length > 1) {
      return;
    }
    this.arr.push(event.touches[0].x + event.touches[0].y);
    if (this.tabCurrentIndex === 2 && this.shapeMode) {
      this.handleShapeDrawing(event, event.touches[0].x, event.touches[0].y);
    } else {
      if (event.touches.length === 1 && event.touches[0].id === 0 && event.type === TouchType.Down) {
        this.mPath = new DrawPath(this.mPaint, this.path2Db);
        this.mPath.paint = this.mPaint;
        this.mPath.path = new Path2D();
        this.context.clearRect(0, 0, this.context.width, this.context.height);
        this.mBrush.down(this.mPath.path, event.touches[0].x, event.touches[0].y);
        this.mPath.addPoint(event.touches[0].x, event.touches[0].y);
      }
      if (event.touches.length === 1 && event.touches[0].id === 0 && event.type === TouchType.Move) {
        const now = Date.now();
        if (now - this.lastDrawTime > this.DRAW_INTERVAL) {
          this.mBrush.move(this.mPath.path, event.touches[0].x, event.touches[0].y);
          this.context.clearRect(0, 0, this.context.width, this.context.height);
          this.mPath.addPoint(event.touches[0].x, event.touches[0].y);
          this.drawInvoker.execute(this.context);
          if (this.arr.length > 4) {
            this.mPath.draw(this.context);
          }
          this.lastDrawTime = now;
        }
      }
      if (event.touches.length === 1 && event.touches[0].id === 0 && event.type === TouchType.Up) {
        this.add(this.mPath);
        this.arr = [];
        this.redoDraw = false;
        this.unDoDraw = true;
        this.context.clearRect(0, 0, this.context.width, this.context.height);
        this.paths.push(this.mPath);
        this.drawInvoker.execute(this.context);
      }
    }
  }

  // 添加图形绘制处理函数
  public handleShapeDrawing(event: TouchEvent, x: number, y: number): void {
    if (event.type === TouchType.Down) {
      this.startShapeDrawing(this.currentShape, x, y);
    } else if (event.type === TouchType.Move) {
      this.drawShapePreview(x, y);
    } else if (event.type === TouchType.Up) {
      this.finishShapeDrawing(x, y);
    }
  }

  // 添加图形绘制方法
  public startShapeDrawing(shapeType: ShapeType, x: number, y: number): void {
    this.shapeMode = true;
    this.currentShape = shapeType;
    this.unDoDraw = true;
    this.startX = x;
    this.startY = y;
    this.isDrawingShape = true;
    if (shapeType === ShapeType.TRIANGULAR || shapeType === ShapeType.ARROW) {
      this.drawShapePreview(x, y);
    }
  }

  public drawShapePreview(x: number, y: number): void {
    if (!this.isDrawingShape || this.currentShape === ShapeType.NONE) {
      return;
    }

    // 清除画布并重绘所有内容
    this.context.clearRect(0, 0, this.context.width, this.context.height);
    this.drawInvoker.execute(this.context);

    // 绘制当前图形的预览
    this.drawShape(this.context, this.startX, this.startY, x, y, this.currentShape, true);
  }

  public finishShapeDrawing(x: number, y: number): void {
    if (!this.isDrawingShape || this.currentShape === ShapeType.NONE) {
      return;
    }

    // 创建图形路径并添加到撤销重做系统
    const shapePath = this.createShapePath(this.startX, this.startY, x, y, this.currentShape);
    this.add(shapePath);
    // 重置绘制状态但不退出图形模式
    this.isDrawingShape = false;
    this.context.clearRect(0, 0, this.context.width, this.context.height);
    this.drawInvoker.execute(this.context);
    this.drawInvoker.addShapePoints({
      shapeType: this.currentShape,
      startX: this.startX,
      startY: this.startY,
      x,
      y,
      color: this.color,
      strokeWidth: this.strokeWidth,
      alpha: 1,
    });
  }

  // 退出图形模式
  public exitShapeMode(): void {
    this.shapeMode = false;
    this.currentShape = ShapeType.NONE;
    this.isDrawingShape = false;
  }

  private createShapePath(startX: number, startY: number, endX: number, endY: number, shapeType: ShapeType): DrawPath {
    const path = new Path2D();
    this.drawShapeToPath(path, startX, startY, endX, endY, shapeType);

    const shapePaint = new Paint(
      CommonConstants.ZERO,
      CommonConstants.COLOR_STRING,
      CommonConstants.ONE,
    );
    shapePaint.setStrokeWidth(this.strokeWidth);
    shapePaint.setColor(this.color);
    shapePaint.setGlobalAlpha(1);

    return new DrawPath(shapePaint, path);
  }

  private drawShape(context: CanvasRenderingContext2D, startX: number, startY: number, endX: number, endY: number,
    shapeType: ShapeType, isPreview: boolean = false): void {
    context.save();

    if (isPreview) {
      // 预览模式使用虚线
      context.setLineDash([5, 5]);
      context.strokeStyle = this.color;
      context.globalAlpha = this.alpha * 0.7;
    } else {
      context.strokeStyle = this.color;
      context.globalAlpha = this.alpha;
    }

    context.lineWidth = this.strokeWidth;

    // 对于直线和箭头，使用圆滑的端点
    if (shapeType === ShapeType.TRIANGULAR || shapeType === ShapeType.ARROW) {
      context.lineCap = 'round';
      context.lineJoin = 'round';
    }

    context.beginPath();

    const width = endX - startX;
    const height = endY - startY;

    switch (shapeType) {
      case ShapeType.RECTANGLE:
        context.rect(startX, startY, width, height);
        break;

      case ShapeType.CIRCLE:
        const radius = Math.sqrt(width * width + height * height) / 2;
        context.arc(startX + width / 2, startY + height / 2, radius, 0, Math.PI * 2);
        break;

      case ShapeType.TRIANGLE:
        this.drawTriangle(context, startX, startY, endX, endY);
        break;

      case ShapeType.PENTAGON:
        this.drawPentagon(context, startX, startY, endX, endY);
        break;

      case ShapeType.STAR:
        this.drawStar(context, startX, startY, endX, endY);
        break;
      case ShapeType.TRIANGULAR:
        context.moveTo(startX, startY);
        context.lineTo(endX, endY);
        break;

      case ShapeType.ARROW:
        this.drawArrow(context, startX, startY, endX, endY);
        break;
    }
    context.stroke();
    context.restore();
  }

  private drawShapeToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number,
    shapeType: ShapeType): void {
    const width = endX - startX;
    const height = endY - startY;

    switch (shapeType) {
      case ShapeType.RECTANGLE:
        path.rect(startX, startY, width, height);
        break;

      case ShapeType.CIRCLE:
        const radius = Math.sqrt(width * width + height * height) / 2;
        path.arc(startX + width / 2, startY + height / 2, radius, 0, Math.PI * 2);
        break;

      case ShapeType.TRIANGLE:
        this.drawTriangleToPath(path, startX, startY, endX, endY);
        break;

      case ShapeType.PENTAGON:
        this.drawPentagonToPath(path, startX, startY, endX, endY);
        break;

      case ShapeType.STAR:
        this.drawStarToPath(path, startX, startY, endX, endY);
        break;
      case ShapeType.TRIANGULAR:
        this.drawLineToPath(path, startX, startY, endX, endY);
        break;

      case ShapeType.ARROW:
        this.drawArrowToPath(path, startX, startY, endX, endY);
        break;
    }
  }

  // 绘制五角形（正五边形）
  private drawPentagon(context: CanvasRenderingContext2D, startX: number, startY: number, endX: number,
    endY: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const radius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;

    context.moveTo(centerX + radius * Math.cos(0), centerY + radius * Math.sin(0));

    for (let i = 1; i <= 5; i++) {
      const angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
      context.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle));
    }

    context.closePath();
  }

  private drawPentagonToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const radius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;

    path.moveTo(centerX + radius * Math.cos(0), centerY + radius * Math.sin(0));

    for (let i = 1; i <= 5; i++) {
      const angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
      path.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle));
    }

    path.closePath();
  }

  // 绘制箭头
  private drawArrow(context: CanvasRenderingContext2D, startX: number, startY: number, endX: number,
    endY: number): void {
    const arrowLength = 20;
    const arrowWidth = 10;

    // 绘制主线
    context.moveTo(startX, startY);
    context.lineTo(endX, endY);

    // 计算箭头方向
    const angle = Math.atan2(endY - startY, endX - startX);

    // 绘制箭头头部
    const arrowPoint1: Pos = {
      x: endX - arrowLength * Math.cos(angle) + arrowWidth * Math.sin(angle),
      y: endY - arrowLength * Math.sin(angle) - arrowWidth * Math.cos(angle),
    };

    const arrowPoint2: Pos = {
      x: endX - arrowLength * Math.cos(angle) - arrowWidth * Math.sin(angle),
      y: endY - arrowLength * Math.sin(angle) + arrowWidth * Math.cos(angle),
    };

    context.moveTo(endX, endY);
    context.lineTo(arrowPoint1.x, arrowPoint1.y);
    context.moveTo(endX, endY);
    context.lineTo(arrowPoint2.x, arrowPoint2.y);
  }

  // 绘制五角星
  private drawStar(context: CanvasRenderingContext2D, startX: number, startY: number, endX: number,
    endY: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const outerRadius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;
    const innerRadius = outerRadius * 0.4;

    context.moveTo(centerX + outerRadius * Math.cos(0 - Math.PI / 2),
      centerY + outerRadius * Math.sin(0 - Math.PI / 2));

    for (let i = 0; i < 5; i++) {
      // 外点
      const outerAngle = (i * 2 * Math.PI / 5) - Math.PI / 2;
      context.lineTo(centerX + outerRadius * Math.cos(outerAngle), centerY + outerRadius * Math.sin(outerAngle));

      // 内点
      const innerAngle = ((i + 0.5) * 2 * Math.PI / 5) - Math.PI / 2;
      context.lineTo(centerX + innerRadius * Math.cos(innerAngle), centerY + innerRadius * Math.sin(innerAngle));
    }

    context.closePath();
  }

  // 绘制直线
  private drawLineToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number): void {
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);
  }

  // 绘制箭头
  private drawArrowToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number): void {
    const arrowLength = 20;
    const arrowWidth = 10;

    path.moveTo(startX, startY);
    path.lineTo(endX, endY);

    const angle = Math.atan2(endY - startY, endX - startX);

    const arrowPoint1: Pos = {
      x: endX - arrowLength * Math.cos(angle) + arrowWidth * Math.sin(angle),
      y: endY - arrowLength * Math.sin(angle) - arrowWidth * Math.cos(angle),
    };

    const arrowPoint2: Pos = {
      x: endX - arrowLength * Math.cos(angle) - arrowWidth * Math.sin(angle),
      y: endY - arrowLength * Math.sin(angle) + arrowWidth * Math.cos(angle),
    };

    // 绘制箭头头部
    path.moveTo(endX, endY);
    path.lineTo(arrowPoint1.x, arrowPoint1.y);
    path.moveTo(endX, endY);
    path.lineTo(arrowPoint2.x, arrowPoint2.y);
  }

  private drawStarToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const outerRadius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;
    const innerRadius = outerRadius * 0.4;

    path.moveTo(centerX + outerRadius * Math.cos(0 - Math.PI / 2), centerY + outerRadius * Math.sin(0 - Math.PI / 2));

    for (let i = 0; i < 5; i++) {
      const outerAngle = (i * 2 * Math.PI / 5) - Math.PI / 2;
      path.lineTo(centerX + outerRadius * Math.cos(outerAngle), centerY + outerRadius * Math.sin(outerAngle));

      const innerAngle = ((i + 0.5) * 2 * Math.PI / 5) - Math.PI / 2;
      path.lineTo(centerX + innerRadius * Math.cos(innerAngle), centerY + innerRadius * Math.sin(innerAngle));
    }

    path.closePath();
  }

  // 绘制三角形
  private drawTriangle(context: CanvasRenderingContext2D, startX: number, startY: number, endX: number,
    endY: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const radius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;

    context.moveTo(centerX + radius * Math.cos(0 - Math.PI / 2), centerY + radius * Math.sin(0 - Math.PI / 2));

    for (let i = 1; i < 3; i++) {
      const angle = (i * 2 * Math.PI / 3) - Math.PI / 2;
      context.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle));
    }

    context.closePath();
  }

  private drawTriangleToPath(path: Path2D, startX: number, startY: number, endX: number, endY: number): void {
    const centerX = startX + (endX - startX) / 2;
    const centerY = startY + (endY - startY) / 2;
    const radius = Math.min(Math.abs(endX - startX), Math.abs(endY - startY)) / 2;

    path.moveTo(centerX + radius * Math.cos(0 - Math.PI / 2), centerY + radius * Math.sin(0 - Math.PI / 2));

    for (let i = 1; i < 3; i++) {
      const angle = (i * 2 * Math.PI / 3) - Math.PI / 2;
      path.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle));
    }

    path.closePath();
  }

  // 取消图形绘制
  public cancelShapeDrawing(): void {
    this.isDrawingShape = false;
    this.shapeMode = false;
    this.currentShape = ShapeType.NONE;
    this.context.clearRect(0, 0, this.context.width, this.context.height);
    this.drawInvoker.execute(this.context);
  }

  add(path: DrawPath): void {
    this.drawInvoker.add(path);
  }

  ToggleThicknessColor(): void {
    this.mPaint = new Paint(CommonConstants.ZERO, CommonConstants.COLOR_STRING, CommonConstants.ONE);
    this.mPaint.setStrokeWidth(this.strokeWidth);
    this.mPaint.setColor(this.color);
    this.mPaint.setGlobalAlpha(this.alpha);
    this.mBrush = new NormalBrush();
  }

  drawOperateUndo(): void {
    this.drawInvoker.undo();
    this.isDrawing = true;
    if (!this.drawInvoker.canUndo()) {
      this.unDoDraw = false;
    }
    this.redoDraw = true;
  }

  drawOperateRedo(): void {
    this.drawInvoker.redo();
    this.isDrawing = true;
    if (!this.drawInvoker.canRedo()) {
      this.redoDraw = false;
    }
    this.unDoDraw = true;
  }

  clear(): void {
    this.drawInvoker.clear();
    this.isDrawing = true;
    this.redoDraw = false;
    this.unDoDraw = false;
    this.canvasColor = '#FFFFFF'
    this.title = ''
    this.currentEditIndex = -1
    this.penSelectIndex = 0;
    this.strokeWidth = 3;
    this.canvasBackgroundImage = ''
  }

  drawInvokerClear() {
    this.drawInvoker.clear();
    this.redoDraw = false;
    this.unDoDraw = false;
  }

  /*
   * 圆珠笔
   * */
  drawWithBallpointPen(index: number) {
    this.penSelectIndex = index
    this.alpha = 1;
    this.percent = '100';
    this.ToggleThicknessColor();
  }

  /*
   * 马克笔
   * */
  drawWithMarkerPen(index: number) {
    this.penSelectIndex = index
    this.ToggleThicknessColor();
  }

  /*
   * 铅笔
   * */
  drawWithPencilPen(index: number) {
    this.penSelectIndex = index
    this.alpha = 0.6
    this.percent = '100'
    this.ToggleThicknessColor()
  }

  /*
   * 钢笔
   * */
  drawWithFountainPen(index: number) {
    this.penSelectIndex = index
    this.percent = '100'
    this.alpha = 1
    this.ToggleThicknessColor()
  }

  /*
   * 喷笔
   * */
  drawWithSprayPen(index: number) {
    this.penSelectIndex = index
  }

  public setEraserSize(size: number): void {
    this.eraserSize = Math.max(5, Math.min(50, size)); // 限制橡皮擦大小范围
  }

  /*
   * 橡皮擦
   * */
  public activateEraser(): void {
    this.mPaint = new Paint(CommonConstants.ZERO, CommonConstants.COLOR_STRING, CommonConstants.ONE);
    this.mPaint.setStrokeWidth(this.eraserSize);
    this.mPaint.setColor(this.canvasColor);
    this.mPaint.setGlobalAlpha(CommonConstants.ONE);
    this.isPaint = false;
  }

  /*
   * 判断是否有绘画路径
   * */
  public hasContent(): boolean {
    const hasDrawingPaths = this.drawInvoker.hasPaths();
    return hasDrawingPaths && this.isOnSave;
  }

  /*
   * 返回提醒
   * */
  saveNotice(uiContext: UIContext) {
    if (this.hasContent()) {
      baseToast.show({
        type: 'dialog',
        hasTitle: '温馨提示',
        message: '当前绘画未保存，请确认是否退出',
        confirmAction: () => {
          baseToast.hide();
          this.pathStack.pop()
        },
      }, uiContext);
      return true;
    }
    return false;
  }

  // 序列化路径
  private serializePaths(): SerializedPath[] {
    const serializedPaths: SerializedPath[] = [];

    // 获取所有路径
    const paths = this.drawInvoker.getAllPaths();

    for (const path of paths) {
      serializedPaths.push({
        points: path.getPoints(),
        color: path.paint.strokeStyle,
        strokeWidth: path.paint.lineWidth,
        alpha: path.paint.globalAlpha,
        brushType: 'normal',
      });
    }

    return JSON.parse(JSON.stringify(serializedPaths));
  }

  public serializeCanvas(): CanvasState {
    const state: CanvasState = {
      title: this.title,
      paths: this.serializePaths(),
      shapePoints: this.drawInvoker.getShapePoints(),
      brushType: 'normal',
      backgroundColor: this.canvasColor,
      backgroundImage: this.canvasBackgroundImage,
      width: this.context.width,
      height: this.context.height,
      time: new Date().getTime(),
      thumbnail: this.context.toDataURL('image/png', 0.92),
    };

    return state;
  }


  public loadFromSerializedData(canvasInfo?: CanvasState): void {
    if (!canvasInfo) {
      return
    }
    this.canvasBackgroundImage = canvasInfo.backgroundImage
    this.canvasColor = canvasInfo.backgroundColor
    this.paths = [];
    this.context.clearRect(0, 0, this.context.width, this.context.height);

    canvasInfo.paths.forEach(serializedPath => {
      const path = this.createPathFromSerialized(serializedPath);
      this.paths.push(path);
    });
    canvasInfo.shapePoints.forEach(serializedPath => {
      const path = this.createShapePathFromSerialized(serializedPath);
      this.paths.push(path);
    });
    this.redrawCanvas();
  }


  // 从序列化数据创建路径
  private createPathFromSerialized(serialized: SerializedPath): DrawPath {
    const paint = new Paint(serialized.strokeWidth, serialized.color, serialized.alpha);
    const path2Db: Path2D = new Path2D();
    const path = new DrawPath(paint, path2Db);
    this.mPath = path
    // 重建路径点
    if (serialized.points && serialized.points.length >= 2) {
      path.rebuildFromPoints(serialized.points);
    }
    return path;
  }

  // 从序列化数据创建路径
  private createShapePathFromSerialized(serialized: ShapePos): DrawPath {
    const paint = new Paint(serialized.strokeWidth, serialized.color, serialized.alpha);
    const path2Db: Path2D = new Path2D();
    const path = new DrawPath(paint, path2Db);
    this.mPath = path
    path.drawShapeFromData(serialized);
    return path;
  }

  // 重绘画布
  private redrawCanvas(): void {
    // 清除画布
    this.context.clearRect(0, 0, this.context.width, this.context.height);

    // 绘制所有路径
    this.paths.forEach((path, index) => {
      // 如果是选中的路径，改变颜色以示区别
      path.draw(this.context);
    });
    this.drawInvoker.loadPaths(this.paths)
    this.drawOperateUndo()
    this.drawOperateRedo()
  }

  public validate(uiContext: UIContext) {
    if (this.title) {
      return true
    }
    uiContext.getPromptAction().showToast({ message: '请输入名称' })
    return false
  }

  public saveDrawBoard() {
    this.isOnSave = false
    this.context.clearRect(0, 0, this.context.width, this.context.height);
    this.context.fillStyle = this.canvasColor;
    this.context.fillRect(CommonConstants.ZERO, CommonConstants.ZERO, this.context.width, this.context.height);
    this.drawInvoker.execute(this.context);
    const canvasData = this.serializeCanvas();
    if (this.currentEditIndex !== -1) {
      this.drawHistory.drawInfoList.splice(this.currentEditIndex, 1)
    }
    this.drawHistory.drawInfoList.unshift(canvasData)
    this.title = ''
    PersistenceV2.save(DrawHistory);
  }
}