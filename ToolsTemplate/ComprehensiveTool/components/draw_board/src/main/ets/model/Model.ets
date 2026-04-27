import { Type } from '@kit.ArkUI'

export enum ShapeType {
  NONE = 'none',
  RECTANGLE = 'rectangle',
  CIRCLE = 'circle',
  TRIANGLE = 'triangle',
  PENTAGON = 'pentagon',
  STAR = 'star',
  TRIANGULAR = 'triangular',
  ARROW = 'arrow'
}


export class ShapePos {
  x: number = 0
  y: number = 0
  startX: number = 0
  startY: number = 0
  shapeType: ShapeType = ShapeType.NONE
  color: string = ''
  strokeWidth: number = 0
  alpha: number = 0
}


export interface DrawPos {
  x: number
  y: number
  width: number
  height: number
}

export interface PencilPos {
  x: number
  y: number
  w: number
}

// CanvasProject.ets
export interface CanvasProject {
  id: string;
  name: string;
  createTime: number;
  updateTime: number;
  thumbnail: string; // 缩略图base64
  canvasData: string; // 画布数据JSON
  pathCount: number; // 路径数量
}

export class Pos {
  x: number = 0
  y: number = 0
}

// 序列化的路径
@ObservedV2
export class SerializedPath {
  @Type(Pos)
  points?: Pos[] = []; // 路径点数据
  color: string = ''; // 路径颜色
  strokeWidth: number = 1; // 线条宽度
  alpha: number = 1; // 透明度
  brushType: string = ''; // 画笔类型
}

// 画布数据接口
@ObservedV2
export class CanvasState {
  @Type(SerializedPath)
  paths: SerializedPath[] = [];
  backgroundColor: string = '';
  @Type(ShapePos)
  shapePoints: ShapePos[] = []
  brushType: string = ''
  backgroundImage: ResourceStr = '';
  width: number = 0;
  height: number = 0;
  thumbnail: string = ''
  @Trace title: string = ''
  time: number = 0
}


/**
 * 绘画历史
 */
@ObservedV2
export class DrawHistory {
  @Type(CanvasState)
  @Trace drawInfoList: CanvasState[] = [];
}