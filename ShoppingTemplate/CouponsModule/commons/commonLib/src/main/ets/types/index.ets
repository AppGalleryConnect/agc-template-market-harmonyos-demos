export interface TabListItem {
  label: string,
  icon: Resource,
  iconChecked: Resource,
  component: WrappedBuilder<[]>,
}

export interface ClickGridItem {
  title: string,
  icon: ResourceStr,
  click?: () => void,
}

export interface ClickListItem {
  icon?: ResourceStr,
  label: string,
  value?: string,
  click?: () => void,
}

export interface OnPopParams {
  reduce: number,
  selectId: string,
}