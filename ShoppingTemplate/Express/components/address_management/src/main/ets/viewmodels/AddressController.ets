import { UtilLog } from '@hw-agconnect/util-log';
import { AddressDTO } from '../models/AddressDTO';
import { AddressVM } from './AddressVM';

@ObservedV2
export class AddressController {
  // ── 响应式状态（View 订阅这些字段驱动渲染）──
  @Trace addressList: AddressVM[] = [];
  // 定义钩子：由外部实现具体的逻辑
  onLoadAddress?: () => Promise<AddressVM[]>;
  onAddAddress?: (item: AddressDTO) => Promise<boolean>;
  onDeleteAddress?: (addressId: number) => Promise<boolean>;
  onModifyAddress?: (address: AddressDTO, isSetDefault?: boolean) => Promise<boolean>;

  async loadAddress(): Promise<void> {
    if (!this.onLoadAddress) {
      return;
    }
    try {
      this.addressList = await this.onLoadAddress();
    } catch (e) {
      UtilLog.error(`[AddressController] onLoadAddress failed: ${JSON.stringify(e)}`);
    }
  }
}