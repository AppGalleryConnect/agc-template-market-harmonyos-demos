import FreeCollageModel from '../model/FreeCollageModel';
import { LayoutTemplateModel } from '../model/LayoutTemplateModel';
import PosterTemplateModel from '../model/PosterTemplateModel';

// 上下（vertical split）
const LAYOUT_2_1 = new LayoutTemplateModel();
LAYOUT_2_1.id = 'fixed-2-1';
LAYOUT_2_1.image = $r('app.media.bc_choose_p_2_1_default');
LAYOUT_2_1.selectedImage = $r('app.media.bc_choose_p_2_1');
LAYOUT_2_1.count = 2;
LAYOUT_2_1.regions = [
  { path: 'M 0 0 L 1200 0 L 1200 600 L 0 600 Z' },
  { path: 'M 0 600 L 1200 600 L 1200 1200 L 0 1200 Z' },
];

// 2-2 左右（horizontal split）
const LAYOUT_2_2 = new LayoutTemplateModel();
LAYOUT_2_2.id = 'fixed-2-2';
LAYOUT_2_2.image = $r('app.media.bc_choose_p_2_2_default');
LAYOUT_2_2.selectedImage = $r('app.media.bc_choose_p_2_2');
LAYOUT_2_2.count = 2;
LAYOUT_2_2.regions = [
  { path: 'M 0 0 L 600 0 L 600 1200 L 0 1200 Z' },
  { path: 'M 600 0 L 1200 0 L 1200 1200 L 600 1200 Z' },
];

// 3-1 纵向（上下三等分）
const LAYOUT_3_1 = new LayoutTemplateModel();
LAYOUT_3_1.id = 'fixed-3-1';
LAYOUT_3_1.image = $r('app.media.bc_choose_p_3_1_default');
LAYOUT_3_1.selectedImage = $r('app.media.bc_choose_p_3_1');
LAYOUT_3_1.count = 3;
LAYOUT_3_1.regions = [
  { path: 'M 0 0 L 1200 0 L 1200 400 L 0 400 Z' },
  { path: 'M 0 400 L 1200 400 L 1200 800 L 0 800 Z' },
  { path: 'M 0 800 L 1200 800 L 1200 1200 L 0 1200 Z' },
];

// 3-2 斜向（左右三等分）
const LAYOUT_3_2 = new LayoutTemplateModel();
LAYOUT_3_2.id = 'fixed-3-2';
LAYOUT_3_2.name = '双斜线分割';
LAYOUT_3_2.image = $r('app.media.bc_choose_p_3_2_default');
LAYOUT_3_2.selectedImage = $r('app.media.bc_choose_p_3_2');
LAYOUT_3_2.count = 3;
LAYOUT_3_2.regions = [
  { path: 'M 0 0 L 200 0 L 500 1200 L 0 1200 Z' },
  { path: 'M 200 0 L 600 0 L 900 1200 L 500 1200 Z' },
  { path: 'M 600 0 L 1200 0 L 1200 1200 L 900 1200 Z' },
];

// 4-1 纵向排列（上下四等分）
const LAYOUT_4_1 = new LayoutTemplateModel();
LAYOUT_4_1.id = 'fixed-4-1';
LAYOUT_4_1.image = $r('app.media.bc_choose_p_4_1_default');
LAYOUT_4_1.selectedImage = $r('app.media.bc_choose_p_4_1');
LAYOUT_4_1.count = 4;
LAYOUT_4_1.regions = [
  { path: 'M 0 0 L 1200 0 L 1200 300 L 0 300 Z' },
  { path: 'M 0 300 L 1200 300 L 1200 600 L 0 600 Z' },
  { path: 'M 0 600 L 1200 600 L 1200 900 L 0 900 Z' },
  { path: 'M 0 900 L 1200 900 L 1200 1200 L 0 1200 Z' },
];

// 4-2 横向排列（左右四等分）
const LAYOUT_4_2 = new LayoutTemplateModel();
LAYOUT_4_2.id = 'fixed-4-2';
LAYOUT_4_2.image = $r('app.media.bc_choose_p_4_2_default');
LAYOUT_4_2.selectedImage = $r('app.media.bc_choose_p_4_2');
LAYOUT_4_2.count = 4;
LAYOUT_4_2.regions = [
  { path: 'M 0 0 L 300 0 L 300 1200 L 0 1200 Z' },
  { path: 'M 300 0 L 600 0 L 600 1200 L 300 1200 Z' },
  { path: 'M 600 0 L 900 0 L 900 1200 L 600 1200 Z' },
  { path: 'M 900 0 L 1200 0 L 1200 1200 L 900 1200 Z' },
];

