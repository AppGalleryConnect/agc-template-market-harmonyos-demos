import { util } from '@kit.ArkTS';
import { SettingType, SupportedSetting } from './SettingType';

export interface ISelectOption {
  id: number | string;
  label: string;
  value?: Object;
}

export interface IRouterParams {
  routerName: string;
  routerParams?: Object;
  onPop?: () => void;
  animated?: boolean;
}

/**
 * 设置item模型
 */
@ObservedV2
export class SettingItem {
  @Trace id: string = util.generateRandomUUID();
  @Trace type: SettingType = SettingType.TEXT;
  @Trace supportedType?: SupportedSetting;
  @Trace extraParams?: Object;
  @Trace label?: ResourceStr;
  @Trace subLabel?: ResourceStr = '';
  @Trace routerParam?: IRouterParams;
  @Trace switchV?: boolean = false;
  @Trace selectIndex: number = 0;
  @Trace selectOptions?: ISelectOption[];
  @Trace autoClose: boolean = true;
  @Trace normalText?: ResourceStr = '';
  @Trace onClick?: (param?: Object) => void;
  @Trace onSelect?: (index: number) => void;
  @Trace onChange?: (param?: Object) => void;
  @Trace showPop: boolean = false;

  public setItemId(id: string): SettingItem {
    this.id = id;
    return this;
  }

  public setType(type: SettingType): SettingItem {
    this.type = type;
    return this;
  }

  public setSupportedType(supportedType: SupportedSetting): SettingItem {
    this.supportedType = supportedType;
    return this;
  }

  public setExtraParams(extraParams?: Object): SettingItem {
    this.extraParams = extraParams;
    return this;
  }

  public setLabel(label: ResourceStr): SettingItem {
    this.label = label;
    return this;
  }

  public setSubLabel(subLabel: ResourceStr): SettingItem {
    this.subLabel = subLabel;
    return this;
  }

  public setRouterParam(routerParam: IRouterParams): SettingItem {
    this.routerParam = routerParam;
    return this;
  }

  public setSwitchValue(switchV: boolean): SettingItem {
    this.switchV = switchV;
    return this;
  }

  public setSelectIndex(selectIndex: number): SettingItem {
    this.selectIndex = selectIndex;
    return this;
  }

  public setSelectOptions(selectOptions: ISelectOption[]): SettingItem {
    this.selectOptions = selectOptions;
    return this;
  }

  public setAutoClose(autoClose: boolean): SettingItem {
    this.autoClose = autoClose;
    return this;
  }

  public setShowPop(showPop: boolean): SettingItem {
    this.showPop = showPop;
    return this;
  }

  public setNormalText(normalText: ResourceStr): SettingItem {
    this.normalText = normalText;
    return this;
  }

  public setClickEvent(func: (param?: Object) => void): SettingItem {
    this.onClick = (param?: Object) => {
      func(param);
    };
    return this;
  }

  public setSelectEvent(func: (index: number) => void): SettingItem {
    this.onSelect = (index: number) => {
      func(index);
    };
    return this;
  }

  public setOnChange(func: (param?: Object) => void): SettingItem {
    this.onChange = (param?: Object) => {
      func(param);
    };
    return this;
  }
}

@ObservedV2
export class SettingGroup {
  @Trace id: string = util.generateRandomUUID();
  @Trace title?: ResourceStr = '';
  @Trace list: SettingItem[] = [];

  public setGroupId(id: string): SettingGroup {
    this.id = id;
    return this;
  }

  public setTitle(title: ResourceStr): SettingGroup {
    this.title = title;
    return this;
  }

  public setList(list: SettingItem[]): SettingGroup {
    this.list = list;
    return this;
  }
}