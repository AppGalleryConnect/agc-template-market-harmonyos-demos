import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { Constants, GlobalContext, RouterMap } from 'common'
import { AddressInfo, MyAddressList, MyPassengerList, PassengerInfo } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { PageParam } from '../viewmodel/CommonInfoAddVM';
import { CommonInfoAddPageBuilder } from '../views/CommonInfoAddPage';

@ComponentV2
export struct CommonInfoList {
  @Param currentIndex: number = Constants.TAB_INDEX_ZERO
  @Local passengerList: MyPassengerList = PersistenceV2.connect(MyPassengerList, () => new MyPassengerList())!
  @Local addressList: MyAddressList = AppStorageV2.connect(MyAddressList, () => new MyAddressList())!
  ctx: UIContext = GlobalContext.getUIContext();

  deleteItem(id: string) {
    this.ctx.showAlertDialog({
      title: this.currentIndex === Constants.TAB_INDEX_ZERO ? '确定删除旅客吗？' : '确定删除地址吗',
      message: '',
      width: 328,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          fontColor: 'rgba(0, 0, 0, 0.50)',
          action: () => {
          }
        },
        {
          value: '确认',
          action: () => {
            this.currentIndex === Constants.TAB_INDEX_ZERO ? this.passengerList.deleteById(id) :
            this.addressList.deleteById(id)
          }
        }
      ]
    })
  }

  @Builder
  cardTitleBuilder(item: PassengerInfo | AddressInfo) {
    Row() {
      Row({ space: 4 }) {
        Text(item.name)
          .fontSize(16)
          .fontWeight(500)
          .fontColor('#000')
        if (item.id === this.passengerList.mySelfId) {
          Text('本人')
            .fontSize(10)
            .fontColor('#2F7CFF')
            .padding({
              left: 4,
              right: 4,
              top: 2,
              bottom: 2
            })
            .borderRadius(4)
            .border({ width: 1, color: '#99BFFF' })
        }
      }

      Image($r('app.media.ic_edit_card'))
        .width(20)
        .height(20)
        .onClick(() => {
          let param: PageParam = this.currentIndex === Constants.TAB_INDEX_ZERO ? {
            pageType: this.currentIndex,
            passengerInfo: item as PassengerInfo
          } : {
            pageType: this.currentIndex,
            addressInfo: item as AddressInfo
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.COMMON_INFO_ADD_PAGE,
            builder: wrapBuilder(CommonInfoAddPageBuilder),
            param
          })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  cardContentRow(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .width(52)
        .fontSize(13)
        .fontColor('rgba(0, 0, 0, 0.50)')
      Text(value)
        .layoutWeight(1)
        .fontSize(13)
        .fontColor('rgba(0, 0, 0, 0.50)')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  infoCardBuilder(item: PassengerInfo | AddressInfo) {
    Column({ space: 8 }) {
      this.cardTitleBuilder(item)
      if ((item as PassengerInfo).idNumber) {
        this.cardContentRow('身份证号', (item as PassengerInfo).getEncryptionID())
      }
      this.cardContentRow('手机号码', item.getEncryptionPhone())
      if ((item as AddressInfo).area) {
        this.cardContentRow('地址', (item as AddressInfo).getFullAddress())
      }
      Row() {
        Text('删除')
          .textBtnStyle()
          .onClick(() => {
            this.deleteItem(item.id)
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .backgroundColor('#fff')
    .borderRadius(16)
    .padding(12)
  }

  @Builder
  listAddButton() {
    Row() {
      Row({ space: 5 }) {
        Image($r('app.media.ic_plus_circle'))
          .width(14)
          .height(14)
        Text(this.currentIndex === Constants.TAB_INDEX_ZERO ? '新增常用人' : '新增地址')
          .fontSize(14)
          .fontColor('#333333')
      }
    }
    .width('100%')
    .borderRadius(24)
    .padding({ top: 13, bottom: 13 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff')
    .onClick(() => {
      let param: PageParam = {
        pageType: this.currentIndex
      }
      phoneRouterControl.jumpPage({
        pageName: RouterMap.COMMON_INFO_ADD_PAGE,
        builder: wrapBuilder(CommonInfoAddPageBuilder),
        param
      })
    })
  }

  build() {
    Column({ space: 10 }) {
      // 旅客列表
      if (this.currentIndex === Constants.TAB_INDEX_ZERO) {
        ForEach(this.passengerList.list, (item: PassengerInfo) => {
          this.infoCardBuilder(item)
        },(item: PassengerInfo) => JSON.stringify(item))
      }
      // 地址列表
      if (this.currentIndex === Constants.TAB_INDEX_ONE) {
        ForEach(this.addressList.list, (item: AddressInfo) => {
          this.infoCardBuilder(item)
        },(item: AddressInfo) => JSON.stringify(item))
      }
      this.listAddButton()
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}

@Extend(Text)
function textBtnStyle() {
  .fontSize(12)
  .fontColor('rgba(0, 0, 0, 0.70)')
  .padding({
    top: 8,
    bottom: 8,
    left: 26,
    right: 26
  })
  .backgroundColor('#fff')
  .borderRadius(10)
  .border({ width: 1, color: 'rgba(0, 0, 0, 0.10)' })
}
