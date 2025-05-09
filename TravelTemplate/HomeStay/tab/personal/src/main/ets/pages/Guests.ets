import { Constants, NavPathName } from 'constant';
import { Source } from '../model/Index';
import { Passenger } from 'type';
import { GuestPageVM } from '../viewmodel/GuestPageVM';
import { GetInfoRequest, https } from 'network';
import { AccountUtil } from 'account';
import { TitleBar } from 'component';

@Builder
export function GuestsBuilder() {
  Guests();
}

@Extend(Image)
function operationImage() {
  .size({ width: 24, height: 24 }).opacity(0.2);
}

@Component
export struct Guests {
  vm: GuestPageVM = GuestPageVM.instance;
  @State source: string = '';
  @State openId: string | undefined = AccountUtil.getOpenId();
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

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
        Column() {
          TitleBar({
            isShowBack: true, title: '常用旅客', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          List() {
            ForEach(this.vm.passengers, (item: Passenger) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(`${item.passengerName}`)
                        .fontSize(14)
                        .fontWeight(500)
                        .width(Constants.FULL_SCREEN)
                        .textAlign(TextAlign.Start);

                      Row({ space: 8 }) {
                        Text('手机号').fontSize(14).fontColor(Color.Gray);
                        Text(`${item.passengerPhone}`).fontSize(14).fontColor(Color.Gray);
                      }.margin({ top: 12 }).width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);

                      if (item.passengerCardId.length) {
                        Row({ space: 8 }) {
                          Text('身份证').fontSize(14).fontColor(Color.Gray);
                          Text(`${item.passengerCardId}`).fontSize(14).fontColor(Color.Gray);
                        }.margin({ top: 4 }).width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);
                      }
                    }.width('60%');

                    if (this.source !== 'Reserve') {
                      Row({ space: 24 }) {
                        Image($r('app.media.edit')).operationImage().onClick(() => {
                          this.mainPathStack.pushPathByName(NavPathName.ADD_GUEST, item, (popInfo: ESObject) => {
                            let index =
                              this.vm.passengers.findIndex((item) => item.passengerId === popInfo.result.passengerId);
                            this.vm.passengers.splice(index, 1, popInfo.result);
                          });
                        });

                        Image($r('app.media.delete')).operationImage().onClick(() => {
                          this.vm.deleteGuest(item.passengerId);
                        });
                      };
                    }
                  }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);

                  Divider().vertical(false).margin({ top: 16 });
                };
              }.padding(16).onClick(() => {
                if (this.source) {
                  this.mainPathStack.popToName(NavPathName.RESERVE, item);
                }
              });
            }, (item: Passenger) => item.passengerName);
          }.scrollBar(BarState.Off).align(Alignment.Top).height('80%');
        };

        Row() {
          Button('添加旅客', { type: ButtonType.Normal })
            .width(150)
            .height(44)
            .fontColor(Color.Black)
            .backgroundColor(Color.White)
            .border({ width: 1, color: Color.Black, radius: $r('sys.float.corner_radius_level4') })
            .onClick(() => {
              this.mainPathStack.pushPathByName(NavPathName.ADD_GUEST, null, (popInfo: ESObject) => {
                if (this.vm.passengers.find(item => item.passengerId === popInfo.result.passengerId)) {
                  return;
                }

                let passenger: Passenger = {
                  passengerId: popInfo.result.passengerId,
                  openId: popInfo.result.openId,
                  passengerName: popInfo.result.passengerName,
                  passengerPhone: popInfo.result.passengerPhone,
                  passengerCardType: popInfo.result.passengerCardType,
                  passengerCardId: popInfo.result.passengerCardId,
                  appId: popInfo.result.passengerCardId,
                };
                this.vm.passengers.push(passenger);
              });
            });
        }
        .position({ y: '90%' })
        .height('10%')
        .width(Constants.FULL_SCREEN)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center);
      };
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let sourceType = context.pathInfo.param as Source;
      if (sourceType) {
        this.source = sourceType.source;
      }
    });
  }
}