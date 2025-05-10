import { RouterMap } from 'commonlib';

export interface DishesItem {
  id: string,
  name: string,
  img: ResourceStr
}

export interface ServerItem {
  label: string,
  icon: ResourceStr,
  page: RouterMap
}

export interface SettingItem {
  label: string,
  page: RouterMap
}

export class RecipeItem {
  id: number = 0;
  banner: ResourceStr = '';
  title: string = '';
  label?: string[] = [];
  used?: number = 0;
  star: number = 0;
  avatar: ResourceStr = '';
  nickname: string = '';
}


@ObservedV2
export class Step {
  @Trace description: string;
  @Trace stepImg: string;

  constructor(description: string, stepImg: string) {
    this.description = description;
    this.stepImg = stepImg;
  }
}


