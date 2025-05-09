import { allPayMethod, PayMethod } from 'commonlib';
import { MainEntryVM } from 'commonlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { requestPaymentPromise } from 'commonlib';


@Builder
export function CheckOutPageBuilder(name: string, param: Object){
  CheckOutPage()
}

@Component
export struct CheckOutPage{
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @State pay:PayMethod = allPayMethod[0]
  textTimerController: TextTimerController = new TextTimerController()
  vm: MainEntryVM = MainEntryVM.instance;
  lastPageIndex:number = MainEntryVM.instance.navStack.size()-1
  totalPrice:string = JSON.stringify(MainEntryVM.instance.navStack.getParamByIndex(this.lastPageIndex))

  build() {
    NavDestination(){
      Column(){
      Column() {
        Row() {
          Text('￥' + this.totalPrice ).fontSize(40).fontColor(Color.Red).fontWeight(FontWeight.Bold)
        }
        .margin({ top: 30 })

        Row() {
          Text('剩余支付时间 ')
          TextTimer({ isCountDown: true, count: 900000, controller: this.textTimerController })
            .format('mm:ss')
            .onAppear(() => {
              this.textTimerController.start()
            })
        }
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .height(30)
        .width(170)
        .backgroundColor('#ffcacaca')
        .margin({ top: 10 })

        Column() {
          ForEach(allPayMethod, (pay: PayMethod, index: number) => {
            Column() {
              Row() {
                Row() {
                  Image(pay.imageDefault).width(20).height(20)
                  Text(pay.text)
                }
                Radio({ value: 'Radio' + index, group: 'radioGroup' })
                  .checked(index === 0 ? true : false)
                  .onClick(()=>{
                    this.pay = allPayMethod[index]
                  })
              }
              .margin({top:20})
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              if (index !== allPayMethod.length-1) {
                Divider()
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .height(70)
            .width('90%')
          }, (item: string, index: number) => item + index)
        }
        .borderRadius(20)
        .margin({ top: 40 })
        .backgroundColor(Color.White)
        .width('90%')
      }

        Column(){
          Row() {
            Text(this.pay.text+' ￥'+this.totalPrice).fontColor(Color.White)
          }
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .height(40)
          .width('90%')
          .backgroundColor($r('app.color.orange'))
          .onClick(()=>{
            if (this.pay.text==='华为支付') {
              requestPaymentPromise(this.context)
            }
            let link: undefined|Resource = this.pay.url;
            if (this.pay.url!=null) {
              this.context.openLink(this.context.resourceManager.getStringSync(link), { appLinkingOnly: true })
                .then(() => {
                  console.info('openlink success.');
                })
                .catch((error: BusinessError) => {
                  console.error(`openlink failed. error:${JSON.stringify(error)}`);
                });
            }
          })
        }
        .margin({bottom:30})
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#fff1ecec')
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(false)
    .title('安全收银台')
    .height('100%')
  }
}