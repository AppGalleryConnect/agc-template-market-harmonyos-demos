import { CommonTitle, CommonUtil, EmitterUtils, ScanUtil } from 'lib_foundation'
import { OrderListView } from '../components/OrderListView'
import { StateBar } from '../components/StateBar'
import { QueryPageVM } from '../viewModels/QueryPageVM'

@ComponentV2
export struct OrderPage {
  @Param currentTabIndex: number = 0;
  @Local queryDelay: number = 0;
  vm: QueryPageVM = QueryPageVM.instance;
  controller: TextInputController = new TextInputController();
  tabController: TabsController = new TabsController();
  private debouncedQuery = CommonUtil.debounce(() => {
    // 刷新列表
    this.vm.isRefreshing = true;
  });

  @Monitor('currentTabIndex')
  onChangeTabIndex() {
    const delay = Date.now();
    const canQuery = delay - this.queryDelay > 1000;
    if (this.currentTabIndex === 1 && canQuery) {
      // 刷新列表
      this.vm.isRefreshing = true;
    } else {
      this.queryDelay = Date.now();
    }
  }

  aboutToAppear(): void {
    this.queryDelay = Date.now();
    this.vm.queryOrderList(false);

    // 开启监听
    EmitterUtils.on('refreshOrderList', () => {
      // 刷新列表
      this.vm.isRefreshing = true;
    })
  }

  aboutToDisappear(): void {
    EmitterUtils.off('refreshOrderList');
  }

  build() {
    Column() {
      CommonTitle({
        title: '查快递',
        fontSize: 26,
        showBackBtn: false,
      })
      Column() {
        this.searchBtnView()
        StateBar()
        this.listContentView()
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  // 搜索
  @Builder
  searchBtnView() {
    Row() {
      Search({ placeholder: '请输入运单/手机号或扫码查询', controller: this.controller, value: $$this.vm.searchText })
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
        .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
        .layoutWeight(1)
        .defaultFocus(false)
        .enableKeyboardOnFocus(false)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .enterKeyType(EnterKeyType.Search)
        .onChange(() => {
          this.debouncedQuery();
        })

      Button() {
        SymbolGlyph($r('sys.symbol.line_viewfinder'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(async () => {
        const tempCode = await ScanUtil.getScanResult(this);
        this.vm.searchText = tempCode;
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  listContentView() {
    Tabs({ barPosition: BarPosition.Start, controller: this.tabController, index: $$this.vm.selectedIndex }) {
      TabContent() {
        OrderListView({
          list: this.vm.sendOrderList,
          index: 0,
        })
      }
      TabContent() {
        OrderListView({
          list: this.vm.receiveOrderList,
          index: 1,
        })
      }
      TabContent() {
        OrderListView({
          list: this.vm.pendingPayOrderList,
          index: 2,
        })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .barHeight(0)
    .scrollable(false)
  }
}