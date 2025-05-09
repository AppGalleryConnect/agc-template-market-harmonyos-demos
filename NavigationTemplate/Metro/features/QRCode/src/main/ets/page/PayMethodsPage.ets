import {
  authorisedPayMethod,
  defaultPayMethod,
  MainEntryVM,
  PayMethod,
  unauthorizedPayMethod,
  userPayMethod,
  UserPayMethod
} from 'commonlib'
import { defaultPayMethodDialog } from '../components/defaultPayMethod'
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseTitle } from 'componentlib';

@Builder
export function PayMethodsPageBuilder(name: string, param: Object) {
  PayMethodsPage()
}


@Component
export struct PayMethodsPage {
  @State userPayMethod: UserPayMethod = userPayMethod
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  vm: MainEntryVM = MainEntryVM.instance;
  pageInfos: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: defaultPayMethodDialog({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    backgroundColor: Color.White,
    cornerRadius: 10
  })

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  @Builder
  PayMethodBuilder() {
    Text('支付方式')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.PayMethodBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Column() {
        Column() {
          Text('选择乘车码支付方式')
            .fontSize(20)
            .margin({ top: 12 })
          this.myPayList(defaultPayMethod, true)

          ForEach(authorisedPayMethod, (item: PayMethod) => {
            if (item !== defaultPayMethod) {
              this.myPayList(item, false)
            }
          }, (item: string, index: number) => item + index)

          ForEach(unauthorizedPayMethod, (item: PayMethod) => {
            if (item !== defaultPayMethod) {
              this.myPayList(item, false)
            }
          }, (item: string, index: number) => item + index)
        }
        .alignItems(HorizontalAlign.Start)
        .height('100%')
        .width(304)
      }
      .backgroundColor($r('app.color.tab_font_color_selected'))
      .width(328)
      .height(200)
      .borderRadius(16)

      Column() {
        Column() {
          Text($r('app.string.mention'))
            .fontSize(14)
            .fontColor($r('app.color.grey'))
          Text($r('app.string.mention_content'))
            .fontSize(12)
            .fontColor($r('app.color.grey'))
            .margin({ top: 8 })
        }
        .margin({ top: 12 })
        .alignItems(HorizontalAlign.Start)
        .width(304)
      }
      .margin({ top: 12 })
      .borderRadius(16)
      .width(328)
      .height(100)
      .backgroundColor($r('app.color.tab_font_color_selected'))
    }
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .height('100%')
  }

  @Builder
  myPayList(payMethod: PayMethod, checked: boolean) {
    Row() {
      Row() {
        Row() {
          Image(payMethod.imageDefault)
            .width(24)
            .height(24)
        }
        .margin({ left: 12 })
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background_color_white'))
        .width(40)
        .height(40)
        .borderRadius(20)

        Text(payMethod.text)
          .fontSize(14)
          .fontColor($r('app.color.tab_font_color_selected'))
          .margin({ left: 12 })
      }

      if (payMethod.authorised) {
        Radio({ value: 'Radio1', group: 'radioGroup' })
          .checked(checked)
          .radioStyle({})
          .borderRadius(10)
          .backgroundColor($r('app.color.background_color_white'))
          .margin({ right: 14 })
          .width(20)
          .height(20)
      } else {
        Row() {
          Text('立即开通')
            .fontSize(12)
            .fontColor($r('app.color.tab_font_color_selected'))
          Image($r('app.media.ic_public_right_arrow_for_pay'))
            .width(16)
            .height(16)
            .margin({ left: 4 })
            .onClick(() => {
              let link: Resource | undefined = payMethod.url;
              if (link != null) {
                this.context.openLink(this.context.resourceManager.getStringSync(link), { appLinkingOnly: true })
                  .then(() => {
                    console.info('openlink success.');
                  })
                  .catch((error: BusinessError) => {
                    console.error(`openlink failed. error:${JSON.stringify(error)}`);
                  });
              }

            })
        }
        .height(16)
        .margin({ right: 14 })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 12 })
    .borderRadius(8)
    .backgroundColor(payMethod.backgroundColor)
    .width('100%')
    .height(60)
  }
}

