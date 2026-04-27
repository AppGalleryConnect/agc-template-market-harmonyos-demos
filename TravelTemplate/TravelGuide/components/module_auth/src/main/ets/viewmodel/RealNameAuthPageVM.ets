import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { AppStorageBank, IUserInfo, UserInfo } from 'module_base';

@ObservedV2
export class RealNameAuthPageVM {
  private static _instance: RealNameAuthPageVM;
  stack: NavPathStack = new NavPathStack();
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
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

  update(data: IUserInfo) {
    AppStorageBank.updateUserInfo(data)
    promptAction.showToast({ message: '实名成功！' })
  }
}
