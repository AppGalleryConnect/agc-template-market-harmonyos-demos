export interface TabSingleItem {
  label?: ResourceStr;
  fontColor?: ResourceColor;
  fontColorActive?: ResourceColor;
  index?: number;
  icon?: Resource;
  iconActive?: Resource;
  component?: WrappedBuilder<[string]>;
}