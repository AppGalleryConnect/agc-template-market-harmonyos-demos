import { SearchCondition } from '../model/SearchCondition';
import { UserFullInfo, BasicUserInfo, CommonUtils, NavigationTitleBuilder, Constants } from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { PromptAction, UIContext } from '@kit.ArkUI';
import { RangeField } from '../model/RangeField';
import { EnumField } from '../model/EnumField';
import { resourceManager } from '@kit.LocalizationKit';
import UserService from '../service/UserService';

@Builder
export function UserSearchPageBuilder() {
  UserSearchPage()
}

@Component
export struct UserSearchPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private scroller: Scroller = new Scroller();
  @State searchCondition: SearchCondition = new SearchCondition();
  @State selectedCity: string = Constants.PLEASE_CHOOSE;
  @State originFrom: string = Constants.PLEASE_CHOOSE;
  @State ethnicGroup: string = Constants.PLEASE_CHOOSE;
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @State member: boolean = true;

  aboutToAppear(): void {
    let currentUser: BasicUserInfo | undefined = AppStorage.get(Constants.CURRENT_USER_BASIC);
    if (currentUser != null && currentUser !== undefined) {
      this.member = currentUser.isVip === Constants.YES;
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            this.buildSearchInputRow()
            this.buildAgeRow()
            this.buildHeightRow()
            this.buildEdu()
            this.buildMarriageStatus()
            this.buildMonthlyIncome()
            this.buildMemberSubscribeRow()
            if (this.member) {
              this.buildMemberSearchArea(true, 0)
            } else {
              this.buildMemberSearchArea(false, 20)
            }
            Blank().height(50)
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(0xFFF8F6F6)
        .scrollBarWidth(5)
        .edgeEffect(EdgeEffect.Spring)

        Row() {
          Column() {
            Image($r('app.media.ic_arrow_clockwise')).width(20).height(20).margin({ bottom: 2 })
            Text('重置')
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .fontColor($r('app.color.title_font_color'))
          }
          .onClick(() => {
            this.searchCondition = new SearchCondition();
            this.selectedCity = Constants.PLEASE_CHOOSE;
            this.originFrom = Constants.PLEASE_CHOOSE;
            this.ethnicGroup = Constants.PLEASE_CHOOSE;
          })
          .width('18%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 12, bottom: 12 })

          Column() {
            Button('确定')
              .width('90%')
              .margin({ right: 16 })
              .backgroundColor($r('app.color.button_background_color'))
              .fontSize($r('sys.float.Body_L'))
              .onClick(() => {
                Logger.debug('--------searchCondition=' + JSON.stringify(this.searchCondition))
                if (this.checkSearchCondition()) {
                  UserService.searchUsers(this.searchCondition).then((data: UserFullInfo[] | null) => {
                    Logger.debug('--------search result=' + JSON.stringify(data))
                    this.pageStack.pushPathByName('UserListPage', data);
                  })
                }
              })
          }.width('82%').margin({ top: 12, bottom: 12 })
        }
        .position({ y: '92%' })
        .width('100%')
        .height(90)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.White)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('搜索用户'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildMemberSearchArea(enabled: boolean, blur: number) {
    Column() {
      this.buildRealNameAuth()
      Column() {
        this.buildCurrentResidence()
        this.buildOriginFrom()
        this.buildEthnicGroup()
      }.borderRadius(16).backgroundColor(Color.White).margin({ top: 8, bottom: 8 })

      this.buildJobRow()
      this.buildHasChildrenRow()
      this.buildHasHouseRow()
      this.buildHasBuyCarRow()
    }.enabled(enabled).blur(blur)
  }

  @Builder
  buildMemberSubscribeRow() {
    if (!this.member) {
      Row() {
        Text('开通会员即可使用如下高级搜索')
          .fontColor('#E6FFFFFF')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .textAlign(TextAlign.Start)
          .margin({ left: 12 })

        Button('开通')
          .backgroundColor($r('app.color.button_background_color'))
          .fontSize($r('sys.float.Body_M'))
          .height(24)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .margin({ right: 12 })
          .onClick(() => {
            this.pageStack.pushPathByName('Member', null, (popInfo: PopInfo) => {
              let basicUserInfo = popInfo.result as BasicUserInfo;
              if (basicUserInfo != null && basicUserInfo.isVip != null) {
                this.member = basicUserInfo.isVip === Constants.YES
              }
            });
          })
      }
      .backgroundImage($r('app.media.member_search'))
      .backgroundImageSize(ImageSize.FILL)
      .width('92%')
      .height(44)
      .borderRadius(16)
      .margin({ top: 16, bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    } else {
      Row() {
        Text('如下高级搜索为会员特权')
          .fontSize($r('sys.float.Body_M'))
          .margin({ left: 12 })
          .fontWeight(FontWeight.Regular)
          .fontColor('#E6FFFFFF')
      }
      .backgroundImage($r('app.media.member_search'))
      .backgroundImageSize(ImageSize.FILL)
      .width('95%')
      .borderRadius(10)
      .backgroundColor($r('app.color.light_blue'))
      .height(44)
      .margin({ top: 16, bottom: 16 })
    }
  }

  checkSearchCondition(): boolean {
    if (!checkAgeRangeAndHeightRange(this.searchCondition.ageStart, this.searchCondition.ageEnd,
      this.searchCondition.heightStart, this.searchCondition.heightEnd, this.promptAction,
      getContext(this).resourceManager)) {
      return false
    }
    return true;
  }

  @Builder
  buildHasBuyCarRow() {
    EnumRow({
      enumField: new EnumField(Constants.CAR_PREFIX, 'hasBuyCarGroup', Constants.HAS_CAR_VALUES, 14,
        '1fr', '1fr 1fr 1fr', 50, (result: CheckboxGroupResult) => {
          let selectedHasBuyCar = assembleSelectedResult(result, Constants.HAS_CAR_VALUES, this.getUIContext());
          this.searchCondition.hasBuyCar = selectedHasBuyCar;
        }),
      selectedVal: this.searchCondition.hasBuyCar
    })
  }

  @Builder
  buildHasHouseRow() {
    EnumRow({
      enumField: new EnumField(Constants.HOUSE_PREFIX, 'hasHouseGroup', Constants.HOUSE_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr', 90, (result: CheckboxGroupResult) => {
          this.searchCondition.house =
            assembleSelectedResult(result, Constants.HOUSE_DISPLAY_VALUES, this.getUIContext());
        }),
      selectedVal: this.searchCondition.house
    })
  }

  @Builder
  buildHasChildrenRow() {
    EnumRow({
      enumField: new EnumField(Constants.HAS_CHILDREN_PREFIX, 'hasChildrenGroup',
        Constants.HAS_CHILDREN_DISPLAY_VALUES, 14,
        '1fr 1fr 1fr', '1fr 1fr', 90, (result: CheckboxGroupResult) => {
          this.searchCondition.hasChildren =
            assembleSelectedResult(result, Constants.HAS_CHILDREN_DISPLAY_VALUES, this.getUIContext());
        }),
      selectedVal: this.searchCondition.hasChildren
    })
  }

  @Builder
  buildJobRow() {
    EnumRow({
      enumField: new EnumField(Constants.WORK_PREFIX, 'jobGroup', Constants.WORK_DISPLAY_VALUES, 14,
        '1fr 1fr 1fr 1fr 1fr 1fr 1fr', '1fr 1fr', 240, (result: CheckboxGroupResult) => {
          this.searchCondition.job = assembleSelectedResult(result, Constants.WORK_DISPLAY_VALUES, this.getUIContext());
        }),
      selectedVal: this.searchCondition.job
    })
  }

  @Builder
  buildEthnicGroup() {
    Row() {
      buildTitleForOneCondition(Constants.ETHNIC_GROUP_PREFIX)

      Text(`${this.ethnicGroup}`).fontSize($r('sys.float.Body_M')).width('70%').textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width('5%').margin({ left: 10 })
    }.width('92%').height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(Constants.ETHNIC_GROUPS, (result: TextPickerResult) => {
        if (typeof result.value === 'string') {
          this.ethnicGroup = result.value
          this.searchCondition.ethnicGroup = result.value
        }
      }))
    })
  }

  @Builder
  buildOriginFrom() {
    Row() {
      buildTitleForOneCondition(Constants.ORIGIN_FROM_PREFIX)

      Text(`${this.originFrom}`).fontSize($r('sys.float.Body_M')).width('70%').textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width('5%').margin({ left: 10 })
    }.width('92%').height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(Constants.CITY_PICKER, (result: TextPickerResult) => {
        let selectedVal = this.getSelectedCity(result);
        this.searchCondition.originFrom = selectedVal;
        this.originFrom = selectedVal;
      }))
    })
  }

  private getSelectedCity(result: TextPickerResult) {
    let selectedVal = '';
    if (typeof result.value === 'string') {
      selectedVal = result.value;
    } else {
      if (result.value.length > 1 && result.value[1] !== '') {
        selectedVal = result.value.join(Constants.BAR);
      } else {
        selectedVal = result.value[0];
      }
    }
    return selectedVal;
  }

  @Builder
  buildCurrentResidence() {
    Row() {
      buildTitleForOneCondition(Constants.CURRENT_RESIDENCE_PREFIX)

      Text(`${this.selectedCity}`).fontSize($r('sys.float.Body_M')).width('70%').textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width('5%').margin({ left: 10 })
    }.width('92%').height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(Constants.CITY_PICKER, (result: TextPickerResult) => {
        let selectedVal = this.getSelectedCity(result);
        this.searchCondition.currentResidence = selectedVal;
        this.selectedCity = selectedVal;
      }))
    })
  }

  @Builder
  buildRealNameAuth() {
    EnumRow({
      enumField: new EnumField(Constants.REAL_NAME_AUTH_PREFIX, 'realNameAuthGroup',
        Constants.REAL_NAME_AUTH_VALUES_FOR_SEARCH,
        14, '1fr', '1fr 1fr', 50, (result: CheckboxGroupResult) => {
          this.searchCondition.realNameAuth =
            assembleSelectedResult(result, Constants.REAL_NAME_AUTH_VALUES_FOR_SEARCH, this.getUIContext());
        }),
      selectedVal: this.searchCondition.realNameAuth
    })
  }

  @Builder
  buildMarriageStatus() {
    EnumRow({
      enumField: new EnumField(Constants.MARRIAGE_STATUS_PREFIX, 'marriageStatusGroup',
        Constants.MARRIAGE_STATUS_DISPLAY_VALUES, 14,
        '1fr', '1fr 1fr 1fr 1fr', 45, (result: CheckboxGroupResult) => {
          this.searchCondition.marriageStatus =
            assembleSelectedResult(result, Constants.MARRIAGE_STATUS_DISPLAY_VALUES, this.getUIContext());
        }),
      selectedVal: this.searchCondition.marriageStatus
    })
  }

  @Builder
  buildEdu() {
    EnumRow({
      enumField: new EnumField(Constants.EDUCATION_PREFIX, 'eduGroup', Constants.EDU_FOR_SEARCH_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr 1fr', 90, (result: CheckboxGroupResult) => {
          this.searchCondition.education =
            assembleSelectedResult(result, Constants.EDU_FOR_SEARCH_DISPLAY_VALUES, this.getUIContext());
        }),
      selectedVal: this.searchCondition.education
    })
  }

  @Builder
  buildSearchInputRow() {
    Row() {
      Search({ placeholder: '输入昵称或ID，仅能查询公开会员' })
        .padding(5)
        .letterSpacing(0)
        .backgroundColor($r('app.color.light_grey_bg'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: 14, weight: FontWeight.Regular, family: Constants.HARMONY_HEITI })
        .fontColor($r('app.color.text_font_color_black'))
        .textFont({ size: 12, weight: FontWeight.Regular, family: Constants.HARMONY_HEITI })
        .onSubmit((value: string) => {
          value = value.trim();
          if (CommonUtils.isDigit(value)) {
            this.searchCondition.userNo = value;
          } else {
            this.searchCondition.nickName = value;
          }
          if (this.checkSearchCondition()) {
            UserService.searchUsers(this.searchCondition).then((data: UserFullInfo[]) => {
              this.pageStack.pushPathByName('UserListPage', data);
            })
          }
        });
    }.width('92%').height(40)
    .margin({
      left: 16,
      top: 10,
      bottom: 8,
      right: 16
    })
  }

  @Builder
  buildHeightRow() {
    RangeRow({
      rangeField: new RangeField('身高', ['160', '185'], (value: string) => {
        if (value == null || value === '') {
          this.searchCondition.heightStart = null;
        } else {
          this.searchCondition.heightStart = parseInt(value);
        }
      }, (value: string) => {
        if (value == null || value === '') {
          this.searchCondition.heightEnd = null;
        } else {
          this.searchCondition.heightEnd = parseInt(value);
        }
      }, [Constants.MIN_HEIGHT, Constants.MAX_HEIGHT], '请输入140-239的数字'),
      rangeStartText: this.searchCondition.heightStart == null ? '' : this.searchCondition.heightStart.toString(),
      rangeEndText: this.searchCondition.heightEnd == null ? '' : this.searchCondition.heightEnd.toString(),
    })
  }

  @Builder
  buildAgeRow() {
    RangeRow({
      rangeField: new RangeField('年龄', ['18', '99'], (value: string) => {
        if (value == null || value === '') {
          this.searchCondition.ageStart = null;
        } else {
          this.searchCondition.ageStart = parseInt(value);
        }
      }, (value: string) => {
        if (value == null || value === '') {
          this.searchCondition.ageEnd = null;
        } else {
          this.searchCondition.ageEnd = parseInt(value);
        }
      }, [Constants.ADULT_AGE, Constants.MAX_AGE], '请输入18-99的数字'),
      rangeStartText: this.searchCondition.ageStart == null ? '' : this.searchCondition.ageStart.toString(),
      rangeEndText: this.searchCondition.ageEnd == null ? '' : this.searchCondition.ageEnd.toString(),
    })
  }

  @Builder
  buildMonthlyIncome() {
    EnumRow({
      enumField: new EnumField(Constants.INCOME_PREFIX, 'incomeGroup', Constants.INCOME_FOR_SEARCH_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr 1fr', 90, (result: CheckboxGroupResult) => {
          this.searchCondition.monthlyIncome =
            assembleSelectedResult(result, Constants.INCOME_FOR_SEARCH_DISPLAY_VALUES, this.getUIContext());
        }),
      selectedVal: this.searchCondition.monthlyIncome
    })
  }
}

