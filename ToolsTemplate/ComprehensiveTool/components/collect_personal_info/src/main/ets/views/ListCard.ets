import { AppStorageV2 } from '@kit.ArkUI';
import { Constants, GENDER_OPTIONS } from '../common/Constant';
import { encryptPhone, formatDate } from '../common/Util';
import { FormType, ISelectOption, ObservedInfoItem } from '../common/FormModel';
import { ConfigInfo } from '../common/ConfigModel';
import { EnterTextInput } from '../components/EnterTextInput';
import { ChooseAvatar } from '../components/ChooseAvatar';
import { ChooseDate } from '../components/ChooseDate';
import { EnterTextArea } from '../components/EnterTextArea';
import { SelectDialog } from '../components/SelectDialog';
import { EnterPhoneNumber } from '../components/EnterPhoneNumber';

@ComponentV2
export struct ListCard {
  @Param list: ObservedInfoItem[] = [];
  @Param labelFg: Length = 16;
  @Param subLabelFg: Length = 12;
  @Param valueFg: Length = 14;
  @Param lanes: number = 1;
  @Local configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!;
  private readonly DEFAULT_MESSAGE = '内容不能为空';

  build() {
    List() {
      ForEach(this.list, (v: ObservedInfoItem) => {
        ListItem() {
          Row({ space: Constants.SPACE_M }) {
            Column() {
              Text(v.label)
                .fontSize(this.labelFg)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);
              Text(v.subLabel)
                .fontSize(this.subLabelFg)
                .fontColor($r('sys.color.font_secondary'))
                .visibility(v.subLabel ? Visibility.Visible : Visibility.None);
            }
            .alignItems(HorizontalAlign.Start)
            .accessibilityGroup(true);

            Row() {
              if (this.isAvatarScene(v)) {
                this.avatarScene(v);
              } else {
                this.textScene(v);
              }
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize('24vp')
                .fontColor([$r('sys.color.font_fourth')])
                .margin({ left: Constants.SPACE_XS })
                .visibility(v.showRightArrow && v.selectOptions.length <= 0 ? Visibility.Visible : Visibility.None);
              SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                .fontSize('12vp')
                .fontColor([$r('sys.color.font_fourth')])
                .margin({ left: Constants.SPACE_M })
                .visibility(v.selectOptions.length > 0 ? Visibility.Visible : Visibility.None);
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End);
          }
          .padding({
            top: v.type === FormType.CHOOSE_AVATAR ? Constants.PADDING_S : Constants.PADDING_M,
            bottom: v.type === FormType.CHOOSE_AVATAR ? Constants.PADDING_S : Constants.PADDING_M,
            left: Constants.PADDING_S,
            right: Constants.PADDING_S,
          })
          .borderRadius($r('app.float.large_radius'))
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .onTouchIntercept(() => {
            if (v.type === FormType.CHOOSE_AVATAR) {
              return HitTestMode.None;
            }
            return HitTestMode.Default;
          })
          .onClick(() => {
            if (v.onClick) {
              v.onClick();
              return;
            }
            if (v.selectOptions?.length) {
              v.showPop = true;
            } else {
              v.showSheet = true;
            }
          })
          .bindSheet(v.showSheet, this.sheetBuilder(v), this.getSheetOptions(v))
          .bindPopup(v.showPop, this.getPopOptions(v));
        };
      }, (v: ObservedInfoItem) => JSON.stringify(v));
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width(Constants.FULL_PERCENT)
    .height('auto')
    .lanes(this.lanes)
    .borderRadius($r('app.float.large_radius'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .visibility(this.list.length > 0 ? Visibility.Visible : Visibility.None)
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: Constants.PADDING_M,
      endMargin: Constants.PADDING_M,
    })
    .padding(Constants.PADDING_XS);
  }

  isAvatarScene(v: ObservedInfoItem) {
    return v.type === FormType.CHOOSE_AVATAR;
  }

  getPopOptions(v: ObservedInfoItem) {
    return {
      builder: () => {
        this.popUpBuilder(v);
      },
      enableArrow: false,
      autoCancel: true,
      placement: Placement.BottomRight,
      width: 224,
      offset: {
        x: 4,
        y: -8,
      },
      onWillDismiss: () => {
        v.showPop = false;
      },
    } as CustomPopupOptions;
  }

