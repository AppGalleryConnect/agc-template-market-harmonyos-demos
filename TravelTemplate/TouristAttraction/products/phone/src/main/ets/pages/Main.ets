import { AppStorageV2 } from '@kit.ArkUI';
import { connection } from '@kit.NetworkKit';
import { TextReader } from '@kit.SpeechKit';
import { AppBaseModel } from 'common';
import { OrderType } from 'mine/src/main/ets/model/OrderTypeInfo';
import { CustomShareParams } from 'module_base';
import { OrderPageVM } from 'order';
import { Page, TabBarType } from 'types';
import { TabBarData, TABS_INFO } from '../model/TabBarInfo';
import { MainEntryVM } from '../viewmodel/MainEntryVM';

@Builder
export function MainBuilder() {
  Main();
}

@ComponentV2
struct Main {
  orderVm: OrderPageVM = OrderPageVM.instance;
  vm: MainEntryVM = MainEntryVM.instance;
  tabController: TabsController = new TabsController();
  @Local appBaseModel: AppBaseModel = AppStorageV2.connect(AppBaseModel, () => new AppBaseModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local shareRouter: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  @Local page: Page = AppStorageV2.connect(Page, 'Page', () => new Page())!;
  public netConnection: connection.NetConnection | undefined = undefined;
  private JUDGE_NET_TAG: string = 'this.currNet.isUseful';

  @Monitor('shareRouter.id')
  onShareClick() {
    if (this.shareRouter.id) {
      this.mainPathStack.pushPathByName(this.shareRouter.pageName, this.shareRouter.goodId);
    }
  }

  aboutToAppear() {
    this.register();
    this.onShareClick();
    this.vm.init(this.getUIContext());
    this.pageChange();
  }

  @Monitor('page.time')
  pageChange(): void {
    this.appBaseModel.mainTabIndex = this.page.index;
    if (this.page.index === TabBarType.MINE) {
      this.mainPathStack.pushPathByName('OrderView', OrderType.TICKET);
    } else if (this.page.index === TabBarType.TICKET) {
      let currentName: string[] = this.mainPathStack.getAllPathName();
      if (currentName.length && currentName[currentName.length - 1] !== 'Main') {
        this.mainPathStack.popToName('Main');
      }
    }
  }

  register() {
    if (this.netConnection === undefined) {
      this.init();
    }
  }

  init() {
    this.netConnection = connection.createNetConnection();
    this.netConnection.register(() => {
      console.info('connection register success');
    });

    this.netConnection.on('netAvailable', (data) => {
      console.info('this  netAvailable ');
      AppStorage.setOrCreate(this.JUDGE_NET_TAG, this.judgeHasNet());
    });

    this.netConnection.on('netUnavailable', () => {
      console.info('this  netUnavailable ');
      AppStorage.setOrCreate(this.JUDGE_NET_TAG, this.judgeHasNet());
    });

    this.netConnection.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      AppStorage.setOrCreate(this.JUDGE_NET_TAG, this.judgeHasNet());
    });

    this.netConnection.on('netLost', () => {
      AppStorage.setOrCreate(this.JUDGE_NET_TAG, this.judgeHasNet());
    });
  }

  judgeHasNet(): boolean {
    try { // Get current network connection
      let netHandle = connection.getDefaultNetSync();

      // 0-100 Reserved connections for the system
      if (!netHandle || netHandle.netId < 100) {
        return false;
      }

      // Get the properties of the connection
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap;
      if (!cap) {
        return false;
      }

      for (let em of cap) {
        if (connection.NetCap.NET_CAPABILITY_VALIDATED === em) {
          return true;
        }
      }
    } catch (e) {
      let err = e as BusinessError;
      console.info('get netInfo error ：' + JSON.stringify(err));
    }
    return false;
  }

  @Builder
  mainTabBar(title: ResourceStr, targetIndex: number, selectedImg: ResourceStr, normalImg: Resource) {
    Column({ space: 4 }) {
      SymbolGlyph(normalImg)
        .fontSize(24)
        .width(24)
        .height(24)
        .fontColor(
          this.appBaseModel.mainTabIndex === targetIndex ? [$r('sys.color.multi_color_04')] :
            [$r('sys.color.icon_secondary')]);
      Text(title)
        .fontSize(10)
        .fontColor(this.appBaseModel.mainTabIndex === targetIndex ? '#64BB5C' : Color.Black)
        .opacity(this.appBaseModel.mainTabIndex === targetIndex ? 1 : 0.6);
    }
    .onClick(() => {
      this.appBaseModel.mainTabIndex = targetIndex;
    })
    .width(this.vm.tabWidth)
    .padding({
      top: 5,
      bottom: this.vm.isTabVertical ? 5 : 5 + this.vm.windowBottomHeight,
      left: 4,
      right: 4,
    })
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Tabs({ index: this.appBaseModel.mainTabIndex }) {
        ForEach(TABS_INFO, (item: TabBarData) => {
          TabContent() {
            item.component.builder();
          }.tabBar(this.mainTabBar(item.title, item.id, item.activeIcon, item.defaultIcon));
        }, (item: TabBarData) => JSON.stringify(item));
      }
      .barWidth(this.vm.tabWidth)
      .barHeight(this.vm.tabBarHeight)
      .vertical(this.vm.isTabVertical)
      .scrollable(false)
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .barOverlap(!this.vm.isTabVertical)
      .barPosition(this.vm.barPosition)
      .backgroundColor('rgba(241, 243, 245, 0.8)')
      .divider(this.vm.showDivider)
      .onChange(() => {
        TextReader.stop().then(() => {
          TextReader.release();
        });
      });
    }.hideTitleBar(true);
  }
}