@Builder
export function buildTitleForOneCondition(name: string) {
  Text(name)
    .fontSize($r('sys.float.Body_M'))
    .textAlign(TextAlign.Start)
    .fontWeight(FontWeight.Regular)
    .fontColor($r('app.color.text_font_color_black'))
    .margin({ left: 12 })
}

export function assembleSelectedResult(result: CheckboxGroupResult, itemValues: string[],
  uiContext: UIContext): string {
  let selectedItems = '';
  if (result.status === SelectStatus.All || result.name.length === itemValues.length) {
    return Constants.ENUM_ALL;
  }

  for (let i = 0; i < result.name.length; i += 1) {
    //转换成枚举数字值并进行拼接
    selectedItems += Constants.getIndex(result.name[i], itemValues);
    if (i < result.name.length - 1) {
      selectedItems += ',';
    }
  }
  return selectedItems;
}

export function buildTextPickerDialogOption(values: TextCascadePickerRangeContent[] | string[],
  selectedFunc: (result: TextPickerResult) => void, canLoop?: boolean): TextPickerDialogOptions {
  return {
    range: values,
    disappearTextStyle: { color: Color.Gray, font: { size: 16, weight: FontWeight.Lighter } },
    textStyle: { color: Color.Black, font: { size: 16, weight: FontWeight.Normal } },
    selectedTextStyle: {
      color: $r('app.color.button_background_color'),
      font: { size: 16 }
    },
    acceptButtonStyle: { fontColor: $r('app.color.button_background_color') },
    cancelButtonStyle: { fontColor: $r('app.color.button_background_color') },
    onAccept: selectedFunc,
    canLoop: canLoop === undefined ? false : canLoop
  }
}

