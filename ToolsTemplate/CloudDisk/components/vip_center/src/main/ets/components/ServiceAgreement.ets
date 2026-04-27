import { VipNavTitle } from './VipNavTitle';

@Builder
export function ServiceAgreementBuilder() {
  ServiceAgreement()
}

/**
 * @usage: 用于会员服务协议展示场景。提供会员服务协议内容查看页面。
 * 关键数据结构：routerModule（导航路由栈NavPathStack）。
 * @layout: 导航目标页面布局。顶部为VipNavTitle导航标题（浅黄色背景），中间为协议内容文字（居中显示）。
 * @constraints: routerModule导航路由栈必须正确初始化
 * @isGen: true
 * @fileType: component
 * @zhName: 会员服务协议组件
 */
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