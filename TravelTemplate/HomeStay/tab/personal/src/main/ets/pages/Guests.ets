import { UIDialog } from '@hw-agconnect/ui-dialog';
import { Constants } from 'constant';
import { CommonHeader } from 'component';
import { Passenger } from 'type';
import { GetInfoRequest, https } from 'network';
import { Source } from '../model/Index';
import { GuestPageVM } from '../viewmodel/GuestPageVM';
import { AddGuest } from './AddGuest';

@Builder
export function GuestsBuilder() {
  Guests();
}

@ComponentV2
export struct Guests {
  vm: GuestPageVM = GuestPageVM.instance;
  @Local source: string = '';
  @Local openId: string = '';
  @Local isShowAddSheet: boolean = false;
  @Local isEditMode: boolean = false;
  @Local editingPassengerId: number = -1;
  @Local addGuestName: string = '';
  @Local addGuestPhone: string = '';
  @Local addGuestCardType: number = -1;
  @Local addGuestCardNo: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  contextMenuBuilder(item: Passenger) {
    if (this.source !== 'Reserve') {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Row() {
          Text('编辑')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .padding(12)
            .onClick(() => {
              this.isEditMode = true;
              this.editingPassengerId = item.passengerId;
              this.addGuestName = item.passengerName;
              this.addGuestPhone = item.passengerPhone;
              this.addGuestCardType = Number(item.passengerCardType) || 0;
              this.addGuestCardNo = item.passengerCardId ?? '';
              this.isShowAddSheet = true;
            })
          Text('删除')
            .fontSize(16)
            .fontColor($r('sys.color.warning'))
            .padding(12)
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
                  this.vm.deleteGuest(this.getUIContext(), item.passengerId);
                  UIDialog.closeLast();
                },
              });
            })
        }
      }
    }
  }

  @Builder
  deleteBuilder(item: Passenger) {

    Image($r('app.media.icon_delete_guests'))
      .width(40)
      .height(40)
      .margin({ left: 16 })
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
            this.vm.deleteGuest(this.getUIContext(), item.passengerId);
            UIDialog.closeLast();
          },
        });
      })
  }

  @Builder
  addGuestSheetBuilder() {
    AddGuest({
      isEditMode: this.isEditMode,
      editingPassengerId: this.editingPassengerId,
      initialGuestName: this.addGuestName,
      initialGuestPhone: this.addGuestPhone,
      initialGuestCardType: this.addGuestCardType,
      initialGuestCardNo: this.addGuestCardNo,
      onClose: () => {
        this.isShowAddSheet = false;
      },
      onSave: (passengerId: number, name: string, phone: string, cardType: string, cardNo: string) => {
        if (this.isEditMode) {
          let index = this.vm.passengers.findIndex((item) => item.passengerId === passengerId);
          if (index >= 0) {
            this.vm.passengers.splice(index, 1, {
              passengerId: passengerId,
              openId: '',
              passengerName: name,
              passengerPhone: phone,
              passengerCardType: cardType,
              passengerCardId: cardNo,
              appId: '',
            });
          }
        } else {
          this.vm.passengers.push({
            passengerId: passengerId,
            openId: '',
            passengerName: name,
            passengerPhone: phone,
            passengerCardType: cardType,
            passengerCardId: cardNo,
            appId: '',
          });
        }
      },
      onDelete: (passengerId: number) => {
        this.vm.deleteGuest(this.getUIContext(), passengerId);
      },
    })
  }

  async aboutToAppear(): Promise<void> {
    const data: GetInfoRequest = {
      appId: '',
      openId: this.openId ?? '',
    };

    const res = await https.queryPassengers(data);

    if (res?.code === 200) {
      this.vm.passengers = this.vm.mapPassengerInfo(res.data);
    }
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '常用旅客', showBackButton: true, backButtonClick: () => {
            this.mainPathStack.pop();
          },
        });

        List({ space: 12 }) {
          ForEach(this.vm.passengers, (item: Passenger) => {
            ListItem() {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(item.passengerName)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))

                  if (item.passengerCardId.length) {
                    Row({ space: 4 }) {
                      Text('证件号')
                        .fontSize(14)
                        .fontColor($r('sys.color.font_secondary'))
                      Text(item.passengerCardId)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.font_primary'))
                    }
                  }

                  Row({ space: 4 }) {
                    Text('手机号')
                      .fontSize(14)
                      .fontColor($r('sys.color.font_secondary'))
                    Text(item.passengerPhone)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                if (this.source !== 'Reserve') {
                  Image($r('app.media.icon_edit_guests'))
                    .width(24)
                    .height(24)
                    .onClick(() => {
                      this.isEditMode = true;
                      this.editingPassengerId = item.passengerId;
                      this.addGuestName = item.passengerName;
                      this.addGuestPhone = item.passengerPhone;
                      this.addGuestCardType = Number(item.passengerCardType) || 0;
                      this.addGuestCardNo = item.passengerCardId ?? '';
                      this.isShowAddSheet = true;
                    })
                }
              }
              .width(Constants.FULL_SCREEN)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .padding(12)
              .borderRadius(16)
              .alignItems(VerticalAlign.Center)
              .bindContextMenu(this.contextMenuBuilder(item), ResponseType.LongPress, {
                preview: MenuPreviewMode.IMAGE,
                hapticFeedbackMode: HapticFeedbackMode.ENABLED
              })
            }
            .swipeAction({ end: {
              builder: () => {
                this.deleteBuilder(item)
              },
              onAction: () => {
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
                    this.vm.deleteGuest(this.getUIContext(), item.passengerId);
                    UIDialog.closeLast();
                  },
                });
              },
            } })
          }, (item: Passenger) => item.passengerName);
        }
        .width(Constants.FULL_SCREEN)
        .layoutWeight(1)
        .margin({ top: 12, left: 16, right: 16 })
        .scrollBar(BarState.Off)

        Button('添加常用旅客')
          .borderRadius($r('sys.float.corner_radius_level11'))
          .height(44)
          .width(Constants.FULL_SCREEN)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .margin({ left: 16, right: 16, top: 12, bottom: 44 })
          .onClick(() => {
            this.isEditMode = false;
            this.editingPassengerId = -1;
            this.addGuestName = '';
            this.addGuestPhone = '';
            this.addGuestCardType = -1;
            this.addGuestCardNo = '';
            this.isShowAddSheet = true;
          });
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ left: 16, right: 16 })
      .bindSheet($$this.isShowAddSheet, this.addGuestSheetBuilder(), {
        height: SheetSize.LARGE,
        showClose: false,
        dragBar: false,
      })
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let sourceType = context.pathInfo.param as Source;
      if (sourceType) {
        this.source = sourceType.source;
      }
    });
  }
}
