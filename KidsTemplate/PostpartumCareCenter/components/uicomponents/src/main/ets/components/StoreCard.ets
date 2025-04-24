import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { StoreModel } from '../model/StoreModel';
import { ComponentContent } from '@kit.ArkUI';
import { PromptActionClass } from '@ohos_agcit/postpartum_care_center_utils';
import { callPhone } from './StoreDetail';

const TAG: string = '[StoreCard]';

@Builder
export function callDialog(callPhone:Function) {
  Column() {
    Row() {
      Text('025-0000 0000')
        .fontSize(16)
        .margin({
          top:24,
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    Row() {

      Text('取消')
        .width('50%')
        .height(64)
        .fontSize(16)
        .fontColor('rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          PromptActionClass.closeDialog();
        })

      Text('呼叫')
        .onClick(() => {
          callPhone();
          PromptActionClass.closeDialog();
        })
        .width('50%')
        .height(64)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize(16)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }
  .width(328)
  .height(116)
  .borderRadius(32)
  .backgroundColor(Color.White)
}
@Preview
@ComponentV2
export struct StoreCard {
  vm: MainEntryVM = MainEntryVM.instance;
  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<object> = new ComponentContent(this.ctx,wrapBuilder(callDialog), callPhone)
  @Param store: StoreModel =
    new StoreModel(1, '南京涵江楼', '软件大道101号', '11100001111', $r('app.media.store_pic1'), '南京', 31.98, 118.76);

  build() {
    Column() {
      Stack() {
        Image(this.store.image)
          .width('100%')
          .borderRadius({
            topLeft: $r('app.string.border_radius_16'),
            topRight: $r('app.string.border_radius_16'),
          })
          .height(180)
          .objectFit(ImageFit.Cover);
        Text(this.store.distance !== null ? `距离${this.store.distance}km` : this.vm.locationServiceMessage)
          .fontSize($r('app.string.font_size_10'))
          .fontColor('#FFFFFF')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .backgroundColor('rgba(0,0,0,0.40)')
          .borderRadius($r('app.string.border_radius_8'))
          .padding({
            left: $r('app.string.padding_8'),
            right: $r('app.string.padding_8'),
            top: $r('app.string.padding_1'),
            bottom: $r('app.string.padding_1'),
          })// .position({ top: 10, right: 10 })
          .position({ top: 8, right: 8 })
          .height(16)
          .onClick(() => {
            this.vm.requestLocationPermission();
          });
      }
      .width('100%')
      .height(180)
      .margin({ bottom: $r('app.string.margin_ms') });

      Text(this.store.name)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize($r('app.string.font_size_16'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.string.margin_xxs') });
      Row() {
        Text(this.store.address)
          .height(16)
          .fontColor('rgba(0,0,0,0.60)')
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Image($r('app.media.ic_navigation'))
          .width(16)
          .height(16)
          .margin({ left: $r('app.string.margin_xxs') });
      }
      .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
      .margin({ bottom: $r('app.string.margin_l') })
      .onClick(() => {
        this.vm.queryLocation(this.store);
      });

      Row({ space: 24 }) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.visit_Consulting'))
            .fontSize($r('app.string.font_size_12'))// 设置字号为12
            .fontFamily('HarmonyHeiTi')// 设置字体为鸿蒙黑体
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.90)');
        }
        .backgroundColor('#FFFFFF')
        .padding({
          top: $r('app.string.padding_6'),
          bottom: $r('app.string.padding_7'),
        }) // 设置文字内边距
        .borderRadius($r('app.string.border_radius_14'))
        .borderWidth(1)
        .borderStyle(BorderStyle.Solid)
        .borderColor('rgba(0,0,0,0.40)')
        .width(72)
        .onClick(() => {
          // 电话号码和回调函数
          PromptActionClass.openDialog(this.getUIContext(), this.contentNode);
        });

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.visit_booking'))
            .fontSize($r('app.string.font_size_12'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF');
        }
        .backgroundColor('#333333')
        .padding({
          top: $r('app.string.padding_6'),
          bottom: $r('app.string.padding_7'),
        }) // 设置文字内边距
        .borderRadius($r('app.string.border_radius_14'))
        .borderWidth(1)
        .borderStyle(BorderStyle.Solid)
        .borderColor('#333333')
        .width(72)
        .onClick(() => {
          this.vm.navStack.pushPathByName('Booking', this.store.name);
        });
      }
      .height(28); // 设置Row的高度
    }
    .shadow({
      radius: 8, // 模糊半径
      color: 'rgba(0,0,0,0.08)', // 阴影颜色
    })
    .height(312)
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      const params: Record<string, Object> = { 'store': this.store, 'contentNode':  this.contentNode};
      this.vm.navStack.pushPathByName('StoreDetail', params);
    });
  }
}