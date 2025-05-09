import { CommonConstants, RouterModule } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';
import { promptAction } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { BaseSuccessResponse, https, Contacts } from 'network';

@Builder
export function AddVisitorPageBuilder() {
  AddVisitorPage();
}


@ComponentV2
struct AddVisitorPage {
  vm: MinePageVM = MinePageVM.instance;
  @Local contactInfo: Contacts = {
    personID: util.generateRandomUUID(false),
    name: '',
    cardType: '身份证',
    cardID: '',
    phone: '',
  };

  cloneContact(): void {
    if (this.vm.contactInfo) {
      this.contactInfo.name = this.vm.contactInfo.name;
      this.contactInfo.personID = this.vm.contactInfo.personID;
      this.contactInfo.cardType = this.vm.contactInfo.cardType;
      this.contactInfo.cardID = this.vm.contactInfo.cardID;
      this.contactInfo.phone = this.vm.contactInfo.phone;
    }
  }

  isContactInfoValid(): boolean {
    if (!this.contactInfo.name) {
      promptAction.showToast({ message: '请填写姓名！' });
      return false;
    }
    if (!this.contactInfo.cardID) {
      promptAction.showToast({ message: '请填写证件号！' });
      return false;
    }
    const idRegex = /^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$/i;
    if (!idRegex.test(this.contactInfo.cardID)) {
      promptAction.showToast({ message: '证件号格式不正确！' });
      return false;
    }

    if (!this.contactInfo.phone) {
      promptAction.showToast({ message: '请填写联系电话！' });
      return false;
    }
    const reg = /^[1][2,3,4,5,6,7,8,9][0-9]{9}$/;
    if (!reg.test(this.contactInfo.phone)) {
      promptAction.showToast({ message: '联系电话格式不正确！' });
      return false;
    }
    return true;
  }

  async upDateContactInfo(): Promise<void> {
    if (!this.isContactInfoValid()) {
      return;
    }
    const res: BaseSuccessResponse = await https.upDateContacts(this.contactInfo);
    if (res.code === 0) {
      promptAction.showToast({ message: '修改成功!' });
      const timer = setTimeout(() => {
        RouterModule.pop();
        clearTimeout(timer);
      }, 200);
    }
  }

  aboutToAppear(): void {
    this.vm.getContactInfo();
    this.cloneContact();
  }

  aboutToDisappear(): void {
    this.vm.clear();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Text('姓名').width(140).labelStyle();
              TextInput({ placeholder: '请输入', text: this.contactInfo.name }).inputValueStyle().onChange((res) => {
                this.contactInfo.name = res;
              });
            }.width('100%');

            Divider().width('100%').margin({ bottom: 10 }).strokeWidth(1);
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Text('证件类型').width(140).labelStyle();
              Text('身份证').labelStyle().textAlign(TextAlign.End);
            }.width('100%');

            Divider().width('100%').margin({ bottom: 10 }).strokeWidth(1);
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Text('证件号').width(140).labelStyle();
              TextInput({ placeholder: '请输入证件号', text: this.contactInfo.cardID })
                .inputValueStyle()
                .onChange((res) => {
                  this.contactInfo.cardID = res;
                });
            }.width('100%');

            Divider().width('100%').margin({ bottom: 10 }).strokeWidth(1);
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Text('联系电话').width(140).labelStyle();
              TextInput({ placeholder: '请输入', text: this.contactInfo.phone }).inputValueStyle().onChange((res) => {
                this.contactInfo.phone = res;
              });

            }.width('100%');

            Divider().width('100%').strokeWidth(1);
          }.margin({bottom:20})
        }
        .padding({ top: 10, left: 20, right: 20 })
        .height('calc(100% - 75vp)')
        .backgroundColor(CommonConstants.BG_COLOR_WHITE)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Row({ space: 8 }) {
          Button('保存')
            .backgroundColor(CommonConstants.FONT_COLOR_GREEN)
            .type(ButtonType.Normal)
            .borderRadius(20)
            .width(160)
            .fontColor(CommonConstants.FONT_COLOR_WHITE)
            .fontWeight(500)
            .onClick(() => {
              this.upDateContactInfo();
            });
          Button('取消')
            .backgroundColor('#0C000000')
            .type(ButtonType.Normal)
            .borderRadius(20)
            .width(160)
            .fontColor(CommonConstants.FONT_COLOR_BLACK)
            .fontWeight(500)
            .onClick(() => {
              RouterModule.pop();
            });
        }.justifyContent(FlexAlign.Center).height(75).backgroundColor(CommonConstants.BG_COLOR_WHITE).width('100%');

      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .padding({ top: 10 });
    }.title('添加常用参观人');

  }
}

@Extend(TextInput)
function inputValueStyle() {
  .textAlign(TextAlign.End)
  .flexGrow(1)
  .padding({
    top: 10,
    bottom: 10,
    left: 0,
    right: 0,
  })
  .height(47)
  .fontSize(CommonConstants.FONT_SIZE_L)
  .fontColor(CommonConstants.FONT_COLOR_BLACK)
  .backgroundColor('transparent');
}

@Extend(Text)
function labelStyle() {
  .width(140).height(47).fontSize(CommonConstants.FONT_SIZE_L).fontColor(CommonConstants.FONT_COLOR_BLACK);
}