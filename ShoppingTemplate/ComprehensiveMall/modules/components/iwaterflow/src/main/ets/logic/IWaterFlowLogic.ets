import { ComponentEntryProxy } from '@common/customtypes';

@ObservedV2
export class IWaterFlowLogic {

  public scroller: Scroller = new Scroller();

  @Trace
  public viewData: ComponentEntryProxy[] = [];

  @Trace
  public isEnd: boolean = false;

  @Trace
  public isLoading: boolean = false;

  private reachEndEventCallback: () => void = () => {};

  public up = (): void => {
    this.scroller.scrollEdge(Edge.Top);
  }

  public setData(data: ComponentEntryProxy[], refresh: boolean = false): void {
    if (refresh) {
      this.viewData = [];
    }
    this.viewData.push(...data);
  }

  public setOnReachEndEventCallback = (callback: () => void): void => {
    this.reachEndEventCallback = callback;
  }

  public onReachEnd = (): void => {
    this.reachEndEventCallback();
  }

  public calculateColumnCount(template: string): number {
    return template.split(' ').length;
  }
}
