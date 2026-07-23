/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { DialPanel } from 'dial_panel';
import {
  BreakpointNameEnum,
  CardContainer,
  CommonConstants,
  CustomShareParams,
  GridRowColSetting,
  HomeBaseInfo,
  IJumpToDetailParam,
  LinkState,
  LoginBtnInCard,
  NavHeaderBar,
  RouterModule,
  WindowUtils
} from 'lib_foundation';
import {
  CommonUtils,
  GoodInfo,
  IContent,
  IntroItem,
  IntroType,
  IQuestionAnswer,
  RouterMap,
  TypeGood,
  WindowUtil
} from 'module_base';
import { CardLongTakeDelegate, LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';

@Builder
export function GoodDetailBuilder() {
  GoodDetail()
}

@ComponentV2
export struct GoodDetail {
  @Local breakpoint: string = 'sm';
  @Local good: GoodInfo = new GoodInfo();
  @Local longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
  @Local longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local instance: CustomShareParams =
    AppStorageV2.connect(CustomShareParams, 'shareInstance', () => new CustomShareParams())!;
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  linkState: LinkState = AppStorageV2.connect(LinkState, () => new LinkState())!;
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext)

  @Computed
  get priceLabel() {
    return CommonUtils.handleCash(this.good.vipPrice);
  }

  @Computed
  get imagesItem() {
    return this.good.intro.filter(item => item.type === IntroType.IMAGE);
  }

  @Computed
  get gridCount() {
    const length = this.imagesItem.length;
    const isSmallScreen = this.breakpoint === BreakpointNameEnum.SM;

    if (isSmallScreen) {
      return length === 1 ? '1fr' : '1fr 1fr';
    } else {
      const gridCount = Math.min(length, 4);
      return Array(gridCount).fill('1fr').join(' ');
    }
  }

  @Computed
  get submitBtnLabel() {
    return this.good.type === TypeGood.PAY ? '立即预约' : '咨询报价';
  }

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    const params: IJumpToDetailParam[] = RouterModule.getNavParam({ url: RouterMap.GOOD_DETAIL });
    if (params.length && params[params.length - 1]) {
      this.good = params[params.length - 1].goodInfo as GoodInfo;
      this.longTakeTransitionParam = params[params.length - 1].longTakeTransitionParam as LongTakeTransitionParam;
    }
    this.instance.pageName = 'GoodDetail';
    this.instance.goodId = this.good.id;
    this.instance.goodName = this.good.title;
  }

  aboutToDisappear(): void {
    // 设置分享参数
    this.instance.pageName = '';
    this.instance.goodId = '';
    this.instance.goodName = '';
  }

  build() {
    NavDestination() {
      if (this.longTakeSession) {
        CardLongTakeDelegate({
          longTakeSession: this.longTakeSession,
          contentBuilder: (): void => {
            this.ContentBuilder()
          },
        })
      } else {
        this.ContentBuilder()
      }
    }
    .padding({ top: WindowUtils.windowTopPadding })
    .id('GoodDetail')
    .hideTitleBar(true)
    // 弹出页需要修改navDestination的背景颜色为session中的值
    .backgroundColor($r('sys.color.background_secondary'))
    .onSizeChange(() => {
      this.longTakeSession.setNewSize({ width: '100%', height: '100%' });
    })
    .onReady((navDestContext: NavDestinationContext) => {
      if (this.longTakeTransitionParam) {
        this.longTakeSession.init(navDestContext, this.longTakeTransitionParam, {
          pop: () => {
            RouterModule.pop()
          },
        });
      }
    })
  }

  @Builder
  ContentBuilder() {
    Column() {
      NavHeaderBar({
        title: this.good.title || '服务详情',
        showBackBtn: true,
      })
        .margin({
          bottom: 12,
          left: GridRowColSetting.getPageMargin(this.breakpoint),
          right: GridRowColSetting.getPageMargin(this.breakpoint)
        })

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Scroll() {
            Column({ space: 12 }) {
              this.Banner()
              this.TitleCard()
              if (this.good.serviceContentList) {
                this.ServiceContentCard()
              }
              if (this.good.servicePipeList) {
                this.ServiceWorkflowCard()
              }
              if (this.good.feeList) {
                this.ChargeInstructionCard()
              }
              if (this.good.qaList.length) {
                this.CommonQuestionCard()
              }
              this.MoreDetail()
            }
          }
          .margin({
            bottom: 12,
            left: GridRowColSetting.getPageMargin(this.breakpoint),
            right: GridRowColSetting.getPageMargin(this.breakpoint)
          })
          .height(`calc(100% - 116vp - ${WindowUtils.windowBottomPadding}vp - 2*${GridRowColSetting.getButtonGutter(
            this.breakpoint)}vp)`)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }

        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          this.BottomOperate()
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  @Builder
  Banner() {
    if (this.breakpoint === BreakpointNameEnum.SM) {
      Image(CommonUtils.handleImgUrl(this.good.image))
        .width(CommonConstants.FULL_PERCENT)
        .aspectRatio(16 / 9)
        .objectFit(ImageFit.Cover)
        .borderRadius(16)
    } else {
      Image(CommonUtils.handleImgUrl(this.good.image))
        .width(CommonConstants.FULL_PERCENT)
        .height(184)
        .objectFit(ImageFit.Cover)
        .borderRadius(16)
    }
  }

  @Builder
  TitleCard() {
    Column({ space: 12 }) {
      Text(this.good.title)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontFamily('HarmonyHeiTi')

      Row() {
        if (this.good.type === TypeGood.PAY) {
          Text() {
            Span(this.priceLabel + '元')
              .fontSize($r('sys.float.Subtitle_L'))
              .fontWeight(FontWeight.Medium)
            Span(this.good.serviceDetailList?.length ? '起' : '').fontSize(12)
          }
          .fontColor($r('sys.color.multi_color_08'))
        } else {
          Text('咨询报价')
            .fontColor($r('sys.color.multi_color_08'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
        }

        Text(`年售${this.good.soldNum}+`)
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 8 }) {
        Text(this.good.subTitle)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)

        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.phone_fill'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_emphasize')])
          Text('咨询商家')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
        }
        .onClick(() => {
          this.dialPanel
            .setTitle('联系客服')
            .setPhoneNumber(this.homeBaseInfo.hotline)
            .open();
        })
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ServiceContentCard() {
    CardContainer({ title: '服务内容' }) {
      Column({ space: 4 }) {
        ForEach(this.good.serviceContentList, (v: IContent) => {
          Text(v.title + v.content)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .lineHeight(19)
            .width(CommonConstants.FULL_PERCENT)
        }, (v: IContent) => v.title + v.content)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ServiceWorkflowCard() {
    CardContainer({ title: '服务流程' }) {
      Column({ space: 4 }) {
        ForEach(this.good.servicePipeList, (v: string) => {
          Text(v)
            .lineHeight(19)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
        }, (v: string) => v)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ChargeInstructionCard() {
    CardContainer({ title: '费用说明' }) {
      Column({ space: 4 }) {
        ForEach(this.good.feeList, (v: string) => {
          Text(v)
            .lineHeight(19)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
        }, (v: string) => v)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  CommonQuestionCard() {
    CardContainer({ title: '常见问题' }) {
      Column({ space: 12 }) {
        ForEach(this.good.qaList, (v: IQuestionAnswer) => {
          Column({ space: 4 }) {
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.questionmark_circle_fill'))
                .fontSize(16)
                .fontColor([$r('sys.color.icon_emphasize')])
              Text(v.question)
                .lineHeight(19)
                .fontSize($r('sys.float.Body_M'))
            }

            Text(v.answer)
              .lineHeight(19)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
        }, (v: IQuestionAnswer) => v.question + v.answer)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  MoreDetail() {
    if (this.imagesItem.length) {
      Grid() {
        ForEach(this.imagesItem, (item: IntroItem) => {
          GridItem() {
            Image(CommonUtils.handleImgUrl(item.value))
              .borderRadius(8)
              .layoutWeight(1)
              .aspectRatio(16 / 9)
              .objectFit(ImageFit.Cover)
          }
        }, (item: IntroItem) => item.type + item.value)
      }
      .rowsGap(this.breakpoint === BreakpointNameEnum.SM ? 8 : 12)
      .columnsGap(this.breakpoint === BreakpointNameEnum.SM ? 8 : 12)
      .columnsTemplate(this.gridCount)
    }
  }

  onSubmit() {
    if (this.good.type === TypeGood.PAY) {
      RouterModule.push({ url: RouterMap.ORDER_PAGE, param: this.good });
    } else {
      this.dialPanel
        .setTitle('联系客服')
        .setPhoneNumber(this.homeBaseInfo.hotline)
        .open();
    }
  }

  @Builder
  BottomOperate() {
    Row() {
      if (this.linkState.isLink) {
        Button(this.submitBtnLabel)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .width(CommonConstants.FULL_PERCENT)
          .constraintSize({ maxWidth: 448 })
          .height(40)
          .backgroundColor($r('app.color.common_theme_color'))
          .onClick(() => {
            this.onSubmit();
          })
      } else {
        if (this.good.type === TypeGood.PAY) {
          LoginBtnInCard({
            btnHeight: 40,
            btnWidth: '100%',
            fontSize: $r('sys.float.Body_L'),
            onBind: () => {
              RouterModule.push({ url: RouterMap.ORDER_PAGE, param: this.good })
            }
          })
        } else {
          Button(this.submitBtnLabel)
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .width(CommonConstants.FULL_PERCENT)
            .constraintSize({ maxWidth: 448 })
            .height(40)
            .backgroundColor($r('app.color.common_theme_color'))
            .onClick(() => {
              this.onSubmit();
            })
        }
      }
    }
    .justifyContent(FlexAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: GridRowColSetting.getButtonGutter(this.breakpoint),
      bottom: GridRowColSetting.getButtonGutter(this.breakpoint) + WindowUtils.windowBottomPadding,
      right: 10,
      left: 10
    })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