export function checkAgeRangeAndHeightRange(ageStart: number | null, ageEnd: number | null, heightStart: number | null,
  heightEnd: number | null, promptAction: PromptAction, resourceMgr: resourceManager.ResourceManager): boolean {
  let invalidRangeTips: string[] = resourceMgr.getStringArrayByNameSync('invalid_range_tips');
  if (ageStart != null && (ageStart < Constants.ADULT_AGE || ageStart > Constants.MAX_AGE)) {
    showToast(invalidRangeTips[0], promptAction);
    return false;
  }
  if (ageEnd != null && (ageEnd < Constants.ADULT_AGE || ageEnd > Constants.MAX_AGE)) {
    showToast(invalidRangeTips[0], promptAction);
    return false;
  }
  if (ageStart != null && ageEnd != null) {
    if (ageEnd < ageStart) {
      showToast(invalidRangeTips[1], promptAction);
      return false;
    }
  }

  if (heightStart != null && (heightStart < Constants.MIN_HEIGHT || heightStart > Constants.MAX_HEIGHT)) {
    showToast(invalidRangeTips[2], promptAction);
    return false;
  }
  if (heightEnd != null && (heightEnd < Constants.MIN_HEIGHT || heightEnd > Constants.MAX_HEIGHT)) {
    showToast(invalidRangeTips[2], promptAction);
    return false;
  }

  if (heightStart != null && heightEnd != null) {
    if (heightEnd < heightStart) {
      showToast(invalidRangeTips[3], promptAction);
      return false;
    }
  }
  return true;
}

