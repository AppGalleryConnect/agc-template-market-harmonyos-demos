import { HolidaysMonth, HolidaysYear, OldAlmanac } from './CalendarBeans';

export class MockData {
  public static GET_OLD_ALMANAC: OldAlmanac = {
    'yi': '祭祀 祈福 求嗣 开光 纳采 订盟 解除 栽种 纳畜 牧养 扫舍 进人口',
    'yinli': '乙巳(蛇)年三月廿一',
    'wuxing': '沙中土 除执位',
    'jishen': '天德合 阴德 明堂 四相 五富 相日 吉期 玉堂 月德合',
    'yangli': '2025-04-18',
    'baiji': '丁不剃头头必生疮 已不远行财物伏藏',
    'chongsha': '冲猪(辛亥)煞东',
    'xiongshen': '劫煞 五虚 八风 重日',
    'ji': '修坟 造桥 作灶 出行 安葬 盖屋 入宅',
  };
  public static GET_HOLIDAY_YEAR: HolidaysMonth = {
    'year': '2025',
    'holidayArray': [{
      'rest': '',
      'festival': '2025-4-4',
      'name': '清明',
      'list': [{ 'date': '2025-4-4', 'status': '1' }, { 'date': '2025-4-4', 'status': '1' },
        { 'date': '2025-4-6', 'status': '1' }],
      'desc': '4月4日（周五）至6日（周日）放假，共3天。',
      'listNum': 3,
    }],
    'yearMonth': '2025-4',
  };
}