// 5-1 上三下二（上：3×1；下：2×1）
const LAYOUT_5_1 = new LayoutTemplateModel();
LAYOUT_5_1.id = 'fixed-5-1';
LAYOUT_5_1.image = $r('app.media.bc_choose_p_5_1_default');
LAYOUT_5_1.selectedImage = $r('app.media.bc_choose_p_5_1');
LAYOUT_5_1.count = 5;
LAYOUT_5_1.regions = [
  { path: 'M 0 0 L 400 0 L 400 600 L 0 600 Z' },
  { path: 'M 400 0 L 800 0 L 800 600 L 400 600 Z' },
  { path: 'M 800 0 L 1200 0 L 1200 600 L 800 600 Z' },
  { path: 'M 0 600 L 600 600 L 600 1200 L 0 1200 Z' },
  { path: 'M 600 600 L 1200 600 L 1200 1200 L 600 1200 Z' },
];

// 5-2 螺旋矩形
const LAYOUT_5_2 = new LayoutTemplateModel();
LAYOUT_5_2.id = 'fixed-5-2';
LAYOUT_5_2.image = $r('app.media.bc_choose_p_5_2_default');
LAYOUT_5_2.selectedImage = $r('app.media.bc_choose_p_5_2');
LAYOUT_5_2.count = 5;
LAYOUT_5_2.regions = [
  { path: 'M 0 0 L 400 0 L 400 800 L 0 800 Z' },
  { path: 'M 400 0 L 1200 0 L 1200 400 L 400 400 Z' },
  { path: 'M 800 400 L 1200 400 L 1200 1200 L 800 1200 Z' },
  { path: 'M 0 800 L 800 800 L 800 1200 L 0 1200 Z' },
  { path: 'M 400 400 L 400 800 L 800 800 L 800 400 Z' },
];

export const FIXED_LAYOUT_TEMPLATES: LayoutTemplateModel[] = [
  LAYOUT_2_1,
  LAYOUT_2_2,
  LAYOUT_3_1,
  LAYOUT_3_2,
  LAYOUT_4_1,
  LAYOUT_4_2,
  LAYOUT_5_1,
  LAYOUT_5_2,
];

const POSTER_2_1 = new PosterTemplateModel();
POSTER_2_1.id = 'poster2_1';
POSTER_2_1.count = 2;
POSTER_2_1.background = $rawfile('bc_bg_haibao2_1.png');
POSTER_2_1.oriRegions = [
  {
    coordinates: [{
      'x': 111,
      'y': 306,
    },
      {
        'x': 549,
        'y': 306,
      },
      {
        'x': 549,
        'y': 1245,
      },
      {
        'x': 111,
        'y': 1245,
      }],
  },
  {
    coordinates: [{
      'x': 555,
      'y': 55,
    },
      {
        'x': 993,
        'y': 55,
      },
      {
        'x': 993,
        'y': 995,
      },
      {
        'x': 555,
        'y': 995,
      }],
  },
];
POSTER_2_1.isVip = true;

const POSTER_2_2 = new PosterTemplateModel();
POSTER_2_2.id = 'poster2_2';
POSTER_2_2.count = 2;
POSTER_2_2.background = $rawfile('bc_bg_haibao2_2.png');
POSTER_2_2.oriRegions = [
  {
    coordinates: [{
      'x': 500,
      'y': 0,
    },
      {
        'x': 864,
        'y': 390,
      },
      {
        'x': 450,
        'y': 700,
      },
      {
        'x': 60,
        'y': 360,
      }],
  },
  {
    coordinates: [{
      'x': 357,
      'y': 750,
    },
      {
        'x': 1020,
        'y': 600,
      },
      {
        'x': 950,
        'y': 1100,
      },
      {
        'x': 530,
        'y': 1210,
      }],
  },
];

const POSTER_3_1 = new PosterTemplateModel();
POSTER_3_1.id = 'poster3-1';
POSTER_3_1.count = 3;
POSTER_3_1.background = $rawfile('bc_bg_haibao3_1.png');

POSTER_3_1.oriRegions = [
  { coordinates: [{ x: 126, y: 36 }, { x: 954, y: 36 }, { x: 954, y: 675 }, { x: 126, y: 675 }] },
  { coordinates: [{ x: 48, y: 726 }, { x: 504, y: 726 }, { x: 504, y: 1176 }, { x: 48, y: 1176 }] },
  { coordinates: [{ x: 528, y: 726 }, { x: 1011, y: 726 }, { x: 1011, y: 1176 }, { x: 528, y: 1176 }] },
];

const POSTER_3_2 = new PosterTemplateModel();
POSTER_3_2.id = 'poster3-2';
POSTER_3_2.count = 3;
POSTER_3_2.background = $rawfile('bc_bg_haibao3_2.png');

POSTER_3_2.oriRegions = [
  { coordinates: [{ x: 366, y: 66 }, { x: 972, y: 66 }, { x: 972, y: 1026 }, { x: 366, y: 1026 }] },
  { coordinates: [{ x: 168, y: 375 }, { x: 459, y: 375 }, { x: 459, y: 747 }, { x: 168, y: 747 }] },
  { coordinates: [{ x: 168, y: 795 }, { x: 459, y: 795 }, { x: 459, y: 1167 }, { x: 168, y: 1167 }] },
];

