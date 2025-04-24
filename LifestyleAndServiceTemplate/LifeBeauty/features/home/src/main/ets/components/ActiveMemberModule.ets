import { activeMemberCard, ActiveMemberRequest, CommonUtils, PHONE_REG, queryUserInfo, UIBackBtn } from 'utils';
import { webview } from '@kit.ArkWeb';

@Extend(Text)
function formLabel() {
  .fontSize(16)
  .fontWeight(500)
}


@Extend(Row)
function formRowItem() {
  .height(48)
  .width('100%')
  .borderWidth({ bottom: 0.5 })
  .borderColor($r('app.color.grey_20'))
}

interface GenderOption {
  value: string;
  label: ResourceStr;
}


@ComponentV2
export struct ActiveMember {
  @Local showSheet: boolean = false;
  @Local showSheetGender: boolean = false;
  @Local showSheetBirth: boolean = false;
  @Local showH5Agreement: boolean = false;
  @Local name: string = '';
  @Local gender: number = -1;
  @Local phone: string = '';
  @Local birthDate: Date | null = null;
  @Local isAgree: boolean = false;
  @Local _tempGender: number = 0;
  private _tempBirth: Date | null = null;
  controller: webview.WebviewController = new webview.WebviewController();
  private GENDER_OPTIONS: GenderOption[] = [
    {
      value: '0',
      label: '男',
    },
    {
      value: '1',
      label: '女',
    },
  ];

  validateInfo(): boolean {
    if (!this.isAgree) {
      this.getUIContext().getPromptAction().showToast({ message: '请勾选并同意协议' });
      return false;
    }
    if (!this.name) {
      this.getUIContext().getPromptAction().showToast({ message: '姓名未填写' });
      return false;
    }

    if (this.gender === -1) {
      this.getUIContext().getPromptAction().showToast({ message: '性别未选择' });
      return false;
    }

    if (!this.phone) {
      this.getUIContext().getPromptAction().showToast({ message: '手机号未填写' });
      return false;
    }

    if (!PHONE_REG.test(this.phone)) {
      this.getUIContext().getPromptAction().showToast({ message: '手机号不正确' });
      return false;
    }

    if (!this.birthDate) {
      this.getUIContext().getPromptAction().showToast({ message: '生日未填写' });
      return false;
    }

    return true;
  }

  onSubmit() {
    const isValid = this.validateInfo();
    if (isValid) {
      const data: ActiveMemberRequest = {
        name: this.name,
        gender: this.GENDER_OPTIONS[this.gender].value,
        mobile: this.phone,
        birth: this.birthDate?.getTime() || 0,
      };
      activeMemberCard(data).then(() => {
        this.showSheet = false;
        queryUserInfo();
        this.getUIContext().getPromptAction().showToast({ message: '会员卡开通成功' });
      })
    }
  }

