import { VipNavTitle } from './VipNavTitle';

@Builder
export function ServiceAgreementBuilder() {
  ServiceAgreement()
}

@ComponentV2
export struct ServiceAgreement {
  @Local routerModule: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      VipNavTitle({
        title: '会员服务协议',
        bg: '#F3E0C3',
        routerModule: this.routerModule,
      })
      Column() {
        Text('会员服务协议内容')
      }
      .margin({ top: '60%' })
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.routerModule = ctx.pathStack
    })
  }
}