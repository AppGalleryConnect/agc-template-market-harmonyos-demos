@ObservedV2
export class FilterOption {
  @Trace name: string;
  @Trace selectIndex: number;
  @Trace selectArr: string[];

  constructor(name: string, selectIndex: number, selectArr: string[]) {
    this.name = name;
    this.selectIndex = selectIndex;
    this.selectArr = [...selectArr];
  }
}


export interface ResultItem {
  filterName: string,
  selectIndex: number
}

export enum LayoutType {
  DEFAULT = '0',
  SPLIT = '1'
}