  getSheetOptions(v: ObservedInfoItem) {
    const options = {
      height: v.sheetOptions.height ?? SheetSize.LARGE,
      showClose: v.sheetOptions.showClose ?? true,
      keyboardAvoidMode: v.sheetOptions.keyboardAvoidMode ?? SheetKeyboardAvoidMode.RESIZE_ONLY,
      preferType: v.sheetOptions.preferType ?? SheetType.CENTER,
      onTypeDidChange: (type: SheetType) => {
        this.configInfo.sheetType = type;
      },
      onWillDisappear: () => {
        v.showSheet = false;
      },
    } as SheetOptions;

    if (v.type !== FormType.PHONE_INPUT) {
      options.title = () => {
        this.sheetTitleBuilder(v);
      };
    }
    return options;
  }

  getValue(v: ObservedInfoItem) {
    if (v.value instanceof Date) {
      return formatDate(v.value as Date);
    }
    if (typeof v.value === 'number') {
      return GENDER_OPTIONS[v.value].label;
    }
    if (v.type === FormType.PHONE_INPUT) {
      return encryptPhone(v.value as string);
    }
    return v.value as ResourceStr;
  }

  commonCB(v: ObservedInfoItem, value: Object) {
    v.invocation(value)
      .then(() => {
        if (v.onChange) {
          v.onChange(value);
        }
        v.showSheet = false;
        v.showPop = false;
      })
      .catch(() => {
        this.getUIContext().getPromptAction().showToast({ message: '更新失败' });
      });
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'));
  }

  @Builder
  sheetTitleBuilder(v: ObservedInfoItem) {
    Row() {
      if (v.isInputFocus) {
        Text(v.sheetTitle || `设置${v.label}`)
          .fontSize(20)
          .fontWeight(700)
          .transition(TransitionEffect.OPACITY
            .animation({ duration: 200, curve: Curve.Sharp }),
          );
      }
    }
    .height(56);
  }

  @Builder
  popUpBuilder(v: ObservedInfoItem) {
    SelectDialog({
      item: v,
      onSelected: (option: ISelectOption) => {
        this.commonCB(v, option.value);
      },
    });
  }

  @Builder
  sheetBuilder(v: ObservedInfoItem) {
    if ([FormType.TEXT_INPUT].includes(v.type)) {
      this.inputBuilder(v);
    } else if ([FormType.TEXTAREA].includes(v.type)) {
      this.textareaBuilder(v);
    } else if ([FormType.DATE_SELECT].includes(v.type)) {
      this.birthBuilder(v);
    } else if ([FormType.PHONE_INPUT].includes(v.type)) {
      this.phoneBuilder(v);
    }
  }

  @Builder
  inputBuilder(v: ObservedInfoItem) {
    EnterTextInput({
      inputType: v.type === FormType.PHONE_INPUT ? InputType.PhoneNumber : InputType.Normal,
      value: v.value as string,
      placeholder: v.placeholderText,
      minLength: v.minLength,
      maxLength: v.maxLength,
      title: v.sheetTitle || `设置${v.label}`,
      onKeyboardPopUp: (value) => {
        v.isInputFocus = value;
      },
      onChange: (value) => {
        if (!value) {
          this.getUIContext().getPromptAction().showToast({ message: v.validMessageText ?? this.DEFAULT_MESSAGE });
          return;
        }
        this.commonCB(v, value);
      },
    });
  }

  @Builder
  textareaBuilder(v: ObservedInfoItem) {
    EnterTextArea({
      value: v.value as ResourceStr,
      placeholder: v.placeholderText,
      maxLength: v.maxLength,
      title: v.sheetTitle || `设置${v.label}`,
      onKeyboardPopUp: (value) => {
        v.isInputFocus = value;
      },
      onChange: (value) => {
        this.commonCB(v, value);
      },
    });
  }

  @Builder
  phoneBuilder(v: ObservedInfoItem) {
    EnterPhoneNumber({
      data: v,
    });
  }

  @Builder
  birthBuilder(v: ObservedInfoItem) {
    ChooseDate({
      date: v.value as Date,
      onDateSelected: (date: Date) => {
        this.commonCB(v, date);
      },
      onClose: () => {
        v.showSheet = false;
      },
    });
  }

  @Builder
  avatarScene(v: ObservedInfoItem) {
    ChooseAvatar({
      url: v.value as ResourceStr,
      onChooseAvatar: (avatar: string) => {
        this.commonCB(v, avatar);
      },
    });
  }

  @Builder
  textScene(v: ObservedInfoItem) {
    if (v.showValue && v.value !== '') {
      Text(this.getValue(v))
        .fontSize(this.valueFg)
        .fontColor($r('sys.color.font_secondary'))
        .maxFontScale(2);
    }
  }
}