export function showToast(msg: string, promptAction: PromptAction) {
  promptAction.showToast({
    message: msg,
    duration: 2000,
    bottom: 150
  })
}

@Component
export struct EnumRow {
  @State enumField: EnumField | null = null;
  @Prop selectedVal: string | null;

  aboutToAppear(): void {
    Logger.debug('----aboutToAppear, selectedVal=' + this.selectedVal + ', name=' + this.enumField?.name);
  }

  build() {
    Column() {
      Row() {
        buildTitleForOneCondition(this.enumField?.name === undefined ? '' : this.enumField?.name);
      }.height(30).justifyContent(FlexAlign.Start).width('100%').margin({ top: 12 })

      Grid() {
        ForEach(this.enumField?.enumValues, (itemName: string, idx: number) => {
          GridItem() {
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Checkbox({ name: itemName, group: this.enumField?.groupName })
                .select(hasSelect(this.selectedVal, idx, this.enumField?.name))
                .shape(CheckBoxShape.CIRCLE)
                .selectedColor($r('app.color.button_background_color'))
                .onChange((itemVal: boolean) => {
                })
              Text(itemName).fontSize(this.enumField?.itemTextFontSize).fontWeight(500);
            }
          }
        }, (itemName: string, idx: number) => itemName);
        GridItem() {
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            CheckboxGroup({ group: this.enumField?.groupName })
              .selectedColor($r('app.color.button_background_color'))
              .onChange((result: CheckboxGroupResult) => {
                if (this.enumField?.selectedFunc !== undefined) {
                  this.enumField.selectedFunc(result);
                }
              });
            Text('不限').fontSize($r('sys.float.Body_M')).lineHeight(20).fontWeight(500);
          };
        }
      }
      .rowsTemplate(this.enumField?.rowTemplate)
      .columnsTemplate(this.enumField?.columnsTemplate)
      .width('95%')
      .height(this.enumField?.height)
      .margin({ left: 12, right: 12 })
    }.backgroundColor(Color.White).width('92%').borderRadius(16).margin({ top: 8, bottom: 8 })
  }
}

