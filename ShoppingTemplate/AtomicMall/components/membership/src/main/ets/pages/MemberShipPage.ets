import { iap } from '@kit.IAPKit';
import { ComponentContent } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BreakpointSystem } from 'module_ui_base';
import { HintParam, MemberList, MemberParams, MemberShipPrivilege, Privacy, ProductInfo } from '../model/Index';
import { MemberShipVM } from '../viewmodel/MemberShipVM';
import { MemberPrivacy } from '../component/MemberPrivacy';
import { privacyCheckHint } from '../component/PrivacyCheckHint';

@Preview
@ComponentV2
export struct MemberShipPage {
  vm: MemberShipVM = MemberShipVM.instance;
  @Local privacy: Privacy = new Privacy();
  @Local cardWidth: number = 0;
  @Local avoidHeight: number = 0;
  @Param linearColors: Array<[
    ResourceColor,
    number
  ]> = [['#FFFFFF', 0.0], ['#E5EDF5', 0.5], ['#0A59F7', 1.0]];
  @Local showBlur: boolean = false
  @Param themeColor: ResourceStr = $r('app.color.theme_color');
  @Param routerModule: NavPathStack = new NavPathStack();
  @Param isSheet: boolean = false;
  @Param productsInfo: ProductInfo[] = [];
  @Param privacyContent: string = '';
  @Param lastPurchaseProductExpireTime: string = 'xxxx-xx-xx';
  @Event subscribeCallBack: (params: MemberParams) => Promise<void> = () => new Promise(() => {
  });
  @Event ownedMemberCallBack: (list: MemberList) => Promise<void> = () => new Promise(() => {
  });
  @Event queryExpireTime: (productId: string, time?: number) => Promise<void> = () => new Promise(() => {
  });
  private privacyCheckNode?: ComponentContent<Object>;
  private uiContext: UIContext = this.getUIContext();
  private scroller: Scroller = new Scroller()

  @Computed
  get memberStatus() {
    let member = '';
    let product: iap.Product | undefined;
    if (this.vm.isMember) {
      if (this.vm.isRenewMember) {
        product = this.vm.productInfoList.find(item => item.id === this.vm.renewProductId);
      } else {
        product = this.vm.productInfoList.find(item => item.id === this.vm.nonRenewProductId);
      }
      if (product) {
        member = `（${product?.name}）` ?? '';
      }
    }
    return member;
  }

  @Computed
  get renewMemberSubscribedStatus() {
    if (this.vm.isRenewMember &&
      (this.vm.productInfoList[this.vm.selectedProductIndex]?.type ?? iap?.ProductType.NONRENEWABLE) ===
      iap?.ProductType.AUTORENEWABLE) {
      return false;
    }
    return true;
  }

  @Computed
  get privilegeByProductId() {
    let product =
      this.productsInfo.find(item => item.productId === this.vm.productInfoList[this.vm.selectedProductIndex]?.id ?? 0);
    return product?.privileges ?? [];
  }

  @Computed
  get autoRenewPrivacy() {
    let product =
      this.productsInfo.find(item => (item.productId === this.vm.productInfoList[this.vm.selectedProductIndex]?.id) &&
        (item.type === iap.ProductType.AUTORENEWABLE));
    return [product?.privacyName, product?.privacyContent].filter((item) => item) ?? [];
  }

  async aboutToAppear(): Promise<void> {
    this.vm.queryPurchase();
    this.vm.queryProducts(this.productsInfo);
    this.privacyCheckNode =
      new ComponentContent(this.uiContext, wrapBuilder<[HintParam]>(privacyCheckHint),
        { node: this.privacyCheckNode!!, uiContext: this.uiContext } as HintParam);
    this.vm.uiContext = this.uiContext;
    this.vm.setEvent(this.subscribeCallBack, this.queryExpireTime, this.ownedMemberCallBack);
    this.avoidHeight =
      await this.vm.getWindowAvoidArea(this.getUIContext().getHostContext() as common.UIAbilityContext);
  }

  @Builder
  Operation() {
    if (!this.isSheet) {
      Row({ space: 8 }) {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .fontWeight(FontWeight.Normal);
        }
        .width(40)
        .height(40)
        .margin({ right: 8 })
        .type(ButtonType.Circle)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => this.routerModule.pop());

        Text('会员中心').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'));
      }
      .position({ left: 0, right: 0 })
      .padding({ bottom: 12, left: 16 })
      .zIndex(2)
      .backgroundBlurStyle(this.showBlur ? BlurStyle.Thin : BlurStyle.NONE,
        { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }
  }

