import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { ContactModel } from '../mode/ContactModel';
import { ContactVM } from '../mode/ContactVM';

@Builder
export function AddContactPageBuilder() {
  AddContactPage();
}

@Entry
@ComponentV2
struct AddContactPage {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  @Local private name: string = ''; // 姓名输入框的值
  @Local private phone: string = ''; // 手机号输入框的值
  @Local private choosen: boolean = false; // 是否为默认联系人
  contactVM: ContactVM = ContactVM.instance;
  contact: ContactModel = new ContactModel(this.name, this.phone, this.choosen);

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.name'))
              .fontSize(16)
              .fontFamily($r('app.string.font_regular'))
              .fontWeight(FontWeight.Medium)
              .lineHeight(22)
              .layoutWeight(1);

            TextInput({ placeholder: $r('app.string.name_input'), text: this.name })
              .width(150)
              .height(32)
              .borderRadius(4)
              .backgroundColor(Color.White)
              .padding(8)
              .textAlign(TextAlign.End)
              .onChange((value: string) => {
                this.name = value;
              });
          }
          .alignItems(VerticalAlign.Center);

          Divider()
            .strokeWidth(1)
            .color($r('app.color.color_middle_gray'));

          Row() {
            Text($r('app.string.add_phone_number'))
              .fontSize(16)
              .fontFamily($r('app.string.font_regular'))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .lineHeight(22);

            TextInput({ placeholder: $r('app.string.phone_number_input'), text: this.phone })
              .width(150)
              .height(32)
              .backgroundColor(Color.White)
              .borderRadius(4)
              .padding(8)
              .textAlign(TextAlign.End)
              .onChange((value: string) => {
                this.phone = value;
              });
          }
          .alignItems(VerticalAlign.Center);
        }
        .backgroundColor(Color.White)
        .borderRadius(16)
        .height(112)
        .padding(16)
        .margin({ top: 20, bottom: 20 })
        .justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text('设为默认')
            .fontSize(16)
            .fontFamily($r('app.string.font_regular'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Start);

          Toggle({ type: ToggleType.Switch, isOn: this.choosen })
            .width(36)
            .height(20)
            .selectedColor($r('app.color.color_red'))
            .onChange((isOn: boolean) => {
              this.choosen = isOn;
            });
        }
        .height(56)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding(16)
        .margin({ bottom: 20 });

        Button($r('app.string.save'))
          .width(CommonConstants.FULL_WIDTH)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.color_red'))
          .fontSize(16)
          .fontFamily($r('app.string.font_regular'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.saveContact();
            this.appPathStack.pushPathByName('contact', true);
          })
          .position({
            left: 0,
            bottom: 20,
          });
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .padding({
        left:16,
        right: 16
      })
    }
    .title('添加联系人信息')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .linearGradient({
      angle: 180,
      colors: [['#D0E1F5', 0], ['#F1F3F5', 1]],
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }

  // 保存联系人逻辑
  saveContact() {
    // 更新 contact 对象的 name 和 phone 属性
    this.contact.name = this.name;
    this.contact.contactNumber = this.phone;
    this.contactVM.addContact(this.contact);
    if (this.choosen) {
      this.contactVM.setChoosen(this.contact);
    }
  }
}