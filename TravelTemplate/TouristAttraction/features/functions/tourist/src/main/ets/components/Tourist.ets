import { Constant } from 'common';
import { cardTypeOptions, TouristInfo } from 'types';
import { TouristVM } from '../viewmodel/TouristVM';
import { promptAction } from '@kit.ArkUI';
import { TitleBar } from 'components';

@Extend(Text)
function touristKeyText() {
  .fontSize(14).opacity(0.9).width(60).textAlign(TextAlign.Start);
}

@Extend(Button)
function touristOperationBtn(isCancel: boolean) {
  .fontSize(14)
  .fontColor(isCancel ? '#64BB5C' : Color.White)
  .backgroundColor(isCancel ? Color.White : '#64BB5C')
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
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  aboutToAppear(): void {
    this.cloneTouristInfo.id = this.touristInfo.id;
    this.cloneTouristInfo.name = this.touristInfo.name;
    this.cloneTouristInfo.phone = this.touristInfo.phone;
    this.cloneTouristInfo.cardType = this.touristInfo.cardType;
    this.cloneTouristInfo.cardNo = this.touristInfo.cardNo;
  }

  @Builder
  CardTypeSelectBuilder(tourist: TouristInfo) {
    TextPicker({ range: cardTypeOptions, selected: tourist.cardType })
      .onChange((value: string | string[], index: number | number[]) => {
        tourist.cardType = (Array.isArray(index) ? index[0] : index);
      });
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          Row() {
            Text('姓名').touristKeyText();
            TextInput({ placeholder: '请输入姓名', text: this.touristInfo?.name }).onChange((value: string) => {
              this.cloneTouristInfo.name = value;
            }).backgroundColor(Color.Transparent)
              .placeholderColor('rgba(0, 0, 0, 0.4)');
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start);

          Divider();

          Row() {
            Text('手机号码').touristKeyText();
            TextInput({ placeholder: '请输入手机号码', text: this.touristInfo?.phone }).onChange((value: string) => {
              this.cloneTouristInfo.phone = value;
            }).backgroundColor(Color.Transparent)
              .placeholderColor('rgba(0, 0, 0, 0.4)');
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start);

          Divider();

          Row() {
            Row({ space: 16 }) {
              Text('证件类型').touristKeyText();
              Text(cardTypeOptions[this.touristInfo.cardType]);
            };

            Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
            this.isShow = true;
          }).bindSheet($$this.isShow, this.CardTypeSelectBuilder(this.cloneTouristInfo), {
            height: '40%',
          });

          Divider();

          Row() {
            Text('证件号码').touristKeyText();
            TextInput({ placeholder: '请输入证件号码', text: this.touristInfo?.cardNo }).onChange((value: string) => {
              this.cloneTouristInfo.cardNo = value;
            }).backgroundColor(Color.Transparent)
              .placeholderColor('rgba(0, 0, 0, 0.4)');
          }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start);
        }.borderRadius(8).backgroundColor(Color.White).padding(12);

        Row({ space: 16 }) {
          Button('取消').touristOperationBtn(true).onClick(() => {
            this.isInReserve ? this.cancelEdit(true) : this.mainPathStack.pop();
          });
          Button('保存').touristOperationBtn(false).onClick(() => {
            if (!this.vm.validate(this.cloneTouristInfo)) {
              return;
            }

            this.touristInfo.id = this.cloneTouristInfo.id;
            this.touristInfo.name = this.cloneTouristInfo.name;
            this.touristInfo.phone = this.cloneTouristInfo.phone;
            this.touristInfo.cardType = this.cloneTouristInfo.cardType;
            this.touristInfo.cardNo = this.cloneTouristInfo.cardNo;
            this.vm.editItemInfo(this.touristInfo, this.isEdit);
            this.isInReserve ? this.changeSheetContent(true) : this.mainPathStack.pop();
          });
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center);
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