import { IAddrInfo, RouterMap, sendAddressData } from 'module_base';
import { Context } from './common/Context';
import { Operation } from './common/CommonConst';

@ComponentV2
export struct AddressManage {
  @BuilderParam
  private contentBuilder: () => void = buildEmptyComponent;
  @Param
  public navPathStack: NavPathStack = new NavPathStack();
  @Param
  public isSelectMode: boolean = false;
  @Param
  public route: string = ''
  @Param
  public address: IAddrInfo = sendAddressData
  @Event
  public onSelect: (address: IAddrInfo) => void = () => {
  };
  @Event
  public onBeforeNavigate: () => boolean = () => true;
  private readonly ctx: Context = new Context();

  public aboutToAppear(): void {
    this.ctx.navPathStack = this.navPathStack;
    this.ctx.isSelectMode = this.isSelectMode;
    this.ctx.onSelect = this.onSelect;
    if (this.route) {
      this.ctx.isOnlyEdit = true
    }
  }

  @Monitor('navPathStack', 'isSelectMode', 'onSelect')
  public onAttributeChange(iMonitor: IMonitor): void {
    for (let k of iMonitor.dirty) {
      let v: IMonitorValue<ESObject> | undefined = iMonitor.value<ESObject>(k);
      if (v) {
        switch (k) {
          case 'navPathStack':
            this.ctx.navPathStack = v.now as NavPathStack;
            break;
          case 'isSelectMode':
            this.ctx.isSelectMode = v.now as boolean;
            break;
          case 'onSelect':
            this.ctx.onSelect = v.now as (address: IAddrInfo) => void;
            break;
        }
      }
    }
  }

  public build(): void {
    Column() {
      this.contentBuilder();
    }
    .width('auto')
    .height('auto')
    .onClick(() => {
      if (this.onBeforeNavigate()) {
        if (this.route) {
          this.ctx.editingIAddrInfo = {
            id: this.address.id,
            name: this.address.name,
            phone: this.address.phone,
            countryCode: this.address.countryCode,
            country: this.address.country,
            province: this.address.province,
            city: this.address.city,
            district: this.address.district,
            street: this.address.street,
            detail: this.address.detail,
            isDefault: this.address.isDefault,
            createdAt: this.address.createdAt,
            updatedAt: this.address.updatedAt,
          }
          this.ctx.operation = Operation.EDIT
          this.navPathStack.pushPathByName(this.route, this.ctx);
        } else {
          this.navPathStack.pushPathByName(RouterMap.ADDRESS_MANAGE_PAGE, this.ctx);
        }
      }
    })
  }
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
