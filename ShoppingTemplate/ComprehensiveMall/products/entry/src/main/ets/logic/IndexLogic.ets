import { TabSwiperViewData } from '@components/tabswiper';
import { CartDto, ComponentEntry, LoadingStatus, UserDto } from '@common/customtypes';
import { Config } from '@common/const';
import { client } from '@common/network';
import { iData } from '@common/data';
import { buildIconTextTab, IconTextTabLogic } from '@guis/tabs';

import { BusinessError } from '@ohos.base';
import HashMap from '@ohos.util.HashMap';
import authentication from '@hms.core.authentication';

import { IndexData, TabSwiperDataItem } from '../datas/IndexData';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class IndexLogic {

  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;

  @Trace
  public tabSwiperViewData: TabSwiperViewData = [];

  @Trace
  public barBackgroundColor: ResourceColor = Color.Transparent;

  @Trace
  public barBackgroundBlurStyle: BlurStyle = BlurStyle.COMPONENT_ULTRA_THICK;

  @Trace
  public initialIndex: number = 0;

  private tabLogicMap: HashMap<string, IconTextTabLogic> = new HashMap();

  private tabActiveId: string = '';

  private load = (): void => {
    if (iData.local.userToken) {
      client.user.loginByToken(iData.local.userToken)
        .then((user: UserDto) => {
          iData.global.isLogin = true;
          iData.global.nickname = user.nickname;
          iData.global.phone = user.maskedPhoneNumber;
          client.cart.getCartData().then((cartDto: CartDto) => {
            iData.global.cartVersion = cartDto.version;
            iData.global.cartTotal = cartDto.total;
          });
        })
        .catch(() => {
          iData.global.isLogin = false;
        })
        .finally(() => {
          this.initTabSwiper();
          this.loadingStatus = LoadingStatus.SUCCESS;
        })
    } else {
      this.initTabSwiper();
      this.loadingStatus = LoadingStatus.SUCCESS;
    }
  }

  private initTabSwiper(): void {
    let maxPriority: number = 0;
    for (let i: number = 0; i < IndexData.STATIC_TAB_SWIPER_DATA.length; i++) {
      const item: TabSwiperDataItem = IndexData.STATIC_TAB_SWIPER_DATA[i];
      this.registerTabLogic(item);
      if (item.priority > maxPriority) {
        maxPriority = item.priority;
        this.tabActiveId = item.id;
        this.initialIndex = i;
      }
      this.pushTabSwiperViewData(item);
    }
    if (this.tabActiveId !== '') {
      this.onTabSwiperChange(this.initialIndex, this.tabActiveId);
    }
  }

  private registerTabLogic(item: TabSwiperDataItem): void {
    const tabLogic: IconTextTabLogic = new IconTextTabLogic();
    tabLogic.setModel(item.tabModel);
    this.tabLogicMap.set(item.id, tabLogic);
  }

  private pushTabSwiperViewData(item: TabSwiperDataItem): void {
    const tabLogic: IconTextTabLogic = this.tabLogicMap.get(item.id);
    if (tabLogic) {
      this.tabSwiperViewData.push({
        id: item.id,
        tab: new ComponentEntry(wrapBuilder(buildIconTextTab), [tabLogic]),
        tabContent: new ComponentEntry(item.contentWarpBuilder, [])
      });
    }
  }

  public onTabSwiperChange = (_: number, id: string): void => {
    iData.global.rootPageActiveTabId = id;
    this.tabLogicMap.get(this.tabActiveId)?.setSelected(false);
    this.tabActiveId = id;
    this.tabLogicMap.get(this.tabActiveId).setSelected(true);
    if (id === Config.HOME_PAGE_ID) {
      this.barBackgroundColor = Color.Transparent;
      this.barBackgroundBlurStyle = BlurStyle.COMPONENT_ULTRA_THICK;
    } else {
      this.barBackgroundColor = Color.White;
      this.barBackgroundBlurStyle = BlurStyle.NONE;
    }
  }

  constructor() {
    client.user.huaweiLogin()
      .then((res: authentication.LoginWithHuaweiIDResponse) => {
        const credential: authentication.LoginWithHuaweiIDCredential | undefined = res.data;
        if (!credential) {
          throw new Error();
        }
      })
      .catch((_: BusinessError | Error) => {
        if (Config.IS_DEV) {
          promptAction.showToast({ message: 'error: 静默登录失败' });
        }
      })
      .finally(() => {
        this.load();
      })
  }
}
