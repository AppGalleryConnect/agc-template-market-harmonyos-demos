import { getRecipeBriefInfoListByIds } from './RecipeList';

let mineList: Array<number> = [2, 10, 18];

let historyList: Array<number> = [1, 2];

let collectionList: Array<number> = [1, 3];

export const getMyRecipeList = () => {
  const list = getRecipeBriefInfoListByIds(mineList)
  return list;
}

export const addMyRecipe = (id: number) => {
  mineList = mineList.filter(item => item !== id);
  mineList.unshift(id);
}

export const getHistoryList = () => {
  const list = getRecipeBriefInfoListByIds(historyList)
  return list;
}

export const addHistory = (id: number) => {
  historyList = historyList.filter(item => item !== id);
  historyList.unshift(id);
}

export const getCollectionList = () => {
  const list = getRecipeBriefInfoListByIds(collectionList)
  return list;
}

export const addCollection = (id: number) => {
  collectionList = collectionList.filter(item => item !== id);
  collectionList.unshift(id);
}

export const removeCollection = (id: number) => {
  collectionList = collectionList.filter(item => item !== id);
}

export const isCollected = (id: number) => {
  return collectionList.includes(id);
}
