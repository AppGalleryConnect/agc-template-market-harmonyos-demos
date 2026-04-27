import { SeckillProductInfo, SeckillStatus } from 'lib_network';

export interface SeckillProductStyle {
  progressBgColor: ResourceColor| LinearGradientOptions
  progressLabelFontColor: ResourceColor
  soldLabelFontColor: ResourceColor
  originalPriceFontColor: ResourceColor
  originalPriceBgColor: ResourceColor
  seckillPriceFontColor: ResourceColor
  seckillPriceBgColor: ResourceColor
  buttonFontColor: ResourceColor
  buttonBgColor: ResourceColor
}

export class SeckillUtil {
  /** 获取进度条文案 */
  public static getPercentLabel(product: SeckillProductInfo) {
    if (product.remainStock === 0) {
      return '已售罄';
    }
    const sold = product.totalStock - product.remainStock;
    const percent = (sold / product.totalStock) * 100;
    if (percent < 20) {
      return '新品开抢';
    }
    if (percent > 90) {
      return '即将售罄';
    }
    return '已抢' + percent.toFixed(0) + '%';
  }

  /** 获取销售量文案 */
  public static getSoldLabel(product: SeckillProductInfo) {
    if (!product.remainStock) {
      return '限量抢购';
    }
    const sold = product.totalStock - product.remainStock;
    if (!sold) {
      return '';
    }
    let soldLabel: string = '';

    if (sold < 100) {
      soldLabel = sold.toString();
    } else if (sold < 1000) {
      soldLabel = Math.floor(sold / 100) + '00+';
    }
    return '已售' + soldLabel;
  }

  /** 获取秒杀商品卡片样式 */
  public static getSeckillProductStyle(product: SeckillProductInfo, status: SeckillStatus): SeckillProductStyle {
    if (status === SeckillStatus.ONGOING) {
      if (product.remainStock === 0) {
        return {
          progressBgColor: $r('app.color.background_color_button_grey'),
          progressLabelFontColor: $r('app.color.font_color_level3'),
          soldLabelFontColor: $r('app.color.font_color_level3'),
          originalPriceFontColor: $r('app.color.font_color_level3'),
          originalPriceBgColor: $r('app.color.background_color_button_grey'),
          seckillPriceFontColor: $r('app.color.font_color_level3'),
          seckillPriceBgColor: $r('app.color.background_color_button_grey'),
          buttonFontColor: $r('app.color.font_color_level3'),
          buttonBgColor: $r('app.color.background_color_button_grey'),
        };
      }else{
        return {
          progressBgColor: {
            colors: [[0xFFE64566, 0.5], [0x8FE86581, 0.9]],
            direction: GradientDirection.Left,
          },
          progressLabelFontColor: $r('app.color.font_color_level1_invert'),
          soldLabelFontColor: $r('app.color.theme_color'),
          originalPriceFontColor:$r('app.color.font_color_level2'),
          originalPriceBgColor: $r('app.color.background_color_primary'),
          seckillPriceFontColor:  $r('app.color.theme_color'),
          seckillPriceBgColor: $r('app.color.background_color_theme'),
          buttonFontColor: $r('app.color.font_color_level1_invert'),
          buttonBgColor:  $r('app.color.theme_color'),
        };
      }
      }else {
        return {
          progressBgColor: {
            colors: [[0xFFE64566, 0.5], [0x8FE86581, 0.9]],
            direction: GradientDirection.Left,
          },
          progressLabelFontColor: $r('app.color.font_color_level1_invert'),
          soldLabelFontColor: $r('app.color.theme_color'),
          originalPriceFontColor:$r('app.color.font_color_level2'),
          originalPriceBgColor: $r('app.color.background_color_primary'),
          seckillPriceFontColor:  $r('app.color.theme_color_second'),
          seckillPriceBgColor: $r('app.color.background_color_theme_second'),
          buttonFontColor: $r('app.color.font_color_level1_invert'),
          buttonBgColor:  $r('app.color.theme_color_second'),
        };
    }
  }
}
