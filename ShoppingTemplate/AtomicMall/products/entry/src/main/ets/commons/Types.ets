import { MainMenuOption, SubMenuOption } from './Enums';

export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
  component: WrappedBuilder<[]>;
}

export interface MainMenuItem {
  type: MainMenuOption;
  icon: ResourceStr;
  label: string;
}

export interface SubMenuItem {
  type: SubMenuOption;
  icon: Resource;
  label: string;
}
