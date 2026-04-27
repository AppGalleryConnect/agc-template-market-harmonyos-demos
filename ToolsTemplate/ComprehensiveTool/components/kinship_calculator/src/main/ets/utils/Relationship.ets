import { RelationShip } from '../model/RelationShip';
import { getItemsById, reverseId } from './Id';
import { getSelectors, mergeSelector, selectorToId } from './Selector';

// 对外方法
export function relationship(parameter: RelationShip) {
  let options: RelationShip = {
    text: parameter.text, // 目标对象：目标对象的称谓汉字表达，称谓间用‘的’字分隔
    target: '', // 相对对象：相对对象的称谓汉字表达，称谓间用‘的’字分隔，空表示自己
    sex: parameter.sex, // 本人性别：0表示女性,1表示男性
    reverse: parameter.reverse, // 称呼方式：true对方称呼我,false我称呼对方
    mode: 'default', // 模式选择：使用setMode方法定制不同地区模式，在此选择自定义模式
    optimal: false, // 最短关系：计算两者之间的最短关系
  }
  if (!options.text) {
    return ['']
  }
  let fromSelectors = getSelectors(options.text);
  let toSelectors = getSelectors(options.target);
  if (!toSelectors.length) {
    toSelectors = [''];
  }
  const result = fromSelectors.flatMap(fromSelector => {
    return toSelectors.flatMap(toSelector => {
      return mergeSelector({
        from: fromSelector,
        to: toSelector,
        sex: options.sex,
        optimal: options.optimal,
      }).flatMap(data => {
        const ids = data ? selectorToId(data.selector, data.sex) : [];
        return ids.flatMap(id => {
          let temps = [id];
          let sex = data.sex;
          if (options.reverse) {
            temps = reverseId(id, sex);
            if (id.match(/([fhs1](&[ol\d]+)?|[olx]b)$/)) {
              sex = 1;
            } else {
              sex = 0;
            }
          }
          return temps.flatMap(id => {
            let items = getItemsById(id);
            if (!items.length) {
              items = getItemsById(sex + ',' + id);
            }
            return items;
          });
        });
      });
    });
  });
  return result
}