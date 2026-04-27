@ObservedV2
export class TravelAggregatedPaymentKey {
  @Trace value: string  = ''

  constructor(value?: string) {
    this.value = value || '';
  }
}