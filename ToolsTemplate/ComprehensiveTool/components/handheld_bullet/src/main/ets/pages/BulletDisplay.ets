import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Orientation } from '../constant/Enum';
import { BulletVM } from '../viewmodel/BulletVM';

@Builder
export function BulletDisplayBuilder() {
  BulletDisplay();
}

@ComponentV2
export struct BulletDisplay {
  vm: BulletVM = BulletVM.instance;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync();

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      UtilLog.info(0xFF00, `Bullet`, 'setWindowOrientation: ' + orientation + ' Succeeded.');
    }).catch((err: BusinessError) => {
      UtilLog.info(0xFF00, `Bullet`, 'setWindowOrientation: ' + orientation + ' Failed. Cause: ' + JSON.stringify(err));
    });
  }

  aboutToAppear() {
    this.vm.offsetX = 0;
    this.vm.contentWidth = 0;
    this.vm.isAnimating = false;
    this.vm.isShowBack = false;
    clearTimeout(this.vm.time);
    clearTimeout(this.vm.backTime);
    this.setOrientation(Orientation.LANDSCAPE);
  }

  aboutToDisappear(): void {
    this.setOrientation(Orientation.PORTRAIT);
  }

  build() {
    NavDestination() {
      Image(this.vm.isLock ? $r('app.media.ic_lock') : $r('app.media.ic_unlock'))
        .size({ width: 40, height: 40 }).position({ x: 36, y: (this.vm.contentWidth - 40) / 2 })
        .zIndex(9999)
        .onClick(() => {
          this.vm.isLock = !this.vm.isLock;
        });

      Stack({ alignContent: Alignment.Top }) {
        if (this.vm.bullet.isSupportRoll) {
          if (this.vm.isOverFlow) {
            Row() {
              Text(this.vm.bullet.content)
                .fontSize(this.vm.bullet.fontSize)
                .fontColor(this.vm.bullet.textColor)
                .height('100%')
                .width(this.vm.bullet.content.length * this.vm.bullet.fontSize)
                .position({ x: 0 });
            }
            .translate({ x: this.vm.offsetX })
            .onAppear(() => {
              this.vm.startScrolling();
            })
            .backgroundColor(Color.Transparent)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
            .height('100%')
            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              this.vm.offsetX = Number(newValue.height);
              this.vm.contentWidth = Number(newValue.height);
            });
          } else {
            Row() {
              Text(this.vm.bullet.content)
                .fontSize(this.vm.bullet.fontSize)
                .fontColor(this.vm.bullet.textColor)
                .maxLines(1);
            }
            .translate({ x: this.getUIContext().vp2px(this.vm.offsetX - this.vm.bullet.content.length * 16) })
            .onAppear(() => {
              this.vm.startScrolling();
            })
            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              this.vm.offsetX = Number(newValue.height);
              this.vm.contentWidth = Number(newValue.height);
            })
            .backgroundColor(Color.Transparent)
            .constraintSize({ minWidth: '100%' })
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
            .height('100%');
          }
        } else {
          if (this.vm.isOverFlow) {
            Row() {
              Text(this.vm.bullet.content)
                .fontSize(this.vm.bullet.fontSize)
                .fontColor(this.vm.bullet.textColor)
                .maxLines(1);
            }
            .height('100%')
            .width(this.vm.bullet.content.length * this.vm.bullet.fontSize)
            .position({ x: 0 })
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              this.vm.offsetX = Number(newValue.height);
              this.vm.contentWidth = Number(newValue.height);
            });
          } else {
            Row() {
              Text(this.vm.bullet.content)
                .fontSize(this.vm.bullet.fontSize)
                .fontColor(this.vm.bullet.textColor)
                .maxLines(1);
            }
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center).onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              this.vm.offsetX = Number(newValue.height);
              this.vm.contentWidth = Number(newValue.height);
            });
          }
        }

        if (this.vm.isShowBack) {
          Button('返回')
            .backgroundColor($r('sys.color.comp_background_primary'))
            .fontColor($r('sys.color.font_primary'))
            .width(120)
            .height(40)
            .borderRadius(20)
            .margin({ top: 24 })
            .onClick(() => {
              this.vm.stack.pop();
            });
        }
      };
    }.onClick(() => {
      if (!this.vm.isLock) {
        this.vm.isShowBack = !this.vm.isShowBack;
        if (this.vm.isShowBack) {
          this.vm.startHideBack();
        }
      }
    }).gesture(
      LongPressGesture({ repeat: true })
        .onAction((event: GestureEvent | undefined) => {
          if (event) {
            this.vm.stack.pop();
          }
        })
        .onActionEnd(() => {
          UtilLog.info(0xFF00, 'Bullet', `Bullet Display quit by longPressGesture`);
        }),
    ).backgroundColor(this.vm.bullet.bgColor).hideTitleBar(true);
  }
}