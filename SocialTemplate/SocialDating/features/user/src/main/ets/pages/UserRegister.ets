import {
  CommonRsp,
  CreateUserRequest,
  GetUserResponse,
  UserInfo,
  Constants,
  DateUtils,
  UiUtils,
  getPicResult
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import UserService from '../service/UserService';
import { SearchCondition } from '../model/SearchCondition';
import { buildTextPickerDialogOption } from './UserSearchPage';

const FIELD_TO_SET: string = '待完善'

@Builder
export function UserRegisterPageBuilder() {
  UserRegisterPage()
}

@Component
export struct UserRegisterPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State searchCondition: SearchCondition = new SearchCondition();
  @State inputValue: string = '';
  @State birth: string = FIELD_TO_SET;
  @State marriageStatus: string = FIELD_TO_SET;
  @State monthlyIncome: string = FIELD_TO_SET;
  @State edu: string = FIELD_TO_SET;
  @State selectedCity: string = FIELD_TO_SET;
  @State gender: string = FIELD_TO_SET;
  @State member: boolean = false;
  private createUserRequest: CreateUserRequest = new CreateUserRequest();

  aboutToAppear(): void {
  }

  build() {
    NavDestination() {
      Row() {
        Text('用户创建')
          .fontColor($r('app.color.text_font_color_black'))
          .fontSize(18)
          .fontWeight(FontWeight.Regular)
          .fontFamily(Constants.HARMONY_HEITI)
          .height(56)
          .width('92%')
          .textAlign(TextAlign.Start)
      }.width('92%').justifyContent(FlexAlign.Start)

      Stack() {
        Column() {
          this.buildGenderRow()
          Divider().strokeWidth(1).width('92%')
          this.buildBirthDateRow()
          Divider().strokeWidth(1).width('92%')
          this.buildMarriageStatus()
          Divider().strokeWidth(1).width('92%')
          this.buildEdu()
          Divider().strokeWidth(1).width('92%')
          this.buildMonthlyIncome()
          Divider().strokeWidth(1).width('92%')
          this.buildCurrentResidence()
        }.backgroundColor(Color.White).borderRadius(16).width('92%').margin({ top: 20 })

        Row() {
          Button('确认')
            .width('100%')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Bold)
            .fontFamily(Constants.HARMONY_HEITI)
            .backgroundColor($r('app.color.button_background_color'))
            .enabled(!this.requiredFieldsEmpty())
            .onClick(() => {
              if (this.requiredFieldsEmpty()) {
                if (this.gender === FIELD_TO_SET) {
                  this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置性别'))
                }
                if (this.marriageStatus === FIELD_TO_SET) {
                  this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置婚姻状态'))
                }
                if (this.birth === FIELD_TO_SET) {
                  this.getUIContext().showAlertDialog(UiUtils.buildAlertDialogOption('请设置出生日期'))
                }
              }
              if (!this.requiredFieldsEmpty()) {
                let currentUnionId: string | null | undefined = AppStorage.get(Constants.UNION_ID);
                if (currentUnionId != null && currentUnionId !== undefined) {
                  this.createUserRequest.hwUnionId = currentUnionId;
                }
                Logger.debug('createUser, req=' + JSON.stringify(this.createUserRequest));
                UserService.createUser(this.createUserRequest).then((data: CommonRsp | null) => {
                  Logger.debug('createUser rsp=' + JSON.stringify(data))
                  UserService.getUserFullInfoByUnionId(this.createUserRequest.hwUnionId == null ? undefined :
                  this.createUserRequest.hwUnionId)
                    .then((data: GetUserResponse | null) => {
                      if (data != null && data.ret != null && data.ret.retCode === Constants.RET_SUCCESS_CODE &&
                        data.userFullInfo != null && data.userFullInfo.userInfo != null) {
                        let currentUser = UserInfo.toBasicUserInfo(data.userFullInfo.userInfo);
                        AppStorage.setOrCreate(Constants.CURRENT_USER_BASIC,
                          currentUser);
                        this.pageStack.pop(currentUser, false);
                      }
                    })
                })
              }
            })
        }.position({ y: '85%' }).width('92%').justifyContent(FlexAlign.Center)
      }
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      Logger.debug('userRegister backPressed')
      return true
    })
  }

  private requiredFieldsEmpty(): boolean {
    return this.gender === FIELD_TO_SET ||
      this.marriageStatus === FIELD_TO_SET || this.birth === FIELD_TO_SET;
  }

  @Builder
  buildBirthDateRow() {
    Row() {
      this.buildTitleForOneCondition('您的出生日期', true)
      Row() {
        Text(`${this.birth}`).fontSize($r('sys.float.Body_M')).width('55%').textAlign(TextAlign.End)
        Image($r('app.media.ic_right_arrow')).width('6%').margin({ left: 16, right: 16 })
      }.onClick(() => {
        DatePickerDialog.show({
          start: DateUtils.getYearsBefore(Constants.MAX_AGE),
          end: DateUtils.getYearsBefore(Constants.ADULT_AGE),
          selected: DateUtils.getYearsBefore(Constants.DATE_PICKER_DEFAULT),
          disappearTextStyle: { color: Color.Gray, font: { size: '16fp', weight: FontWeight.Regular } },
          textStyle: { color: '#ff182431', font: { size: '16fp', weight: FontWeight.Regular } },
          selectedTextStyle: {
            color: $r('app.color.button_background_color'), font: {
              size: '16',
              weight: FontWeight.Regular,
              family: Constants.HARMONY_HEITI,
              style: FontStyle.Normal
            }
          },
          acceptButtonStyle: { backgroundColor: $r('app.color.button_background_color'), fontColor: Color.White },
          cancelButtonStyle: { backgroundColor: $r('app.color.button_background_color'), fontColor: Color.White },
          onDateAccept: (value: Date) => {
            // 通过Date的setFullYear方法设置按下确定按钮时的日期，这样当弹窗再次弹出时显示选中的是上一次确定的日期
            this.birth = DateUtils.formatDateStr(value);
            this.createUserRequest.birth = this.birth;
          }
        })
      })
    }.width('92%').height('8%')
  }

  @Builder
  buildGenderRow() {
    Row() {
      this.buildTitleForOneCondition('您的性别', true)

      Row() {
        Text(`${this.gender}`).fontSize($r('sys.float.Body_M')).width('55%').textAlign(TextAlign.End)
        Image($r('app.media.ic_right_arrow')).width('6%').margin({ left: 16, right: 16 })
      }.onClick(() => {
        TextPickerDialog.show(buildTextPickerDialogOption(Constants.GENDER_DISPLAY_VALUES,
          (result: TextPickerResult) => {
            this.gender = result.value as string
            this.createUserRequest.gender =
              Constants.getIndex(this.gender, Constants.GENDER_DISPLAY_VALUES);
          }, false))
      })
    }.width('92%').height('8%')
  }

  @Builder
  buildCurrentResidence() {
    Row() {
      this.buildTitleForOneCondition('您的现居地', false)

      Row() {
        Text(`${this.selectedCity}`).fontSize($r('sys.float.Body_M')).width('55%').textAlign(TextAlign.End)
        Image($r('app.media.ic_right_arrow')).width('6%').margin({ left: 16, right: 16 })
      }.onClick(() => {
        TextPickerDialog.show(buildTextPickerDialogOption(Constants.CITY_PICKER, (result: TextPickerResult) => {
          this.selectedCity = getPicResult(result);
          this.createUserRequest.currentResidence = this.selectedCity;
        }))
      })
    }.width('92%').height('8%')
  }

  @Builder
  buildMonthlyIncome() {
    Row() {
      this.buildTitleForOneCondition('您的月收入', false)

      Row() {
        Text(`${this.monthlyIncome}`).fontSize($r('sys.float.Body_M')).width('55%').textAlign(TextAlign.End)
        Image($r('app.media.ic_right_arrow')).width('6%').margin({ left: 16, right: 16 })
      }.onClick(() => {
        TextPickerDialog.show(buildTextPickerDialogOption(Constants.MONTHLY_INCOME_DISPLAY_VALUES,
          (result: TextPickerResult) => {
            this.monthlyIncome = result.value as string
            this.createUserRequest.monthlyIncome =
              Constants.getIndex(this.monthlyIncome, Constants.MONTHLY_INCOME_DISPLAY_VALUES);
          }))
      });
    }.width('92%').height('8%').alignItems(VerticalAlign.Center)

  }

  @Builder
  buildMarriageStatus() {
    Row() {
      this.buildTitleForOneCondition('您的婚姻状况', true)

      Row() {
        Text(`${this.marriageStatus}`)
          .fontSize($r('sys.float.Body_M'))
          .width('55%')
          .textAlign(TextAlign.End)
          .fontColor($r('app.color.text_font_color_black'))
        Image($r('app.media.ic_right_arrow')).width('6%').margin({ left: 16, right: 16 })
      }.onClick(() => {
        TextPickerDialog.show(buildTextPickerDialogOption(Constants.MARRIAGE_STATUS_DISPLAY_VALUES,
          (result: TextPickerResult) => {
            this.marriageStatus = result.value as string
            this.createUserRequest.maritalStatus =
              Constants.getIndex(this.marriageStatus, Constants.MARRIAGE_STATUS_DISPLAY_VALUES);
          }))
      });
    }.width('92%').height('8%').alignItems(VerticalAlign.Center)
  }

  @Builder
  buildTitleForOneCondition(name: string, isRequired: boolean) {
    Row() {
      if (isRequired) {
        Image($r('app.media.ic_red_dot')).width(4).height(4)
      } else {
        Blank().width(4)
      }
      Text(name)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Regular)
        .margin({ left: 10, top: 5, bottom: 5 })
    }.width('35%').justifyContent(FlexAlign.Start)
  }

  @Builder
  buildEdu() {
    Row() {
      this.buildTitleForOneCondition('您的学历', false)
      Row() {
        Text(`${this.edu}`).fontSize($r('sys.float.Body_M')).width('55%').textAlign(TextAlign.End)
        Image($r('app.media.ic_right_arrow')).width('6%').margin({ left: 16, right: 16 })
      }.onClick(() => {
        TextPickerDialog.show(buildTextPickerDialogOption(Constants.EDUCATION_DISPLAY_VALUES,
          (result: TextPickerResult) => {
            this.edu = result.value as string
            this.createUserRequest.education =
              Constants.getIndex(this.edu, Constants.EDUCATION_DISPLAY_VALUES);
          }))
      });
    }.width('92%').height('8%').alignItems(VerticalAlign.Center)
  }
}