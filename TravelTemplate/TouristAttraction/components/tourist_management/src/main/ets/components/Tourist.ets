import { CARD_TYPE_OPTIONS, TouristInfo } from 'module_base';
import { TouristVM } from '../viewmodel/TouristVM';

@Extend(Text)
function touristKeyText() {
  .fontSize(14).opacity(0.9).width(80).textAlign(TextAlign.Start);
}

@Extend(Button)
function touristOperationBtn(isCancel: boolean) {
  .fontSize($r('sys.float.Body_M'))
  .fontColor(isCancel ? '#64BB5C' : $r('sys.color.font_on_primary'))
  .backgroundColor(isCancel ? $r('sys.color.font_on_primary') : '#64BB5C')
  .border({ radius: 20, color: isCancel ? '#64BB5C' : Color.Transparent })
  .width(150)
  .padding({
    top: 10,
    bottom: 10,
  });
}

@Builder
export function TouristDetailBuilder() {
  Tourist();
}

@ComponentV2
export struct Tourist {
  vm: TouristVM = TouristVM.instance;
  @Local isShow: boolean = false;
  @Local cloneTouristInfo: TouristInfo = new TouristInfo();
  @Param @Once isEdit: boolean = false;
  @Param @Once isInReserve: boolean = false;
  @Param @Once touristInfo: TouristInfo = new TouristInfo();
  @Event changeSheetContent: (value: boolean) => void;
  @Event cancelEdit: (value: boolean) => void;
  // 保存联系人
  @Event addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => void;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  aboutToAppear(): void {
    this.cloneTouristInfo.id = this.touristInfo.id;
    this.cloneTouristInfo.name = this.touristInfo.name;
    this.cloneTouristInfo.phone = this.touristInfo.phone;
    this.cloneTouristInfo.cardType = this.touristInfo.cardType;
    this.cloneTouristInfo.cardNo = this.touristInfo.cardNo;
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Text('姓名').touristKeyText();
            TextInput({ placeholder: '请输入姓名', text: this.touristInfo?.name })
              .onChange((value: string) => {
                this.cloneTouristInfo.name = value;
              }).backgroundColor(Color.Transparent)
              .placeholderColor($r('sys.color.font_secondary'))
              .flexGrow(1)
          }.width('100%')

          Divider();

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Text('手机号码').touristKeyText();
            TextInput({ placeholder: '请输入手机号码', text: this.touristInfo?.phone })
              .onChange((value: string) => {
                this.cloneTouristInfo.phone = value;
              }).backgroundColor(Color.Transparent)
              .placeholderColor($r('sys.color.font_secondary'))
              .flexGrow(1)
          }.width('100%')

          Divider();

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Row({ space: 16 }) {
              Text('证件类型').touristKeyText();
              Text(CARD_TYPE_OPTIONS[this.touristInfo.cardType])
                .flexGrow(1)
                .margin({ left: -16 })
            };
          }.width('100%')

          Divider();

          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Text('证件号码').touristKeyText();
            TextInput({ placeholder: '请输入证件号码', text: this.touristInfo?.cardNo })
              .onChange((value: string) => {
                this.cloneTouristInfo.cardNo = value;
              }).backgroundColor(Color.Transparent)
              .placeholderColor($r('sys.color.font_secondary'))
              .flexGrow(1)
          }.width('100%')
        }.borderRadius(8).backgroundColor($r('sys.color.font_on_primary')).padding(12);

        Row({ space: 16 }) {
          Button('取消').touristOperationBtn(true).onClick(() => {
            this.isInReserve ? this.cancelEdit(true) : this.mainPathStack.pop();
          });
          Button('保存').touristOperationBtn(false).onClick(() => {
            if (!this.vm.validate(this.getUIContext(), this.cloneTouristInfo)) {
              return;
            }

            this.touristInfo.id = this.cloneTouristInfo.id;
            this.touristInfo.name = this.cloneTouristInfo.name;
            this.touristInfo.phone = this.cloneTouristInfo.phone;
            this.touristInfo.cardType = this.cloneTouristInfo.cardType;
            this.touristInfo.cardNo = this.cloneTouristInfo.cardNo;
            this.addOrEditTourist(this.touristInfo, this.isEdit);
            this.isInReserve ? this.changeSheetContent(true) : this.mainPathStack.pop();
          });
        }.width('100%').justifyContent(FlexAlign.Center);
      }
      .backgroundColor('#F1F3F5F2')
      .padding({
        top: 12,
        bottom: this.windowBottomHeight,
        left: 12,
        right: 12,
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .height('90%');
    };
  }
}