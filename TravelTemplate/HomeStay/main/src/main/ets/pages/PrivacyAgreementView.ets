import { Logger, PreferenceUtils } from 'util';

const TAG: string = '[PrivacyView]';

@ComponentV2
export struct PrivacyAgreementView {
  @Param
  stack: NavPathStack = new NavPathStack();
  @Param
  appIcon: ResourceStr = '';
  @Param
  appName: ResourceStr = '';
  @Param
  appDesc: ResourceStr = '';
  @Param
  themeColor: ResourceColor = '#007DFF';
  @Param
  privacySummary: ResourceStr =
    '本应用需联网，调用XX、XX权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅';
  @Param
  privacyLinkDesc: ResourceStr = 'XX业务与隐私的声明、权限使用说明';
  @Event
  handleConfirm: () => void;
  @Local
  openSheet: boolean = false;
  @Local
  isAgree: boolean = false;

  aboutToAppear(): void {
    this.isAgree = PreferenceUtils.getInstance(this.getUIContext().getHostContext()).get('isAgreePrivacy') as boolean;
    if (this.isAgree) {
      this.handleConfirm?.();
    }
  }

  build() {
    if (!this.isAgree) {
      Stack() {
        Column() {
          Scroll() {
            Column() {
              Image(this.appIcon)
                .width(72)
                .draggable(false)
                .borderRadius(8)
                .margin({ top: 136 });
              Text(this.appName)
                .fontSize($r('sys.float.Title_L'))
                .fontWeight(FontWeight.Medium)
                .margin({
                  top: 24,
                  bottom: 24,
                });
              Text(this.appDesc)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'));
            };
          }
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .layoutWeight(1);

          Column() {
            Image($r('app.media.ic_security'))
              .width(16)
              .draggable(false);
            this.confirmContentBuilder();
            Row({ space: 16 }) {
              Button('取消')
                .fontColor(this.themeColor)
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .height(40)
                .layoutWeight(1)
                .onClick(() => {
                  this.openSheet = true;
                });
              Button('同意')
                .height(40)
                .backgroundColor(this.themeColor)
                .layoutWeight(1)
                .onClick(() => {
                  PreferenceUtils.getInstance(this.getUIContext().getHostContext()).put('isAgreePrivacy', true);
                  this.handleConfirm?.();
                });
            }
            .padding({
              top: 16,
              bottom: 16,
            });
          }
          .margin({
            top: 12,
          });
        }
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          bottom: 16,
        });

        if (this.openSheet) {
          this.doubleCheckDialog();
        }
      }
      .height('100%')
      .width('100%');
    }
  }

  @Builder
  doubleCheckDialog() {
    Column() {
      Column() {
        Text(`您需要同意协议才能体验${this.appName}`)
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
          .margin({ top: 16 });
        this.confirmContentBuilder();
        Row({ space: 16 }) {
          Button('退出应用')
            .fontColor(this.themeColor)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              try {
                this.getUIContext().getHostContext()?.getApplicationContext().killAllProcesses();
              } catch (err) {
                Logger.error(TAG, 'kill application failed. error:' + JSON.stringify(err));
              }

            });
          Button('同意并继续')
            .height(40)
            .backgroundColor(this.themeColor)
            .layoutWeight(1)
            .onClick(() => {
              this.openSheet = false;
              PreferenceUtils.getInstance(this.getUIContext().getHostContext()).put('isAgreePrivacy', true);
              this.handleConfirm?.();
            });
        }
        .padding({
          top: 16,
          bottom: 16,
        });
      }
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(32);
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.mask_fourth'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({
      left: 16,
      right: 16,
    })
    .justifyContent(FlexAlign.Center);

  }

  @Builder
  confirmContentBuilder() {
    Text() {
      Span(this.privacySummary)
        .fontColor($r('sys.color.font_secondary'));
      Span(this.privacyLinkDesc)
        .fontColor(this.themeColor)
        .onClick(() => {
          this.stack.pushPath({ name: 'PrivacyPolicyPage', param: null });
        });
      Span('。')
        .fontColor($r('sys.color.font_secondary'));
    }
    .fontSize($r('sys.float.Caption_M'))
    .margin({
      top: 16,
      bottom: 8,
    });

    Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
      .fontSize($r('sys.float.Caption_M'))
      .fontColor($r('sys.color.font_secondary'));
  }
}