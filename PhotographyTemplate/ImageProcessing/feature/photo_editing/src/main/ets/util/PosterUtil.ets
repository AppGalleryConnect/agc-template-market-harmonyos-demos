import { PosterRegion, XY } from '../model/CollageModel';

export class PosterUtil {
  static mapPointToDisplay(p: XY, scaleX: number, scaleY: number, offX: number, offY: number): XY {
    const x = offY ? offX + p.x * scaleX : p.x * scaleX;
    const y = offX ? offY + p.y * scaleY : p.y * scaleY
    return { x, y };
  }

  // 求包围盒
  static bboxOfPoints(pts: XY[]) {
    const xs = pts.map(p => p.x), ys = pts.map(p => p.y);
    const minX = Math.min(...xs), minY = Math.min(...ys);
    const maxX = Math.max(...xs), maxY = Math.max(...ys);
    let posterRegion = new PosterRegion();
    posterRegion.x = minX;
    posterRegion.y = minY;
    posterRegion.width = maxX - minX;
    posterRegion.height = maxY - minY;
    return posterRegion;
  }

  // 生成局部Path（把点平移到以包围盒左上角为 0,0 的局部坐标）
  static localPathFromAbsPoints(ptsAbs: XY[]) {
    const segs = [`M ${ptsAbs[0].x} ${ptsAbs[0].y}`, ...ptsAbs.slice(1).map(p => `L ${p.x} ${p.y}`), 'Z'];
    return segs.join(' ');
  }
}