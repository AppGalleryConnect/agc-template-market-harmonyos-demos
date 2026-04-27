/**
 * @usage: 常用信息页面，管理用户的常用旅客、地址、发票抬头信息，支持添加、编辑、删除常用信息
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件和tab切换栏，下方是对应类型的信息列表
 * @constraints: currentIndexTab控制当前显示的信息类型（旅客、地址、发票抬头）；passengerList和
 * myInvoiceList分别管理旅客和发票数据
 * @isGen: true
 * @fileType: page
 * @zhName: 常用信息
 * @domain: 旅游
 * @image: screenshots/person/CommonInfo.jpg
 * @component: CommonHeader,CommonPeopleList,CommonInfoList,InvoiceListComp
 */
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BarVM, CommonHeader, Constants, TValueType,
} from 'common';
import { InvoiceList, InvoiceListComp } from 'travel_invoice';
import { OHPage, phoneRouterControl } from 'oh_router';
import { CommonInfoList } from '../comp/CommonInfoList';
import { MyPassengerList } from 'common_travel_guide';
import { CommonPeopleList } from '../comp/CommonPeopleList'

@Builder
export function CommonInfoPageBuilder(params: TValueType) {
  CommonInfoPage({
    pageParam: params
  });
}

phoneRouterControl.registerPageBuilder('CommonInfoPage', wrapBuilder(CommonInfoPageBuilder))

@ComponentV2
export struct CommonInfoPage {
  @Param pageParam?: TValueType = null
  @Local passengerList: MyPassengerList = PersistenceV2.connect(MyPassengerList, () => new MyPassengerList())!
  @Local myInvoiceList: InvoiceList = AppStorageV2.connect(InvoiceList, () => new InvoiceList())!
  @Local currentIndexTab: number = Constants.TAB_INDEX_ZERO;

  aboutToAppear() {
    this.currentIndexTab = this.pageParam as number ?? Constants.TAB_INDEX_ZERO
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontColor(this.currentIndexTab === index ? '#000' : 'rgba(0, 0, 0, 0.50)')
      if (this.currentIndexTab === index) {
        Row().width(12).height(3).borderRadius(2).backgroundColor('#333')
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 10, bottom: 4 })
    .height(37)
    .onClick(() => {
      this.currentIndexTab = index;
    })
  }

  @Builder
  tabContentBuilder(index: number) {
    Scroll() {
      if (index === Constants.TAB_INDEX_TWO) {
        InvoiceListComp({
          invoiceList: this.myInvoiceList,
          routerModule: phoneRouterControl.getRouter()
        })
      } else if (index === Constants.TAB_INDEX_ZERO) {
        CommonPeopleList()
      } else {
        CommonInfoList({ currentIndex: index })
      }
    }
    .layoutWeight(1)
    .padding({ bottom: BarVM.instance.aiBarH })
    .width('100%')
    .align(Alignment.TopStart)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .zIndex(index === this.currentIndexTab ? 999 : 0)
    .visibility(index === this.currentIndexTab ? Visibility.Visible : Visibility.Hidden)
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '常用信息',
        backgroundColorParam: '#F1F3F5',
        onReturnClick: () => {
          phoneRouterControl.popPage({
            popData: this.passengerList.list
          });
        },
      })
        .padding({ left: 16, right: 16 })

      Row({ space: 24 }) {
        this.tabBuilder('旅客', Constants.TAB_INDEX_ZERO)
        this.tabBuilder('地址', Constants.TAB_INDEX_ONE)
        this.tabBuilder('发票抬头', Constants.TAB_INDEX_TWO)
      }
      .padding({ left: 16, right: 16 })
      .height(37)
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Stack() {
        this.tabContentBuilder(Constants.TAB_INDEX_ZERO)
        this.tabContentBuilder(Constants.TAB_INDEX_ONE)
        this.tabContentBuilder(Constants.TAB_INDEX_TWO)
      }
      .padding({ left: 16, right: 16, top: 12 })
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.TopStart)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      OHPage({
        childBuilder: () => {
          this.render();
        },
        isFullScreen: true,
        pageBackgroundColor: '#F1F3F5'
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage({
        popData: this.passengerList.list
      });
      return true
    })
  }
}

