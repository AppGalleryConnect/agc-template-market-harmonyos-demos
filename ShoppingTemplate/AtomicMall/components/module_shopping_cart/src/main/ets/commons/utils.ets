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
