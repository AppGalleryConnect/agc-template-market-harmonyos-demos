import {
  CommonRsp,
  CommonUtils,
  Constants,
  NavigationTitleBuilder,
  UiUtils,
  MateSelectionCriteria,
  UserFullInfo,
  getPicResult
} from 'commons';
import { RangeField } from '../model/RangeField';
import {
  assembleSelectedResult,
  buildTextPickerDialogOption,
  checkAgeRangeAndHeightRange,
  EnumRow,
  RangeRow,
} from './UserSearchPage';
import { PromptAction } from '@kit.ArkUI';
import Logger from 'commons/src/main/ets/utils/Logger';
import { EnumField } from '../model/EnumField';
import UserService from '../service/UserService';

@Builder
export function MateCriteriaPageBuilder() {
  MateCriteriaPage()
}

@Preview
@Component
export struct MateCriteriaPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State userFullInfo: UserFullInfo | null = null;
  @State mateCriteria: MateSelectionCriteria | null = null;
  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  aboutToAppear(): void {
    let params: UserFullInfo[] = this.pageStack.getParamByName('MateCriteriaPage') as UserFullInfo[];
    if (params.length >= 1 && params[0] != null) {
      this.userFullInfo = params[0];
      Logger.debug('------about to appear, mateCriteria=' + JSON.stringify(this.userFullInfo.mateSelectionCriteria));
      if (this.userFullInfo.mateSelectionCriteria != null) {
        this.mateCriteria = this.userFullInfo.mateSelectionCriteria;
      } else {
        this.mateCriteria = new MateSelectionCriteria();
      }
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.buildAgeRangeRow();
          this.buildHeightRangeRow();
          Column() {
            this.buildCurrentResidenceForMateCriteria();
            this.buildOriginFromForMateCriteria();
            this.buildEthnicForMateCriteria();
          }.borderRadius(16).backgroundColor(Color.White).margin({ top: 8, bottom: 8 })

          if (this.mateCriteria != null) {
            this.buildMonthlyIncomeForMateCriteria();
            this.buildEduForMateCriteria();
            this.buildMarriageStatusForMateCriteria();
            this.buildJobForMateCriteria();
            this.buildHasChildrenForMateCriteria();
            this.buildExpectationOfChildrenForMateCriteria();
            this.buildSmokingForMateCriteria();
            this.buildDrinkingForMateCriteria();
          }
          this.buildButtonRow();
        }
      }.scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring);

    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('我的择偶标准'))
  }

  @Builder
  buildButtonRow() {
    Row() {
      Column() {
        Image($r('app.media.ic_arrow_clockwise')).width(20).height(20).margin({ bottom: 2 })
        Text('重置')
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('app.color.text_font_color_black'))
      }.onClick(() => {
        this.mateCriteria = new MateSelectionCriteria();
      }).width('18%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Column() {
        Button('确认')
          .backgroundColor($r('app.color.button_background_color'))
          .fontSize($r('sys.float.Body_L'))
          .width('100%')
          .height(36)
          .onClick(() => {
            if (this.checkParam()) {
              Logger.debug('------------mateCriteria=' + JSON.stringify(this.mateCriteria));
              if (this.userFullInfo != null) {
                this.userFullInfo.mateSelectionCriteria = this.mateCriteria;
                UserService.updateUser(this.userFullInfo).then((data: CommonRsp | null) => {
                  Logger.debug('updateUser rsp=' + JSON.stringify(data));
                  this.pageStack.pop(this.mateCriteria, false)
                })
              }
            }
          })
      }.width('82%')
    }.justifyContent(FlexAlign.Center).width('92%').margin({ top: 8, bottom: 16 })
  }

  checkParam(): boolean {
    if (this.mateCriteria != null) {
      return checkAgeRangeAndHeightRange(this.mateCriteria.ageStart, this.mateCriteria.ageEnd,
        this.mateCriteria.heightStart,
        this.mateCriteria.heightEnd, this.promptAction, getContext(this).resourceManager);
    }
    return false;
  }

  @Builder
  buildHeightRangeRow() {
    RangeRow({
      rangeField: new RangeField('身高', ['160', '185'], (value: string) => {
        let inputVal: number | null = null;
        if (value == null || value === '') {
          inputVal = null;
        } else {
          inputVal = parseInt(value);
        }
        if (inputVal != null && (inputVal >= Constants.MIN_HEIGHT && inputVal <= Constants.MAX_HEIGHT)) {
          if (this.mateCriteria != null) {
            this.mateCriteria.heightStart = inputVal;
          }
        }
      }, (value: string) => {
        let inputVal: number | null = null;
        if (value == null || value === '') {
          inputVal = null;
        } else {
          inputVal = parseInt(value);
        }
        if (inputVal != null && (inputVal >= Constants.MIN_HEIGHT && inputVal <= Constants.MAX_HEIGHT)) {
          if (this.mateCriteria != null) {
            this.mateCriteria.heightEnd = inputVal;
          }
        }
      }, [Constants.MIN_HEIGHT, Constants.MAX_HEIGHT], '请输入140-239的数字'),
      rangeStartText: this.mateCriteria?.heightStart?.toString(),
      rangeEndText: this.mateCriteria?.heightEnd?.toString()
    })
  }

  @Builder
  buildAgeRangeRow() {
    RangeRow({
      rangeField: new RangeField('年龄', ['18', '99'], (value: string) => {
        let inputVal: number | null = null;
        if (value == null || value === '') {
          inputVal = null;
        } else {
          inputVal = parseInt(value);
        }
        if (inputVal != null && (inputVal >= Constants.ADULT_AGE && inputVal <= Constants.MAX_AGE)) {
          if (this.mateCriteria != null) {
            this.mateCriteria.ageStart = inputVal;
          }
        }
      }, (value: string) => {
        let inputVal: number | null = null;
        if (value == null || value === '') {
          inputVal = null;
        } else {
          inputVal = parseInt(value);
        }
        if (inputVal != null && (inputVal >= Constants.ADULT_AGE && inputVal <= Constants.MAX_AGE)) {
          if (this.mateCriteria != null) {
            this.mateCriteria.ageEnd = inputVal;
          }
        }
      }, [Constants.ADULT_AGE, Constants.MAX_AGE], '请输入18-99的数字'),
      rangeStartText: this.mateCriteria?.ageStart?.toString(),
      rangeEndText: this.mateCriteria?.ageEnd?.toString()
    })
  }

  @Builder
  buildItemTitle(name:
    string
  ) {
    Text(name)
      .fontSize($r('sys.float.Body_M'))
      .textAlign(TextAlign.Start)
      .fontWeight(FontWeight.Regular)
      .fontColor($r('app.color.text_font_color_black'))
      .margin({ left: 12, top: 5, bottom: 5 })
      .width('30%')
  }

  @Builder
  buildCurrentResidenceForMateCriteria() {
    Row() {
      this.buildItemTitle('现居地')

      Text((this.mateCriteria == null || this.mateCriteria.currentResidence === undefined) ? '' :
        `${this.mateCriteria.currentResidence}`)
        .fontSize($r('sys.float.Body_M'))
        .width('50%')
        .textAlign(TextAlign.End)
        .textOverflow({ overflow: TextOverflow.MARQUEE })

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }.width('92%').height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.CITY_PICKER,
        (result: TextPickerResult) => {
          let newResidence = getPicResult(result);
          if (this.mateCriteria != null) {
            let tmp = this.mateCriteria.currentResidence;
            this.mateCriteria.currentResidence = this.appendSelectValue(tmp, newResidence)
          }
        }
      ))
    })
  }

  appendSelectValue(existed: string | null, newSelect: string): string | null {
    if (existed == null || existed === '') {
      return newSelect;
    }
    if (CommonUtils.contains(existed, newSelect)) {
      return existed;
    }
    if (existed.split(',').length >= 5) {
      this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('最多只支持5个'));
      return existed;
    }
    return existed + ',' + newSelect;
  }

  @Builder
  buildEthnicForMateCriteria() {
    Row() {
      this.buildItemTitle(Constants.ETHNIC_GROUP_PREFIX)

      Text(this.mateCriteria == null || this.mateCriteria.ethnicGroup === undefined ? '' :
        `${this.mateCriteria.ethnicGroup}`)
        .fontSize($r('sys.float.Body_M'))
        .width('50%')
        .textAlign(TextAlign.End)

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }.width('92%').height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.ETHNIC_GROUPS,
        (result: TextPickerResult) => {
          if (typeof result.value === 'string') {
            if (this.mateCriteria != null) {
              let tmp = this.mateCriteria.ethnicGroup;
              this.mateCriteria.ethnicGroup = this.appendSelectValue(tmp, result.value);
            }
          }
        }
      ))
    })
  }

  @Builder
  buildDrinkingForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.DRINKING_PREFIX, 'drinkingGroup', Constants.DRINKING_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr', 90, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.drinking =
              assembleSelectedResult(result, Constants.DRINKING_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.drinking
    })
  }

  @Builder
  buildMarriageStatusForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.MARRIAGE_STATUS_PREFIX, 'marriageStatusGroup',
        Constants.MARRIAGE_STATUS_DISPLAY_VALUES, 14,
        '1fr', '1fr 1fr 1fr 1fr', 45, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.marriageStatus =
              assembleSelectedResult(result, Constants.MARRIAGE_STATUS_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.marriageStatus
    })
  }

  @Builder
  buildJobForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.WORK_PREFIX, 'jobGroup', Constants.WORK_DISPLAY_VALUES, 14,
        '1fr 1fr 1fr 1fr 1fr 1fr 1fr', '1fr 1fr', 240, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.job =
              assembleSelectedResult(result, Constants.WORK_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.job
    })
  }

  @Builder
  buildHasChildrenForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.HAS_CHILDREN_PREFIX, 'hasChildrenGroup',
        Constants.HAS_CHILDREN_DISPLAY_VALUES, 14,
        '1fr 1fr 1fr', '1fr 1fr', 90, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.hasChildren =
              assembleSelectedResult(result, Constants.HAS_CHILDREN_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.hasChildren
    })
  }

  @Builder
  buildExpectationOfChildrenForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.EXPECTATION_OF_CHILDREN, 'expectationOfChildren',
        Constants.EXPECTATION_OF_CHILDREN_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr', 90, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.expectationOfChildren =
              assembleSelectedResult(result, Constants.EXPECTATION_OF_CHILDREN_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.expectationOfChildren
    })
  }

  @Builder
  buildSmokingForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.SMOKING_PREFIX, 'smokingGroup', Constants.SMOKING_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr', 90, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.smoking =
              assembleSelectedResult(result, Constants.SMOKING_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.smoking
    })
  }

  @Builder
  buildEduForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.EDUCATION_PREFIX, 'eduGroup', Constants.EDU_FOR_SEARCH_DISPLAY_VALUES, 14,
        '1fr 1fr', '1fr 1fr 1fr', 90, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.education =
              assembleSelectedResult(result, Constants.EDU_FOR_SEARCH_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.education
    })
  }

  @Builder
  buildMonthlyIncomeForMateCriteria() {
    EnumRow({
      enumField: new EnumField(Constants.INCOME_PREFIX, 'incomeGroup', Constants.INCOME_FOR_SEARCH_DISPLAY_VALUES,
        14,
        '1fr 1fr', '1fr 1fr 1fr', 90, (result: CheckboxGroupResult) => {
          if (this.mateCriteria != null) {
            this.mateCriteria.monthlyIncome =
              assembleSelectedResult(result, Constants.INCOME_FOR_SEARCH_DISPLAY_VALUES, this.getUIContext());
          }
        }),
      selectedVal: this.mateCriteria?.monthlyIncome
    })
  }

  @Builder
  buildOriginFromForMateCriteria() {
    Row() {
      this.buildItemTitle('籍贯地')

      Text(this.mateCriteria == null ? '' : `${this.mateCriteria.originFrom}`)
        .fontSize($r('sys.float.Body_M'))
        .width('50%')
        .textAlign(TextAlign.End)
        .textOverflow({ overflow: TextOverflow.MARQUEE })

      Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ left: 10 })
    }.width('92%').height('6%').onClick(() => {
      TextPickerDialog.show(buildTextPickerDialogOption(
        Constants.CITY_PICKER,
        (result: TextPickerResult) => {
          let newResidence = getPicResult(result);
          Logger.debug(' originFrom, new selected=' + newResidence)
          if (this.mateCriteria != null) {
            let tmp = this.mateCriteria.originFrom;
            this.mateCriteria.originFrom = this.appendSelectValue(tmp, newResidence)
          }
        }
      ))
    })
  }
}