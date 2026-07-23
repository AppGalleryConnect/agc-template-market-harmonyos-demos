import { AppStorageV2 } from '@kit.ArkUI';
import { agreeDialogBuilder, PopViewUtils, RouterMap, RouterModule, SafeUtil } from 'lib_foundation';
import { BreakpointModel } from 'module_weather_core';

@ObservedV2
export class SafeVM {
  @Trace breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get pagePadding(): number {
    return this.breakpointModel.pagePadding;
  }

  public privacyClick() {
    RouterModule.push({ url: RouterMap.PRIVACY_POLICY });
  }

  public agreeBtnClick() {
    SafeUtil.setAgreed();
  }

  public cancelBtnClick() {
    PopViewUtils.showPopView(wrapBuilder(agreeDialogBuilder), { alignment: DialogAlignment.Center })
  }
}
