// ArkTS 要求对象字面量对应显式类型，声明弹出层选项接口
export interface PopupOffset {
  x: number;
  y: number
}

export interface CustomPopupOptions {
  builder: () => void;
  enableArrow?: boolean;
  autoCancel?: boolean;
  placement?: Placement;
  width?: number;
  offset?: PopupOffset;
  radius?: number;
  onWillDismiss?: () => void;
}