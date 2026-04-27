import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { getInstance, setPathStack } from '../common/RouteStack';
import { FloatText } from '../model/FloatText';
import { DecompressionToolPageVM } from '../viewmodel/DecompressionToolPageVM';
import { IMenu, menuList } from '../common/Constant';
import Logger from '../util/Logger';

@Builder
export function DecompressionToolPageBuilder() {
  DecompressionToolPage();
}

@ComponentV2
struct DecompressionToolPage {
  vm: DecompressionToolPageVM = DecompressionToolPageVM.instance
  mainWin: window.Window =
    (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();

  aboutToAppear(): void {
    this.vm.context = this.getUIContext().getHostContext()
    this.vm.init()
    this.vm.statusBarContentColor = this.mainWin.getWindowSystemBarProperties().statusBarContentColor ?? '#000000'
    let sysBarProps: window.SystemBarProperties = {
      statusBarContentColor: '#ffffff',
    };
    this.mainWin.setWindowSystemBarProperties(sysBarProps).then(() => {
      Logger.info('[StaticUtils] Succeeded in setting the system bar properties.');
    });
  }

  aboutToDisappear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          this.titleBarBuilder()

          Row() {
            Stack() {
              ForEach(this.vm.floatTexts, (item: FloatText) => {
                if (item.isShow) {
                  Text(item.text)
                    .fontSize(item.fontSize)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(item.fontColor)
                    .translate(item.translateOptions)
                    .opacity(item.opacity)
                    .animation({
                      duration: 1000,
                      curve: Curve.EaseOut,
                      iterations: 1,
                      playMode: PlayMode.Normal,
                    })
                }
              }, (item: FloatText) => item.id.toString())
            }
            .width('45%')
            .height(140)
            .alignContent(Alignment.BottomEnd)

            Column() {
              Image($r('app.media.chui'))
                .width(311)
                .height(129)
                .translate(this.vm.translateOptions)
            }
            .alignItems(HorizontalAlign.Start)
            .width('55%')
            .translate({ y: 75 })
            .zIndex(9)
          }
          .zIndex(9)
          .height(155)
          .margin({ top: 65 })

          Stack() {
            Image($r('app.media.muyu_container'))
              .width(260)
              .height(220)
              .scale(this.vm.iconScaleOptions)
              .onClick(() => {
                this.vm.knock()
              })
          }

          if (this.vm.isShowNumber) {
            this.numberBuilder()
          }
        }
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.bg'))
        .backgroundImageSize(ImageSize.FILL)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        if (this.vm.isShowMenu) {
          this.menuBuilder()
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    })
    .onBackPressed(() => {
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: this.vm.statusBarContentColor,
      };
      this.mainWin.setWindowSystemBarProperties(sysBarProps).then(() => {
        Logger.info('[StaticUtils] Succeeded in setting the system bar properties.');
      });
      return false
    })
  }

  @Builder
  titleBarBuilder() {
    Row() {
      Image($r('app.media.left_icon'))
        .size({ height: 40, width: 40 })
        .onClick(() => {
          getInstance().pop()
        });
      Row() {
        Image($r('app.media.menu'))
          .width(18)
          .height(22)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .onClick(() => {
        this.vm.isShowMenu = !this.vm.isShowMenu
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 12,
      right: 12,
    })
  }

  @Builder
  numberBuilder() {
    Text(`${this.vm.totalNumber}次`)
      .fontSize(30)
      .fontColor($r('sys.color.multi_color_09'))
      .fontWeight(FontWeight.Bold)
  }

  @Builder
  menuBuilder() {
    Column() {
      Column() {
        List() {
          ForEach(menuList, (item: IMenu) => {
            ListItem() {
              Row() {
                Text(item.label)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('rgba(255, 255, 255, 0.9)')
              }
              .width(192)
              .height(48)
            }
            .onClick(() => {
              this.vm.change(item)
            })
          }, (item: IMenu) => item.label)
        }
        .alignListItem(ListItemAlign.Center)
        .divider({
          strokeWidth: 1,
          color: 'rgba(255, 255, 255, 0.2)',
        })
      }
      .backgroundColor('rgba(46, 48, 51, 0.9)')
      .borderRadius(20)
      .zIndex(9)
      .position({ right: 16, top: 56 })
      .width(224)
      .height(152)
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.vm.isShowMenu = !this.vm.isShowMenu
    })
  }
}
