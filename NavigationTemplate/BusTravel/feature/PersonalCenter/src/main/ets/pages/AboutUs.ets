import { RouteEntryVM } from 'common'
import { common, Want } from '@kit.AbilityKit';
import { PageHeader } from '../components/PageHeader';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function AboutUsBuilder() {
  AboutUs()
}

@Component
export struct AboutUs {
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State version: string = '15.0.10.300'
  @State newVersion: string = '最新版本号'
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: VersionUpdate({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info('reason======' + JSON.stringify(dismissDialogAction.reason))
      console.log('dialogController dialog onWillDismiss========')
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: '12lpx',
    width: '318lpx',
    height: '329lpx',
    backgroundColor: '#F1F3F5',
  })
  newDialogController: CustomDialogController | null = new CustomDialogController({
    builder: NewUpdate({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info('reason' + JSON.stringify(dismissDialogAction.reason))
      console.log('newDialogController dialog onWillDismiss')
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    cornerRadius: '12lpx',
    width: '318lpx',
    height: '358lpx',
    backgroundColor: Color.Transparent
  })

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  build() {
    NavDestination() {
      Column() {
        this.buildLogo()
        this.buildUse()
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(false)
    .title('关于我们')
  }

  @Builder
  buildLogo() {
    Column() {
      Image($r('app.media.logo'))
        .height('96lpx')
        .width('96lpx')
      Text('实时公交')
        .fontSize('16fp')
        .fontWeight(400)
        .margin({ top: '24lpx', bottom: '4lpx' })
      Text() {
        Span('版本：V')
        Span(this.version)
      }
      .fontSize('12lpx')
      .fontWeight(400)
    }
    .margin({ top: '36lpx' })
  }

  @Builder
  buildUse() {
    Column() {
      Row() {
        Text('意见建议')
          .fontSize(14)
          .height('20lpx')
          .margin({ left: '12lpx' })
        Image($r('app.media.moreicon'))
          .height('14lpx')
          .width('7lpx')
          .margin({ right: '17vp' })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.vm.toRouteDetail('Suggestion')
      })

      Divider()
        .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))
        .margin({
          top: '16vp',
          left: '17lpx',
          right: '17lpx',
          bottom: '16lpx'
        })

      Row() {
        Text('版本更新')
          .fontSize('14fp')
          .height('20lpx')
          .margin({ left: '12lpx' })
        Image($r('app.media.moreicon'))
          .height('14lpx')
          .width('7lpx')
          .margin({ right: 17 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (this.newVersion !== this.version) {
          if (this.newDialogController !== null) {
            this.newDialogController.open()
          }
        } else {
          if (this.dialogController !== null) {
            this.dialogController.open()
          }
        }
      })
    }
    .height('108lpx')
    .width('336lpx')
    .padding({ top: '18lpx', bottom: '18lpx' })
    .margin({ top: '48lpx' })
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius('12lpx')
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }
}

// 最新版本弹窗
@CustomDialog
export struct VersionUpdate {
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text()
        Image($r('app.media.ic_public_close_circle'))
          .height('36lpx')
          .width('36lpx')
          .margin({ right: '12lpx' })
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close()
            }
          })
      }
      .width('100%')
      .height('36lpx')
      .margin({ top: '12lpx' })
      .justifyContent(FlexAlign.SpaceBetween)

      Image($r('app.media.noupdata'))
        .height('120lpx')
        .width('120lpx')
        .margin({ top: '9lpx', bottom: '48lpx' })

      Text('亲~~您已是最新版本')
        .fontSize('16fp')
        .height('21lpx')
        .fontColor('#707172')
        .fontWeight(500)
    }
  }
}

// 有未更新版本弹窗
@CustomDialog
export struct NewUpdate {
  @State versionNo: string = '15.0.10.310'
  @State versionDetail: string = '1、新增NFC功能，通过NFC即可快速乘车支付。' + '\n' +
    '2、优化头像自定义功能，更多有趣的设定头像等你来体验~'
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Stack() {
      Image($r('app.media.update_bg'))
        .width('318lpx')
        .height('358lpx')
      Column() {
        Text() {
          Span('发现新版本： V')
          Span(this.versionNo)
        }
        .fontSize('16lpx')
        .fontWeight(500)
        .margin({ top: '141lpx' })

        Text(this.versionDetail)
          .fontSize('12fp')
          .width('286lpx')
          .fontColor('#707172')
          .margin({ top: '24lpx' })

        Row() {
          Button('取消')
            .height('18lpx')
            .width('90lpx')
            .fontSize('12lpx')
            .fontWeight(500)
            .fontColor($r('sys.color.gray_04'))
            .backgroundColor($r('sys.color.white'))
            .margin({ right: '14lpx' })
            .onClick(() => {
              if (this.controller !== undefined) {
                this.controller.close()
              }
            })

          Button('允许')
            .height('18lpx')
            .width('90lpx')
            .fontSize('12lpx')
            .fontWeight(500)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('app.color.system_color_green'))
            .onClick(() => {
              const want: Want = {
                uri: `store://appgallery.huawei.com/app/`
              };
              const context = getContext(this) as common.UIAbilityContext;
              context.startAbility(want, (err: BusinessError) => {
                if (err.code) {
                  console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
                }
              })
            })
        }
        .margin({ top: '50lpx' })
      }
    }
  }
}