import { AppStorageBank, IUserInfo } from 'module_base';
import { AccountUtil } from '@agctemplate/widgets'
import { UserInfo } from 'live_interaction'

@ObservedV2
export class RealNameAuthPageVM {
  private static _instance: RealNameAuthPageVM;
  stack: NavPathStack = new NavPathStack();
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo()
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

  update(data: IUserInfo, uiContext: UIContext) {
    AppStorageBank.updateUserInfo(data)
    uiContext.getPromptAction().showToast({ message: '实名成功！' })
  }
}
