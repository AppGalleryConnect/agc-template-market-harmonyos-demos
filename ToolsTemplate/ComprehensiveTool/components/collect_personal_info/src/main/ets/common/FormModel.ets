import { PhoneApiInfo } from './DataModel';

// 支持的表单类型枚举
export enum FormType {
  CHOOSE_AVATAR = 'choose_avatar',
  TEXT_INPUT = 'text_input',
  PHONE_INPUT = 'phone_input',
  TEXTAREA = 'textarea',
  DROP_SELECT = 'drop_select',
  DATE_SELECT = 'date_select',
}

export interface ISelectOption {
  id: number | string;
  label: ResourceStr;
  value: Object;
}

// 表单模型
export interface InfoItem {
  type: FormType;
  value?: ResourceStr | Date | number | Object;
  label: ResourceStr;
  subLabel?: ResourceStr;
  placeholderText?: ResourceStr;
  validMessageText?: ResourceStr;
  minLength?: number;
  maxLength?: number;
  showValue?: boolean;
  showRightArrow?: boolean;
  selectOptions?: ISelectOption[];
  sheetTitle?: string;
  sheetOptions?: SheetOptions;
  invocation?: (param: Object) => Promise<void>;
  phoneInfo?: PhoneApiInfo;
  onChange?: (param?: Object) => void;
  onClick?: () => void;
}

// 表单状态模型
@ObservedV2
export class ObservedInfoItem implements InfoItem {
  @Trace type: FormType = FormType.TEXT_INPUT;
  @Trace value: ResourceStr | Date | number | Object = '';
  @Trace label: ResourceStr = '';
  @Trace subLabel: ResourceStr = '';
  @Trace placeholderText: ResourceStr = '';
  @Trace validMessageText: ResourceStr = '';
  @Trace minLength: number = 0;
  @Trace maxLength: number = 10;
  @Trace showRightArrow: boolean = true;
  @Trace showValue: boolean = true;
  @Trace selectOptions: ISelectOption[] = [];
  @Trace sheetTitle: string = '';
  @Trace sheetOptions: SheetOptions = {};
  @Trace showSheet: boolean = false;
  @Trace showPop: boolean = false;
  @Trace isInputFocus: boolean = true;
  @Trace invocation: (param: Object) => Promise<void> = (param: Object) => new Promise((resolve) => resolve());
  @Trace onChange: (param?: Object) => void = () => {
  };
  @Trace onClick?: () => void;
  @Trace phoneInfo: PhoneApiInfo = {
    codeLength: 6,
    sendCode: (phone: string) => Promise.resolve(),
    verifyCode: (phone: string, code: string) => Promise.resolve(),
  };

  constructor(item?: InfoItem) {
    if (!item) {
      return;
    }
    this.assignValue(item);
  }

  assignValue(item: InfoItem) {
    this.type = item.type;
    this.label = item.label;
    this.subLabel = item.subLabel ?? '';
    this.placeholderText = item.placeholderText ?? '';
    this.validMessageText = item.validMessageText ?? '';
    this.minLength = item.minLength ?? 0;
    this.maxLength = item.maxLength ?? 10;
    this.showRightArrow = item.showRightArrow ?? true;
    this.showValue = item.showValue ?? true;
    this.selectOptions = item.selectOptions ?? [];
    this.sheetTitle = item.sheetTitle ?? '';
    this.sheetOptions = item.sheetOptions ?? {};
    this.value = item.value ?? '';
    this.invocation = item.invocation ?? (() => new Promise((resolve) => resolve()));
    this.onChange = item.onChange ?? (() => {
    });
    this.onClick = item.onClick;
    if (item.phoneInfo) {
      this.phoneInfo = item.phoneInfo;
    }
  }
}

// 组合列表
@ObservedV2
export class FormGroup {
  @Trace list: ObservedInfoItem[] = [];
}