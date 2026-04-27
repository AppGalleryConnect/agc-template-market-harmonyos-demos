import { SafePageVM } from '../viewmodels/SafePageVM';

@Builder
export function SafePageBuilder() {
  SafePage()
}

@ComponentV2
struct SafePage {
  vm: SafePageVM = new SafePageVM();

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Scroll() {
            Column() {
              Image($r('app.media.startIcon'))
                .width(72)
                .draggable(false)
                .margin({ top: 136 })
              Text('快递物流')
                .fontSize($r('sys.float.Title_L'))
                .fontWeight(FontWeight.Medium)
                .margin({
                  top: 24,
                  bottom: 2,
                })
              Text('业务描述')
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .layoutWeight(1)

          Column() {
            Image($r('app.media.ic_security'))
              .width(16)
              .draggable(false)
            Text() {
              Span('本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
                .fontColor($r('sys.color.font_secondary'))
              Span('XX业务与隐私的声明、权限使用说明')
                .fontColor('#5c79d9')
                .onClick(() => {
                  this.vm.privacyClick();
                })
              Span('。')
                .fontColor($r('sys.color.font_secondary'))
            }
            .fontSize($r('sys.float.Caption_M'))
            .margin({
              top: 16,
              bottom: 6,
            })

            Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
            Row({ space: 12 }) {
              Button('取消')
                .fontColor('#5c79d9')
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .height(40)
                .layoutWeight(1)
                .onClick(() => {
                  this.vm.openSheet = true;
                })
              Button('同意')
                .height(40)
                .layoutWeight(1)
                .onClick(() => {
                  this.vm.agreeBtnClick();
                })
            }
            .padding({
              top: 16,
              bottom: 16,
            })
          }
        }
        .height('100%')
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: this.vm.windowModel.windowTopPadding,
          bottom: this.vm.windowModel.windowBottomPadding,
        })

        if (this.vm.openSheet) {
          this.doubleCheckDialog()
        }
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
  }

  @Builder
  doubleCheckDialog() {
    Column() {
      Column() {
        Text('您需要同意协议才能体验快递物流模板')
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
        Text() {
          Span('本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
            .fontColor($r('sys.color.font_secondary'))
          Span('XX业务与隐私的声明、权限使用说明')
            .fontColor('#5C79D9')
            .onClick(() => {
              this.vm.privacyClick();
            })
          Span('。')
            .fontColor($r('sys.color.font_secondary'))
        }
        .fontSize($r('sys.float.Caption_M'))
        .margin({ top: 16, bottom: 16 })

        Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
        Row({ space: 16 }) {
          Button('退出应用')
            .fontColor($r('sys.color.font_emphasize'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              this.vm.quitApp();
            })
          Button('同意并继续')
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              this.vm.agreeBtnClick();
            })
        }
        .margin({ top: 24 })
      }
      .backgroundColor(Color.White)
      .width('100%')
      .constraintSize({ maxWidth: 400 })
      .borderRadius(32)
      .padding(16)
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.mask_fourth'))
    .padding({ left: 16, right: 16 })
  }
}
