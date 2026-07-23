import { image } from '@kit.ImageKit';

// Image格式与PixelMap格式映射关系。
export const formatToPixelMapFormatMap = new Map<number, image.PixelMapFormat>([
  [12, image.PixelMapFormat.RGBA_8888],
  [25, image.PixelMapFormat.NV21],
  [35, image.PixelMapFormat.YCBCR_P010],
  [36, image.PixelMapFormat.YCRCB_P010],
]);

// PixelMapFormat格式的单个像素点大小映射关系。
export const pixelMapFormatToSizeMap = new Map<image.PixelMapFormat, number>([
  [image.PixelMapFormat.RGBA_8888, 4],
  [image.PixelMapFormat.NV21, 1.5],
  [image.PixelMapFormat.YCBCR_P010, 3],
  [image.PixelMapFormat.YCRCB_P010, 3],
]);