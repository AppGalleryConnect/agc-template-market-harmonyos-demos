import { filter } from './Filter';

// 扩展选择器
export function expandSelector(selector: string) {
  const result: string[] = [];
  const hash: Record<string, boolean> = {};
  const getSelector = (selector: string) => {
    if (!hash[selector]) {
      hash[selector] = true;
      let s = '';
      // 有问题
      do {
        s = selector;
        for (const item of filter) {
          selector = selector.replace(Reflect.get(item, 'exp'), Reflect.get(item, 'str'));
          if (selector.includes('#')) {
            selector.split('#').forEach(getSelector);
            break
          }
        }
      } while (s !== selector)
      if (!selector.match(/,[mwd0](&[ol\d+])?,w|,[hfs1](&[ol\d]+)?,h/)) { //同志关系去除
        result.push(selector);
      }
    }
  };
  getSelector(selector);
  return result;
}