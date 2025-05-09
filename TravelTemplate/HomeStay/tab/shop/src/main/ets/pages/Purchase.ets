import { paymentService } from '@kit.PaymentKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Constants, NavPathName } from 'constant';
import { AccountUtil } from 'account';
import { createOrder } from '../viewmodel/PurchasePageVM';
import { PurchaseInfo } from 'type';
import { doRandBySync, getCurrentTime } from 'util';
import { TitleBar } from 'component';
import { CreateOrderRequest, https, UpdateOrderRequest } from 'network';

@Builder
export function PurchaseBuilder() {
  Purchase();
}

@Component
export struct Purchase {
  @State remark: string = '';
  @State openId: string | undefined = AccountUtil.getOpenId();
  @State purchaseInfo: PurchaseInfo = new PurchaseInfo();
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

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
              Text('自提点：海湾花园1038号')
                .alignSelf(ItemAlign.Start)
                .fontSize(14)
                .fontWeight(500)
                .padding({ left: 16, top: 10, bottom: 10 });
            }
            .backgroundColor($r('app.color.location_bg_font_color'))
            .width(Constants.FULL_SCREEN)
            .margin({ top: 8 });

            Column() {
              Row() {
                Column() {
                  Image(this.purchaseInfo.commodityInfo.banner).size({ width: 80, height: 80 }).borderRadius(8);
                };

                Column() {
                  Text(this.purchaseInfo.commodityInfo.goodsName).fontSize(12).fontWeight(500).maxLines(2);
                  Text(this.purchaseInfo.sfc).fontSize(10).margin({ top: 8 });
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text(`￥${this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index]}`)
                      .fontSize(14)
                      .fontColor(Color.Red);
                    Text(`x${this.purchaseInfo.count}`).fontSize(12).fontColor(Color.Gray);
                  }.margin({ top: 8 });
                }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1);
              }.width(Constants.FULL_SCREEN);

              Divider().vertical(false).color('#F6F6F6').strokeWidth('2vp').margin({ top: 20 });

              Row() {
                Text('运费').fontSize(14).opacity(0.6);
                Text('免邮').fontSize(14).fontColor('#333333');
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).margin({ top: 12, bottom: 12 });

              Row() {
                Text('备注').fontSize(14).opacity(0.6);
                Blank().layoutWeight(1);
                TextInput({ placeholder: '请输入备注', text: this.remark })
                  .width(70)
                  .textAlign(TextAlign.End)
                  .padding(0)
                  .fontSize(14)
                  .fontColor('#333333')
                  .placeholderFont({ size: 14 })
                  .placeholderColor(Color.Gray)
                  .backgroundColor(Color.White)
                  .onChange((value: string) => {
                    this.remark = value;
                  });
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 });

              Divider().vertical(false).color('#F6F6F6').strokeWidth('2vp').margin({ bottom: 20 });

              Row() {
                Text('订单金额').fontSize(14).opacity(0.6);
                Text(`￥${(this.purchaseInfo.count *
                this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index]).toFixed(2)}`)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'));
              }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);
            }.padding(16);
          };

          Column() {
            Row() {
              Text('需支付：').fontSize(14);
              Text(`￥${(this.purchaseInfo.count *
              this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index]).toFixed(2)}`)
                .fontSize(16)
                .fontColor(Color.Red);
            }.alignItems(VerticalAlign.Bottom);

            Button('立即支付', { type: ButtonType.Normal })
              .width(Constants.FULL_SCREEN)
              .backgroundColor($r('app.color.keyword_type_font_color'))
              .borderRadius($r('sys.float.corner_radius_level4'))
              .margin({ top: 6 })
              .onClick(() => {
                this.purchase();
              });
          }
          .alignItems(HorizontalAlign.Start)
          .width(Constants.FULL_SCREEN)
          .padding(16);
        }.height('90%').justifyContent(FlexAlign.SpaceBetween);
      };
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.purchaseInfo = context.pathInfo.param as PurchaseInfo;
    });
  }

  async purchase() {
    const data: CreateOrderRequest = {
      appId: '',
      commodityId: this.purchaseInfo.commodityInfo.id,
      orderStatus: Constants.MODE === 'MOCK' ? 1 : 0,
      orderType: 1,
      orderRemark: this.remark,
      goodsCount: this.purchaseInfo.count,
      openId: this.openId ?? '',
      orderSn: doRandBySync(),
      createTime: getCurrentTime(),
      sfc: this.purchaseInfo.sfc,
      amount: (this.purchaseInfo.count *
      this.purchaseInfo.commodityInfo.retailPrice[this.purchaseInfo.index]),
      passengerId: 0,
      id: 0,
      planCheckInDate: '',
      planCheckOutDate: '',
      checkInPersonNum: 0,
      dayCount: 0,
      count: 0,
      goodsBanner: '',
    };

    const res = await createOrder(data);

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
          if (res.code === 200) {
            this.mainPathStack.pushPathByName(NavPathName.PAY_SUCCESS, 1);
          }
        } else if (error.code === 1001930011) {
          payStr = '网络链接异常';
        } else if (error.code === 1001930010) {
          payStr = '重复请求';
        }
      });
    }
  }
}