import { SkeletonType, UISkeleton } from '@hw-agconnect/ui-skeleton';
import { RouterMap, RouterModule } from 'lib_foundation';
import { HomePageVM } from '../viewModels/HomePageVM';
import { CommonButton } from './CommonButton';

@ComponentV2
export struct EventCard {
  vm: HomePageVM = HomePageVM.instance;
  // 优惠礼包价值
  @Local claimPackWorth: number = 788;
  // 实名认证新用户最高礼包价值
  @Local newUserAuthPackWorth: number = 24;
  @Param loading: boolean = false;

  @Computed
  get cardHeight() {
    const userInfo = this.vm.userInfoModel;
    if (!userInfo.isLogin || this.loading) {
      return 100;
    }
    if (userInfo.isVip && userInfo.isClaimBenefit && userInfo.isRealName) {
      return 0;
    }
    if (userInfo.isVip && userInfo.isClaimBenefit && !userInfo.isRealName) {
      return 60;
    }
    if ((!userInfo.isVip || !userInfo.isClaimBenefit) && userInfo.isRealName) {
      return 42;
    }
    return 100;
  }

  @Computed
  get showVip() {
    const userInfo = this.vm.userInfoModel;
    if (userInfo.isLogin && userInfo.isVip && userInfo.isClaimBenefit) {
      return false;
    }
    return true;
  }
  @Computed
  get showAuth() {
    if (this.vm.userInfoModel.isLogin && this.vm.userInfoModel.isRealName) {
      return false;
    }
    return true;
  }

  @Computed
  get vipText() {
    const userInfo = this.vm.userInfoModel;
    if (userInfo.isLogin && userInfo.isVip && !userInfo.isClaimBenefit) {
      return '去领取';
    }
    return '去开通';
  }

  // 跳转到会员中心
  jumpMembershipPage() {
    this.vm.loginJumpPage(RouterMap.PURCHASE_PAGE)
  }

  // 跳转到实名认证页面
  jumpRealNameAuthPage() {
    this.vm.loginJumpPage(RouterMap.REAL_NAME_AUTH_PAGE)
  }

  build() {
    Column() {
      UISkeleton({
        options: [{
          type: SkeletonType.RECT,
          radius: 16,
          width: '100%',
          height: this.cardHeight,
        }],
        loading: this.loading
      }) {
        Row() {
          // 开通会员
          this.membershipView()

          CommonButton({ text: this.vipText })
            .onClick(() => {
              // 跳转会员中心
              this.jumpMembershipPage();
            })
        }
        .width('100%')
        .height(40)
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
        .linearGradient({
          angle: 90,
          colors: [
            ['rgba(227, 216, 187, 1)', 0.3],
            ['rgba(245, 243, 239, 1)', 1],
          ],
        })
        .borderRadius(this.showAuth ? { topLeft: 16, topRight: 16 } : 16)
        .visibility(this.showVip ? Visibility.Visible : Visibility.None)

        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          // 实名认证
          this.realNameAuthView()

          CommonButton({ text: this.vm.userInfoModel.isRealName === 0 ? '去认证' : '已认证' })
            .onClick(() => {
              // 跳转实名认证
              this.jumpRealNameAuthPage();
            })
        }
        .height(58)
        .backgroundColor(Color.White)
        .padding({ left: 12, right: 12 })
        .borderRadius(this.showVip ? { bottomLeft: 16, bottomRight: 16 } : 16)
        .visibility(this.showAuth ? Visibility.Visible : Visibility.None)
      }
    }
    .width('100%')
    .height(this.cardHeight)
    .margin({ top: 16 })
  }

  @Builder
  membershipView() {
    Row({ space: 12 }) {
      Image($r('app.media.ic_vip'))
        .width(24)
        .height(24)
      Text('开通会员')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#936900')
      Text() {
        Span('可领')
          .fontColor('#936900')
        Span(` ${this.claimPackWorth}元 `)
          .fontColor('#0A59F7')
        Span('优惠礼包')
          .fontColor('#936900')
      }
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .lineHeight(16)
    }
  }

  @Builder
  realNameAuthView() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_home_Event'))
        .width(24)
        .height(24)
      Column({ space: 4 }) {
        Text() {
          Span('实名认证新用户最高')
            .fontColor($r('sys.color.font_primary'))
          Span(` ${this.newUserAuthPackWorth}元 `)
            .fontColor('#0A59F7')
          Span('首寄礼包')
            .fontColor($r('sys.color.font_primary'))
        }
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .lineHeight(16)

        Text('活动仅剩 30天')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor('#0A59F7')
          .lineHeight(13)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}