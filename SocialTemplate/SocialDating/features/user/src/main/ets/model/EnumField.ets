export class EnumField {
  name: string = '';
  groupName: string = '';
  enumValues: string[] = [];
  itemTextFontSize: number = 14;
  rowTemplate: string = '1fr 1fr 1fr';
  columnsTemplate: string = '1fr 1fr 1fr';
  height: number = 80;
  selectedFunc?: (result: CheckboxGroupResult) => void

  constructor(name: string, groupName: string, enumValues: string[],
    itemTextFontSize: number, rowTemplate: string, columnsTemplate: string, height: number,
    selectedFunc: (result: CheckboxGroupResult) => void) {
    this.name = name;
    this.groupName = groupName;
    this.enumValues = enumValues;
    this.itemTextFontSize = itemTextFontSize;
    this.rowTemplate = rowTemplate;
    this.columnsTemplate = columnsTemplate;
    this.height = height;
    this.selectedFunc = selectedFunc;
  }
}