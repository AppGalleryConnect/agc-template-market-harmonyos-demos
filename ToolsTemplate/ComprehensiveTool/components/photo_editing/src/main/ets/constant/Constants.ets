import { image } from '@kit.ImageKit';
import { CustomFilter } from '../model/CustomFilter';
import { ImageShowModel } from '../model/PageParams';
import { PRESETS } from './Presets';

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

export class Constants {
  static BAR_LIST: ImageShowModel[] = [{
    imageSource: $r('app.media.cropping'),
    text: '裁剪',
  }, {
    imageSource: $r('app.media.text'),
    text: '文字',
  }, {
    imageSource: $r('app.media.filters'),
    text: '滤镜',
  }, {
    imageSource: $r('app.media.sticker'),
    text: '贴纸',
  }];
  static cutList: ImageShowModel[] = [{
    imageSource: $r('app.media.cut_free'),
    text: '自由',
  }, {
    imageSource: $r('app.media.cut_back'),
    text: '壁纸',
  }, {
    imageSource: $r('app.media.cut_9_16'),
    text: '9:16',
  }, {
    imageSource: $r('app.media.cut_16_9'),
    text: '16:9',
  }, {
    imageSource: $r('app.media.cut_1_1'),
    text: '1:1',
  }, {
    imageSource: $r('app.media.cut_3_2'),
    text: '3:2',
  }, {
    imageSource: $r('app.media.cut_4_3'),
    text: '4:3',
  }];
  static carouseList: ImageShowModel[] = [{
    imageSource: $r('app.media.carouse_left'),
    text: '向左90°',
  }, {
    imageSource: $r('app.media.carouse_right'),
    text: '向右90°',
  }, {
    imageSource: $r('app.media.carouse_vertical'),
    text: '水平',
  }, {
    imageSource: $r('app.media.carouse_level'),
    text: '垂直',
  }];
  static filterTagList: string[] = ['最新', '热门', '基础', '质感'];
  static filterList: CustomFilter[] = PRESETS;
  static fontColorList: string[] =
    ['#000000', '#FFFFFF', '#E52424', '#E56224', '#F6C800', '#63B959', '#48ADDD', '#5445EF', '#A946F1'];
  static fontFamilyList: string[] =
    ['HarmonyOS Sans', 'HarmonyOS Sans Condensed', 'HarmonyOS Sans Digit', 'Noto Serif', 'Noto Sans Mono', '宋体', 'Arial'];
  static recommendTextList: string[] = [
    '嗨👋，9月你好～',
    '👌，9月好心情持续营业～',
    '把9月好运一键生成给你',
    '今日份营业结束～',
  ];
  static stickerTagList: string[] = ['最新', '热门'];
  static stickerTagListMap: Map<string, string> = new Map<string, string>([
    ['最新', 'new'],
    ['热门', 'hot'],
  ]);
}