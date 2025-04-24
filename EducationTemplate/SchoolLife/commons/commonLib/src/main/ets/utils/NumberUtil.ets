

class NumberUtil {
  public range(x: number): number[]; // end
  public range(x: [number]): number[]; // [end]
  public range(x: [number, number]): number[];
  public range(x: [number, number, number]): number[];
  public range(x: string | number | number[]) {
    let ar: number[] = [];
    if (typeof x === 'number') {
      for (let i = 0; i < x; i++) {
        ar.push(i);
      }
    } else if (x instanceof Array) {
      if (x.length === 1) {
        /**重载：传入数组只有1个元素 */
        for (let i = 0; i < x[0]; i++) {
          ar.push(i);
        }
      } else if (x.length === 2) {
        /**重载：传入2元素数组 */
        for (let i = x[0]; i < x[1]; i++) {
          ar.push(i);
        }
      } else if (x.length === 3) {
        /**重载：传入3元素数组 */
        for (let i = x[0]; i < x[1]; i += x[2]) {
          ar.push(i);
        }
      }
    }
    return ar;
  }
}

const numberUtil = new NumberUtil();
export { numberUtil as NumberUtil };