const POSTER_4_1 = new PosterTemplateModel();
POSTER_4_1.id = 'poster4-1';
POSTER_4_1.count = 4;
POSTER_4_1.background = $rawfile('bc_bg_haibao4_1.png');

POSTER_4_1.oriRegions = [
  { coordinates: [{ x: 108, y: 267 }, { x: 543, y: 267 }, { x: 543, y: 666 }, { x: 108, y: 666 }] },
  { coordinates: [{ x: 573, y: 267 }, { x: 1008, y: 267 }, { x: 1008, y: 666 }, { x: 573, y: 666 }] },
  { coordinates: [{ x: 573, y: 747 }, { x: 1008, y: 747 }, { x: 1008, y: 1146 }, { x: 573, y: 1146 }] },
  { coordinates: [{ x: 108, y: 747 }, { x: 543, y: 747 }, { x: 543, y: 1165 }, { x: 108, y: 1160 }] },
];

const POSTER_4_2 = new PosterTemplateModel();
POSTER_4_2.id = 'poster4-2';
POSTER_4_2.count = 4;
POSTER_4_2.background = $rawfile('bc_bg_haibao4_2.png');

POSTER_4_2.oriRegions = [
  { coordinates: [{ x: 63, y: 81 }, { x: 612, y: 81 }, { x: 612, y: 612 }, { x: 63, y: 612 }] },
  { coordinates: [{ x: 732, y: 81 }, { x: 1150, y: 201 }, { x: 909, y: 561 }, { x: 615, y: 441 }] },
  { coordinates: [{ x: 78, y: 768 }, { x: 483, y: 675 }, { x: 573, y: 1068 }, { x: 177, y: 1167 }] },
  { coordinates: [{ x: 564, y: 621 }, { x: 1002, y: 621 }, { x: 1002, y: 1089 }, { x: 564, y: 1089 }] },
];

const POSTER_5_1 = new PosterTemplateModel();
POSTER_5_1.id = 'poster5-1';
POSTER_5_1.count = 5;
POSTER_5_1.background = $rawfile('bc_bg_haibao5_1.png');

POSTER_5_1.oriRegions = [
  { coordinates: [{ x: 3, y: 168 }, { x: 279, y: 75 }, { x: 372, y: 351 }, { x: 96, y: 444 }] },
  { coordinates: [{ x: 99, y: 480 }, { x: 375, y: 387 }, { x: 468, y: 663 }, { x: 192, y: 756 }] },
  { coordinates: [{ x: 192, y: 804 }, { x: 468, y: 711 }, { x: 561, y: 987 }, { x: 285, y: 1080 }] },
  { coordinates: [{ x: 297, y: 1110 }, { x: 573, y: 987 }, { x: 666, y: 1300 }, { x: 360, y: 1300 }] },
  { coordinates: [{ x: 621, y: 90 }, { x: 1077, y: 273 }, { x: 900, y: 636 }, { x: 460, y: 530 }] },
];

const POSTER_5_2 = new PosterTemplateModel();
POSTER_5_2.id = 'poster5-2';
POSTER_5_2.count = 5;
POSTER_5_2.background = $rawfile('bc_bg_haibao5_2.png');

POSTER_5_2.oriRegions = [
  { coordinates: [{ x: 114, y: 264 }, { x: 474, y: 264 }, { x: 474, y: 609 }, { x: 114, y: 609 }] },
  { coordinates: [{ x: 321, y: 108 }, { x: 924, y: 108 }, { x: 924, y: 510 }, { x: 321, y: 510 }] },
  { coordinates: [{ x: 33, y: 825 }, { x: 360, y: 825 }, { x: 360, y: 1158 }, { x: 33, y: 1158 }] },
  { coordinates: [{ x: 369, y: 825 }, { x: 696, y: 825 }, { x: 696, y: 1158 }, { x: 369, y: 1158 }] },
  { coordinates: [{ x: 708, y: 825 }, { x: 1035, y: 825 }, { x: 1035, y: 1158 }, { x: 708, y: 1158 }] },
];

/**
 * 导出的所有海报模板
 */
export const POSTER_TEMPLATES: PosterTemplateModel[] = [
  POSTER_2_1,
  POSTER_2_2,
  POSTER_3_1,
  POSTER_3_2,
  POSTER_4_1,
  POSTER_4_2,
  POSTER_5_1,
  POSTER_5_2,
];

const free1 = new FreeCollageModel();
free1.background = $rawfile('bc_ic_freedom_1.png');
const free2 = new FreeCollageModel();
free2.background = $rawfile('bc_ic_freedom_2.png');

export const FREE_TEMPLATES: FreeCollageModel[] = [
  free1,
  free2,
];


