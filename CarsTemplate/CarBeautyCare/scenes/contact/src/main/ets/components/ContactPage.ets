import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { ContactModel } from '../mode/ContactModel';
import { ContactVM } from '../mode/ContactVM';
import { ContactCard } from './ContactCard';

@Builder
export function ContactPageBuilder() {
  ContactPage();
}

@ComponentV2
struct ContactPage {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  contactVM: ContactVM = ContactVM.instance;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Column() {
        // 联系人列表
        List({ space: 12 }) {
          ForEach(this.contactVM.contactList, (item: ContactModel) => {
            ListItem() {
              ContactCard({ card: item });
            }
          });
        }
        .flexGrow(1)
        .margin({ top: 16 });

        // 添加联系人按钮
        Button($r('app.string.contact_add'))
          .width(CommonConstants.FULL_WIDTH)
          .height(48)
          .margin({ bottom: 24, top: 12 })
          .borderRadius(24)
          .backgroundColor($r('app.color.middleRed'))
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick(() => this.appPathStack.pushPathByName('addContact', true));
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Center)
      .padding({
        left:16,
        right:16
      })
    }
    .title('联系人信息')
    .margin({ top: px2vp(this.topRectHeight) })
    .linearGradient({
      angle: 180,
      colors: [['#D0E1F5', 0], ['#F1F3F5', 1]],
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}