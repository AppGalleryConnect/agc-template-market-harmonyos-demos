import { routerStack, WindowUtil } from 'lib_foundation'
import { AddressInfo, PointsApis } from 'lib_network'
import { UpdateAddressPageOptions } from 'lib_widget'
import { AddressDTO, AddressManageUtil } from 'address_management'

export interface PointsUpdateAddressOptions {
  originalAddress: AddressInfo
  orderId: string
  handleSubmitSuccess: () => void
}

export function buildPointsAddressSheetOptions(param: PointsUpdateAddressOptions): UpdateAddressPageOptions {
  const options: UpdateAddressPageOptions = {
    originalAddress: param.originalAddress,
    onSelectAddress: (callback: (address: AddressInfo) => void) => {
      AddressManageUtil.goToAddressListPage(routerStack.getActiveStack(), (data: AddressDTO) => {
        const addr: AddressInfo = {
          name: data.name,
          cellphone: data.phone,
          address: data.province + data.city + data.district + data.street + data.detail,
        }
        callback(addr)
        routerStack.pop()
      })
    },
    onSubmit: (newAddress: AddressInfo) => {
      PointsApis.updateRedemptionAddress(param.orderId, newAddress).then((res) => {
        if (res.code === 0) {
          WindowUtil.toast('地址已更新')
          routerStack.pop()
          param.handleSubmitSuccess()
        }
      })
    },
  }
  return options
}
