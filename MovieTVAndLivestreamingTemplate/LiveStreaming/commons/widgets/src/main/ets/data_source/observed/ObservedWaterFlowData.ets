
export enum BottomStatus {
  NONE = 'NONE',
  LOADING = 'LOADING',
  FAIL = 'FAIL',
}

export class ObservedWaterFlowData {
  bottomStatus: BottomStatus = BottomStatus.NONE;
}