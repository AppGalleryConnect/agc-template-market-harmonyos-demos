import { CARD_TYPE_OPTIONS, Constant, SystemUtil } from 'common';
import { Tourist, Tourists } from 'tourist_management';
import { TouristInfo } from 'types';
import { TicketVM } from '../viewmodel/TicketVM';

@ComponentV2
export struct TouristManagement {
  vm: TicketVM = TicketVM.instance;
  @Local isShow: boolean = false;
  @Local initialSheet: boolean = true;
  @Local isShowTourist: boolean = false;
  @Local editItem: TouristInfo = new TouristInfo();

  aboutToAppear(): void {
    this.vm.getTourists();
  }

  aboutToDisappear(): void {
    // 退出后将填充游客信息清空
    this.vm.selectedTourists = [new TouristInfo(SystemUtil.doRandBySync(2))];
    this.vm.selectTouristCount = 1;
  }

  @Builder
  CardTypeSelectBuilder(tourist: TouristInfo) {
    TextPicker({ range: CARD_TYPE_OPTIONS, selected: tourist.cardType })
      .onChange((value: string | string[], index: number | number[]) => {
        tourist.cardType = (Array.isArray(index) ? index[0] : index);
      });
  }

  @Builder
  TouristCard(tourist: TouristInfo, index: number) {
    Row() {
      Text(`游客${index + 1}${index === 0 ? '（联系人）' : ''}`).opacity(0.4);
    }.justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);

    Row() {
      Text('姓名').fontSize(14).width(80).textAlign(TextAlign.Start);
      TextInput({ text: tourist?.name, placeholder: '请新增/选择游客' })
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('sys.color.font_secondary'))
        .onChange((value: string) => {
          tourist.name = value;
        })
    };

    Divider().margin({ top: 4, bottom: 4 });

    Row() {
      Text(CARD_TYPE_OPTIONS[tourist.cardType]).fontSize(14).width(80).textAlign(TextAlign.Start);

      TextInput({ text: tourist?.cardNo, placeholder: '请新增/选择游客' })
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('sys.color.font_secondary'))
        .onChange((value: string) => {
          tourist.cardNo = value;
        })
    };

    Divider().margin({ top: 4, bottom: 4 });

    if (index === 0) {
      Row() {
        Text('手机号').fontSize(14).width(80).textAlign(TextAlign.Start);
        TextInput({ text: tourist?.phone, placeholder: '请新增/选择游客' })
          .backgroundColor(Color.Transparent)
          .placeholderColor($r('sys.color.font_secondary'))
          .onChange((value: string) => {
            tourist.phone = value;
          })
      };
    }
  }

  @Builder
  AddressManagementBuilder() {
    if (this.initialSheet) {
      Tourists({
        touristList: this.vm.touristList,
        isInReserve: true,
        changeSelectedStatus: (isChecked: boolean, touristId: string) => {
          if (!isChecked) {
            const index = this.vm.selectedTouristsId.findIndex((id) => {
              return id === touristId
            })
            if (index !== -1) {
              this.vm.selectedTouristsId.splice(index, 1)
            }
          }

          if (isChecked) {
            if (this.vm.selectedTouristsId.length === this.vm.selectTouristCount) {
              const oldId = this.vm.selectedTouristsId[0]
              const index = this.vm.touristList.findIndex((item) => {
                return item.id === oldId
              })
              if (index !== -1) {
                this.vm.touristList[index].isChecked = false
              }
              this.vm.selectedTouristsId.shift()
            }
            this.vm.selectedTouristsId.push(touristId)
          }

          this.vm.touristList = this.vm.touristList.map((tourist) => {
            if (tourist.id === touristId) {
              tourist.isChecked = isChecked;
            }
            return tourist;
          });
        },
        setSelectedTourist: () => {
          let tourists = this.vm.touristList.filter(item => item.isChecked);
          let len = tourists.length;
          // 替换选择数量的游客
          for (let i = 0; i < len; i++) {
            if (i > len - 1) {
              this.vm.selectedTourists[i] = new TouristInfo();
              return;
            } else if (i === this.vm.selectedTourists.length) {
              // 全部填充完成后退出
              return;
            }
            this.vm.selectedTourists[i].id = tourists[i].id;
            this.vm.selectedTourists[i].name = tourists[i].name;
            this.vm.selectedTourists[i].phone = tourists[i].phone;
            this.vm.selectedTourists[i].cardType = tourists[i].cardType;
            this.vm.selectedTourists[i].cardNo = tourists[i].cardNo;
            this.vm.selectedTourists[i].isChecked = tourists[i].isChecked;
          }
        },
        changeSheetContent: (value: boolean, tourist: TouristInfo) => {
          this.editItem = tourist;
          this.initialSheet = value;
        },
        closeSheet: () => {
          this.isShowTourist = false;
        },
        addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
          this.vm.editItemInfo(tourist, isEdit);
        },
      });
    } else {
      Tourist({
        touristInfo: this.editItem,
        isInReserve: true,
        isEdit: this.editItem.name.length > 0,
        changeSheetContent: (value: boolean) => {
          this.initialSheet = value;
        },
        cancelEdit: (value: boolean) => {
          this.initialSheet = value;
        },
        addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
          this.vm.editItemInfo(tourist, isEdit);
        },
      });
    }
  }

  build() {
    Column() {
      Row() {
        Text('游客信息').fontSize(14).fontWeight(500);
        Text('新增/选择')
          .borderRadius(4)
          .padding(4)
          .fontSize(14)
          .fontColor('#E84026')
          .backgroundColor('rgba(232, 64, 38, 0.2)')
          .onClick(() => {
            // 拉起游客选择
            this.isShowTourist = true;
          })
          .bindSheet($$this.isShowTourist, this.AddressManagementBuilder(), {
            height: '80%',
            title: { title: '选择游客' },
            onWillDismiss: ((dismissSheetAction: DismissSheetAction) => {
              // 回到上一页
              if (!this.initialSheet) {
                this.initialSheet = true;
              }
              dismissSheetAction.dismiss();
            }),
          });
      }.justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);

      Text(`请填写至少1位游客信息，已填写${this.vm.selectedTourists.length}位`)
        .opacity(0.6)
        .width(Constant.FULL_PERCENT)
        .textAlign(TextAlign.Start)
        .fontSize(12)
        .margin({ top: 4, bottom: 12 });

      Column() {
        ForEach(this.vm.selectedTourists, (item: TouristInfo, index: number) => {
          this.TouristCard(item, index);
        }, (item: TouristInfo) => item.id);
      };
    }.padding(12).backgroundColor($r('sys.color.font_on_primary')).borderRadius(8);
  }
}