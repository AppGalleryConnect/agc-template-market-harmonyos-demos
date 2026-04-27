import { AddressSelectCard } from 'module_template'
import {
  RouterModule,
  methodList,
  ISetting,
  RouterMap,
  Template,
  EmitterUtils,
  CommonNoticeBar,
  CommonTitle,
} from 'lib_foundation'
import { PurchaseBar } from '../components/PurchaseBar'
import { ExpressPageVM } from '../viewModels/ExpressPageVM'
import { OrderOptionsGroup } from '../components/OrderOptionsGroup'


@Builder
export function ExpressPageBuilder() {
  ExpressPage()
}

@ComponentV2
struct ExpressPage {
  vm: ExpressPageVM = ExpressPageVM.instance;
  refreshTemplate: () => void = () => {
    this.vm.getTemplateList();
  }

  aboutToAppear(): void {
    // 初始化常规模板信息
    this.vm.initCommonTemplate();
    // 获取寄件模板
    this.vm.getTemplateList();
    // 获取寄件人默认填充的地址信息
    this.vm.getSenderDefaultAddress();
    // 获取快递公司列表
    this.vm.getCompanyList();
    // 初始化上门时间
    this.vm.initPickUpTime();
    // 获取最近的服务点
    this.vm.getServicePointList();
    // 订阅模板更新事件
    EmitterUtils.on('refresh_template', this.refreshTemplate);
  }

  aboutToDisappear(): void {
    this.vm.reset();
    EmitterUtils.off('refresh_template', this.refreshTemplate);
  }

  jumpToAuthPage() {
    if (this.vm.userInfoModel.isRealName === 0) {
      RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
    }
  }

  build() {
    NavDestination() {
      Column() {
        CommonTitle({
          title: '寄快递',
        })
        Scroll() {
          Column({ space: 12 }) {
            // 实名认证提示
            if (!this.vm.userInfoModel.isRealName) {
              CommonNoticeBar({
                text: '根据相关法律法规，寄件须实名认证。',
                showIcon: true,
                clickAction: () => {
                  this.jumpToAuthPage();
                }
              })
            }
            // 模板选择
            Row() {
              List({ space: 8, scroller: this.vm.listScroller }) {
                ForEach(this.vm.templateList, (template: Template) => {
                  ListItem() {
                    this.templateItem(template)
                  }
                }, (item: Template) => JSON.stringify(item))
              }
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal)
              .margin({ right: 12 })
              .layoutWeight(1)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

              this.createTemplateBtn()
            }
            .width('100%')

            // 寄/收件人信息
            AddressSelectCard({
              stack: RouterModule.stack,
              userId: this.vm.userInfoModel.id,
              senderInfo: this.vm.senderInfo,
              receiverInfo: this.vm.receiverInfo,
              onChangeSender: () => {
                this.vm.onChangeSenderAddress();
              },
              onChangeReceiver: () => {
                this.vm.onChangeReceiverAddress();
              },
              onExchangeAddress: () => {
                this.vm.onExchangeAddress();
              }
            })

            // 寄件方式
            this.methodBtnList()

            // 订单配置项
            OrderOptionsGroup()
          }
          .width('100%')
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: 8,
            bottom: 16
          })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .layoutWeight(1)
        .align(Alignment.Top)

        PurchaseBar()
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  templateItem(template: Template) {
    Row() {
      Text(template.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .lineHeight(19)
        .fontColor(this.vm.selectedTemplate.id === template.id ? Color.White : $r('sys.color.font_primary'))
    }
    .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    .borderRadius(16)
    .backgroundColor(
      this.vm.selectedTemplate.id === template.id ?
        $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'),
    )
    .onClick(() => {
      this.vm.changeTemplate(template)
    })
  }

  @Builder
  createTemplateBtn() {
    Row({ space: 4 }) {
      Text('添加模板')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .lineHeight(19)
        .fontColor($r('sys.color.font_primary'))
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('sys.color.font_primary')])
    }
    .padding({ left: 16, right: 12, top: 4, bottom: 4 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(16)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.TEMPLATE_PAGE });
    })
  }

  @Builder
  methodBtnList() {
    Row({ space: 12 }) {
      ForEach(methodList, (method: ISetting) => {
        Button() {
          Text(method.text)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.vm.selectedShippingMethod === method.value ? Color.White : $r('sys.color.font_primary'))
            .lineHeight(19)
        }
        .padding({left: 8, right: 8, top: 4, bottom: 4})
        .backgroundColor(this.vm.selectedShippingMethod === method.value ?
          $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.selectedShippingMethod = method.value;
          this.vm.getEstimatedPrice()
        })
      }, (item: ISetting[]) => JSON.stringify(item))
    }
    .width('100%')
  }
}