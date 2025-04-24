@ObservedV2
export class AddressInfo {
  id: string = '';
  @Trace name: string = '';
  @Trace phone: string = '';
  @Trace district: string = '';
  @Trace detail: string = '';
  @Trace type: number = 0;
}

export class AddressList extends Array<AddressInfo> {
}

