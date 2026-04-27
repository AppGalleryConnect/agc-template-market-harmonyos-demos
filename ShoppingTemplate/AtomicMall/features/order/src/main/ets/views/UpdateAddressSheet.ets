import { routerStack } from 'lib_foundation'
import { AddressInfo } from 'lib_network'
import { buildUpdateAddressPage, UpdateAddressPageOptions } from 'lib_widget'
import { OrderUtil } from '../utils/OrderUtil'
import { AddressDTO, AddressManageUtil } from 'address_management'

export interface UpdateAddressSheetOptions {
  originalAddress?: AddressInfo
  orderNo: string
  handleSubmitSuccess: () => void
}

@Builder
export function buildUpdateAddressSheet() {
  buildUpdateAddressPage()
}

export function buildOrderAddressSheetOptions(param: UpdateAddressSheetOptions): UpdateAddressPageOptions {
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
      OrderUtil.handleUpdateAddress({
        orderNo: param.orderNo,
        callback: () => {
          param.handleSubmitSuccess()
        },
        data: newAddress,
      })
    },
  }
  return options
}
