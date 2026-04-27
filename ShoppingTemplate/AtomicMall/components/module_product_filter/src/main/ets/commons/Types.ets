export interface FilterTypeInterface {
  id: string;
  label: string;
  mutiple?:boolean;
  options: FilterOptionItem[];
}

export interface FilterOptionItem {
  key: string;
  label: string;
}

export interface FilterSelectionItem {
  id: string;
  value: string[];
}

export interface ProductFilterOptions {
  filterTypeList?: FilterTypeInterface[];
  initFilter?: FilterSelectionItem[];
  handleConfirm?: (res: FilterSelectionItem[]) => void;
}