function hasSelect(selectedVal: string | null, idx: number, name: string | undefined): boolean {
  if (selectedVal == null || selectedVal === '') {
    return false;
  } else {
    let selectedVals = selectedVal.split(',');
    if (selectedVals.length === 1 && selectedVals[0] === Constants.ENUM_ALL) {
      return true;
    }
    let idxStr = idx.toString();
    for (let index = 0; index < selectedVals.length; index++) {
      if (selectedVals[index] === idxStr) {
        return true;
      }
    }
    return false;
  }
}

@Component
export struct RangeRow {
  @State rangeField: RangeField | null = null;
  @Prop rangeStartText: string | null = null;
  @Prop rangeEndText: string | null = null;
  @State rangeStartTextFontColor: Color = Color.Black;
  @State rangeEndTextFontColor: Color = Color.Black;
  private controller: TextInputController = new TextInputController();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  build() {
    Row() {
      buildTitleForOneCondition(this.rangeField?.name ? this.rangeField.name : '')
      TextInput({
        text: this.rangeStartText,
        placeholder: this.rangeField?.rangePlaceHolder[0],
        controller: this.controller
      })
        .type(InputType.Number)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: 14, weight: 400 })
        .caretColor($r('sys.color.font_emphasize'))
        .fontColor($r('app.color.text_font_color_black'))
        .height(32)
        .maxLength(3)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.rangeStartTextFontColor)
        .width(88)
        .borderRadius(16)
        .margin({ left: 8, top: 12, bottom: 12 })
        .onEditChange((isEditing: boolean) => {
          if (!isEditing) {
            if (!checkIsValid(this.rangeStartText, this.rangeField?.valueRange)) {
              this.showToast();
              this.rangeStartTextFontColor = Color.Red;
            } else {
              this.rangeStartTextFontColor = Color.Black;
            }
          }
        })
        .onChange((value: string) => {
          this.rangeStartText = value;
          this.rangeField?.startFunc?.(value);
        });
      Text('-')
        .fontSize($r('sys.float.Body_M'))
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
        .margin({ left: 12, right: 12 });
      TextInput({
        text: this.rangeEndText,
        placeholder: this.rangeField?.rangePlaceHolder[1],
        controller: this.controller
      })
        .type(InputType.Number)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: 14, weight: FontWeight.Regular })
        .caretColor($r('sys.color.font_emphasize'))
        .height(32)
        .maxLength(3)
        .margin(20)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.rangeEndTextFontColor)
        .width(88)
        .borderRadius(16)
        .margin({ top: 12, bottom: 12 })
        .onEditChange((isEditing: boolean) => {
          if (!isEditing) {
            if (!checkIsValid(this.rangeEndText, this.rangeField?.valueRange)) {
              this.showToast();
              this.rangeEndTextFontColor = Color.Red;
            } else {
              this.rangeEndTextFontColor = Color.Black;
            }
          }
        })
        .onChange((value: string) => {
          this.rangeEndText = value;
          this.rangeField?.endFunc?.(value);
        });
    }
    .width('92%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }

  private showToast() {
    this.promptAction.showToast({
      message: this.rangeField?.errorTip,
      duration: 2000,
      bottom: 200,
      textColor: Color.Red
    });
  }
}

function checkIsValid(inputText: string | null, valueRange: number[] | undefined): boolean {
  if (inputText == null || valueRange === undefined) {
    return true;
  }
  let input = parseInt(inputText);
  return input >= valueRange[0] && input <= valueRange[1];
}
