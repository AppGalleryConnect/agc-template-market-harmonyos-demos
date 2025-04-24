import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { ContactModel } from '../mode/ContactModel';
import { ContactVM } from '../mode/ContactVM';

@ComponentV2
export struct ContactCard {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  contactVM: ContactVM = ContactVM.instance;
  list: ContactModel[] = this.contactVM.contactList;
  @Param card: ContactModel = this.list[0];

  build() {
    Row() {
      Text(this.card.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Start);

      if (this.card.choosen) {
        Row() {
          Text('默认')
            .fontSize(10)
            .fontColor('#EE3B55')
        }
        .width(24)
        .height(14)
        .borderRadius(2)
        .border({
          width: 1,
          color: '#EE3B55'
        })
        .margin({ right: 4 })
      }

      Text(this.card.contactNumber)
        .fontSize(14)
        .textAlign(TextAlign.End)
        .fontColor('rgba(0, 0, 0, 0.6)')
        .margin({right:4})

      Image($r('app.media.ic_right_arrow_lined'))
        .width(7)
        .height(14)
        .fillColor('rgba(0,0,0,0.2)')
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(56)
    .padding(16)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetX: 0,
      offsetY: 2,
    })
    .onClick(() => {
      const size = this.appPathStack.size() - 1;
      const allPahtName:string[] = this.appPathStack.getAllPathName();
      const prePathName = allPahtName[size - 1];
      if (prePathName === 'confirmOrder') {
        this.contactVM.setSelectContact(this.card)
        this.appPathStack.pop();
      }
    })
  }
}