
export class RangeField{
  name:string|null= null;
  rangePlaceHolder: string[] = [];
  startFunc?: (value: string) => void
  endFunc?: (value: string) => void
  errorTip: string = ''
  valueRange: number[] = []

  constructor(name: string | null, rangePlaceHolder: string[],
    startFunc: (value: string) => void, endFunc: (value: string) => void, valueRange: number[], errorTip:string) {
    this.name = name;
    this.rangePlaceHolder = rangePlaceHolder;
    this.startFunc = startFunc;
    this.endFunc = endFunc;
    this.valueRange = valueRange;
    this.errorTip = errorTip;
  }
}