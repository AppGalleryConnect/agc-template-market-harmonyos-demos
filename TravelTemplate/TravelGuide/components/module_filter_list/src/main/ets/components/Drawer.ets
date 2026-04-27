import { WindowUtil } from '../utils/WindowUtil';

export class DrawerController {
  open = () => {

  };
  close = () => {

  };
}


@ComponentV2
export struct Drawer {
  @Param controller: DrawerController = new DrawerController();
  @Local drawerHeight: number = 0;
  @Local curHeight: number = 0;
  @Local isOpen: boolean = false;
  @Local contentOpacity: number = 1;
  @Local wrapWidth: Length = '100%';
  @BuilderParam contentBuilderParam: () => void = this.contentBuilder;
  @Event onDrawChange: (isOpen: boolean) => void = () => {

  };
  callbackFn: () => void = () => {
    this.wrapWidth = px2vp(WindowUtil.getWindowRect().width);
  };

  @Builder
  contentBuilder() {

  }

  async aboutToAppear(): Promise<void> {
    if (this.controller) {
      this.controller.open = this.open;
      this.controller.close = this.close;
    }
    await WindowUtil.getCurrentWindow();
    this.callbackFn();
    WindowUtil.onWindowSizeChange(this.callbackFn);
  }

  aboutToDisappear(): void {
    WindowUtil.offWindowSizeChange(this.callbackFn);
  }

  build() {
    Column() {

      if (this.isOpen) {
        Column() {


        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .backgroundColor('#33000000')
        .onClick(() => {
          this.close();
        })
        .hitTestBehavior(HitTestMode.Block);
      }
      Scroll() {
        Column() {
          if (this.isOpen) {
            this.contentBuilderParam();
          }
        }.width('100%')
        .onSizeChange((oldVal, newVal: SizeOptions) => {
          const newHeight = newVal.height as number;
          this.drawerHeight = newHeight;
        });
      }
      .clip(true)
      .height(this.curHeight)
      .width('100%')
      .scrollBar(BarState.Off)
      .opacity(this.contentOpacity)
      .position({ x: 0, y: 0 })
      .zIndex(2)
      .onClick(() => {

      });

    }.width(this.wrapWidth).zIndex(2);
  }

  private open = () => {
    if (this.isOpen) {
      animateTo({
        duration: 300,
        curve: Curve.Friction,
        onFinish: () => {
          animateTo({
            duration: 300,
            curve: Curve.Friction,
          }, () => {
            this.curHeight = this.drawerHeight;
            this.contentOpacity = 1;
          });
        },
      }, () => {
        this.curHeight = 0;
        this.contentOpacity = 0;
      });
    } else {
      animateTo({
        duration: 300,
        curve: Curve.Friction,
      }, () => {
        this.isOpen = true;
        this.curHeight = this.drawerHeight;
        this.contentOpacity = 1;
        this.onDrawChange(this.isOpen);
      });
    }


  };
  private close = () => {
    animateTo({
      duration: 300,
      curve: Curve.Friction,
      onFinish: () => {

      },
    }, () => {
      this.isOpen = false;
      this.curHeight = 0;
      this.contentOpacity = 1;
      this.onDrawChange(this.isOpen);
    });
  };
}