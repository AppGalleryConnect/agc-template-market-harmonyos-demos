import { HistorySearchItem } from './Types';

@ObservedV2
export class HistoryModel {
  @Trace
  list: HistorySearchItem[] = [];
}
