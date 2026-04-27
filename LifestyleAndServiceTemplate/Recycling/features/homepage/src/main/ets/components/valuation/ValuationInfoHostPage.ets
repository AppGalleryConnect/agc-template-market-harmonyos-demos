import { BuildValuationInfoPageBuilder } from 'valuation_information'
import { phoneRouterControl, NavPageInfo } from 'oh_router'
import { Constants, RouterMap } from 'common'
import { OrderSubmitPageBuilder } from './OrderSubmitPage';

/**
 * @usage: 估价信息填写宿主页面，承载 valuation_information 组件的 BuildValuationInfoPageBuilder，用于填写设备属性和功能情况后提交估价
 * @layout: 页面采用垂直布局（Column），内部嵌入 BuildValuationInfoPageBuilder 组件
 * @constraints: 提交前需填写必选项（手机：保修期、容量、颜色；电脑：内存、硬盘类型、处理器）
 * @isGen: true
 * @fileType: page
 * @zhName: 估价信息填写页面
 * @subPage: OrderSubmitPage
 * @component: BuildValuationInfoPageBuilder
 * @image: screenshots/homepage/valuationInfoHost.png
 */

interface SelectionPair {
  title: string;
  value: string
}

interface SubmitData {
  modelName: string;
  imageSrc?: ResourceStr;
  deviceType: string;
  price: number;
  selections: SelectionPair[]
}

interface HostParams {
  modelName: string;
  imageSrc: ResourceStr;
  deviceType?: string
}

interface OrderParams {
  modelName: string;
  imageSrc?: ResourceStr;
  deviceType?: string;
  price?: number;
  selections?: SelectionPair[]
}

@Builder
export function ValuationInfoHostPageBuilder(params: object) {
  ValuationInfoHostPage({ params: params as HostParams })
}

@ComponentV2
export struct ValuationInfoHostPage {
  @Param params: HostParams = { modelName: '', imageSrc: $r('app.media.image_demo_phone3'), deviceType: 'phone' }

  build() {
    NavDestination() {
      Column() {
        BuildValuationInfoPageBuilder({
          modelName: this.params.modelName,
          imageSrc: this.params.imageSrc,
          deviceType: this.params.deviceType,
          onBack: () => phoneRouterControl.popPage(),
          onSubmit: (data: SubmitData) => {
            const requiredTitles =
              data.deviceType === 'computer' ? ['内存', '硬盘类型', '处理器'] : ['保修期', '容量', '颜色']
            const selectedTitles = new Set(data.selections?.map(s => s.title) ?? [])
            for (let t of requiredTitles) {
              if (!selectedTitles.has(t)) {
                this.getUIContext().getPromptAction().showToast({ message: `请选择${t}必选项！` })
                return
              }
            }
            const orderParam: OrderParams = {
              modelName: data.modelName,
              imageSrc: data.imageSrc,
              deviceType: data.deviceType,
              price: data.price,
              selections: data.selections,
            }
            const orderPage: NavPageInfo = {
              pageName: RouterMap.VALUATION_ORDER_PAGE,
              builder: wrapBuilder(OrderSubmitPageBuilder),
              param: orderParam,
            }
            phoneRouterControl.jumpPage(orderPage)
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideToolBar(true).title('填写估价信息').padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
