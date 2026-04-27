import { ReductionTypes, ScenarioStatus } from '../commons/Enums';
import { CouponItem } from '../commons/Types';
import { getScenarioStatus, getReduceDays, getReduceDesc } from '../utils/CouponCalculator';

@Preview
@ComponentV2
export struct CouponCard {
  @Require @Param coupon: CouponItem;
  @Param totalMoney: number = 0;
  @Param themeColor: ResourceColor = $r('sys.color.multi_color_08');
  /** 由父组件根据场景决定是否可用（影响透明度） */
  @Param isAvailable: boolean = true;
  /** 右上角操作区（使用按钮 / Radio / 状态图），由父组件提供 */
  @BuilderParam actionSlot: (status: ScenarioStatus) => void = this.defaultSlot;
  @Local showBottomDesc: boolean = false

  @Computed
  get status(): ScenarioStatus {
    return getScenarioStatus(this.coupon, this.totalMoney);
  }

  @Computed
  get mainNumber() {
    if (this.coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
      return (Number(this.coupon.amountRule.discountCoefficient) * 10).toFixed(1)
    }
    return this.coupon.amountRule.discountAmount
  }

  @Computed
  get restrictionLabel() {
    if (this.coupon.amountRule.discountType === ReductionTypes.FULL_REDUCTION) {
      return $r('app.string.full_available', `${Number(this.coupon.amountRule.fullAmount)}`)
    }
    return ''
  }

  @Computed
  get fontColor() {
    if (this.isAvailable) {
      return this.themeColor
    }
    return $r('app.color.font_color_level2')
  }

  @Computed
  get badgeLabel() {
    if (this.status === ScenarioStatus.HAS_USED) {
      return '已使用'
    }
    if (this.status === ScenarioStatus.EXPIRE) {
      return '已失效'
    }
    const createTimestamp: number = new Date(this.coupon.createdTime).getTime()
    if (new Date().getTime() - createTimestamp <= 60 * 60 * 24 * 1000) {
      return 'New'
    }
    return ''
  }

  @Builder
  defaultSlot(_status: ScenarioStatus) {
  }

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text() {
              if (this.coupon.amountRule.discountType !== ReductionTypes.DISCOUNT_REDUCTION) {
                Span($r('app.string.currency_symbol'))
              }
              Span(this.mainNumber).fontSize($r('app.float.font_size_24'))
              if (this.coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
                Span($r('app.string.discount'))
              }
              if (this.restrictionLabel) {
                Span(' ').letterSpacing(2)
                Span(this.restrictionLabel)
                  .fontSize($r('app.float.font_size_10'))
                  .opacity(0.6)
                  .fontWeight(FontWeight.Regular)
              }
            }
            .fontColor(this.fontColor)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')

          Text(this.coupon.couponName)
            .fontSize($r('app.float.font_size_14'))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.fontColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: $r('app.float.margin_4') })

          if (this.coupon.usageRestriction) {
            Text(this.coupon.usageRestriction)
              .subStyle(this.fontColor)
              .margin({ bottom: $r('app.float.margin_4') })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Text(`${this.coupon.endTime + ' 23:59'} 到期`).subStyle(this.fontColor)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 右上操作区，由父组件通过 actionSlot 提供
        Column() {
          this.actionSlot(this.status)
          Blank().height(16)
          if (this.status !== ScenarioStatus.LESS_FULL && this.status !== ScenarioStatus.FUTURE_USE) {
            SymbolGlyph(this.showBottomDesc ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
              .fontColor([this.fontColor])
              .fontSize(24)
              .opacity(0.6)
              .onClick(() => {
                this.showBottomDesc = !this.showBottomDesc;
              })
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.End)
        .constraintSize({ maxWidth: '40%' })
        .padding({left:$r('app.float.padding_16')})
      }
      .alignItems(VerticalAlign.Bottom)

      if (this.badgeLabel) {
        Row() {
          Text(this.badgeLabel)
            .fontColor($r('app.color.font_color_level1_invert'))
            .fontSize($r('app.float.font_size_10'))
        }
        .backgroundColor(this.fontColor)
        .borderRadius({
          bottomLeft: 12,
          topRight: 12,
        })
        .padding({
          left: 8,
          right: 8,
          top: 2,
          bottom: 2,
        })
        .position({
          right: -12,
          top: -12,
        })
      }

      if (this.status === ScenarioStatus.LESS_FULL || this.status === ScenarioStatus.FUTURE_USE) {
        this.buildCouponReminder()
      } else {
        if (this.showBottomDesc) {
          this.buildBottomDescription()
        }
      }
    }
    .clip(true)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('app.float.border_radius_16'))
    .backgroundColor($r('app.color.background_color_primary'))
    .padding(14)
    .border({
      width: 2,
      color: $r('app.color.background_color_primary'),
    })
  }

  @Builder
  buildCouponReminder() {
    Row()
      .width('100%')
      .border({
        width: { top: 1 },
        color: this.fontColor,
        style: BorderStyle.Dashed,
      })
      .opacity(0.6)
      .margin({ top: 8 })

    Column({ space: 4 }) {
      Text('本单不可用原因')
        .fontSize($r('app.float.font_size_10'))
        .fontColor(this.themeColor)

      if (this.status === ScenarioStatus.LESS_FULL) {
        Text($r('app.string.below_threshold',
          (Number(this.coupon.amountRule.fullAmount) - this.totalMoney).toFixed(2)))
          .reminderStyle($r('app.color.font_color_level2'))
      } else {
        Text($r('app.string.below_startTime', getReduceDays(this.coupon)))
          .reminderStyle($r('app.color.font_color_level2'))
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 8 })
    .width('100%')

  }

  @Builder
  buildBottomDescription() {
    Column({ space: 4 }) {
      Text() {
        Span($r('app.string.validity_time_prefix'))
        Span(`${this.coupon.startTime}零点至${this.coupon.endTime}午时\n`)
        Span($r('app.string.discount_method_prefix'))
        Span(getReduceDesc(this.coupon))
      }
      .fontColor($r('app.color.font_color_level1'))
      .fontSize($r('app.float.font_size_10'))
      .lineHeight(12)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 8 })
    .margin({ top: 8 })
    .width('100%')
    .border({
      width: { top: 1 },
      color: this.fontColor,
      style: BorderStyle.Dashed,
    })
    .opacity(0.6)
  }
}

@Extend(Text)
function subStyle(color: ResourceColor) {
  .fontColor(color)
  .fontSize($r('app.float.font_size_10'))
  .opacity(0.6)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text)
function reminderStyle(color: ResourceColor) {
  .fontSize($r('app.float.font_size_10'))
  .fontColor(color);
}
