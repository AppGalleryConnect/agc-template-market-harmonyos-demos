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

@ObservedV2
export class RecipeItem {
  @Trace id: number = 0;
  @Trace banner: ResourceStr = '';
  @Trace title: string = '';
  @Trace label?: string[] = [];
  @Trace used?: number = 0;
  @Trace star: number = 0;
  @Trace avatar: ResourceStr = '';
  @Trace nickname: string = '';
  @Trace video: string = '';
  @Trace isVip: number = 0;
}

@ObservedV2
export class FunctionItem {
  label: string = ''
  @Trace rightLabel?: string = ''
  callback: () => void = () => {
  }

  constructor(label: string = '', callback: () => void = () => {
  }, rightLabel: string = '') {
    this.label = label
    this.rightLabel = rightLabel
    this.callback = callback
  }
}