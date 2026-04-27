/*
 * 选择器 - 非唯一性关系链，将【中文表述】转换为【关系链】
*/
import { replace } from './Replace';

import { filterId, getGenById, reverseId } from './Id';
import { getCacheData } from './Cache';
import { SelectorParam, SelectorRes } from '../model/Selector';
import { Sex } from '../common/Constant';
import { expandSelector } from './ExpandSelector';

// 获得最简
function getOptimal(options: SelectorParam) {
  let from = options.from
  let to = options.to
  let sex = options.sex
  let fromChain = from.split(',');
  let toChain = to.split(',');
  for (let i = 0; i < fromChain.length && i < toChain.length; i++) {
    if (fromChain[i] === toChain[i]) {
      from = fromChain.slice(i + 1).join(',');
      to = toChain.slice(i + 1).join(',');
      sex = fromChain[i].match(/^([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?/) ? 1 : 0;
      continue;
    } else {
      if (getGenById(fromChain[i]) === getGenById(toChain[i]) && fromChain[i].match(/^[xol][bs]|^[sd]/) &&
      toChain[i].match(/^[xol][bs]|^[sd]/)) {
        let formType = fromChain[i].replace(/&([ol\d]+)/, '').replace(/^[xol]([bs])/, '$1');
        let toType = toChain[i].replace(/&([ol\d]+)/, '').replace(/^[xol]([bs])/, '$1');
        if (formType !== toType) {
          break;
        }
        let fromAttr = fromChain[i].match(/&([ol\d]+)/)?.[1] || fromChain[i].match(/([ol])[bs]/)?.[1] || '';
        let toAttr = toChain[i].match(/&([ol\d]+)/)?.[1] || toChain[i].match(/([ol])[bs]/)?.[1] || '';
        if (fromAttr && toAttr) {
          if (!Number.isNaN(fromAttr) && !Number.isNaN(toAttr)) {
            if (Number(fromAttr) > Number(toAttr)) {
              fromChain[i] = fromChain[i].replace(/^[xol]b|^s/, 'lb').replace(/^[xol]s|^d/, 'ls');
            } else if (Number(fromAttr) < Number(toAttr)) {
              fromChain[i] = fromChain[i].replace(/^[xol]b|^s/, 'ob').replace(/^[xol]s|^d/, 'os');
            }
          } else if (!Number.isNaN(fromAttr) && toAttr === 'o' || fromAttr === 'l' && !Number.isNaN(toAttr)) {
            fromChain[i] = fromChain[i].replace(/^[xol]b|^s/, 'lb').replace(/^[xol]s|^d/, 'ls');
          } else if (!Number.isNaN(fromAttr) && toAttr === 'l' || fromAttr === 'o' && !Number.isNaN(toAttr)) {
            fromChain[i] = fromChain[i].replace(/^[xol]b|^s/, 'ob').replace(/^[xol]s|^d/, 'os');
          }
          from = fromChain.slice(i).join(',');
          to = toChain.slice(i + 1).join(',');
          sex = toChain[i].match(/^([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?/) ? 1 : 0;
        } else if (options.optimal) {
          fromAttr = fromChain[i].match(/([xol])[bs]/)?.[1] || '';
          toAttr = toChain[i].match(/([xol])[bs]/)?.[1] || '';
          if (fromAttr === 'x' || toAttr === 'x') {
            from = fromChain.slice(i + 1).join(',');
            to = toChain.slice(i + 1).join(',');
            sex = fromChain[i].match(/^([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?/) ? 1 : 0;
            continue;
          }
        }
      }
      break;
    }
  }
  return {
    from,
    to,
    sex,
  } as SelectorParam
};

// 中文获取选择器
export function getSelectors(str: string): string[] {
  str = str.replace(/之/g, '的').replace(/吾之?(.+)/, '$1').replace(/我的?(.+)/, '$1');
  // 惯用口语标准化
  if (str.match(/[^娘婆岳亲]家的?(孩子|儿子|女儿)/)) {
    str = str.replace(/家的?/, '的');
  }
  str = str.replace(/(舅|姑)+(爸|父|丈|妈|母)?家的?(哥|姐|弟|妹)+/, '$1表$3')
    .replace(/(舅|姑)+(爸|父|丈|妈|母)?家的?/, '$1表');
  str = str.replace(/(伯|叔)+(父|母)?家的?(哥|姐|弟|妹)+/, '堂$3').replace(/(伯|叔)+(父|母)?家的?/, '堂');
  str = str.replace(/姨+(爸|父|丈|妈|母)?家的?(哥|姐|弟|妹)+/, '姨$2').replace(/姨+(爸|父|丈|妈|母)?家的?/, '姨');

  const lists = str.split('的');
  let result: string[] = [];
  let isMatch = true;
  while (lists.length) {
    const name = lists.shift(); //当前匹配词
    if (!name) {
      return ['']
    }
    let items: string[] = []; //当前匹配词可能性
    const keywords = [name];
    let getList = (name: string) => {
      // 词义扩展
      replace.forEach(item => {
        item.arr.forEach(word => {
          const name1 = name.replace(item.exp, word);
          if (name1 !== name) {
            keywords.push(name1);
            getList(name1);
          }
        });
      });
    };
    getList(name);
    // 通过关键词找关系
    const itemsMap: string[][] = [[], [], []];
    keywords.forEach((name) => {
      name = name.replace(/^[尕幺细满碎晚末尾幼]/, '小');
      const cacheData = getCacheData()
      items = items.concat(cacheData[name] || []);
    });
    // 如找不到结果，再是否存在称呼的排行问题(不直接判断，因存在"大舅""三从父兄""三世祖"这样特俗含义的情况)
    itemsMap.forEach((itemsX) => {
      if (!items.length) {
        items = itemsX;
      }
    });
    // 完全匹配不到结果
    if (!items.length) {
      isMatch = false;
    }
    const res: string[] = [];
    if (!result.length) {
      result = [''];
    }
    result.forEach((a) => {
      items.forEach((b) => {
        res.push(a + (b ? ',' + b : ''));
      });
    });
    result = res;
  }
  return isMatch ? filterId(result) : [];
}

// 合并选择器，查找两个对象之间的关系
export function mergeSelector(param: SelectorParam) {
  const fromSelector = param.from
  const toSelector = param.to
  let mySex = param.sex
  if (mySex < 0) {
    const fromSex = fromSelector.match(/^,[w1]/) ? 1 : fromSelector.match(/^,[h0]/) ? 0 : -1;
    const toSex = toSelector.match(/^,[w1]/) ? 1 : toSelector.match(/^,[h0]/) ? 0 : -1;
    if (fromSex === -1 && toSex > -1) {
      mySex = toSex;
    } else if (fromSex > -1 && toSex === -1) {
      mySex = fromSex;
    } else if (fromSex === toSex) {
      mySex = fromSex;
    } else {
      return [];
    }
  }
  let fromIds = selectorToId(param.from, mySex);
  let toIds = selectorToId(param.to, mySex);
  if (!fromIds.length || !toIds.length) {
    return [];
  }
  const result: SelectorRes[] = [];
  fromIds.forEach(from => {
    toIds.forEach(to => {
      let sex = mySex;
      let selector = ',' + to;
      if (selector.match(/,([fhs1](&[ol\d]+)?|[olx]b)(&[ol\d]+)?$/)) {
        sex = 1;
      }
      if (selector.match(/,([mwd0](&[ol\d]+)?|[olx]s)(&[ol\d]+)?$/)) {
        sex = 0;
      }
      if (from && to) {
        let isOptimal = param.optimal;
        if (from.match(/&\d+/) || to.match(/&\d+/)) {
          isOptimal = true;
        }
        if (isOptimal) {
          const res = getOptimal({
            from,
            to,
            sex: mySex,
            optimal: param.optimal,
          })
        }
      }
      let toRids = to ? reverseId(to, mySex) : [''];
      toRids.forEach((toR) => {
        let selector = (toR ? ',' + toR : '') + (from ? ',' + from : '');
        result.push({
          selector,
          sex,
        });
      });
    });
  });
  return result;
}
;


// 选择器转ID
export function selectorToId(selector: string, sex: Sex): string[] {
  if (!selector.match(/^,/)) {
    selector = ',' + selector;
  }
  //性别判断
  if (sex < 0) {
    if (selector.match(/^,[w1]/)) {
      sex = 1;
    } else if (selector.match(/^,[h0]/)) {
      sex = 0;
    }
  } else if (sex === 1 && selector.match(/^,[h0]/)) {
    return [];
  } else if (sex === 0 && selector.match(/^,[w1]/)) {
    return [];
  }
  if (sex > -1 && !selector.includes(',1') && !selector.includes(',0')) {
    selector = ',' + sex + selector;
  }
  if (selector.match(/,[mwd0](&[ol\d]+)?,w|,[hfs1](&[ol\d]+)?,h/)) { //同志关系去除
    return [];
  }
  const result = expandSelector(selector).map(selector => selector.replace(/,[01]/, '').substr(1)); //去前面逗号和性别信息
  return filterId(result);
}
;