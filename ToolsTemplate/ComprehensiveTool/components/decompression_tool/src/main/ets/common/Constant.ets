export enum MenuType {
  AUTOMATIC = 1,
  HIDE = 2,
  CLEAR = 3
}

@ObservedV2
export class IMenu {
  @Trace type: MenuType = MenuType.AUTOMATIC
  @Trace label: string = ''
}

export const menuList: IMenu[] = [
  {
    type: MenuType.AUTOMATIC,
    label: '自动',
  },
  {
    type: MenuType.HIDE,
    label: '隐藏次数',
  },
  {
    type: MenuType.CLEAR,
    label: '次数清零',
  },
]

