import { ToastDialog } from '@hw-agconnect/ui-toast';
import { AddressController, AddressDTO, AddressVM, goToAddressListPage } from 'address_management';
import { RouterMap, RouterModule, ControllerModule, AddressBook, EmitterUtils, HttpApi } from 'lib_foundation'
import { NoticeRouterMap } from 'notice_center';
import { MenuInfo } from '../types';
import { MinePageVM } from '../viewModels/MinePageVM'


@ComponentV2
export struct MainService {
  vm: MinePageVM = MinePageVM.instance;
  controller: AddressController = new AddressController();

  private serviceList: MenuInfo[] = [
    {
      label: '我的快递',
      icon: $r('sys.symbol.archivebox_fill'),
      isSymbol: true,
      action: () => {
        this.jumpToMyExpress();
      },
    },
    {
      label: '地址管理',
      icon: $r('app.media.address_manage'),
      action: () => {
       this.jumpToMyAddress();
      },
    },
    {
      label: '我的消息',
      icon: $r('sys.symbol.envelope_fill'),
      isSymbol: true,
      action: () => {
        this.jumpToMyMessage();
      },
    },
    {
      label: '优惠券',
      icon: $r('sys.symbol.ticket_fill'),
      isSymbol: true,
      action: () => {
        this.jumpToMyCoupon();
      },
    },
  ]

  aboutToAppear(): void {
    this.initAddressController();
  }

  initAddressController() {
    // 注入查询逻辑
    this.controller.onLoadAddress = async () => {
      const resp = await HttpApi.queryAddressList(this.vm.userInfoModel.id);
      let addressList: AddressVM[] = [];
      if (resp.length > 0) {
        addressList = resp.map((item) => new AddressVM(item as AddressDTO))
      }
      return addressList;
    };

    // 注入新增地址逻辑
    this.controller.onAddAddress = async (address: AddressDTO) => {
      const time: number = new Date().getTime();
      address.createdAt = time;
      address.updatedAt = time;
      address.userId = this.vm.userInfoModel.id;
      const resp = await HttpApi.addAddressBook(address as AddressBook)
      return resp > 0;
    };

    // 注入删除逻辑
    this.controller.onDeleteAddress = async (addressId: number) => {
      const resp = HttpApi.deleteAddress(addressId);
      const tempAddress = {
        addressId,
      } as AddressDTO
      EmitterUtils.emit('refreshAddressInfo', { address: tempAddress });
      return resp;
    };

    // 注入修改地址逻辑
    this.controller.onModifyAddress = async (address: AddressDTO, isSetDefault: boolean = false) => {
      const time = Date.now();
      address.updatedAt = time;
      const resp = await HttpApi.updateAddressBook(address as AddressBook, isSetDefault);
      EmitterUtils.emit('refreshAddressInfo', { address: address });
      return resp;
    }
  }

  jumpToMyExpress() {
    const controller = ControllerModule.get();
    if (this.vm.userInfoModel.isLogin) {
      if (controller) {
        controller.changeIndex(1);
      }
    } else {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        if (controller) {
          controller.changeIndex(1);
        }
      })
    }
  }

  jumpToMyAddress() {
    if (this.vm.userInfoModel.isLogin) {
      goToAddressListPage(RouterModule.stack, {
        controller: this.controller
      });
    } else {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        goToAddressListPage(RouterModule.stack, {
          controller: this.controller
        });
      })
    }
  }

  jumpToMyMessage() {
    if (this.vm.userInfoModel.isLogin) {
      RouterModule.push({ url: NoticeRouterMap.NOTICE_CENTER })
    } else {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        RouterModule.push({ url: NoticeRouterMap.NOTICE_CENTER })
      })
    }
  }

  jumpToMyCoupon() {
    if (this.vm.userInfoModel.isLogin) {
      RouterModule.push({ url: RouterMap.COUPON_PAGE })
    } else {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        RouterModule.push({ url: RouterMap.COUPON_PAGE })
      })
    }
  }

  jumpToRealName() {
    if (this.vm.userInfoModel.isLogin) {
      if (this.vm.userInfoModel && this.vm.userInfoModel.isRealName === 1) {
        ToastDialog.showToast({ message: '已实名！' })
        return
      }
      RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
    } else {
      RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
        if (this.vm.userInfoModel && this.vm.userInfoModel.isRealName === 1) {
          ToastDialog.showToast({ message: '已实名！' })
          return
        }
        RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
      })
    }
  }

  build() {
    Row() {
      ForEach(this.serviceList, (item: MenuInfo) => {
        this.mainServiceBuilder(item)
      }, (item: MenuInfo) => JSON.stringify(item))
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  mainServiceBuilder(item: MenuInfo) {
    Column({ space: 4 }) {
      if (item.isSymbol) {
        SymbolGlyph(item.icon).fontSize(24).fontColor([$r('sys.color.icon_emphasize')])
      } else {
        Image(item.icon).width(24).height(24)
      }

      Text(item.label)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(16)
    }
    .onClick(() => {
      item.action();
    })
  }
}