import { IButtonItem } from '../components/ButtonGroup';
import { ShapeType } from '../model/Model';

export class CommonConstants {
  static readonly ZERO: number = 0;
  static readonly ONE: number = 1;
  static readonly NEGATIVE_ONE: number = -1;
  static readonly THREE: number = 3;
  static readonly TEN: number = 10;
  static readonly TWENTY_ONE: number = 21;
  static readonly CANVAS_WIDTH: number = 750;
  static readonly ONE_HUNDRED: number = 100;
  static readonly COLOR_STRING: string = '';
  static readonly SIGN: string = '%';
  static readonly BLACK: string = 'black';
  static readonly ONE_HUNDRED_PERCENT: string = '100%';
  static readonly COLOR_ARR: string[] = [
    '#F2F2F2','#D0EFFB','#D0E7FF','#DCE0FB','#E9D8F9','#FAD0E6','#FED8D8','#FFE5D0','#FFECD0','#FFF3D0','#EAF7D0','#DDF5DD','#D0F3F5',
    '#E6E6E6','#B9E7FA','#B9DBFF','#CAD0F9','#DFC5F7','#F7B9DA','#FDC4C5','#FFD9B9','#FFE2B9','#FFEDB9','#DFF3B9','#CCF1CC','#B9EDF0',
    '#D9D9D9','#8BD8F7','#8BC3FF','#A7B2F5','#C99EF1','#F28BC1','#FC9E9F','#FFC08B','#FFD08B','#FFE18B','#CAEC8B','#ABE7AB','#8BE1E6',
    '#CCCCCC','#5CC8F4','#5CACFF','#8493F1','#B478EC','#ED5CA9','#FB7779','#FFA75C','#FFBD5C','#FFD65C','#B5E45C','#89DE89','#5CD6DC',
    '#B3B3B3','#2EB9F1','#2E94FF','#6174ED','#9F51E7','#E82E90','#FA5053','#FF8E2E','#FFAA2E','#FFCA2E','#A0DD2E','#68D568','#2ECAD2',
    '#999999','#00AAEE','#007DFF','#3F56EA','#8A2BE2','#E40078','#FA2A2F','#FF7500','#FF9800','#FFBF00','#8CD600','#47CC47','#00BFC9',
    '#808080','#009BD9','#0072E8','#3A4FD5','#7E28CE','#D0006E','#E42729','#E86B00','#E88B00','#E8AE00','#80C300','#41BA41','#00AEB7',
    '#4D4D4D','#008CC3','#0067D1','#3447C0','#7124B9','#BB0063','#CD2325','#D16000','#D17D00','#D19D00','#73B000','#3BA73B','#009DA5',
    '#333333','#007CAE','#005BBA','#2E3FAB','#6520A5','#A60058','#B61F21','#BA5600','#BA6F00','#BA8B00','#669C00','#349534','#008B93',
    '#191919','#006D98','#0050A3','#293795','#581C90','#92004D','#A01B1D','#A34B00','#A36100','#A37A00','#5A8900','#2E822E','#007A80',
  ]
  static readonly WHITE: string = '#ffffff';
  static readonly DETENTS: [Length, Length] = [550, 600];
}

export interface CanvasPen {
  name: ResourceStr
  id: ResourceStr
  select: ResourceStr
  unSelect: ResourceStr
}

export interface CanvasShape {
  name: ResourceStr
  id: ShapeType
  resource: ResourceStr
}

export const canvasPenList: CanvasPen[] = [
  {
    name: $r('app.string.ballpoint'),
    id: 'ballpoint',
    select: $r('app.media.ballpoint_active'),
    unSelect: $r('app.media.ballpoint'),
  },
  {
    name: $r('app.string.marker'),
    id: 'marker',
    select: $r('app.media.marker_active'),
    unSelect: $r('app.media.marker'),
  },
  {
    name: $r('app.string.pencil'),
    id: 'pencil',
    select: $r('app.media.pencils_active'),
    unSelect: $r('app.media.pencils'),
  },
  {
    name: $r('app.string.fountain_pen'),
    id: 'fountain',
    select: $r('app.media.stencil_active'),
    unSelect: $r('app.media.stencil'),
  },
]


export const canvasShapeList: CanvasShape[] = [
  {
    name: $r('app.string.rectangle'),
    id: ShapeType.RECTANGLE,
    resource: $r('app.media.rectangle'),
  },
  {
    name: $r('app.string.circle'),
    id: ShapeType.CIRCLE,
    resource: $r('app.media.circle'),
  },
  {
    name: $r('app.string.five_star'),
    id: ShapeType.STAR,
    resource: $r('app.media.star'),
  },
  {
    name: $r('app.string.triangle'),
    id: ShapeType.TRIANGLE,
    resource: $r('app.media.triangle_line'),
  },
]

export const BUTTON_LIST:IButtonItem[] = [
  {
    id: '1',
    label: '填充'
  }
]