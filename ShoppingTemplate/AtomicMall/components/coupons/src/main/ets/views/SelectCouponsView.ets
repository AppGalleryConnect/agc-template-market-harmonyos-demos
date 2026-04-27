import { CouponCard } from '../components/CouponCard';
import { CouponCommonLoading } from '../components/CouponCommonLoading';
import { buildCouponEmptyStatus } from '../components/CouponEmptyStatus';
import { getReduceAmount, getScenarioStatus } from '../utils/CouponCalculator';
import { SelectCouponButton } from '../components/SelectCouponButton';
import { ScenarioStatus } from '../commons/Enums';
import { CouponItem, CouponsControllerType } from '../commons/Types';

@ComponentV2
export struct SelectCouponsView {
  @Require @Param controller: CouponsControllerType;
  @Local currentIndex: number = 0;

  @Computed
  get contentData() {
    const data: CouponItem[][] = [[], []];
    this.controller.couponList.forEach(item => {
      const status = getScenarioStatus(item, this.controller.totalMoney);
      switch (status) {
        case ScenarioStatus.NOW_USE:
          data[0].push(item);
          break;
        case ScenarioStatus.LESS_FULL:
        case ScenarioStatus.FUTURE_USE:
          data[1].push(item);
          break;
        default:
          break;
      }
    });
    // 减免多 => 减免少
    data[0].sort((a, b) =>
    getReduceAmount(b, this.controller.totalMoney) - getReduceAmount(a, this.controller.totalMoney),
    );
    // 满额不足 => 活动未开始
    data[1].sort((a, b) =>
    getScenarioStatus(a, this.controller.totalMoney) - getScenarioStatus(b, this.controller.totalMoney),
    );
    return data;
  }

  async aboutToAppear() {
    await this.controller.loadCoupons();
  }

  build() {
    Column() {
      SelectCouponButton({
        onIndexChange: (index) => {
          this.currentIndex = index
        },
      })
      if (this.controller.isLoading) {
        CouponCommonLoading()
      } else if (this.contentData[this.currentIndex].length === 0) {
        buildCouponEmptyStatus(this.emptyMessageForSelect())
      } else {
        Column() {
          List({ space: 12 }) {
            ForEach(this.contentData[this.currentIndex], (item: CouponItem) => {
              ListItem() {
                CouponCard({
                  coupon: item,
                  totalMoney: this.controller.totalMoney,
                  isAvailable: this.currentIndex === 0,
                  themeColor: this.controller.themeColor,
                  actionSlot: (status: ScenarioStatus) => {
                    this.couponActionBuilder(item, status);
                  },
                })
              }
            }, (item: CouponItem, i: number) => JSON.stringify(item) + '_' + i)
          }
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)

          if (!this.currentIndex && !this.controller.isLoading) {
            this.bottomBuilder();
          }
        }
        .padding($r('app.float.padding_16'))
        .layoutWeight(1)
      }
    }
    .layoutWeight(1)
    .backgroundColor($r('app.color.background_color_sheet'))
    .expandSafeArea()
  }

  @Builder
  couponActionBuilder(item: CouponItem, status: ScenarioStatus) {
    if (status === ScenarioStatus.NOW_USE) {
      Radio({ value: '', group: 'radioGroup' })
        .checked(this.controller.selectedId === item.couponID)
        .radioStyle({ checkedBackgroundColor: this.controller.themeColor })
        .height(20)
        .width(20)
        .onClick(() => {
          this.controller.toggleSelect(item);
        })
    }
  }

  @Builder
  bottomBuilder() {
    Column({ space: 8 }) {
      Text() {
        Span($r('app.string.selected_coupon', this.controller.selectedId ? '1' : '0'))
          .fontColor($r('app.color.font_color_level1'))
        Span($r('app.string.currency_symbol'))
        Span(this.controller.reduce.toFixed(2))
      }
      .fontSize($r('app.float.font_size_12'))
      .fontColor(this.controller.themeColor)

      Button($r('app.string.confirm'))
        .fontColor($r('sys.color.font_on_primary'))
        .height(40)
        .backgroundColor(this.controller.themeColor)
        .onClick(async () => {
          await this.controller.confirm();
          this.controller.closeSheet?.();
        })
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: $r('app.float.padding_8'), bottom: $r('app.float.padding_16') })
    .expandSafeArea()
    .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 100, curve: Curve.Smooth }))
  }

  private emptyMessageForSelect(): ResourceStr {
    if (this.currentIndex === 0) {
      return $r('app.string.coupon_empty_available');
    }
    return $r('app.string.coupon_empty_unavailable');
  }
}
