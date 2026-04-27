import { BUTTON_TYPE } from '../common/Constant';

export class CalcButtonItemModel {
  value: string;
  type: BUTTON_TYPE;
  flag: number;
  text: string;
  bgColor: Resource;

  constructor( value: string, type: BUTTON_TYPE, flag: number, text: string, bgColor: Resource) {
    this.value = value;
    this.type = type;
    this.flag = flag;
    this.text = text;
    this.bgColor = bgColor;
  }
}

