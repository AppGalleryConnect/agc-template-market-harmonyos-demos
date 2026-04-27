/*
 * 标识符 - 唯一性关系链，将【关系链】转换成【中文表述】
*/
import { Sex } from '../common/Constant';
import { GMap, HashId } from '../model/Id';
import { getMapData } from './Map'

// 逆转ID
export function reverseId(id: string, sex: Sex) {
  if (!id) {
    return [''];
  }
  // 映射关系
  let hash: HashId = {
    f: ['d', 's'],
    m: ['d', 's'],
    h: ['w', ''],
    w: ['', 'h'],
    s: ['m', 'f'],
    d: ['m', 'f'],
    lb: ['os', 'ob'],
    ob: ['ls', 'lb'],
    xb: ['xs', 'xb'],
    ls: ['os', 'ob'],
    os: ['ls', 'lb'],
    xs: ['xs', 'xb'],
  };
  // 年纪判断
  let age = '';
  if (id.match(/&o$/)) {
    age = '&l';
  } else if (id.match(/&l$/)) {
    age = '&o';
  }
  id = id.replace(/&[ol\d+]/g, '');
  // 性别判断
  if (sex < 0) {
    if (id.match(/^w/)) {
      sex = 1;
    } else if (id.match(/^h/)) {
      sex = 0;
    }
  }
  const doing = (sex: Sex) => {
    try {
      const sid = (',' + sex + ',' + id).replace(/,[fhs]|,[olx]b/g, ',1').replace(/,[mwd]|,[olx]s/g, ',0');
      const sidArr = sid.slice(0, sid.length - 2).split(',').reverse();
      const rId = id.split(',').reverse().map((id, i): string => Reflect.get(hash, id)[sidArr[i]]).join(',');
      const gen = getGenById(rId);
      return rId + (gen ? '' : age);
    } catch (e) {
      return ''
    }
  };
  if (sex < 0) {
    return [doing(1), doing(0)];
  } else {
    return [doing(sex)];
  }
}
;

// ID列表去重
export function filterId(arr: string[]) {
  const sameList = arr.filter(item => item === item.replace(/[ol](?=[s|b])/g, 'x').replace(/&[ol]/, ''));
  return arr.filter(item => {
    const temp = item.replace(/[ol](?=[s|b])/g, 'x').replace(/&[ol]/, '');
    return sameList.includes(item) || item !== temp && !sameList.includes(temp);
  }).filter((item, idx, arr) => arr.indexOf(item) === idx);
}
;

// 通过ID获取世代数
export function getGenById(id: string) {
  const gMap: GMap = {
    'f': 1,
    'm': 1,
    's': -1,
    'd': -1,
  };
  let gen = 0;
  id.split(',').forEach(sub => {
    const s = sub.replace(/&[ol\d]+/, '');
    gen += Reflect.get(gMap, s) || 0;
  });
  return gen;
}
;

// 通过ID获取关系称呼
export function getItemsById(id: string): string[] {
  let items: string[] = [];
  const modeData = getMapData()
  const getData = (key: string) => {
    let ids: string[] = [];
    const k1 = key.replace(/(,[sd])(,[wh])?$/, '$1&o$2');
    const k2 = key.replace(/(,[sd])(,[wh])?$/, '$1&l$2');
    if (modeData[k1] && modeData[k2]) {
      ids = [k1, k2];
    } else if (modeData[key]) {
      ids = [key];
    }
    return filterId(ids).map(id => modeData[id][0]);
  };
  // 对排序进行处理
  if (id.match(/&([\d]+)(,[hw])?$/)) {
    const idRes = id.match(/&([\d]+)(,[hw])?$/)
    if (idRes === null) {
      return []
    }
  }
  // // 直接匹配称呼
  if (!items.length) {
    id = id.replace(/&\d+/g, '');
    items = getData(id);
  }
  // 忽略年龄条件查找
  if (!items.length) {
    id = id.replace(/&[ol]/g, '');
    items = getData(id);
  }
  // 忽略年龄条件查找
  if (!items.length) {
    id = id.replace(/[ol](b|s)/g, 'x$1');
    items = getData(id);
  }
  // 缩小访问查找
  if (!items.length) {
    let l = id.replace(/x/g, 'l');
    let o = id.replace(/x/g, 'o');
    items = items.concat(getData(o), getData(l));
  }
  return items;
}