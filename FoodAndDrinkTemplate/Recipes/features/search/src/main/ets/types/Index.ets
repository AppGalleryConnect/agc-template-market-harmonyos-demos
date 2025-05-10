// 排序规则
export enum SortType {
  General = '0',
  Grade = '1',
  Cooked = '2'
}

export interface TabItem {
  label: string,
  sortType: SortType
}



