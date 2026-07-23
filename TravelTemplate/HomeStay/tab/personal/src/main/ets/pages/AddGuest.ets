import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Constants } from 'constant';
import { isValidPhoneNo, hasPassenger } from 'util';
import { AddOrModifyPassengerRequest, https } from 'network';

const CARD_TYPE_LIST: string[] = ['身份证', '护照', '回乡证', '台胞证', '港澳台居住证'];

@ComponentV2
export struct AddGuest {
  @Param isEditMode: boolean = false;
  @Param editingPassengerId: number = -1;
  @Param initialGuestName: string = '';
  @Param initialGuestPhone: string = '';
  @Param initialGuestCardType: number = -1;
  @Param initialGuestCardNo: string = '';
  @Local addGuestName: string = '';
  @Local addGuestPhone: string = '';
  @Local addGuestCardType: number = -1;
  @Local addGuestCardNo: string = '';
  @Event onClose: () => void = () => {};
  @Event onSave: (passengerId: number, name: string, phone: string, cardType: string, cardNo: string) => void =
    () => {};
  @Event onDelete: (passengerId: number) => void = () => {};

  aboutToAppear(): void {
    this.addGuestName = this.initialGuestName;
    this.addGuestPhone = this.initialGuestPhone;
    this.addGuestCardType = this.initialGuestCardType;
    this.addGuestCardNo = this.initialGuestCardNo;
  }

  build() {
    Column() {
      Row() {
        Text(this.isEditMode ? '编辑常用旅客' : '添加常用旅客')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Blank()
        Image($r('app.media.ic_right_close'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.onClose();
          })
      }
      .width(Constants.FULL_SCREEN)
      .padding({ top: 16, bottom: 8 })

      Column() {
        Row() {
          Text('姓名')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(64)
            .flexShrink(0)

          TextInput({ text: this.addGuestName, placeholder: '必填' })
            .placeholderColor($r('sys.color.font_secondary'))
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.addGuestName = value;
            })
        }
        .width(Constants.FULL_SCREEN)
        .height(48)
        .alignItems(VerticalAlign.Center)

        Divider().color($r('sys.color.comp_divider'))

        Row() {
          Text('手机号码')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(64)
            .flexShrink(0)

          TextInput({ text: this.addGuestPhone, placeholder: '必填，请输入11位手机号码' })
            .placeholderColor($r('sys.color.font_secondary'))
            .backgroundColor(Color.Transparent)
            .type(InputType.PhoneNumber)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.addGuestPhone = value;
            })
        }
        .width(Constants.FULL_SCREEN)
        .height(48)
        .alignItems(VerticalAlign.Center)

        Divider().color($r('sys.color.comp_divider'))

        Row() {
          Text('证件类型')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(64)
            .flexShrink(0)

          Text(this.addGuestCardType >= 0 ? CARD_TYPE_LIST[this.addGuestCardType] : '请选择')
            .fontColor(this.addGuestCardType >= 0 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
            .margin({ left: 16 })
            .layoutWeight(1)

          Image($r('app.media.ic_right'))
            .width(12)
            .height(24)
        }
        .width(Constants.FULL_SCREEN)
        .height(48)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          UIDialog.open({
            contentBuilder: () => this.cardTypeDialogBuilder()
          });
        })

        Divider().color($r('sys.color.comp_divider'))

        Row() {
          Text('证件号码')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(64)
            .flexShrink(0)

          TextInput({ text: this.addGuestCardNo, placeholder: '必填' })
            .placeholderColor($r('sys.color.font_secondary'))
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.addGuestCardNo = value;
            })
        }
        .width(Constants.FULL_SCREEN)
        .height(48)
        .alignItems(VerticalAlign.Center)
      }
      .width(Constants.FULL_SCREEN)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .padding({ left: 12, right: 12 })
      .borderRadius(16)

      Blank().layoutWeight(1);

      Row({ space: 16 }) {
        if (this.isEditMode) {
          Button('删除')
            .borderRadius($r('sys.float.corner_radius_level11'))
            .height(44)
            .layoutWeight(1)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.warning'))
            .onClick(() => {
              UIDialog.open({
                content: '确定要删除此常用旅客吗？',
                confirmButtonOptions: {
                  button: '删除',
                  buttonFontColor: $r('sys.color.warning'),
                },
                cancelButtonOptions: {
                  buttonFontColor: $r('sys.color.font_primary')
                },
                showConfirmButton: true,
                showCancelButton: true,
                onConfirm: async () => {
                  this.onDelete(this.editingPassengerId);
                  UIDialog.closeLast();
                  this.onClose();
                },
              });
            })
        } else {
          Button('取消')
            .borderRadius($r('sys.float.corner_radius_level11'))
            .height(44)
            .layoutWeight(1)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.onClose();
            })
        }

        Button('保存')
          .borderRadius($r('sys.float.corner_radius_level11'))
          .height(44)
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            if (this.addGuestName.length === 0 || !isValidPhoneNo(this.addGuestPhone)) {
              ToastDialog.showToast({ message: '请正确填写姓名或手机号码' });
              return;
            }

            let passengerId = this.isEditMode ? this.editingPassengerId : hasPassenger(this.addGuestName,
            this.addGuestPhone);
            this.submitPassenger(passengerId);
          })
      }
      .width(Constants.FULL_SCREEN)
      .padding({ top: 24, bottom: 44 })
    }
    .width(Constants.FULL_SCREEN)
    .padding({ left: 16, right: 16 })
    .borderRadius({
      topLeft: $r('sys.float.corner_radius_level8'),
      topRight: $r('sys.float.corner_radius_level8'),
    })
  }

  async submitPassenger(passengerId: number) {
    const data: AddOrModifyPassengerRequest = {
      passengerId: passengerId,
      passengerName: this.addGuestName,
      passengerPhone: this.addGuestPhone,
      passengerCardType: this.addGuestCardType >= 0 ? String(this.addGuestCardType) : '0',
      passengerCardId: this.addGuestCardNo,
      appId: '',
    };

    const res =
      this.isEditMode ? await https.modifyPassenger(data) : await https.addPassengers(data);

    if (res.code === 200) {
      ToastDialog.showToast({ message: this.isEditMode ? '修改成功' : '添加成功' });
      this.onSave(passengerId, this.addGuestName, this.addGuestPhone,
        this.addGuestCardType >= 0 ? String(this.addGuestCardType) : '0', this.addGuestCardNo);
      this.onClose();
    }
  }

  @Builder
  cardTypeDialogBuilder() {
    Column() {
      TextPicker({ range: CARD_TYPE_LIST, selected: this.addGuestCardType >= 0 ? this.addGuestCardType : 0 })
        .onChange((value: string | string[], index: number | number[]) => {
          if (typeof index === 'number') {
            this.addGuestCardType = index;
          } else if (Array.isArray(index) && index.length > 0) {
            this.addGuestCardType = index[0];
          }
        })
        .disappearTextStyle({
          font: { size: 14, weight: FontWeight.Regular },
        })
        .textStyle({
          color: $r('sys.color.font_primary'),
          font: { size: 16, weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('sys.color.font_primary'),
          font: { size: 20, weight: FontWeight.Medium },
        })
        .canLoop(false)
        .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}
