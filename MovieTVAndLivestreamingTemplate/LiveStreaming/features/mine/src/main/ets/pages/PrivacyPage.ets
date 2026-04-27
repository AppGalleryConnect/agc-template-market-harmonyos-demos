import { BarVM } from '@agctemplate/widgets';

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage();
}

@ComponentV2
export struct PrivacyPage {
  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('隐私协议')
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Text('注册信息：在用户注册备考App账号时，根据App要求提供的个人注册信息，如用户名、密码、手机号码等。\n' +
          '使用记录：用户使用备考App网络服务，或访问App平台网页时，App自动接收并记录的浏览器和计算机上的信息，包括但不限于IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及用户需求的网页记录等数据。\n' +
          '合作数据：App通过合法途径从商业伙伴处取得的用户个人数据。\n' +
          '此外，部分信息可能不适用该隐私政策，比如用户在使用App平台提供的搜索服务时输入的关键字信息，App收集到的用户在App发布的有关信息数据（包括但不限于参与活动、成交信息及评价详情），违反法律规定或违反App规则行为及App已对用户采取的措施。')
          .lineHeight(24);
      }.height('100%').width('100%')
      .padding({ left: 16, right: 16, top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH });
    }.hideTitleBar(true)
  }
}