import { PaymentType } from '../common/CustomTypes';

@ObservedV2
export class CashierPickerContentVM {

  @Trace
  public durationForAppear: number = 270;

  @Trace
  public durationForDisappear: number = 220;

  @Trace
  public amount: number = 0;

  @Trace
  public tradeSummary: string = '';

  @Trace
  public isOpen: boolean = false;

  @Trace
  public selectType: PaymentType = PaymentType.HUAWEI;

  @Trace
  public payment: (type: PaymentType) => void | Promise<void> = () => {};

  @Trace
  public willDismiss: (reason: DismissReason) => void = () => {};

  public reset(): void {
    this.amount = 0;
    this.tradeSummary = '';
    this.selectType = PaymentType.HUAWEI;
  }
}
