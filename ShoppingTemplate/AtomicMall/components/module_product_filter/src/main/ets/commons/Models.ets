import { FilterSelectionItem } from './Types';

@ObservedV2
export class FilterSelectionListModel {
  @Trace list: FilterSelectionItemModel[] = [];
}

@ObservedV2
export class FilterSelectionItemModel implements FilterSelectionItem {
  @Trace id: string = '';
  @Trace value: string[] = [];

  constructor(key: string, value: string[]) {
    this.id = key;
    this.value = value;
  }
}
