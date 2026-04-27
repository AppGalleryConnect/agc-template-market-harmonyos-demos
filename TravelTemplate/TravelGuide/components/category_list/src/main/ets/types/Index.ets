export interface CategoryItem {
  id: string;
  label: string;
  subCategoryId?: string[];
}

export interface ItemInfo {
  id: string;
  title: string;
}

export interface RecipeCategory {
  id: string;
  name: string;
  recipeList: RecipeBriefInfo[];
}

export interface RecipeBriefInfo {
  id: string;
  title: string;
}