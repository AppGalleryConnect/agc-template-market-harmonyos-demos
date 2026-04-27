import { Constants, RouterMap } from 'common'
import { AddressManagerItem, AddressManagerPageVM } from '../viewmodel/AddressManagerPageVM'
import { DeleteAddressDialog } from '../views/MyBankCard/DeleteAddressDialog'
import { promptAction } from '@kit.ArkUI'
import { phoneRouterControl, RouterPopInfo } from 'oh_router'
import { EditAddressPageBuilder } from './EditAddressPage'
import { AddressDTO } from 'address_management'

@Builder
export function AddressManagerPageBuilder(param: Object) {
  AddressManagerPage({ fromPage: param as string })
}

@ComponentV2
export struct AddressManagerPage {
  private logTag: string = 'AddressManagerPage'
  // 地址管理对象
  @Local addressManager: AddressManagerPageVM = AddressManagerPageVM.instance
  // 从哪里跳转的
  @Param fromPage: string = ''

  // 地址单元布局
  @Builder
  buildAddressItem(item: AddressManagerItem, index: number) {
    RelativeContainer() {
      // 住户姓名+住户手机号
      Text(`${item.name} ${item.phone}`)
        .fontSize(16)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .alignRules({
          top: { align: VerticalAlign.Top, anchor: '__container__' },
          left: { align: HorizontalAlign.Start, anchor: '__container__' }
        })
        .margin({ left: 12, top: 11 })
        .id('name_phone')

      // 备注
      if (item.remark) {
        Row() {
          Text(item.remark)
            .height(16)
            .fontSize(10)
            .fontColor('rgba(255, 75, 75, 1)')
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
        }
        .alignRules({
          left: { align: HorizontalAlign.End, anchor: 'name_phone' }
        })
        .margin({ left: 7, top: 12 })
        .padding({ left: 3, right: 3 })
        .border({ width: 0.5, color: 'rgba(255, 75, 75, 1)', radius: 4 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }

      // 住户地址
      Text(item.address).fontSize(12).fontColor('rgba(0, 0, 0, 0.8)')
        .alignRules({
          top: { anchor: 'name_phone', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .margin({ left: 12, top: 12 })

      // 是否默认
      Row() {
        if (item.isDefault) {
          Image($r('app.media.ic_address_selected')).size({ width: 12, height: 12 })
        } else {
          Row()
            .size({ width: 12, height: 12 })
            .border({ width: 1, color: 'rgba(0, 0, 0, 0.2)', radius: 3 })
            .backgroundColor('rgba(255, 255, 255, 1)')
        }
        Text('设为默认地址').fontSize(10).fontColor('rgba(0, 0, 0, 0.6)')
          .margin({ left: 4 })
      }
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .onClick(() => {
        if (item.isDefault) {
          return
        }
        item.isDefault = true
        this.addressManager.addressList.forEach((i: AddressManagerItem) => {
          if (i !== item) {
            i.isDefault = false
          }
        })
        // 给出提示
        promptAction.showToast({
          message: '已设为默认地址'
        })
      })
      .margin({ left: 12, bottom: 24 })

      // 删除 + 修改
      Row() {
        Text('删除')
          .width(52)
          .height(28)
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .border({ width: 1, color: 'rgba(0, 0, 0, 0.2)', radius: 14 })
          .margin({ right: 8 })
          .onClick(() => {
            promptAction.openCustomDialog({
              builder: () => {
                this.deleteCustomDialog(item.id)
              },
              alignment: DialogAlignment.Center,
              width: '90%'
            })
              .then((id) => {
                this.addressManager.deleteDialogId = id
              })
          })

        Text('修改')
          .width(52)
          .height(28)
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .border({ width: 1, color: 'rgba(0, 0, 0, 0.2)', radius: 14 })
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.EDIT_PICK_UP_ADDRESS_PAGE,
              builder: wrapBuilder(EditAddressPageBuilder),
              param: index
            })
          })

      }.alignRules({
        right: { anchor: '__container__', align: HorizontalAlign.End },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })
      .margin({ right: 12, bottom: 16 })

    }
    .width('100%')
    .height(120)
    .borderRadius(16)
    .backgroundColor('rgba(255, 255, 255, 1)')
    .onClick(() => {
      // 如果不是从修改预约信息页面跳转过来，则不返回
      if (!this.fromPage) {
        return
      }
      const dto: AddressDTO = {
        id: item.id,
        name: item.name,
        phone: item.phone,
        countryCode: 'CN',
        country: '',
        province: '',
        city: '',
        district: '',
        street: item.area,
        detail: item.detailAddress,
        isDefault: item.isDefault,
        createdAt: Date.now(),
        updatedAt: Date.now(),
      }
      const popInfo: RouterPopInfo = { popData: dto }
      phoneRouterControl.popPage(popInfo)
    })

  }

  @Builder
  deleteCustomDialog(id: string) {
    DeleteAddressDialog({
      vm: this.addressManager,
      deleteId: id
    })
  }

  build() {
    NavDestination() {
      Column() {
        List({ space: 8 }) {
          ForEach(this.addressManager.addressList, (item: AddressManagerItem, index: number) => {
            ListItem() {
              this.buildAddressItem(item, index)
            }
          }, (item: AddressManagerItem, idx: number) => JSON.stringify(item) + idx)
        }.width('100%').layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        Row() {
          Text('新建地址')
            .layoutWeight(1)
            .height(40)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(255, 255, 255, 1)')
            .backgroundColor('rgba(255, 75, 75, 1)')
            .textAlign(TextAlign.Center)
            .margin({ left: 12, right: 12 })
            .borderRadius(20)
            .onClick(() => {
              // 置空，表示是新增
              phoneRouterControl.jumpPage({
                pageName: RouterMap.EDIT_PICK_UP_ADDRESS_PAGE,
                builder: wrapBuilder(EditAddressPageBuilder),
                param: -1
              })
            })
        }
        .width('100%')
        .margin({ bottom: 24, top: 12 })

      }.width('100%').height('100%').backgroundColor('rgba(245, 245, 245, 1)').padding({ top: 12, left: 16, right: 16 })
    }
    .title('取件地址')
    .hideToolBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}