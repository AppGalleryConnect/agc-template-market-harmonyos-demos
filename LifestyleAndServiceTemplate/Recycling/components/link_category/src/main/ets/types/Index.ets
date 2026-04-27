export interface RecipeCategory {
  id: number;
  name: string;
  recipeList: RecipeBriefInfo[];
}



export interface RecipeBriefInfo {
  id: number;
  title: string;
  description: string;
  category: string;
  cookingTime: number;
  difficulty: string;
  author: string;
  authorAvatar: string;
  thumbnail: string;
  views: number;
  likes: number;
}