import { CallTelSheetBuilder, Constants, RouterMap, StoreInfoModel } from 'common/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MenuComp {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel) as StoreInfoModel;
  @Local callTelSheet: boolean = false

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_address_mg')).width(24).height(24)
          Text($r('app.string.address_mg')).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ left: 12 })
        }

        Image($r('app.media.ic_right2')).width(14).height(14)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.pageStack?.pushPathByName(RouterMap.ADDRESS_MG_PAGE, null)
      })

      Divider().margin({ top: 12, bottom: 12, left: 30 })
      Row() {
        Row() {
          Image($r('app.media.ic_contact_us')).width(24).height(24)
          Text($r('app.string.contact_us')).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ left: 12 })
        }

        Image($r('app.media.ic_right2')).width(14).height(14)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        // 拨打商家电话
        this.callTelSheet = true
      })

      Divider().margin({ top: 12, bottom: 12, left: 30 })
      Row() {
        Row() {
          Image($r('app.media.ic_setting')).width(24).height(24)
          Text($r('app.string.setting')).fontSize(14).fontColor($r('sys.color.font_primary')).margin({ left: 12 })
        }

        Image($r('app.media.ic_right2')).width(14).height(14)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.pageStack?.pushPathByName(RouterMap.SETTING_PAGE, null)
      })
    }
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .borderRadius(12)
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .bindSheet($$this.callTelSheet, CallTelSheetBuilder(this.storeModel.tel, () => {
      this.closeTelSheet()
    }), {
      height: 290,
      blurStyle: BlurStyle.Thick,
      backgroundColor: '#E6FFFFFF',
      showClose: false,
    });
  }

  closeTelSheet() {
    this.callTelSheet = false
  }
}