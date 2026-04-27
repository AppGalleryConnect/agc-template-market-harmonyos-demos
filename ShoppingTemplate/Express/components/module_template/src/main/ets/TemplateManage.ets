import { RouterMap } from 'module_base';
import { Context, ctx } from './common/Context';

@ComponentV2
export struct TemplateManage {
  @BuilderParam
  private contentBuilder: () => void = buildEmptyComponent;
  @Param
  public navPathStack: NavPathStack = new NavPathStack();
  @Event
  public onPushPath: ((id: number) => void) | undefined = undefined
  @Event
  public onBeforeNavigate: () => boolean = () => true;
  private readonly ctx: Context = ctx

  public aboutToAppear(): void {
    this.ctx.navPathStack = this.navPathStack;
    this.ctx.onPushPath = this.onPushPath
  }

  @Monitor('navPathStack', 'isSelectMode', 'onSelect', 'onPushPath')
  public onAttributeChange(iMonitor: IMonitor): void {
    for (let k of iMonitor.dirty) {
      let v: IMonitorValue<ESObject> | undefined = iMonitor.value<ESObject>(k);
      if (v) {
        switch (k) {
          case 'navPathStack':
            this.ctx.navPathStack = v.now as NavPathStack;
            break;
          case 'onPushPath':
            this.ctx.onPushPath = v.now as (id: number) => void;
            break;
        }
      }
    }
  }

  public build(): void {
    Column() {
      this.contentBuilder();
    }
    .width('auto')
    .height('auto')
    .onClick(() => {
      if (this.onBeforeNavigate()) {
        this.navPathStack.pushPath({
          name: RouterMap.TEMPLATE_PAGE,
        });
      }
    })
  }
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
