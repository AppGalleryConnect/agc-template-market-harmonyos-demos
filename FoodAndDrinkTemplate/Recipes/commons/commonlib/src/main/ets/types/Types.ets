export interface UserInfo {
  id: number;
  avatar: string;
  name: string;
  nickname: string;
  sex: string;
  cellphone: string;
  birthday: string;
  introDesc:string;
  code: string;
  isLogin: boolean;
  isMembership: boolean;
}

export interface DialogParams {
  title: string,
  confirmFunc?: () => void
  cancelFunc?: () => void
}

export interface RecipesTable {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

export interface recipesData {
  id: number;
  title: string;
  description: string ;
  category: string;
  cookingTime: number;
  difficulty: string;
  authorId: number
  author: string;
  authorAvatar: string;
  thumbnail: string;
  views: number;
  likes: number;
  isCollected: number;
  video: string;
  heatness? : number;
  isVip? : number
}