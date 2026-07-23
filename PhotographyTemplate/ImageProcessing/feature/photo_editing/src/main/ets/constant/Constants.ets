import { image } from '@kit.ImageKit';
import { PRESETS, CustomFilter } from 'commonlib';
import { ImageTextItem, ScrawlInfo, MosaicInfo } from '../model/ImageModel';
import { ImageShowModel } from '../model/PageParams';

// 图片可以缩放的最大值
export const MAX_SCALE = 3.0;

// 图片可以缩放的最小值
export const MIN_SCALE = 0.6

// 双击时放大到中间倍数
export const MID_SCALE = 2.0;

export const STROKE_RENDER_THRESHOLD: number = 4;

export const DRAW_INTERVAL: number = 16;

export const DESIGN_W = 1080;
export const DESIGN_H = 1300;

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

export const WATERMARK_WIDTH: number = 266;

export class Constants {
  static BAR_LIST: ImageShowModel[] = [
    {
      imageSource: $r('app.media.filters'),
      text: '滤镜',
    },
    {
      imageSource: $r('app.media.cropping'),
      text: '调整',
    },
    {
      imageSource: $r('app.media.sticker'),
      text: '贴纸',
    },
    {
      imageSource: $r('app.media.text'),
      text: '文字',
    },
    {
      imageSource: $r('app.media.mosaic'),
      text: '马赛克',
    },
    {
      imageSource: $r('app.media.mosaic'),
      text: '涂鸦',
    },
    {
      imageSource: $r('app.media.waterMark'),
      text: '水印',
    },
  ];
  static cutList: ImageTextItem[] = [
    {
      icon: $r('app.media.ic_origin_pic'),
      text: '原图',
      value: 'origin',
    },
    {
      icon: $r('app.media.cut_free'),
      text: '自由',
      value: 'freeCut',
    },
    {
      icon: $r('app.media.cut_9_16'),
      text: '9:16',
      value: 'cut_9_16',
    },
    {
      icon: $r('app.media.cut_16_9'),
      text: '16:9',
      value: 'cut_16_9',
    },
    {
      icon: $r('app.media.cut_1_1'),
      text: '1:1',
      value: 'cut_1_1',
    },
    {
      icon: $r('app.media.cut_3_2'),
      text: '3:2',
      value: 'cut_3_2',
    },
    {
      icon: $r('app.media.cut_4_3'),
      text: '4:3',
      value: 'cut_4_3',
    },
  ];
  static carouseList: ImageTextItem[] = [
    {
      icon: $r('app.media.carouse_left'),
      text: '向左90°',
      value: 'left_90',
    },
    {
      icon: $r('app.media.carouse_right'),
      text: '向右90°',
      value: 'right_90',
    },
    {
      icon: $r('app.media.carouse_horizontal'),
      text: '水平',
      value: 'horizontal',
    },
    {
      icon: $r('app.media.carouse_vertical'),
      text: '垂直',
      value: 'vertical',
    },
  ]
  static filterTagList: string[] = ['最新', '热门', '基础', '质感'];
  static filterList: CustomFilter[] = PRESETS;
  static recommendTextList: string[] = [
    '把3月好运一键生成给你',
    '嗨👋，6月你好～',
    '今日打开',
    '👌，6月好心情持续营业～',
    '为梦想窒息',
    '今日份营业结束～',
  ];
  static stickerTagList: string[] = ['最新', '热门'];
  static stickerTagListMap: Map<string, string> = new Map<string, string>([
    ['最新', 'new'],
    ['热门', 'hot'],
  ]);
  static mosaicList: MosaicInfo[] = [
    {
      icon: $r('app.media.ic_mosaic1'),
      mosaicSource: 'resources/rawfile/mosaic/mosaic1.png',
      isVip: false,
    },
    {
      icon: $r('app.media.ic_mosaic4'),
      mosaicSource: 'resources/rawfile/mosaic/mosaic4.png',
      isVip: true,
    },
  ];
  static scrawlList: ScrawlInfo[] = [
    {
      icon: $r('app.media.ic_brush_1'),
      isVip: false,
      brushWidth: 3,
      shadowBlur: 0,
      lineCap: 'round',
      lineDash: []
    },
    {
      icon: $r('app.media.ic_brush_2'),
      isVip: false,
      brushWidth: 2,
      shadowBlur: 0,
      lineCap: 'butt',
      lineDash: []
    },
    {
      icon: $r('app.media.ic_brush_3'),
      isVip: false,
      brushWidth: 8,
      shadowBlur: 16,
      lineCap: 'round',
      lineDash: []
    },
    {
      icon: $r('app.media.ic_brush_4'),
      isVip: false,
      brushWidth: 8,
      shadowBlur: 0,
      lineCap: 'round',
      lineDash: [8, 9]
    },
  ];
}