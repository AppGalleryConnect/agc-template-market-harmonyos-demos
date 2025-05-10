import { RecipeItem } from '../types/Index';
import { RecipeBriefInfo } from 'network';

export function recipeListMapper(list: RecipeBriefInfo[]) {
  let recipeList: RecipeItem[] = [];
  list.forEach(item => {
    let recipeItem: RecipeItem = new RecipeItem();
    recipeItem.id = item.id;
    recipeItem.banner = item.thumbnail;
    recipeItem.used = item.views;
    recipeItem.star = item.likes;
    recipeItem.title = item.title;
    recipeItem.label = item.category.split('、');
    recipeItem.nickname = item.author;
    recipeItem.avatar = item.authorAvatar || 'ic_avatar';
    recipeList.push(recipeItem);
  });

  return recipeList;
}