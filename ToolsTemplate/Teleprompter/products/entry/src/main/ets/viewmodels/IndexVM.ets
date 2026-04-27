import { BaseViewModel, BreakpointUtils } from 'common';

@ObservedV2
export class IndexVM extends BaseViewModel {
  breakpoint: BreakpointUtils | null = null;

  registerBreakpointListener(context: UIContext) {
    this.breakpoint = new BreakpointUtils(context.getMediaQuery());
    this.breakpoint?.register();
  }

  unregisterBreakpointListener() {
    this.breakpoint?.unRegister();
  }
}
