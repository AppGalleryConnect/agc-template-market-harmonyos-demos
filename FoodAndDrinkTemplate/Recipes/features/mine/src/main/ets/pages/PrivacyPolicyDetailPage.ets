import { BreakpointModel, BreakpointType, buildTitleBar } from 'commonlib';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';

@Builder
export function PrivacyPolicyDetailPageBuilder() {
  PrivacyPolicyDetailPage();
}

@ComponentV2
export struct PrivacyPolicyDetailPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 16,
    md: 16,
    lg: 238,
    xl: 238,
  });

  @Computed
  get columnPadding() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  build() {
    NavDestination() {
      Column() {
        Text('注册信息：在用户注册菜谱App账号时，根据App要求提供的个人注册信息，如用户名、密码、手机号码等。\n' +
          '使用记录：用户使用菜谱App网络服务，或访问App平台网页时，App自动接收并记录的浏览器和计算机上的信息，包括但不限于IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及用户需求的网页记录等数据。\n' +
          '合作数据：App通过合法途径从商业伙伴处取得的用户个人数据。\n' +
          '此外，部分信息可能不适用该隐私政策，比如用户在使用App平台提供的搜索服务时输入的关键字信息，App收集到的用户在App发布的有关信息数据（包括但不限于参与活动、成交信息及评价详情），违反法律规定或违反App规则行为及App已对用户采取的措施。')
          .lineHeight(24);
      }
      .height('100%')
      .width('100%')
      .padding({ top: this.columnPadding === 16 ? this.columnPadding : 78 , bottom: this.columnPadding,
        left: this.columnPadding,
        right: this.columnPadding });
    }
    .title(buildTitleBar('用户协议'), { paddingStart: LengthMetrics.vp(16) })
    .padding({top: 40})
  }
}