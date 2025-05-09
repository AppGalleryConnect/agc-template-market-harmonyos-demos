import {
  BaseSelectedListItem,
  checkPhoneValid,
  Constants,
  PassengerApi,
  PassengerInfo,
  CommonFuncResult,
  AppRouter,
} from 'common';
import { MinePageModel } from '../model/MinePageModel';
import { Decimal } from '@kit.ArkTS';
import { BaseTip, BaseTitle, GlobalDialog } from 'components';
import { SelectCardSheetView } from '../components/SelectCardSheetView';

@Builder
export function addPassengerPageBuilder() {
  AddPassengerPage()
}

@ComponentV2
export struct AddPassengerPage {
  // 编辑乘机人信息
  @Local editPassengerInfo: PassengerInfo = new PassengerInfo();
  @Local isEdit: boolean = false;
  // 乘机人姓名
  @Local name: string = '';
  // 智能填充的证件类型
  @Local idType: ContentType | undefined = ContentType.ID_CARD_NUMBER;
  // 展示的证件类型
  @Local cardTypeList: BaseSelectedListItem[] = MinePageModel.getCardTypeList();
  // 选择的证件类型，默认展示身份证
  @Local selectedCardType: BaseSelectedListItem = this.cardTypeList[0];
  // 证件号码
  @Local cardNo: string = '';
  // 手机号
  @Local phone: string = '';
  // 选择证件类型的半模态
  @Local showCardMode: boolean = false

  // 确定
  confirm() {
    // 校验证件号码
    if (!this.checkCardNoValid()) {
      GlobalDialog.showToast('请填写正确的证件号');
      return;
    }
    // 校验手机号码
    if (!checkPhoneValid(this.phone)) {
      GlobalDialog.showToast('手机号输入错误');
      return;
    }
    let param = {
      id: this.editPassengerInfo.id || this.getUUID(),
      name: this.name,
      certificateType: this.selectedCardType.type,
      certificateNo: this.cardNo,
      phone: this.phone,
    } as PassengerInfo;
    GlobalDialog.showLoadingDialog()
    PassengerApi.addOrEditPassenger(param).then((res) => {
      let result: CommonFuncResult = res.result as CommonFuncResult;
      if (result.ret.code === 0 && (result.result === 0 || result.result === 1)) {
        AppRouter.pop();
      }
    }).finally(() => {
      GlobalDialog.close()
    })
  }

