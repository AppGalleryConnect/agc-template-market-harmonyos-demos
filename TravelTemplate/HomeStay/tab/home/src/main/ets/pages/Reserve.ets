import { CounterComponent, CounterType, promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Constants, NavPathName } from 'constant';
import { EnhancedSource, Source } from '../model/Index';
import { Passenger } from '../model/Passengers';
import { RoomType } from 'type';
import { CalenderUtil, DateModel } from 'calendar';
import { AccountUtil } from 'account';
import { getRoomOrderAmount } from '../viewmodel/ReservePageVM';
import { doRandBySync, getCurrentTime, checkPsgInfo, hasPassenger, isValidPhoneNo } from 'util';
import { AddOrModifyPassengerRequest, CreateOrderRequest, https, UpdateOrderRequest } from 'network';
import { TitleBar } from 'component';

const sourceType: Source = { source: 'Reserve' };

@Builder
export function ReserveBuilder() {
  Reserve();
}

@Component
export struct Reserve {
  @State guest: string = '';
  @State phone: string = '';
  @State remark: string = '';
  @State amount: number = 0;
  @State count: number = 1;
  @State startDate: DateModel | undefined = CalenderUtil.getStartDate();
  @State endDate: DateModel | undefined = CalenderUtil.getEndDate();
  @State openId: string | undefined = AccountUtil.getOpenId();
  @State roomTypeItem: RoomType = new RoomType();
  @State selectPassenger: Passenger = new Passenger();
  controller: TextInputController = new TextInputController();
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  private passengerId: number = 0;

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '确认订单', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        Column() {
          Column() {
            Row() {
              Image(this.roomTypeItem.roomTypeBanner).size({ width: 120, height: 120 }).borderRadius(8);

              Column() {
                Text(this.roomTypeItem.roomTypeName)
                  .fontSize(14)
                  .margin({ top: 8 });

                Text(`${this.startDate?.year}.${this.startDate?.month}.${this.startDate?.day} 至 ${this.endDate?.year}.${this.endDate?.month}.${this.endDate?.day}`)
                  .fontSize(12)
                  .margin({ top: 8 })
                  .fontColor(Color.Gray);

                Row() {
                  Text(`预订间数`);
                  Blank();

                  CounterComponent({
                    options: {
                      type: CounterType.LIST,
                      numberOptions: {
                        value: this.count,
                        min: 1,
                        max: 10,
                        onChange: (value: number) => {
                          this.count = value;
                          this.amount = (getRoomOrderAmount(this.roomTypeItem.roomTypePriceList,
                            this.startDate ?? new DateModel(1970, 1, 1, 0),
                            this.endDate ?? new DateModel(1970, 1, 1, 0))) * this.count;
                        },
                      },
                    },
                  }).margin({ left: 12 }).size({ width: 80 });
                }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start);
              }.margin({ left: 12 }).alignItems(HorizontalAlign.Start);

              Blank();
            }.padding(16).justifyContent(FlexAlign.Start).width(Constants.FULL_SCREEN);

            Row()
              .width(Constants.FULL_SCREEN)
              .height(4)
              .backgroundColor('#F6F6F6');

            Row() {
              Text(`入住人`).fontSize(14).width(60).opacity(0.6);
              TextInput({ text: this.guest, placeholder: '请输入入住人姓名', controller: this.controller })
                .placeholderColor(Color.Gray)
                .backgroundColor(Color.White)
                .placeholderFont({ size: 14 })
                .width('60%')
                .onChange((value: string) => {
                  this.guest = value;
                });
              Text('+常用旅客').fontSize(14).width(80).onClick(() => {
                this.addOrSelectPassenger();
              });
            }
            .alignItems(VerticalAlign.Center)
            .padding({ left: 18, top: 14, bottom: 14 })
            .width(Constants.FULL_SCREEN)
            .justifyContent(FlexAlign.Start);

            Divider()
              .vertical(false)
              .padding({ left: 18, right: 18 });

            Row() {
              Text(`联系电话`).fontSize(14).width(60).opacity(0.6);
              TextInput({ text: this.phone, placeholder: '请输入联系电话' })
                .placeholderColor(Color.Gray)
                .backgroundColor(Color.White)
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.phone = value;
                });
            }.alignItems(VerticalAlign.Center).padding({ left: 18, top: 14, bottom: 14 });

            Divider().vertical(false).padding({ left: 18, right: 18 });

            Row() {
              Text(`备注`).fontSize(14).width(60).opacity(0.6);
              TextInput({ text: this.remark, placeholder: '请输入备注信息', controller: this.controller })
                .placeholderColor(Color.Gray)
                .backgroundColor(Color.White)
                .placeholderFont({ size: 14 })
                .onChange((value: string) => {
                  this.remark = value;
                });
            }.alignItems(VerticalAlign.Center).padding({ left: 18, top: 14, bottom: 14 });

            Row()
              .width(Constants.FULL_SCREEN)
              .height(4)
              .backgroundColor('#F6F6F6');

            Row() {
              Text(`订单金额`).fontSize(14).opacity(0.6);
              Text(`￥${this.amount.toFixed(2)}`).fontSize(16).fontWeight(600).fontWeight(500);
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({
              left: 18,
              right: 18,
              top: 14,
              bottom: 14,
            })
            .width(Constants.FULL_SCREEN);

            Divider()
              .vertical(false)
              .padding({ left: 18, right: 18 });
          };

          Blank();

          Column() {
            Row() {
              Text('需支付：').fontSize(14);
              Text(`￥${this.amount.toFixed(2)}`).fontSize(20).fontColor('#F0353A');
            }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);

            Button('立即支付', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor('##007DFF')
              .fontColor($r('sys.color.font_on_primary'))
              .height(44)
              .borderRadius($r('sys.float.corner_radius_level4'))
              .width(Constants.FULL_SCREEN)
              .margin({ top: 8 })
              .onClick(() => {
                this.pay();
              });
          }.padding(16);
        }.height('90%').justifyContent(FlexAlign.SpaceBetween);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params: EnhancedSource = context.pathInfo.param as EnhancedSource;
      if (params?.source === 'HotelDetail') {
        this.roomTypeItem = (context.pathInfo.param as EnhancedSource).data;
        this.amount = getRoomOrderAmount(this.roomTypeItem.roomTypePriceList,
          this.startDate ?? new DateModel(1970, 1, 1, 0),
          this.endDate ?? new DateModel(1970, 1, 1, 0));
      }
    });
  }

  addOrSelectPassenger() {
    this.mainPathStack.pushPathByName(NavPathName.GUESTS, sourceType, (popInfo: ESObject) => {
      this.guest = popInfo.result.passengerName;
      this.phone = popInfo.result.passengerPhone;
      this.passengerId = popInfo.result.id;
    });
  }

  async pay() {
    if (checkPsgInfo(this.guest, this.phone) || !isValidPhoneNo(this.phone)) {
      promptAction.showToast({
        message: '请填写正确的入住人姓名或联系电话',
        duration: 1000,
      });
      return;
    }

    this.passengerId = hasPassenger(this.guest, this.phone);

    const data: CreateOrderRequest = {
      appId: '',
      passengerId: this.passengerId,
      id: this.roomTypeItem.id,
      orderStatus: 1,
      orderType: 0,
      orderRemark: this.remark,
      planCheckInDate: CalenderUtil.getFormatDate(this.startDate ?? new DateModel(1970, 1, 1, 0)) ?? '',
      planCheckOutDate: CalenderUtil.getFormatDate(this.endDate ?? new DateModel(1970, 1, 1, 0)) ?? '',
      checkInPersonNum: 2,
      dayCount: CalenderUtil.getDayCount(this.startDate ?? new DateModel(1970, 1, 1, 0),
        this.endDate ?? new DateModel(1970, 1, 1, 0)),
      openId: this.openId ?? '',
      orderSn: doRandBySync(),
      createTime: getCurrentTime(),
      amount: this.amount,
      count: this.count,
      goodsCount: 0,
      goodsBanner: '',
      commodityId: 0,
      sfc: '',
    };

    const res = await https.createOrder(data);

    if (res.code === 200) {
      //拉起支付
      let payStr = '';
      paymentService.requestPayment(getContext(this) as common.UIAbilityContext, res.data).then(() => {
        payStr = '支付成功';
      }).catch(async (error: BusinessError) => {
        if (error.code === 1001930000) {
          payStr = '取消支付';
        } else if (error.code === 1001930001) {
          payStr = '模拟支付成功';
          promptAction.showToast({
            message: payStr,
            duration: 1000,
          });
          const res = await https.updateOrder({ orderSn: data.orderSn, orderStatus: 2 } as UpdateOrderRequest);
          if (res?.code === 200) {
            this.mainPathStack.pushPathByName(NavPathName.PAY_SUCCESS, 0);
          }
        } else if (error.code === 1001930011) {
          payStr = '网络链接异常';
        } else if (error.code === 1001930010) {
          payStr = '重复请求';
        }
      });

      const psgData = {
        passengerId: this.passengerId,
        passengerName: this.guest,
        passengerPhone: this.phone,
        passengerCardType: '0',
        passengerCardId: '',
        appId: '',
      } as AddOrModifyPassengerRequest;

      let passengers: string | undefined = AppStorage.get('psgList');

      // 首次添加或旅客列表无该旅客，加入列表
      if (!passengers || this.passengerId === JSON.parse(passengers)?.length) {
        await https.addPassengers(psgData);
      }
    }
  }
}