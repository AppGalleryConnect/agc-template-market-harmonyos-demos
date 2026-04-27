import { ComponentContent, UIContext } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { Operation } from '../common/CustomTypes';
import { LOG_TAG } from '../common/Constants';
import { AddressDTO } from '../models/AddressDTO';
import { AddressFormSheetPage } from '../pages/AddressFormSheetPage';
import { AddressVM } from '../viewmodels/AddressVM';
import { AddressFormSheetContext } from '../viewmodels/AddressFormSheetContext';


export class AddressFormSheet {
  private uiContext: UIContext;
  private ctx: AddressFormSheetContext = new AddressFormSheetContext();
  private node: ComponentContent<AddressFormSheetContext> | null = null;

  public onAddressListUpdate(callback: () => void): AddressFormSheet {
    this.ctx.onAddressListUpdate = callback;
    return this;
  }

  public onWillDismiss(callback: (reason: DismissReason, hasChange: boolean) => void): AddressFormSheet {
    this.ctx.onWillDismiss = callback;
    return this;
  }

  public onWillSpringBackWhenDismiss(callback: (action: SpringBackAction) => void): AddressFormSheet {
    this.ctx.onWillSpringBackWhenDismiss = callback;
    return this;
  }

  public async openForEdit(address: AddressDTO): Promise<boolean> {
    return this.open(address);
  }

  public async openForCreate(): Promise<boolean> {
    return this.open();
  }

  private async open(address?: AddressDTO): Promise<boolean> {
    if (this.ctx.isOpen || this.node) {
      return false;
    }
    this.ctx.operation = address ? Operation.EDIT : Operation.CREATE;
    this.ctx.title = address ? '编辑地址' : '添加地址';
    this.ctx.address = new AddressVM(address);
    try {
      this.ctx.isOpen = true;
      this.node = new ComponentContent(this.uiContext, wrapBuilder(buildAddressFormSheetPage), this.ctx);
      await this.uiContext.openBindSheet(this.node, {
        height: SheetSize.LARGE,
        preferType: SheetType.CENTER,
        showClose: false,
        enableOutsideInteractive: false,
        onWillDismiss: (action: DismissSheetAction) => {
          this.ctx.onWillDismiss(action.reason, this.ctx.address.hasChanges());
        },
        onWillSpringBackWhenDismiss: (action: SpringBackAction) => this.ctx.onWillSpringBackWhenDismiss(action),
        backgroundColor: $r('sys.color.background_secondary'),
        onTypeDidChange: (type: SheetType) => this.ctx.sheetType = type,
        keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      });
      return true;
    } catch {
      this.ctx.isOpen = false;
      this.node = null;
      return false;
    }
  }

  public close(): void {
    if (this.ctx.isOpen && this.node) {
      this.ctx.isOpen = false;
      this.uiContext.closeBindSheet(this.node)
        .catch((err: BusinessError) => {
          UtilLog.error(LOG_TAG, 'close sheet failed. error: ' + JSON.stringify(err))
        })
        .finally(() => this.node = null);
    }
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.ctx.onWillDismiss = () => this.close();
    this.ctx.close = () => this.close();
  }
}

@Builder
function buildAddressFormSheetPage(ctx: AddressFormSheetContext): void {
  AddressFormSheetPage({ ctx: ctx })
}
