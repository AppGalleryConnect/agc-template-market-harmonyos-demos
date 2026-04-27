import { ViewModelState as State, LoadMode } from '../common/CommonConst';
import { Api } from '../http/Api';
import { IAddrInfo } from 'module_base';
import { AddressVM } from './AddressVM';

@ObservedV2
export class AddressMgrVM {
  @Trace
  public list: AddressVM[] = [];
  @Trace
  public state: State = State.UNINITIALIZED;
  @Trace
  public isLoading: boolean = false;

  public initialize(): void {
    if (
      (this.state === State.UNINITIALIZED ||
        this.state === State.INIT_FAILED) &&
        !this.isLoading
    ) {
      this.isLoading = true;
      this.state = State.UNINITIALIZED;
      this.loadAddressList(LoadMode.INIT);
    }
  }

  public create(
    dto: IAddrInfo,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    if (!this.isLoading) {
      this.isLoading = true;
      Api.createAddress(dto)
        .then(() => {
          this.loadAddressList(LoadMode.REFRESH, onSuccess, onError);
        })
        .catch(() => {
          this.isLoading = false;
          if (onError) {
            onError()
          }
        });
    }
  }

  public delete(
    id: string,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    if (!this.isLoading) {
      this.isLoading = true;
      Api.deleteAddress(id)
        .then(() => {
          this.loadAddressList(LoadMode.REFRESH, onSuccess, onError);
        })
        .catch(() => {
          this.isLoading = false;
          if (onError) {
            onError()
          }
        });
    }
  }

  public update(
    dto: IAddrInfo,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    if (!this.isLoading) {
      this.isLoading = true;
      Api.updateAddress(dto)
        .then(() => {
          this.loadAddressList(LoadMode.REFRESH, onSuccess, onError);
        })
        .catch(() => {
          this.isLoading = false;
          if (onError) {
            onError()
          }
        });
    }
  }

  updateDefaultAddress(address: AddressVM, id: string, isDefault: boolean) {
    if (isDefault) {
      this.list.forEach((item) => {
        if (item.id !== id) {
          item.isDefault = false
        }
      });
    }
    Api.updateDefaultAddress(address.toDTO())
    this.loadAddressList(LoadMode.REFRESH)
  }

  private loadAddressList(
    mode: LoadMode,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    Api.listAddresses()
      .then((data: IAddrInfo[]) => {
        this.list = data.map((dto) => {
          const address: AddressVM = new AddressVM();
          address.assignFromDTO(dto);
          return address;
        });
        this.state = State.READY;
        if (onSuccess) {
          onSuccess()
        }
      })
      .catch(() => {
        if (mode === LoadMode.INIT) {
          this.state = State.INIT_FAILED;
        }
        if (onError) {
          onError()
        }
      })
      .finally(() => (this.isLoading = false));
  }
}
