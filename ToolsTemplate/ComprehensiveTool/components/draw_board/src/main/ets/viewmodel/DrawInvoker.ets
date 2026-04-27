import { ShapePos } from '../model/Model';
import DrawPath from './IDraw';

// 修改DrawInvoker
export default class DrawInvoker {
  private undoStack: DrawPath[] = [];
  private redoStack: DrawPath[] = [];
  private shapePoints: ShapePos[] = []

  add(path: DrawPath): void {
    this.undoStack.push(path);
    this.redoStack = [];
  }
  addShapePoints(shapePoints: ShapePos): void {
    this.shapePoints.push(shapePoints)
  }

  getShapePoints(): ShapePos[] {
    return [...this.shapePoints]
  }

  undo(): void {
    if (this.canUndo()) {
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
    if (this.canRedo()) {
      const path = this.redoStack.pop();
      if (path) {
        this.undoStack.push(path);
      }
    }
  }

  clear(): void {
    this.undoStack = [];
    this.redoStack = [];
    this.shapePoints = []
  }

  execute(context: CanvasRenderingContext2D): void {
    if (this.undoStack !== null) {
      this.undoStack.forEach((element: DrawPath) => {
        element.draw(context);
      });
    }
  }

  // 获取所有路径（用于序列化）
  public getAllPaths(): DrawPath[] {
    return [...this.undoStack];
  }

  // 加载路径（用于反序列化）
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

  getPathCount(): number {
    return this.undoStack.length;
  }
}