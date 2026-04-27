import { EditTextVM } from '../viewmodel/EditTextVM';
import { DisplayUtil } from './DisplayUtil';

export type Point2D = [number, number];

/**
 * 旋转方向枚举（匹配CSS/Canvas默认行为）
 */
export enum RotationDirection {
  CLOCKWISE, // 顺时针（CSS transform: rotate 默认）
  COUNTER_CLOCKWISE // 逆时针（Canvas ctx.rotate 默认）
}

export enum CommonSize {
  VIDEO_MARGIN_TOP = 124, //视频距离顶部距离
  EDIT_TEXT_DEFAULT_WIDTH = 130, //编辑框的默认宽度
  EDIT_TEXT_DEFAULT_HEIGHT = 44, //编辑框的默认高度
  EDIT_TEXT_MIN_WIDTH = 50, //编辑框的最小宽度
  EDIT_TEXT_MIN_HEIGHT = 22, //编辑框的最小高度
  EDIT_TEXT_LINE_HEIGHT = 22, //编辑框的行高
  PROMPTER_TEXT_HEADER_WIDTH = 14, //轨道文本的左右拖动元素的宽度
  PROMPTER_TEXT_DIS = 2, //轨道文本之间的最小间隔
  PROMPTER_MIN_WIDTH = 50, //轨道文本最小宽度
  ONE_SECOND_WIDTH = 50, //轨道文本最小宽度
  PROMPTER_DEFAULT_WIDTH = 50, //轨道文本默认宽度
  ONE_LINE_TIME = 3 //多久滚动一行，单位（秒）
}

//获取两点之间的距离
export function calculate2DDistance(p1: Point2D, p2: Point2D): number {
  // 校验坐标格式（确保是 [x, y] 格式的数字数组）
  const validatePoint = (point: Point2D, name: string) => {
    if (
      point.length !== 2 ||
        typeof point[0] !== 'number' ||
      isNaN(point[0]) ||
        typeof point[1] !== 'number' ||
      isNaN(point[1])
    ) {
      throw new Error(`无效的2D坐标点${name}：必须是 [x, y] 格式的有效数字数组`);
    }
  };

  validatePoint(p1, 'p1');
  validatePoint(p2, 'p2');

  // 欧几里得距离公式：distance = √[(x2 - x1)² + (y2 - y1)²]
  const dx = p2[0] - p1[0]; // x轴差值
  const dy = p2[1] - p1[1]; // y轴差值
  const distance = Math.sqrt(dx**2 + dy**2);

  // 保留4位小数（避免浮点数精度冗余，可根据需求调整）
  return Number(distance.toFixed(4));
}

/*
 * 获取角度
 * vertex:顶点
 * */
export function getAngle(centerX: number, centerY: number, touchX: number, touchY: number): number {
  // 计算鼠标相对于中心的偏移量
  const dx = touchX - centerX;
  const dy = touchY - centerY;
  // atan2(dy, dx) 返回弧度制（范围 -180~180），转成 0~360 度
  let angle = (Math.atan2(dy, dx) * 180) / Math.PI;
  return angle < 0 ? angle + 360 : angle;
}

/**
 * 将世界坐标系的平移向量，转换为旋转后的局部坐标系平移向量
 * @param dx 世界坐标系 x 轴平移量（屏幕左右）
 * @param dy 世界坐标系 y 轴平移量（屏幕上下）
 * @param rotateDeg 元素已旋转的角度（度）
 * @returns 局部坐标系的平移量 [dx', dy']
 */
export function convertWorldTranslateToLocal(dx: number, dy: number, rotateDeg: number): [number, number] {
  const theta = (rotateDeg * Math.PI) / 180; // 度转弧度
  // 反向旋转矩阵：x' = dx*cosθ + dy*sinθ; y' = -dx*sinθ + dy*cosθ
  const dxLocal = dx * Math.cos(theta) - dy * Math.sin(theta);
  const dyLocal = dx * Math.sin(theta) + dy * Math.cos(theta);
  return [Math.round(dxLocal * 1000) / 1000, Math.round(dyLocal * 1000) / 1000]; // 保留3位小数
}

/**
 * 计算「点围绕旋转中心旋转后的视觉坐标」
 * @param originalPoint 原始起始点（旋转前的坐标）
 * @param rotationCenter 旋转中心坐标
 * @param rotateDeg 旋转角度（度）
 * @param direction 旋转方向（默认顺时针，匹配CSS）
 * @returns 旋转后的视觉坐标（保留4位小数）
 */
export function calculateRotatedPoint(
  originalPoint: Point2D,
  rotationCenter: Point2D,
  rotateDeg: number,
  direction: RotationDirection = RotationDirection.CLOCKWISE
): Point2D {
  const x0 = originalPoint[0];
  const y0 = originalPoint[1];
  const cx = rotationCenter[0];
  const cy = rotationCenter[1];
  const theta = (rotateDeg * Math.PI) / 180; // 度转弧度

  // 步骤1：原始点 → 旋转中心的局部坐标
  const dx = x0 - cx;
  const dy = y0 - cy;

  let xRotatedLocal: number;
  let yRotatedLocal: number;

  // 步骤2：应用旋转矩阵（根据方向选择公式）
  if (direction === RotationDirection.COUNTER_CLOCKWISE) {
    // 逆时针旋转矩阵（CSS默认）
    xRotatedLocal = dx * Math.cos(theta) + dy * Math.sin(theta);
    yRotatedLocal = -dx * Math.sin(theta) + dy * Math.cos(theta);
  } else {
    // 顺时针旋转矩阵（Canvas默认）
    xRotatedLocal = dx * Math.cos(theta) - dy * Math.sin(theta);
    yRotatedLocal = dx * Math.sin(theta) + dy * Math.cos(theta);
  }

  // 步骤3：局部坐标 → 世界坐标系（视觉坐标）
  const xVisual = cx + xRotatedLocal;
  const yVisual = cy + yRotatedLocal;

  // 保留4位小数，避免浮点数精度冗余
  return [Number(xVisual.toFixed(4)), Number(yVisual.toFixed(4))];
}

export function getTopEiditTextPosition(areaWidth: number, areaHeight: number, width: number, height: number) {
  let x = (areaWidth - width) / 2
  let y = (areaHeight - height) / 2
  return {
    x: x,
    y: y
  } as Position
}

//返回符合条件的数据
export function getMultiData(data: EditTextVM[], i: number) {
  return data.filter((item, index) => {
    return i !== index
  })
}

//检测目标文本与其他文本占用位置是否重叠
export function hasAnyOverlap(target: EditTextVM, segment: EditTextVM[]) {
  let res = false
  for (const temp of segment) {
    if (checkSingleOverlap(target, temp)) {
      res = true
      break
    }
  }
  return res
}

//一对一检测文本占用位置是否重叠
export function checkSingleOverlap(target: EditTextVM, singleSegment: EditTextVM) {
  let tMin = target.prompterX + CommonSize.PROMPTER_TEXT_HEADER_WIDTH
  let tMax = tMin + target.prompterWidth
  let sMin = singleSegment.prompterX + CommonSize.PROMPTER_TEXT_HEADER_WIDTH
  let sMax = sMin + singleSegment.prompterWidth
  const isOverlap = tMin <= sMax && sMin <= tMax
  return isOverlap
}

export function sort(singleSegment: EditTextVM[]) {
  return singleSegment.sort((a, b) => {
    return a.prompterX - b.prompterX
  })
}