  @Builder
  Owned() {
    RelativeContainer() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .size({ height: '100%', width: '100%' })
          .linearGradient({
            direction: GradientDirection.Right, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: this.linearColors, // 数组末尾元素占比小于1时满足重复着色效果
          })
          .borderRadius({ bottomLeft: 16, bottomRight: 16 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

        Image($r('app.media.member'))
          .size({ height: 100, width: 100 })
          .rotate({ angle: 15 })
          .margin({ right: 24, top: 12 });
      }
      .linearGradient({
        direction: GradientDirection.Right, // 渐变方向
        repeating: false, // 渐变颜色是否重复
        colors: this.linearColors, // 数组末尾元素占比小于1时满足重复着色效果
      })
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      .id('bg')
      .height(BreakpointSystem.isTablet ? 120 : 150)

      Row() {
        Column({ space: 8 }) {
          Text() {
            Span(this.vm.isMember ? 'VIP会员' : '非会员')
              .fontSize(18)
              .fontColor($r('sys.color.font_primary'));
            Span(this.memberStatus).fontSize(14).fontColor($r('sys.color.font_secondary'));
          };

          Text(this.vm.isMember ?
            (this.vm.isRenewMember ? `${this.vm.getFormatTime(this.vm.expiresTime)}到期` :
              `${this.lastPurchaseProductExpireTime}到期`) :
            '购买并开通会员后可查看有效期')
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'));
        }.width('calc(100% - 84vp)').alignItems(HorizontalAlign.Start);

        Button(this.vm.isMember ? '会员管理' : '暂未开通')
          .fontColor(this.vm.isMember ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_primary'))
          .backgroundColor(this.vm.isMember ? this.themeColor :
            $r('sys.color.comp_background_tertiary'))
          .fontSize($r('sys.float.Body_S'))
          .size({ height: 28 })
          .onClick(() => {
            if (this.vm.isMember) {
              this.vm.manageSubscribe(this.getUIContext().getHostContext() as common.UIAbilityContext);
            }
          });
      }
      .borderRadius(16)
      .padding(12)
      .width('calc(100% - 32vp)')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .constraintSize({ maxWidth: 560 })
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        center: { anchor: 'bg', align: VerticalAlign.Bottom },
      })
    }
    .width('100%')
    .height('auto')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  Plan() {
    Column({ space: 12 }) {
      Text('会员套餐')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start);
      List({ space: 8 }) {
        if (this.vm.productInfoList.length) {
          ForEach(this.vm.productInfoList, (item: iap.Product, index: number) => {
            ListItem() {
              Stack() {
                Image($r('app.media.img_member_bg'))
                  .width('100%')
                  .objectFit(ImageFit.Cover)

                Row() {
                  Text(item.name)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.font_color_level1_invert'))
                    .fontSize(18)
                    .maxLines(2)
                    .fontWeight(FontWeight.Medium)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ right: 16 })
                  Text(`${item.localPrice?.split('.')[0]}`)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(24)
                    .fontColor($r('app.color.font_color_level1_invert'));
                  Blank()
                  Image($r('app.media.ic_member'))
                    .width(48)
                    .height(48)
                }
                .width('100%')
                .padding(16)
              }
              .borderRadius(16)
              .height(72)
              .clip(true)
              .onClick(() => {
                this.vm.selectedProductIndex = index;
              });
            };
          }, (item: iap.Product) => item.id);
        } else {
          ListItem() {
            Column() {
              Image($r('app.media.ic_search_empty'))
                .height(48)
                .margin({ bottom: 4 })
              Text('暂无数据')
                .fontSize(14)
                .fontColor($r('app.color.font_color_level2'))
            }
            .alignItems(HorizontalAlign.Center)
            .padding(12)
            .backgroundColor($r('sys.color.background_primary'))
            .width('100%')
            .borderRadius(16)
          }
        }
      }
      .height('auto')
      .listDirection(Axis.Horizontal)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .margin({ top: this.isSheet ? 12 : 24 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .constraintSize({ maxWidth: 560 })
  }

  @Builder
  Privilege() {
    Column({ space: 16 }) {
      Text('会员权益')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start);
      List({ space: 24 }) {
        if (this.privilegeByProductId.length) {
          ForEach(this.privilegeByProductId, (item: MemberShipPrivilege) => {
            ListItem() {
              Row({ space: 8 }) {
                Image(item.icon).size({ width: 40, height: 40 });

                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontColor($r('app.color.font_color_level1'))
                  Text(item.des)
                    .fontSize(14)
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontColor($r('app.color.font_color_level2'))
                }.alignItems(HorizontalAlign.Start).width('calc(100% - 48vp)');
              }.width('100%');
            };
          }, (item: MemberShipPrivilege) => item.id);
        } else {
          ListItem() {
            Column() {
              Image($r('app.media.ic_search_empty'))
                .height(72)
                .margin({ bottom: 4 })
              Text('暂无数据')
                .fontSize(14)
                .fontColor($r('app.color.font_color_level2'))
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
        }
      }
      .padding(12)
      .scrollBar(BarState.Off)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
    }
    .margin({ top: 24 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .constraintSize({ maxWidth: 560 })
  }

  @Builder
  Activation() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
          .select(this.vm.isMemberPrivacyChecked)
          .selectedColor(this.themeColor)
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            this.vm.isMemberPrivacyChecked = value;
          });

        Text() {
          Span('开通前请阅读并同意');
          Span('《会员服务协议》').onClick(() => {
            this.privacy.title = '会员服务协议';
            this.privacy.content = this.privacyContent;
            this.vm.isShow = true;
          }).fontColor('#562E15');
          if (this.autoRenewPrivacy.length) {
            Span('和');
            Span(`《${this.autoRenewPrivacy[0]}》`).onClick(() => {
              this.privacy.title = this.autoRenewPrivacy[0] ?? '';
              this.privacy.content = this.autoRenewPrivacy[1] ?? '';
              this.vm.isShow = true;
            }).fontColor('#562E15');
          }
        }
        .fontSize(12)
        .opacity(0.6)
        .width(`calc(100% - 64vp)`)
        .maxLines(2)
        .bindSheet($$this.vm.isShow, MemberPrivacy(this.privacy.content), {
          title: { title: this.privacy.title },
          height: SheetSize.MEDIUM,
          preferType: SheetType.CENTER,
          onWillDismiss: () => {
            this.vm.isShow = false;
          },
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .constraintSize({ maxWidth: 360 })

      Button(this.lastPurchaseProductExpireTime ? '立即续期' : '立即开通')
        .width('calc(100% - 32vp)')
        .backgroundColor(this.themeColor)
        .onClick(() => {
          if (!this.vm.isMemberPrivacyChecked) {
            this.privacyCheckNode?.update({ node: this.privacyCheckNode!!, uiContext: this.uiContext } as HintParam);
            this.vm.showHint(this.uiContext, this.privacyCheckNode!!);
          } else {
            let selectedProduct = this.vm.productInfoList[this.vm.selectedProductIndex];
            this.vm.buyProduct(selectedProduct?.id ?? '', selectedProduct?.type ?? 0);
          }
        })
        .constraintSize({ maxWidth: 360 })
    }
    .width('100%')
    .padding({ top: 12, bottom: this.isSheet ? this.avoidHeight : 0 })
    .backgroundColor($r('sys.color.background_primary'));
  }

  build() {
    NavDestination() {
      if (this.vm.loading) {
        Column() {
          LoadingProgress().size({ width: 72, height: 72 });
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
      } else {
        this.Operation();

        Column() {
          Scroll(this.scroller) {
            Column() {
              if (!this.isSheet) {
                this.Owned();
              }

              Column() {
                this.Plan();
                this.Privilege();
              }.padding({ left: 16, right: 16 });
            };
          }
          .align(Alignment.Top)
          .layoutWeight(1)
          .padding({ bottom: 12 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onWillScroll((xOffset: number, yOffset: number) => {
            if (yOffset > 0) {
              this.showBlur = true;
            }
          })
          .onScrollEdge((side: Edge) => {
            if (side === Edge.Top) {
              this.showBlur = false;
            }
          });

          if (this.renewMemberSubscribedStatus && this.vm.enablePurchase) {
            this.Activation();
          }
        }
        .height('100%')
        .backgroundColor($r('sys.color.background_secondary'))
        .justifyContent(FlexAlign.SpaceBetween)
        .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
          this.cardWidth = Math.floor((newValue.width as number - 48) / 3);
        });
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.vm.pathStack = context.pathStack;
    });
  }
}

@Builder
export function buildMemberShipPage(): void {
  MemberShipPage();
}