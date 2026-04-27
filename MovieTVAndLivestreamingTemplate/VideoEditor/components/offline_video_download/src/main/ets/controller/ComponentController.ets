@ObservedV2
export class ComponentController {
  @Trace public isInterceptor: boolean = false
  @Trace public isLandscape: boolean = false

  onBack(): boolean {
    if (this.isLandscape) {
      this.isInterceptor = true
      return true
    } else {
      return false
    }
  }
}