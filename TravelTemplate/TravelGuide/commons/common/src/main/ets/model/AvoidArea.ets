@ObservedV2
export class AiBarHeight {
  @Trace value: number = 0

  constructor(value?: number) {
    this.value = value || 0;
  }
}

@ObservedV2
export class StatusBarHeight {
  @Trace value: number = 0

  constructor(value?: number) {
    this.value = value || 0;
  }
}