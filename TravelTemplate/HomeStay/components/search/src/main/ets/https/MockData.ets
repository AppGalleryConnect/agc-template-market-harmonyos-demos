import { FilterTagAndList, SearchItem, SearchWordItem } from '../types/Type';

export const HOT_SEARCH_MOCK: SearchItem[] = [
  {
    title: '莫干山民宿攻略',
    index: '1',
    id: 'travel-1',
    intro: '避暑胜地，竹林深处的诗意栖居',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '千岛湖环湖自驾',
    index: '2',
    id: 'travel-2',
    intro: '湖光山色，一路风景一路歌',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '山景房推荐',
    index: '3',
    id: 'travel-3',
    intro: '推窗见山，拥抱自然',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '温泉民宿体验',
    index: '4',
    id: 'travel-4',
    intro: '冬日泡汤，暖身暖心',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '古镇水乡慢生活',
    index: '5',
    id: 'travel-5',
    intro: '小桥流水，岁月静好',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '海边度假小屋',
    index: '6',
    id: 'travel-6',
    intro: '面朝大海，春暖花开',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '亲子主题民宿',
    index: '7',
    id: 'travel-7',
    intro: '带孩子住进童话世界',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '草原星空帐篷',
    index: '8',
    id: 'travel-8',
    intro: '仰望星河，枕草而眠',
    type: 'travel',
    classId: 'travel',
  },
  {
    title: '茶山别墅度假',
    index: '9',
    id: 'travel-9',
    intro: '品茗观景，悠然自得',
    type: 'travel',
    classId: 'travel',
  },
];

export const SEARCH_RESULTS_MOCK: FilterTagAndList[] = [
  {
    label: '民宿',
    id: 'homestay',
    itemList: [
      {
        title: '莫干山民宿攻略',
        index: '1',
        id: 'homestay-1',
        image: $r('app.media.startIcon'),
        intro: '避暑胜地，竹林深处的诗意栖居',
      },
      {
        title: '山景房推荐',
        index: '2',
        id: 'homestay-2',
        image: $r('app.media.startIcon'),
        intro: '推窗见山，拥抱自然',
      },
    ]
  },
];

export const GUESS_LIKE_LIST1: SearchWordItem[] = [
  {
    content: '莫干山民宿',
    id: '001'
  },
  {
    content: '千岛湖自驾',
    id: '002'
  },
  {
    content: '温泉度假',
    id: '003'
  },
  {
    content: '古镇水乡',
    id: '004'
  },
];

export const GUESS_LIKE_LIST2: SearchWordItem[] = [
  {
    content: '海边小屋',
    id: '005'
  },
  {
    content: '亲子民宿',
    id: '006'
  },
  {
    content: '草原帐篷',
    id: '007'
  },
  {
    content: '茶山别墅',
    id: '008'
  },
  {
    content: '星空露营',
    id: '009'
  }
];

export const HISTORY_MOCK: SearchWordItem[] = [
  {
    content: '莫干山',
    id: '001'
  },
  {
    content: '山景房',
    id: '002'
  },
  {
    content: '温泉民宿',
    id: '003'
  },
  {
    content: '海边度假',
    id: '004'
  },
  {
    content: '亲子主题民宿推荐',
    id: '005'
  }
];
