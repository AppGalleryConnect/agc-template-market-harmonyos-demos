import { TextReader } from '@kit.SpeechKit';
import { Constant, PageUtil } from 'common';
import { CustomShareParams } from 'module_base';
import { OrderPageVM } from 'order';
import { TabBarData, TABS_INFO } from '../model/TabBarInfo';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { AppStorageV2 } from '@kit.ArkUI';
import { connection } from '@kit.NetworkKit';

@Builder
export function MainBuilder() {
  Main();
}

@ComponentV2
struct Main {
  orderVm: OrderPageVM = OrderPageVM.instance;
  vm: MainEntryVM = MainEntryVM.instance;
  tabController: TabsController = new TabsController();
  @Provider('homeTabIndex') homeTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local shareRouter: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  public netConnection: connection.NetConnection | undefined = undefined;
  private JUDGE_NET_TAG: string = 'this.currNet.isUseful';

  @Monitor('shareRouter.id')
  onShareClick() {
    if (this.shareRouter.id) {
      this.mainPathStack.pushPathByName(this.shareRouter.pageName, this.shareRouter.goodId);
    }
  }

  aboutToAppear() {
    this.register()
    this.onShareClick();
    this.vm.init(this.getUIContext());
  }

  onPageShow(): void {
    let pageInfo = PageUtil.getPageInfo();
    if (pageInfo.index !== 0) {
      this.homeTabIndex = pageInfo.index;
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
  mainTabBar(title: ResourceStr, targetIndex: number, selectedImg: ResourceStr, normalImg: ResourceStr) {
    Column({ space: 4 }) {
      Image(this.homeTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 });
      Text(title)
        .fontSize(10)
        .fontColor(this.homeTabIndex === targetIndex ? '#64BB5C' :
          Color.Black)
        .opacity(this.homeTabIndex === targetIndex ? 1 : 0.6);
    }.onClick(() => {
      this.homeTabIndex = targetIndex;
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Tabs({ index: $$this.homeTabIndex }) {
        ForEach(TABS_INFO, (item: TabBarData) => {
          TabContent() {
            item.component.builder();
          }.tabBar(this.mainTabBar(item.title, item.id, item.activeIcon, item.defaultIcon));
        }, (item: TabBarData) => JSON.stringify(item));
      }
      .padding({ bottom: this.windowBottomHeight })
      .scrollable(false)
      .animationDuration(0)
      .barPosition(BarPosition.End)
      .onChange(() => {
        TextReader.stop().then(() => {
          TextReader.release();
        });
      });
    }.hideTitleBar(true)
  }
}