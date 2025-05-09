import { Constants } from 'constant';
import { isValidPhoneNo, hasPassenger } from 'util';
import { promptAction } from '@kit.ArkUI';
import { AddOrModifyPassengerRequest, https } from 'network';
import { AccountUtil } from 'account';
import { TitleBar } from 'component';
import { Passenger } from 'type';

@Builder
export function AddGuestBuilder() {
  AddGuest();
}

@Component
export struct AddGuest {
  controller: TextInputController = new TextInputController();
  @State psgId: number = 0;
  @State isModify: boolean = false;
  @State guestName: string = '';
  @State phoneNo: string = '';
  @State openId: string | undefined = AccountUtil.getOpenId();
  @State cardNo: string = '';
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '添加常用旅客', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        Column() {
          Column() {
            Row() {
              Text() {
                Span('姓名').fontSize(14);
                Span('*').fontColor(Color.Red);
              }.width(72);

              TextInput({ text: this.guestName, placeholder: '请确保与证件姓名一致', controller: this.controller })
                .placeholderColor(Color.Gray)
                .backgroundColor(Color.White)
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.guestName = value;
                });
            }.padding({ left: 16, right: 16 });

            Divider().vertical(false).margin({ top: 8 });

            Row() {
              Text() {
                Span('联系电话').fontSize(14);
                Span('*').fontColor(Color.Red);
              }.width(72);

              TextInput({ text: this.phoneNo, placeholder: '请输入', controller: this.controller })
                .placeholderColor(Color.Gray)
                .backgroundColor(Color.White)
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.phoneNo = value;
                });
            }.padding({ left: 16, right: 16 });

            Divider().vertical(false).margin({ top: 8 });

            Row() {
              Text('身份证号').fontSize(14).width(72);
              TextInput({ text: this.cardNo, placeholder: '请输入身份证号', controller: this.controller })
                .placeholderColor(Color.Gray)
                .backgroundColor(Color.White)
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.cardNo = value;
                });

            }.padding({ left: 16, right: 16 });

            Divider().vertical(false).margin({ top: 8 }).width(2);
          }.height('80%');

          Row() {
            Button('取消', { type: ButtonType.Normal })
              .width(140)
              .height(44)
              .fontColor(Color.Black)
              .backgroundColor(Color.White)
              .border({ width: 1, color: Color.Black, radius: $r('sys.float.corner_radius_level4') })
              .margin({ bottom: 16, right: 16 })
              .onClick(() => {
                // 取消返回旅客页面
                this.mainPathStack.pop();
              });

            Button('保存', { type: ButtonType.Normal })
              .width(140)
              .height(44)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor($r('app.color.keyword_type_font_color'))
              .border({ width: 0, radius: $r('sys.float.corner_radius_level4') })
              .margin({ bottom: 16, left: 16 })
              .onClick(() => {
                // 添加到旅客列表
                let passengerId = 0;
                if (!this.isModify) {
                  passengerId = hasPassenger(this.guestName, this.phoneNo);
                } else {
                  passengerId = this.psgId;
                }

                if (this.guestName.length === 0 || !isValidPhoneNo(this.phoneNo)) {
                  promptAction.showToast({
                    message: '请输入正确的姓名或联系电话',
                    duration: 2000,
                  });
                  return;
                }

                this.submitPassenger(passengerId);
              });
          }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Center);
        }.height('90%').justifyContent(FlexAlign.SpaceBetween).padding({ bottom: this.windowBottomHeight });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let passengerInfo = context.pathInfo?.param as Passenger ?? undefined;
      if (passengerInfo) {
        this.isModify = true;
        this.psgId = passengerInfo.passengerId;
        this.guestName = passengerInfo.passengerName;
        this.phoneNo = passengerInfo.passengerPhone;
        this.cardNo = passengerInfo.passengerCardId;
      }
    });
  }

  async submitPassenger(passengerId: number) {
    const data: AddOrModifyPassengerRequest = {
      passengerId: passengerId,
      passengerName: this.guestName,
      passengerPhone: this.phoneNo,
      passengerCardType: '0',
      passengerCardId: this.cardNo,
      appId: '',
    };

    const res =
      this.isModify ? await https.modifyPassenger(data) : await https.addPassengers(data);

    if (res.code === 200) {
      promptAction.showToast({ message: this.isModify ? '修改成功' : '添加成功', duration: 2000 });
      this.mainPathStack.pop(data);
    }
  }
}