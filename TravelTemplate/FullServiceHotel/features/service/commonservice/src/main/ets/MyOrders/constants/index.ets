import { OrderClassLabel } from '../types';

export class Constants {
  public static readonly ORDER_STATUS_LABEL: Map<string, OrderClassLabel> = new Map([
    ['1', OrderClassLabel.PENDING_PAYMENT],
    ['2', OrderClassLabel.PENDING_USAGE],
    ['3', OrderClassLabel.COMPLETE],
    ['4', OrderClassLabel.CANCEL],
  ]);
  public static readonly RELATIVE_CONTAINER_ID: string = '__container__';
}
