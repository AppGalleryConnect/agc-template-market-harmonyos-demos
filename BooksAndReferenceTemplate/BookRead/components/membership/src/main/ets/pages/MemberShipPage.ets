import { iap } from '@kit.IAPKit';
import { ComponentContent, display, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import {
  HintParam,
  LoginApiController,
  MemberList,
  MemberParams,
  MemberShipPrivilege,
  Privacy,
  ProductInfo,
  UserStatus,
} from '../model/Index';
import { MemberShipVM } from '../viewmodel/MemberShipVM';
import { MemberPrivacy } from '../component/MemberPrivacy';
import { privacyCheckHint } from '../component/PrivacyCheckHint';
import { BreakpointType } from '../constant/Enum';
import { DEFAULT_LOGIN_SHEET_HEIGHT } from '../constant/Constant';

@Preview
@ComponentV2
export struct MemberShipPage {
  vm: MemberShipVM = MemberShipVM.instance;
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number || 38.77;
  @Local orientation: window.Orientation = window.Orientation.PORTRAIT;
  @Local privacy: Privacy = new Privacy();
  @Local cardWidth: number = 0;
  @Local screenWidth: number = 0;
  @Local avoidHeight: number = 0;
  @Local showBlur: boolean = false;
  @Local sheetHe: number = 0;
  @Local isBelowMD: boolean = false;
  @Local subscribeButtonAreaWidth: string = '100%';
  @Param linearColors: Array<[
    ResourceColor,
    number
  ]> = [['#FFFFFF', 0.0], ['#0A59F7', 1.0]];
  @Param themeColor: ResourceColor = $r('sys.color.background_emphasize');
  @Param btnFontColor: ResourceColor = $r('sys.color.background_emphasize');
  @Param routerModule: NavPathStack = new NavPathStack();
  @Param isSheet: boolean = false;
  @Param isLinkLoginStatus: boolean = false;
  @Param productsInfo: ProductInfo[] = [];
  @Param privacyContent: string = '';
  @Param lastPurchaseProductExpireTime: string = 'xxxx-xx-xx';
  @Param loginApiController: LoginApiController = new LoginApiController(() => new UserStatus(), () => {
  });
  @Event subscribeCallBack: (params: MemberParams) => Promise<void> = () => new Promise(() => {
  });
  @Event ownedMemberCallBack: (list: MemberList) => Promise<void> = () => new Promise(() => {
  });
  @Event queryExpireTime: (productId: string, time?: number) => Promise<string> = () => new Promise(() => {
  });
  private privacyCheckNode?: ComponentContent<Object>;
  private uiContext: UIContext = this.getUIContext();
  loginResultCallback: (isLoginSuccess: boolean) => void = (isLoginSuccess) => {
    this.vm.userStatus.isLogin = isLoginSuccess;
    if (isLoginSuccess) {
      // 查询会员详情
      this.vm.queryPurchase();
    } else {
      this.getUIContext().getPromptAction().showToast({ message: '登录失败请排查' });
    }
  };

  @Computed
  get isScreenLandScape() {
    let deviceType: string = deviceInfo.deviceType;
    return ((this.orientation === window.Orientation.LANDSCAPE ||
      this.orientation === window.Orientation.LANDSCAPE_INVERTED ||
      this.orientation === window.Orientation.AUTO_ROTATION_LANDSCAPE ||
      this.orientation === window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED ||
      this.orientation === window.Orientation.USER_ROTATION_LANDSCAPE ||
      this.orientation === window.Orientation.USER_ROTATION_LANDSCAPE_INVERTED) &&
      (this.vm.foldStatus !== display.FoldStatus.FOLD_STATUS_EXPANDED) ||
      ((this.vm.rotation === 1 || this.vm.rotation === 3) &&
        this.vm.foldStatus !== display.FoldStatus.FOLD_STATUS_EXPANDED)) && deviceType === 'phone';
  }

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
    if ((this.vm.isRenewMember &&
      (this.vm.productInfoList[this.vm.selectedProductIndex]?.type ?? iap?.ProductType.NONRENEWABLE) ===
        iap?.ProductType.AUTORENEWABLE) || !this.vm.productInfoList.length) {
      return false;
    }
    return true;
  }

  @Computed
  get userStatusContent() {
    let sheetMemberContent = '';
    if (this.vm.userStatus.isLogin && this.isLinkLoginStatus) {
      if (this.vm.isRenewMember) {
        this.vm.userStatus.memberStatus.type === iap.ProductType.AUTORENEWABLE;
        let renewProduct = this.vm.productInfoList.filter((item) => item.id === this.vm.renewProductId);
        this.vm.userStatus.memberStatus.name = renewProduct[0]?.name;
        this.vm.userStatus.memberStatus.expireTime = this.vm.getFormatTime(this.vm.expiresTime);
        sheetMemberContent =
          `${this.vm.userStatus.memberStatus.name}: ${this.vm.userStatus.memberStatus.expireTime}到期`;
      } else if (this.vm.isMember) {
        let nonRenewProduct = this.vm.productInfoList.filter((item) => item.id === this.vm.nonRenewProductId);
        this.vm.userStatus.memberStatus.name = nonRenewProduct[0]?.name;
        this.vm.userStatus.memberStatus.expireTime = this.vm.lastPurchaseProductExpireTime;
        sheetMemberContent =
          `${this.vm.userStatus.memberStatus.name}: ${this.vm.userStatus.memberStatus.expireTime}到期`;
      } else {
        sheetMemberContent = '您还不是会员';
      }
    } else {
      sheetMemberContent = '暂未登录，请点击登录';
    }
    return sheetMemberContent;
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
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.on('SheetHeightChange', (he: number) => {
      this.sheetHe = he;
    });
    this.vm.foldStatus = display.getFoldStatus();
    this.orientation = display.getDefaultDisplaySync().orientation;
    this.vm.setEvent(this.subscribeCallBack, this.queryExpireTime, this.ownedMemberCallBack, this.loginApiController);
    if (this.isLinkLoginStatus && this.vm.loginApiController) {
      this.vm.userStatus = this.vm.loginApiController.queryLoginUserStatus();
    }
    // 不依赖登录或依赖且已登录时查询会员状态
    if (!this.isLinkLoginStatus || (this.isLinkLoginStatus && this.vm.userStatus.isLogin)) {
      this.vm.queryPurchase();
    }
    this.vm.uiContext = this.uiContext;
    this.vm.queryProducts(this.productsInfo);
    this.privacyCheckNode =
      new ComponentContent(this.uiContext, wrapBuilder<[HintParam]>(privacyCheckHint),
        {
          node: this.privacyCheckNode!!,
          uiContext: this.uiContext,
          isExpand: (deviceInfo.deviceType === 'phone' &&
            this.vm.foldStatus !== display.FoldStatus.FOLD_STATUS_EXPANDED),
        } as HintParam);
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
      .padding({ bottom: 12, left: 16, top: this.windowTopHeight })
      .zIndex(2)
      .backgroundBlurStyle(this.showBlur ? BlurStyle.Thin : BlurStyle.NONE,
        { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }
  }

  @Builder
  Owned() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .size({ height: 180, width: '100%' })
          .linearGradient({
            direction: GradientDirection.Right, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: this.linearColors, // 数组末尾元素占比小于1时满足重复着色效果
          })
          .borderRadius({ bottomLeft: 8, bottomRight: 8 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

        Image($r('app.media.member'))
          .opacity(0.5)
          .size({ height: 100, width: 100 })
          .rotate({ angle: 15 })
          .margin({ right: 24, top: 12 });
      };

      GridRow({
        columns: 12,
        breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp'] },
      }) {
        GridCol({
          span: {
            xs: 12,
            sm: 12,
            md: 12,
            lg: this.isSheet ? 12 : 8,
          },
          offset: {
            xs: 0,
            sm: 0,
            md: 0,
            lg: 2,
          },
        }) {
          Row() {
            Column({ space: 8 }) {
              Text() {
                Span(this.vm.isMember ? '已有会员' : '非会员')
                  .fontSize(18)
                  .fontColor($r('sys.color.font_primary'));
                Span(this.memberStatus).fontSize(14).fontColor($r('sys.color.font_secondary'));
              };

              Text(this.vm.isMember ?
                (this.vm.isRenewMember ? `${this.vm.getFormatTime(this.vm.expiresTime)}到期` :
                  `${this.vm.lastPurchaseProductExpireTime}到期`) :
                '购买并开通会员后可查看有效期')
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'));
            }.width('calc(100% - 84vp)').alignItems(HorizontalAlign.Start);

            Button(this.vm.isMember ? '会员管理' : '暂未开通')
              .fontColor(this.vm.isMember ? this.btnFontColor :
                $r('sys.color.font_primary'))
              .backgroundColor(this.vm.isMember ? this.themeColor :
                $r('sys.color.comp_background_tertiary'))
              .fontSize(12)
              .size({ height: 28 })
              .onClick(() => {
                if (this.vm.isMember) {
                  this.vm.manageSubscribe(this.getUIContext().getHostContext() as common.UIAbilityContext);
                }
              });
          }
          .borderRadius(16)
          .padding(12)
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .margin({ top: 24 });
        };
      }.padding({ left: 16, right: 16 });
    };
  }

  @Builder
  EmptyHint() {
    Column({ space: 8 }) {
      Image($r('app.media.member_empty')).size({ width: 120, height: 120 });
      Text('暂无会员套餐').fontSize(14).fontColor($r('sys.color.font_secondary'));
    }.margin({ top: 120 }).width('100%');
  }

  @Builder
  UserStatus() {
    Row() {
      Row({ space: 4 }) {
        if (this.vm.userStatus.isLogin) {
          SymbolGlyph($r('sys.symbol.v_diamond_fill'))
            .fontSize(24)
            .fontColor(this.vm.isMember ? [this.themeColor] : [$r('sys.color.icon_tertiary')])
            .fontWeight(FontWeight.Normal);
        }
        Text(this.userStatusContent).fontSize(14).fontColor($r('sys.color.font_primary'));
      };

      if (!this.vm.userStatus.isLogin) {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_secondary')]);
      }
    }
    .onClick(() => {
      if (this.vm.userStatus.isLogin) {
        return;
      }
      this.vm.loginApiController.handleLogin(this.getUIContext(), this.loginResultCallback);
    })
    .width('calc(100% - 32vp)')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(10)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16);
  }

  @Builder
  Plan() {
    Column({ space: 12 }) {
      Text('会员套餐')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .textAlign(TextAlign.Start);
      List({ space: 8 }) {
        ForEach(this.vm.productInfoList, (item: iap.Product, index: number) => {
          ListItem() {
            Stack({ alignContent: Alignment.Bottom }) {
              Column({ space: 12 }) {
                Text(item.name)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize(14)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text(`${item.localPrice?.split('.')[0]}`)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(24)
                  .fontColor($r('sys.color.font_primary'));
              }
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .borderRadius(8)
              .alignItems(HorizontalAlign.Center)
              .padding(16);

              Stack() {
                Row() {
                }
                .borderRadius({ bottomLeft: 6, bottomRight: 6 })
                .width('100%')
                .height(24)
                .backgroundColor(this.vm.selectedProductIndex === index ? this.themeColor :
                  $r('sys.color.comp_background_tertiary'))
                .opacity(this.vm.selectedProductIndex === index ? 0.1 : 1);

                Text(item.description)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.MARQUEE })
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_primary'));
              }
              .borderRadius({ bottomLeft: 6, bottomRight: 6 });
            }
            .width(this.cardWidth)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .border({
              width: this.vm.selectedProductIndex === index ? 2 : 1,
              radius: 8,
              color: this.vm.selectedProductIndex === index ? this.themeColor :
                $r('sys.color.comp_divider'),
            })
            .onClick(() => {
              this.vm.selectedProductIndex = index;
            });
          };
        }, (item: iap.Product) => item.id);
      }
      .width('100%')
      .height(124)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true });
    }.margin({ top: this.isSheet ? 12 : 24 });
  }

  @Builder
  Privilege() {
    Column({ space: 16 }) {
      Text('会员权益')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .textAlign(TextAlign.Start);
      List({ space: 12 }) {
        ForEach(this.privilegeByProductId, (item: MemberShipPrivilege) => {
          ListItem() {
            Row({ space: 8 }) {
              Image(item.icon).size({ width: 40, height: 40 });

              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text(item.des)
                  .fontSize(14)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor($r('sys.color.font_primary'));
              }.alignItems(HorizontalAlign.Start).width('calc(100% - 48vp)');
            }.width('100%');
          };
        }, (item: MemberShipPrivilege) => item.id);
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .padding(12)
      .scrollBar(BarState.Off)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16)
      .scrollBar(BarState.Off);
    }.margin({ top: 24 });
  }

  @Builder
  Activation() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
          .selectedColor(this.themeColor)
          .select(this.vm.isMemberPrivacyChecked)
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            this.vm.isMemberPrivacyChecked = value;
          });

        Text() {
          Span('开通前请阅读并同意').fontColor($r('sys.color.font_primary'));
          Span('《会员服务协议》').onClick(() => {
            this.privacy.title = '会员服务协议';
            this.privacy.content = this.privacyContent;
            this.vm.isShow = true;
          }).fontColor(this.themeColor);
          if (this.autoRenewPrivacy.length) {
            Span('和');
            Span(`《${this.autoRenewPrivacy[0]}》`).onClick(() => {
              this.privacy.title = this.autoRenewPrivacy[0] ?? '';
              this.privacy.content = this.autoRenewPrivacy[1] ?? '';
              this.vm.isShow = true;
            }).fontColor(this.themeColor);
          }
        }
        .fontSize(12)
        .opacity(0.6)
        .width(this.isBelowMD ? `calc(100% - 64vp)` : '')
        .maxLines(2)
        .bindSheet($$this.vm.isShow, MemberPrivacy(this.privacy.content), {
          title: { title: this.privacy.title },
          enableHoverMode: true,
          hoverModeArea: HoverModeAreaType.BOTTOM_SCREEN,
          height: DEFAULT_LOGIN_SHEET_HEIGHT,
          preferType: SheetType.CENTER,
          onWillDismiss: () => {
            this.vm.isShow = false;
          },
        });
      }.width('100%').justifyContent(FlexAlign.Center);

      Button('立即开通')
        .width(`calc(${this.subscribeButtonAreaWidth} - 32vp)`)
        .backgroundColor(this.themeColor)
        .fontColor(this.btnFontColor)
        // .margin({bottom:this.bottomRectHeight})
        .onClick(() => {
          if (this.isLinkLoginStatus && this.vm.loginApiController && !this.vm.userStatus.isLogin) {
            this.vm.loginApiController.handleLogin(this.getUIContext(), this.loginResultCallback);
          } else {
            if (!this.vm.isMemberPrivacyChecked) {
              this.privacyCheckNode?.update({ node: this.privacyCheckNode!!, uiContext: this.uiContext } as HintParam);
              this.vm.showHint(this.uiContext, this.privacyCheckNode!!);
            } else {
              let selectedProduct = this.vm.productInfoList[this.vm.selectedProductIndex];
              this.vm.buyProduct(selectedProduct?.id ?? '', selectedProduct?.type ?? 0, selectedProduct?.name ?? '');
            }
          }
        });
    }
    .width('100%')
    .margin({ top: this.isScreenLandScape ? 4 : 0 })
    .padding({ top: 12, bottom: (this.isSheet ? (this.isScreenLandScape ? 12 : 28) : 2) + this.bottomRectHeight })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  build() {
    Column() {
      if (this.vm.loading) {
        Column() {
          LoadingProgress().size({ width: 72, height: 72 });
        }.layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
      } else {
        this.Operation();

        Column() {
          Scroll() {
            Column() {
              if (!this.isSheet) {
                this.Owned();
              } else {
                if (this.isLinkLoginStatus && this.vm.loginApiController) {
                  this.UserStatus();
                }
              }

              GridRow({
                columns: 12,
                breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp'] },
              }) {
                GridCol({
                  span: {
                    xs: 12,
                    sm: 12,
                    md: 12,
                    lg: this.isSheet ? 12 : 8,
                  },
                  offset: {
                    xs: 0,
                    sm: 0,
                    md: 0,
                    lg: 2,
                  },
                }) {
                  if (this.vm.productInfoList.length) {
                    Column() {
                      this.Plan();
                      this.Privilege();
                    }.padding({ left: 16, right: 16 });
                  } else {
                    this.EmptyHint();
                  }
                };
              }.onBreakpointChange((breakpoints: string) => {
                if (this.isSheet) {
                  this.cardWidth = Math.floor((this.screenWidth - 48) / 3);
                  if (breakpoints === BreakpointType.XS || breakpoints === BreakpointType.SM) {
                    this.isBelowMD = true;
                  } else if (breakpoints === BreakpointType.MD || breakpoints === BreakpointType.LG) {
                    this.isBelowMD = false;
                  }
                } else {
                  if (breakpoints === BreakpointType.XS || breakpoints === BreakpointType.SM) {
                    this.isBelowMD = true;
                    this.cardWidth = Math.floor((this.screenWidth - 48) / 3);
                  } else if (breakpoints === BreakpointType.MD) {
                    this.cardWidth = Math.floor((this.screenWidth - 48) / 3);
                    this.subscribeButtonAreaWidth = '60%';
                    this.isBelowMD = false;
                  } else if (breakpoints === BreakpointType.LG) {
                    this.cardWidth = Math.floor((this.screenWidth * (8 / 12) - 48) / 3);
                    this.subscribeButtonAreaWidth = '60%';
                    this.isBelowMD = false;
                  }
                }
              });

              if (this.renewMemberSubscribedStatus && this.isScreenLandScape) {
                this.Activation();
              }
            };
          }
          .align(Alignment.Top)
          .padding({ bottom: this.isScreenLandScape ? 0 : 4 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .scrollBar(BarState.Off)
          .onWillScroll((xOffset: number, yOffset: number) => {
            if (yOffset > 0) {
              this.showBlur = true;
            }
          })
          .onScrollEdge((side: Edge) => {
            if (side === Edge.Top) {
              this.showBlur = false;
            }
          })
          .layoutWeight(1);

          if (this.renewMemberSubscribedStatus && !this.isScreenLandScape) {
            this.Activation();
          }
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .height('100%')
        .backgroundColor(this.isSheet ? $r('app.color.common_sheet_bg') : $r('sys.color.background_secondary'))
        .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
          this.screenWidth = newValue.width as number;
          this.vm.listenFoldChange();
          this.vm.listenScreenRotate();
        });
      }
    }.height(this.isSheet ? this.getUIContext().px2vp(this.sheetHe) - 64 : '100%');
  }
}

@Builder
export function buildMemberShipPage(): void {
  MemberShipPage();
}