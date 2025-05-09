import { CommonConstants, EmitterConstants, RouterModule } from 'commonlib';
import { CouponItem } from 'network';
import { ReductionTypes, ScenarioStatus } from '../types';
import { getReduceDays, getReduceDesc, getScenarioStatus } from '../utils';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct CouponCard {
  /** 接收参数 **/
  // 优惠券信息
  @Require @Param coupon: CouponItem;
  // 是否来源订单页;
  @Param isOrder: boolean = false;
  // 订单总金额;
  @Param totalMoney: number = 0;
  // 已选择优惠券ID;
  @Param selectId: string = '';
  // 选中优惠券回调
  @Event clickCoupon: (coupon: CouponItem) => void = () => {
  };
  /** 本地参数 **/
  @Local showInstruction: boolean = false;
  private status: ScenarioStatus = ScenarioStatus.NOW_USE;

  aboutToAppear() {
    this.status = getScenarioStatus(this.coupon, this.totalMoney);
  }

  build() {
    Column() {
      // 主体部分
      Row() {
        // 左
        Column({ space: 2 }) {
          Row({ space: 2 }) {
            if (this.coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
              Text((Number(this.coupon.amountRule.discountCoefficient) * 10).toFixed(1)).leftMainNumberStyle()
              Text($r('app.string.discount')).leftMainUnitStyle().margin({ bottom: $r('app.string.margin_4') })
            } else {
              Text($r('app.string.currency_symbol')).leftMainUnitStyle().margin({ bottom: $r('app.string.margin_4') })
              Text(this.coupon.amountRule.discountAmount).leftMainNumberStyle()
            }
          }.alignItems(VerticalAlign.Bottom)

          if (this.coupon.amountRule.discountType === ReductionTypes.FULL_REDUCTION) {
            Text($r('app.string.full_available', `${Number(this.coupon.amountRule.fullAmount)}`)).leftSubStyle()
          } else if (this.coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
            Text($r('app.string.discount_available', '新品')).leftSubStyle()
          } else {
            Text($r('app.string.no_threshold')).leftSubStyle()
          }
        }
        .justifyContent(FlexAlign.Center)
        .width(90)

        // 右
        Column({ space: 4 }) {
          Text(this.coupon.couponName)
            .maxLines(1)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .lineHeight($r('app.string.line_height_21'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text($r('app.string.coupon_type'))
            .rightSubStyle()
            .margin({ top: $r('app.string.margin_2') })

          Text(`${this.coupon.endTime + ' 23:59'} 到期`).rightSubStyle()

          if (this.isOrder &&
            (this.status === ScenarioStatus.FUTURE_USE || this.status === ScenarioStatus.LESS_FULL)) {
            Row({ space: 4 }) {
              Image($r('app.media.ic_icon_error')).width(12)
              if (this.status === ScenarioStatus.LESS_FULL) {
                Text($r('app.string.below_threshold',
                  (Number(this.coupon.amountRule.fullAmount) - this.totalMoney).toFixed(2))).rightReminderStyle()
              } else {
                Text($r('app.string.below_startTime', getReduceDays(this.coupon))).rightReminderStyle()
              }
            }
          }
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: $r('app.string.padding_12') })
        .border({ width: { left: 1 }, style: BorderStyle.Dashed, color: 'rgba(238, 59, 85, 0.2)' })

        // 右上
        if (this.status === ScenarioStatus.HAS_USED) {
          Image($r('app.media.ic_coupon_used')).width(48).position({ top: -24, right: -8 })
        } else if (this.status === ScenarioStatus.EXPIRE) {
          Image($r('app.media.ic_coupon_expired')).width(48).position({ top: -24, right: -8 })
        } else if (this.isOrder) {
          if (this.status === ScenarioStatus.NOW_USE) {
            Radio({ value: '', group: 'radioGroup' })
              .position({ top: -4, right: 10 })
              .checked(this.selectId === this.coupon.couponID)
              .radioStyle({ checkedBackgroundColor: $r('app.color.sys_brand_fuchsia') })
              .height(20)
              .width(20)
              .onClick(() => {
                this.clickCoupon(this.coupon);
              })
          }
        } else {
          Text($r('app.string.use_now'))
            .position({ top: 0, right: 12 })
            .fontSize($r('app.string.font_size_14'))
            .lineHeight($r('app.string.line_height_18'))
            .fontColor($r('app.color.sys_background_white'))
            .borderRadius($r('app.string.border_radius_8'))
            .backgroundColor($r('app.color.sys_brand_fuchsia'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            })
            .onClick(() => {
              emitter.emit(EmitterConstants.TO_HOME);
              RouterModule.pop();
            })
        }

        // 右下
        Image(this.showInstruction ? $r('app.media.ic_up') : $r('app.media.ic_down'))
          .width(24)
          .height(24)
          .position({ right: 12, bottom: 0 })
          .onClick(() => {
            this.showInstruction = !this.showInstruction;
          })
      }
      .clip(true)
      .width(CommonConstants.FULL_WIDTH)
      .borderRadius($r('app.string.border_radius_16'))
      .backgroundColor($r('app.color.sys_background_white'))
      .opacity(this.status === ScenarioStatus.NOW_USE ||
        (!this.isOrder && (this.status === ScenarioStatus.FUTURE_USE || this.status === ScenarioStatus.LESS_FULL)) ?
        1 : 0.4)
      .padding({ top: $r('app.string.padding_16'), bottom: $r('app.string.padding_16') })

      // 隐藏说明
      if (this.showInstruction) {
        Column({ space: 6 }) {
          Text($r('app.string.instruction_label'))
            .fontSize($r('app.string.font_size_10'))
            .fontColor($r('sys.color.font_secondary'))
          Text(`优惠时间: ${this.coupon.startTime}零点至${this.coupon.endTime}午时`).descTextStyle()
          Text(`优惠方式: ${getReduceDesc(this.coupon)}`).descTextStyle()
        }
        .alignItems(HorizontalAlign.Start)
        .width(CommonConstants.FULL_WIDTH)
        .padding({
          top: 8,
          bottom: 8,
          left: 20,
          right: 20,
        })
      }
    }.width(CommonConstants.FULL_WIDTH)
  }
}

@Extend(Text)
function leftMainNumberStyle() {
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontSize($r('app.string.font_size_24'))
}

@Extend(Text)
function leftMainUnitStyle() {
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontSize($r('app.string.font_size_12'))
}

@Extend(Text)
function leftSubStyle() {
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontSize($r('app.string.font_size_10'))
  .lineHeight($r('app.string.line_height_13'))
}

@Extend(Text)
function rightSubStyle() {
  .fontSize($r('app.string.font_size_12'))
  .lineHeight($r('app.string.line_height_16'))
  .fontColor($r('app.color.sys_brand_fuchsia'))
}


@Extend(Text)
function rightReminderStyle() {
  .fontSize($r('app.string.font_size_10'))
  .fontColor($r('app.color.sys_brand_fuchsia'))
}

@Extend(Text)
function descTextStyle() {
  .fontSize($r('app.string.font_size_8'))
  .fontColor($r('sys.color.font_secondary'))
}