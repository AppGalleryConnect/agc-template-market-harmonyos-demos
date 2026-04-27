import { BaseViewModel, toastUtil } from 'module_base'

@ObservedV2
export class RealNameAuthPageVM extends BaseViewModel {
  private static _instance: RealNameAuthPageVM;
  stack: NavPathStack = new NavPathStack();
  @Trace isShowIdCard1Sheet: boolean = false;
  @Trace isShowIdCard2Sheet: boolean = false;
  @Trace isShowIdCard3Sheet: boolean = false;
  @Trace idCardPic1: string = 'app.media.id_card_pic_1';
  @Trace idCardPic2: string = 'app.media.id_card_pic_2';
  @Trace idCardPic3: string = 'app.media.id_card_pic_3';
  @Trace currentIdx: number | null = null;

  public static get instance() {
    if (!RealNameAuthPageVM._instance) {
      RealNameAuthPageVM._instance = new RealNameAuthPageVM();
    }
    return RealNameAuthPageVM._instance;
  }

  update() {
    toastUtil.showToast('实名成功！')
  }
}
