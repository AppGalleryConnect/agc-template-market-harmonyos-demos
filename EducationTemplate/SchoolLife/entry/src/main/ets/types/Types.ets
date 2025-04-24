export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
  component: WrappedBuilder<[]>;
  titleBgColor: ResourceColor;
}