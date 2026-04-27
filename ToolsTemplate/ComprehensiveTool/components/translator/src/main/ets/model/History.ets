import { Type } from '@kit.ArkUI';

@ObservedV2
export class HistoryInfo {
  @Trace id: string = '';
  @Trace input: string = ''
  @Trace output: string = ''

  constructor(id: string = '', input: string = '', output: string = '') {
    this.id = id;
    this.input = input
    this.output = output
  }
}

@ObservedV2
export class MyHistory {
  @Type(HistoryInfo)
  @Trace list: HistoryInfo[] = [];

  constructor(list: HistoryInfo[] = []) {
    this.list = list;
  }

  addHistory(data: HistoryInfo) {
    this.list.push(data);
  }

  removeHistory(id: string) {
    const removeHistory: HistoryInfo = this.list.filter((item) => item.id === id)[0];
    this.list = this.list.filter((item) => item.id !== id);
    return removeHistory;
  }

  clear() {
    this.list = []
  }
}