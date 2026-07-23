import { MediaQuery } from '@kit.ArkUI';
import { AccountUtil, FLAG_SHOW_ADS, RouterMap, RouterModule, SafeUtil, WindowUtil } from 'lib_foundation';
import { BreakpointUtils, FontUtil } from 'module_weather_core';

@ObservedV2
export class IndexVM {
  private breakpointUtils?: BreakpointUtils;
  @Trace public showAd: boolean = FLAG_SHOW_ADS;

  public async init() {
    WindowUtil.initWindowUtil().then(() => {
      WindowUtil.setFullWindow();
    });
    AccountUtil.setUserInfo();
    FontUtil.setFontInfo();
  }

  public registerBreakpoint(mediaQuery: MediaQuery): void {
    this.breakpointUtils = new BreakpointUtils(mediaQuery);
    this.breakpointUtils.register();
  }

  public unRegisterBreakpoint(): void {
    this.breakpointUtils?.unRegister();
  }

  public checkSafeAgreed() {
    if (SafeUtil.getAgreed()) {
      RouterModule.push({ url: this.showAd ? RouterMap.SPLASH_AD : RouterMap.MAIN })
      return;
    }
    RouterModule.push({ url: RouterMap.SAFE })
  }
}
