export class BaseTabBarItem {
  type: string = ''
  text: ResourceStr = ''
  icon?: ResourceStr = ''

  constructor(type: string, text: ResourceStr, icon?: ResourceStr) {
    this.type = type
    this.text = text
    this.icon = icon
  }
}

// 选择列表弹框
export class BaseSelectedListItem {
  type: string = ''
  label: ResourceStr = ''

  constructor(type: string, label: ResourceStr) {
    this.type = type
    this.label = label
  }
}