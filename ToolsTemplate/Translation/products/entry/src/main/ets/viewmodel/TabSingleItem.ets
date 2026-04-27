// Tab单项数据模型

export interface TabSingleItem {
  label: ResourceStr;
  index: number;
  fontColor: ResourceStr;
  fontColorActive: ResourceStr;
  icon: ResourceStr;
  iconActive: ResourceStr;
  component: WrappedBuilder<[string]>;
}