  @Builder
  genderSheet() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetGender = false;
        })
        Text('性别').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_public_confirm_sheet')).width(40).height(40).onClick(() => {
          this.gender = this._tempGender;
          this.showSheetGender = false;
        })
      }
      .width('100%')
      .height(56)

      Column() {
        ForEach(this.GENDER_OPTIONS, (item: GenderOption, index: number) => {
          Text(item.label)
            .width('100%')
            .height(40)
            .textAlign(TextAlign.Center)
            .padding({ left: 2, right: 2 })
            .backgroundColor(this._tempGender === index ? Color.White : Color.Transparent)
            .borderRadius(8)
            .onClick(() => {
              this._tempGender = index;
            })
        }, (item: GenderOption) => JSON.stringify(item))
      }
      .margin({ top: 57, bottom: 86 })
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  birthSheet() {
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.ic_public_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetBirth = false;
        })
        Text('生日').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_public_confirm_sheet')).width(40).height(40).onClick(() => {
          this.birthDate = this._tempBirth ?? new Date();
          this.showSheetBirth = false;
          console.log('birthdate:' + this.birthDate.toLocaleString())
        })
      }
      .width('100%')
      .height(56)

      DatePicker({ selected: this.birthDate, start: new Date('1900-1-1'), end: new Date() })
        .onDateChange((date: Date) => {
          this._tempBirth = date;
          console.log('_tempBirth:' + this._tempBirth.toLocaleString())
        })
    }
    .padding({ left: 16, right: 16, bottom: 28 })
  }

  @Computed
  get genderFill() {
    if (this.gender === -1) {
      return '请选择';
    }
    return this.GENDER_OPTIONS[this.gender].label;
  }

  @Computed
  get birthFill() {
    if (!this.birthDate) {
      return '请选择';
    }
    return CommonUtils.formatDate(this.birthDate.getTime());
  }

  @Builder
  H5AgreementBuilder() {
    Column() {
      Row({ space: 23 }) {
        UIBackBtn({
          clickEvent: () => {
            this.showH5Agreement = false;
          },
        })
        Text('用户授权协议').fontSize(20).fontWeight(700).height(56)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({
        top: 40,
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      Web({ src: $rawfile('agreement_web.html'), controller: this.controller })
        .layoutWeight(1)
        .geolocationAccess(false)
        .backgroundColor('#F1F3F5')
    }
  }

  @Builder
  fillInfoSheet() {
    Column() {
      // 自定义标题栏
      Row() {
        Image($r('app.media.ic_public_close_sheet')).width(40).height(40).draggable(false).onClick(() => {
          this.showSheet = false;
        })
        Text('编辑个人信息').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_public_confirm_sheet')).width(40).height(40).draggable(false).onClick(() => {
          this.onSubmit();
        })
      }
      .width('100%')
      .height(56)

      // form表单
      Column() {
        Row() {
          Text('姓名').formLabel()
          TextInput({ placeholder: '请输入', text: $$this.name })
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .padding(0)
            .borderRadius(0)
        }.formRowItem()

        Row() {
          Text('性别').formLabel()
          Blank()
          Row({ space: 6 }) {
            Text(this.genderFill).fontColor($r('app.color.common_grey'))
            Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
          }
          .onClick(() => {
            this.showSheetGender = true;
          })
          .bindSheet($$this.showSheetGender, this.genderSheet(), {
            showClose: false,
            height: SheetSize.FIT_CONTENT,
          })
        }.formRowItem()

        Row() {
          Text('手机号').formLabel()
          TextInput({ placeholder: '请输入', text: $$this.phone })
            .type(InputType.PhoneNumber)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .padding(0)
            .borderRadius(0)
        }.formRowItem()


        Row() {
          Text('生日').formLabel()
          Blank()
          Row({ space: 6 }) {
            Text(this.birthFill).fontColor($r('app.color.common_grey'))
            Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
          }
          .onClick(() => {
            this.showSheetBirth = true;
          })
          .bindSheet($$this.showSheetBirth, this.birthSheet(), {
            height: SheetSize.FIT_CONTENT,
            showClose: false,
          })
        }.formRowItem()
      }
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({
        top: 10,
        bottom: 40,
      })

      // 底部说明操作区域
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Checkbox()
            .select($$this.isAgree)
            .selectedColor('#0A59F7')
            .shape(CheckBoxShape.CIRCLE)
            .width(10)
            .height(10)

          Row() {
            Text() {
              Span('加入即代表同意')
              Span('《用户授权协议》')
                .fontColor('#0A59F7')
                .onClick(() => {
                  this.showH5Agreement = true;
                })

              Span('，同时授权你的姓名性别手机号生日信息，用于注册你的会员信息')
            }
            .fontSize(10)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .bindContentCover($$this.showH5Agreement, this.H5AgreementBuilder())
          }
          .layoutWeight(1)

        }
        .alignItems(VerticalAlign.Top)

        Button('同意并加入会员')
          .width('100%')
          .height(40)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.common_theme_color'))
          .onClick(() => {
            this.onSubmit();
          })
      }
      .padding({
        bottom: 60,
        left: 6,
        right: 6,
      })
    }
    .padding(10)
  }

  clearInfo() {
    this.name = '';
    this.gender = -1;
    this.phone = '';
    this.birthDate = null;
    this._tempBirth = null;
  }

  build() {
    Row() {
      Image($r('app.media.ic_member')).width(28).height(24)
      Text('成为会员，尊享专属特权')
        .fontSize(14)
        .fontWeight(500)
        .fontColor($r('app.color.common_member'))
        .margin({ left: 15 })
      Blank()

      Button() {
        Text('立即开卡').fontSize(14).fontWeight(500)
      }
      .padding({
        top: 4,
        bottom: 4,
        left: 8,
        right: 8,
      })
      .backgroundColor($r('app.color.common_member'))
      .onClick(() => {
        this.clearInfo();
        this.showSheet = true;
      })
      .bindSheet($$this.showSheet, this.fillInfoSheet(), {
        showClose: false,
        backgroundColor: '#F1F3F5',
        height: SheetSize.FIT_CONTENT,
      })
    }
    .padding(16)
    .borderRadius(8)
    .backgroundColor('#1F1F20')
    .width('100%')
  }
}