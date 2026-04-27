import {
  OrderTabsMap, OrderStatusMap, OrderButtonStyleMap, OrderActionMap,
} from './Enums';

/**
 * 订单类型
 */
export interface OrderType {
  type: OrderTabsMap;
  label: string;
  statusInfo: OrderStatusInfo[];
}

/**
 * 订单状态
 */
export interface OrderStatusInfo {
  status: OrderStatusMap;
  action: OrderAction[];
}

/**
 * 订单操作
 */
export interface OrderAction {
  style: OrderButtonStyleMap;
  actionType: OrderActionMap;
  label: string;
  enableHide?: boolean;
}

/**
 * 订单操作入参
 */
export interface OrderActionReq {
  orderNo: string;
  callback?: () => void;
  data?: object;
}

export interface TextSegment {
  text: string;
  isPhone: boolean;
}


export interface CourierInfo {
  name: string
  contactPhone: string
}


export class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  buttonStyle: OrderButtonStyleMap = OrderButtonStyleMap.PRIMARY;
  size: ControlSize = ControlSize.NORMAL;

  constructor(
    buttonStyle: OrderButtonStyleMap = OrderButtonStyleMap.PRIMARY,
    size: ControlSize = ControlSize.NORMAL,
  ) {
    this.buttonStyle = buttonStyle;
    this.size = size;
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    instance
      .fontSize(
        this.size === ControlSize.NORMAL
          ? $r('app.float.font_size_14')
          : $r('app.float.font_size_12'),
      )
      .height(this.size === ControlSize.NORMAL ? 40 : 28)
      .padding({
        left: $r('app.float.space_m'),
        right: $r('app.float.space_m'),
        top: $r('app.float.space_xs'),
        bottom: $r('app.float.space_xs'),
      })
      .constraintSize({ minWidth: this.size === ControlSize.NORMAL ? 96 : 64 });

    if (this.buttonStyle === OrderButtonStyleMap.PRIMARY) {
      instance.backgroundColor($r('app.color.theme_color'));
    } else {
      instance
        .backgroundColor($r('app.color.background_color_primary'))
      if (this.buttonStyle === OrderButtonStyleMap.SECONDARY) {
        instance
          .backgroundColor($r('app.color.background_color_button_grey'))
          .fontColor($r('app.color.theme_color'));
      } else if (this.buttonStyle === OrderButtonStyleMap.OTHERS) {
        instance
          .backgroundColor($r('app.color.background_color_button_grey'))
          .fontColor($r('app.color.font_color_level1'));
      }
    }
  }
}
