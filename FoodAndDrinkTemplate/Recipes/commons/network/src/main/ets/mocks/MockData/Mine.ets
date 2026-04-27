import { MemberPackage } from '../../types/Member';
import { BloggerFollower } from '../../types/Recipe';
import { getRecipeBriefInfoListByIds } from './RecipeList';

const followers: BloggerFollower[] = [
  {
    id: 1,
    authorId: 1001,
    author: '暖心小厨娘',
    authorAvatar: 'avatar1',
    isFollower:false
  },
  {
    id: 2,
    authorId: 1002,
    author: '米其林在家',
    authorAvatar: 'avatar6',
    isFollower:false
  },
  {
    id: 3,
    authorId: 1003,
    author: '翻车美食家',
    authorAvatar: 'avatar3',
    isFollower:false
  },
  {
    id: 4,
    authorId: 1004,
    author: '低卡实验室',
    authorAvatar: 'avatar4',
    isFollower:false
  },
  {
    id: 5,
    authorId: 1005,
    author: '环球美食记',
    authorAvatar: 'avatar5',
    isFollower:false
  },
  {
    id: 6,
    authorId: 1006,
    author: '烘焙小达人',
    authorAvatar: 'avatar6',
    isFollower:false
  },
  {
    id: 7,
    authorId: 1007,
    author: '川味厨房',
    authorAvatar: 'avatar7',
    isFollower:false
  },
  {
    id: 8,
    authorId: 1008,
    author: '素食主义',
    authorAvatar: 'avatar8',
    isFollower:false
  },
  {
    id: 9,
    authorId: 1009,
    author: '早餐研究所',
    authorAvatar: 'avatar9',
    isFollower:false
  },
  {
    id: 10,
    authorId: 1010,
    author: '甜品控',
    authorAvatar: 'avatar10',
    isFollower:false
  },
  {
    id: 11,
    authorId: 1011,
    author: '日料大师',
    authorAvatar: 'avatar1',
    isFollower:false
  },
  {
    id: 12,
    authorId: 1012,
    author: '快手菜专家',
    authorAvatar: 'avatar6',
    isFollower:false
  },
  {
    id: 13,
    authorId: 1013,
    author: '面点师傅',
    authorAvatar: 'avatar3',
    isFollower:false
  },
  {
    id: 14,
    authorId: 1014,
    author: '烧烤之王',
    authorAvatar: 'avatar4',
    isFollower:false
  },
  {
    id: 15,
    authorId: 1015,
    author: '汤品专家',
    authorAvatar: 'avatar5',
    isFollower:false
  },
  {
    id: 16,
    authorId: 1016,
    author: '咖啡与甜点',
    authorAvatar: 'avatar6',
    isFollower:false
  },
  {
    id: 17,
    authorId: 1017,
    author: '地中海美食',
    authorAvatar: 'avatar7',
    isFollower:false
  },
  {
    id: 18,
    authorId: 1018,
    author: '家常菜大全',
    authorAvatar: 'avatar8',
    isFollower:false
  },
  {
    id: 19,
    authorId: 1019,
    author: '减脂餐日记',
    authorAvatar: 'avatar9',
    isFollower:false
  },
  {
    id: 20,
    authorId: 1020,
    author: '夜市小吃',
    authorAvatar: 'avatar10',
    isFollower:false
  },
  {
    id: 21,
    authorId: 1021,
    author: '韩式料理',
    authorAvatar: 'avatar1',
    isFollower:false
  },
  {
    id: 22,
    authorId: 1022,
    author: '泰式风味',
    authorAvatar: 'avatar6',
    isFollower:false
  },
  {
    id: 23,
    authorId: 1023,
    author: '意式厨房',
    authorAvatar: 'avatar3',
    isFollower:false
  },
  {
    id: 24,
    authorId: 1024,
    author: '法式甜点',
    authorAvatar: 'avatar4',
    isFollower:false
  },
  {
    id: 25,
    authorId: 1025,
    author: '中式面点',
    authorAvatar: 'avatar5',
    isFollower:false
  },
  {
    id: 26,
    authorId: 1026,
    author: '火锅达人',
    authorAvatar: 'avatar6',
    isFollower:false
  },
  {
    id: 27,
    authorId: 1027,
    author: '海鲜料理',
    authorAvatar: 'avatar7',
    isFollower:false
  },
  {
    id: 28,
    authorId: 1028,
    author: '空气炸锅美食',
    authorAvatar: 'avatar8',
    isFollower:false
  },
  {
    id: 29,
    authorId: 1029,
    author: '电饭煲料理',
    authorAvatar: 'avatar9',
    isFollower:false
  },
  {
    id: 30,
    authorId: 1030,
    author: '一人食记',
    authorAvatar: 'avatar10',
    isFollower:false
  },
];

let mineList: Array<number> = [10, 18, 3, 4, 5,1,11,9];

let historyList: Array<number> = [1, 2];

let collectionList: Array<number> = [1, 3];

let memberPackages: Array<MemberPackage> = [{
  id: 1,
  title: '终身会员',
  price: 0.01,
  description: '终身VIP权益',
}, {
  id: 2,
  title: '终身会员',
  price: 0.02,
  description: '终身VIP权益',
}];

export const getMyRecipeList = () => {
  const list = getRecipeBriefInfoListByIds(mineList);
  return list;
};

export const addMyRecipe = (id: number) => {
  mineList = mineList.filter(item => item !== id);
  mineList.unshift(id);
};

export const removeMyRecipe = (ids: number[]) => {
  ids.forEach(id => {
    mineList = mineList.filter(item => item !== id);
  });
};

export const getHistoryList = () => {
  const list = getRecipeBriefInfoListByIds(historyList);
  return list;
};

export const addHistory = (id: number) => {
  historyList = historyList.filter(item => item !== id);
  historyList.unshift(id);
};

export const getCollectionList = () => {
  const list = getRecipeBriefInfoListByIds(collectionList);
  return list;
};

export const addCollection = (id: number) => {
  collectionList = collectionList.filter(item => item !== id);
  collectionList.unshift(id);
};

export const removeCollection = (id: number) => {
  collectionList = collectionList.filter(item => item !== id);
};

export const isCollected = (id: number) => {
  return collectionList.includes(id);
};

export const getBloggerFollowers = (id: number) => {
  return followers;
};

export const getMemberPackages = () => {
  return memberPackages;
};
