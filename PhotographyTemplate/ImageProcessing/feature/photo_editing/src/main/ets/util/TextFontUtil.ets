import { Logger } from 'commonlib';
import { TextFontModel } from '../model/ImageModel';


export class TextFontUtil {
  public static fontList: TextFontModel[] = [
    {
      isVip: false,
      font: {
        familyName: '',
        familySrc: '',
      }
    },
    {
      isVip: false,
      font: {
        familyName: '兰亭黑体',
        familySrc: $rawfile('fonts/兰亭黑体.ttf')
      },
    },
    {
      isVip: false,
      font: {
        familyName: '站酷快乐体',
        familySrc: $rawfile('fonts/站酷快乐体.ttf')
      },
    },
    {
      isVip: false,
      font: {
        familyName: '萍方雅圆体',
        familySrc: $rawfile('fonts/萍方雅圆体.ttf')
      },
    },
    {
      isVip: true,
      font: {
        familyName: '包图小白体',
        familySrc: $rawfile('fonts/包图小白体.ttf')
      },
    },
    {
      isVip: false,
      font: {
        familyName: '雅黑手写体',
        familySrc: $rawfile('fonts/雅黑手写体.ttf')
      },
    },
    {
      isVip: true,
      font: {
        familyName: '书宋泡泡体',
        familySrc: $rawfile('fonts/书宋泡泡体.ttf')
      },
    },
    {
      isVip: true,
      font: {
        familyName: '青松手写体',
        familySrc: $rawfile('fonts/青松手写体.ttf')
      }
    },
  ]

  public static registerFont(uiContext: UIContext) {
    try {
      for(let i = 0; i < TextFontUtil.fontList.length; i++) {
        const item = TextFontUtil.fontList[i];
        if (item.font.familySrc) {
          uiContext.getFont().registerFont(item.font);
        }
      }
    } catch (err) {
      Logger.error('TextFontUtil', 'registerFont err: ' + JSON.stringify(err));
    }
  }
}


/**
 * 两个数字相加
 * @param {Number} 两个数字
 * */
export const calcAdd = (a: number, b: number) => {
  let x: string | number;
  let y: string | number;
  let m: number;
  try {
    x = a.toString().split('.')[1].length;
  } catch (e) {
    x = 0;
  }
  try {
    y = b.toString().split('.')[1].length;
  } catch (e) {
    y = 0;
  }
  m = Math.pow(10, Math.max(x, y));
  return (a * m + b * m) / m;
};
/**
 * 两个数字相减
 * @param {Number} 两个数字
 * */
export const calcSub = (a: number, b: number) => {
  let x: string | number;
  let y: string | number;
  let m: number;
  let n: number;
  try {
    x = a.toString().split('.')[1].length;
  } catch (e) {
    x = 0;
  }
  try {
    y = b.toString().split('.')[1].length;
  } catch (e) {
    y = 0;
  }
  m = Math.pow(10, Math.max(x, y));
  n = x >= y ? x : y;
  return ((a * m - b * m) / m).toFixed(n);
};