  // 生成uuid
  getUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Number(Decimal.random()) * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  // 校验证件号码是否有效
  checkCardNoValid(): boolean {
    // 身份证/户口簿校验
    if (this.selectedCardType.type === 'idCard' || this.selectedCardType.type === 'Hukou') {
      const chinaID = /^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$/;
      return chinaID.test(this.cardNo);
    }
    // 护照校验
    if (this.selectedCardType.type === 'passport') {
      const passport = /^[A-Za-z0-9]{6,10}$/;
      return passport.test(this.cardNo);
    }
    // 台胞证校验
    if (this.selectedCardType.type === 'taiwan') {
      const taiwanPassport = /^[0-9]{8}$/;
      return taiwanPassport.test(this.cardNo);
    }
    // 港澳台居民居住证校验
    if (this.selectedCardType.type === 'hkMacau') {
      const hkMcTwPermit = /^[HMhm]\d{8,10}$/;
      return hkMcTwPermit.test(this.cardNo);
    }
    return false;
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: this.isEdit ? '编辑乘机人' : '添加乘机人',
          bgColor: $r('sys.color.white'),
          showBackBtn: true,
          onBack: () => {
            AppRouter.pop();
          },
        });

        List() {
          ListItem() {
            Column({space: 12}) {
              Row() {
                BaseTip({
                  text: $r('app.string.add_passenger_tip'),
                });
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .padding({
                left: 10,
                right: 10,
                top: 6,
                bottom: 6,
              })
              .backgroundColor('rgba(0,0,0,0.05)')
              .borderRadius(4);

              // 乘机人姓名
              Row() {
                Text('姓名').fontWeight(FontWeight.Medium).fontSize(16)

                TextInput({ text: this.name, placeholder: '请与乘机人证件一致' })
                  .placeholderColor($r('sys.color.ohos_id_blur_style_component_thick_color_dark'))
                  .placeholderFont({ size: 14, weight: FontWeight.Regular })
                  .maxLength(12)
                  .layoutWeight(1)
                  .contentType(ContentType.PERSON_FULL_NAME)
                  .selectionMenuHidden(true)
                  .borderRadius(0)
                  .backgroundColor(Color.Transparent)
                  .inputFilter(Constants.NAME_REG, () => {
                  })
                  .onChange((value: string) => {
                    this.name = value;
                  });
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .backgroundColor($r('sys.color.white'))
              .padding({
                left: 12,
                right: 12,
                top: 13,
                bottom: 13,
              })
              .borderRadius(16);

              /*
                 * 在填写实名信息表单的场景支持身份证输入或户口簿输入，其中，身份证和户口簿共用一个输入框，ContentType.ID_CARD_NUMBER目前只支持身份证号的推荐、填充，
                 * 不支持其他类型的证件，需要开发者根据输入场景动态配置输入框的ContentType，只在身份证输入场景下使用ContentType.ID_CARD_NUMBER。
                 * */
              // 证件类型
              Row() {
                Text('证件类型').fontWeight(FontWeight.Medium).fontSize(16)

                Row() {
                  Text(this.selectedCardType.label).fontWeight(FontWeight.Regular).fontSize(16)
                  Image($r('app.media.ic_right_arrow')).width(16).height(16).fillColor('#999');
                }
                .layoutWeight(1)
                .padding({ left: 16, top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)
                .onClick(() => {
                  this.showCardMode = !this.showCardMode
                });
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .backgroundColor($r('sys.color.white'))
              .padding({
                left: 12,
                right: 12,
                top: 13,
                bottom: 13,
              })
              .borderRadius(16)
              .bindSheet($$this.showCardMode, this.CardSheetBuilder(), {
                height: '50%',
                blurStyle: BlurStyle.COMPONENT_THICK,
                preferType: SheetType.BOTTOM,
                title: {
                  title: '请选择证件类型'
                },
              })

              // 证件号码
              Row() {
                Text('证件号码').fontWeight(FontWeight.Medium).fontSize(16)

                TextInput({ text: this.cardNo, placeholder: '请请与乘机人证件一致' })
                  .placeholderColor($r('sys.color.ohos_id_blur_style_component_thick_color_dark'))
                  .placeholderFont({ size: 14, weight: FontWeight.Regular })
                  .maxLength(18)
                  .layoutWeight(1)
                  .contentType(this.idType)
                  .selectionMenuHidden(true)
                  .borderRadius(0)
                  .backgroundColor(Color.Transparent)
                  .inputFilter('[0-9]', () => {
                  })
                  .onChange((value: string) => {
                    this.cardNo = value;
                  });
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .backgroundColor($r('sys.color.white'))
              .padding({
                left: 12,
                right: 12,
                top: 13,
                bottom: 13,
              })
              .borderRadius(16);

              // 手机号
              Row() {
                Row({ space: 12 }) {
                  Text('手机号码').fontWeight(FontWeight.Medium).fontSize(16)
                  Text('+86').fontWeight(FontWeight.Regular).fontSize(16)
                  Divider()
                    .strokeWidth(0.5)
                    .color($r('sys.color.ohos_id_color_button_divider'))
                    .height(14)
                    .vertical(true);
                };

                TextInput({ text: this.phone, placeholder: '请输入手机号码' })
                  .placeholderColor($r('sys.color.ohos_id_blur_style_component_thick_color_dark'))
                  .placeholderFont({ size: 14, weight: FontWeight.Regular })
                  .layoutWeight(1)
                  .maxLength(11)
                  .contentType(ContentType.PHONE_NUMBER)
                  .selectionMenuHidden(true)
                  .borderRadius(0)
                  .backgroundColor(Color.Transparent)
                  .inputFilter('[0-9]', (value: string) => {
                  })
                  .onChange((value: string) => {
                    this.phone = value;
                  });
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .backgroundColor($r('sys.color.white'))
              .padding({
                left: 12,
                right: 12,
                top: 13,
                bottom: 13,
              })
              .borderRadius(16)
            }
            .margin({bottom: 20})
          }
          ListItem() {
            Button('保存', { type: ButtonType.Capsule, stateEffect: true })
              .width('100%')
              .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
              .enabled(this.name !== '' && this.cardNo !== '' && this.phone !== '')
              .onClick(() => {
                this.confirm();
              })
          }
          .position({
            left: 0,
            bottom: 0
          })
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .layoutWeight(1)
        .padding({ left: 14, right: 14, top: 10})
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.color_page_bg'))
    .onReady((cxt) => {
      let editPassengerInfo = cxt.pathInfo.param as PassengerInfo;
      if (editPassengerInfo) {
        this.isEdit = true;
        this.editPassengerInfo = editPassengerInfo
        this.name = this.editPassengerInfo.name;
        this.phone = this.editPassengerInfo.phone;
        this.cardNo = this.editPassengerInfo.certificateNo;
        this.selectedCardType =
          this.cardTypeList.find((item: BaseSelectedListItem) => item.type ===
          this.editPassengerInfo.certificateType) ||
          this.cardTypeList[0];
      }
    });
  }

  @Builder
  LabelView(label: string) {
    Text(label)
      .textAlign(TextAlign.Start).padding({ right: 10 }).fontWeight(600);
  }

  @Builder
  CardSheetBuilder() {
    SelectCardSheetView({
      listData: this.cardTypeList,
      selectedItem: this.selectedCardType,
      selectCard: (data: BaseSelectedListItem) => {
        this.selectedCardType = data;
        // 在选择证件类型时，更改证件号码对应的ContentType值
        if (data.type === '0') {
          this.idType = ContentType.ID_CARD_NUMBER;
        } else {
          this.idType = undefined;
        }
        this.showCardMode = false
      }
    })
  }
}