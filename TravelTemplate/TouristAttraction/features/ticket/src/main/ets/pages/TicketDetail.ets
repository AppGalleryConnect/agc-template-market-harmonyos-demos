import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, Constant, SystemUtil } from 'common';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { CustomShareParams, LoginConfirmDialogComponent } from 'module_base';
import { https } from 'network';
import { UserInfo } from 'types';
import { TitleBar } from 'uicomponents';
import { CustomServiceDialog } from '../components/CustomServiceDialog';
import { mapperTicketInfo } from '../mapper/Index';
import { TicketInfo, TicketType } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';

@Builder
export function TicketDetailBuilder() {
  TicketDetail();
}

@ComponentV2
export struct TicketDetail {
  vm: TicketVM = TicketVM.instance;
  @Local yOffset: number = 0;
  scroller: Scroller = new Scroller();
  @Local isShow: boolean = false;
  @Local isShowCall: boolean = false;
  @Local showIndex: number = 0;
  @Local selectedIndex: number = 0;
  @Local ticketInfo: TicketInfo = new TicketInfo();
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local index: number = 0;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LoginConfirmDialogComponent({
      confirm: () => {
        this.userInfo.mockLink();
        this.getUIContext().getPromptAction().showToast({ message: '成功关联账号' });
        this.mainPathStack.pushPathByName('TicketReserve', this.ticketInfo.ticketType[this.index]);
      },
    }),
    customStyle: false,
    autoCancel: true,
  });
  @Local instance: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private tabsController: TabsController = new TabsController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  options: ImagePreviewOptions = new ImagePreviewOptions();

  getTicketById(ticketId: number) {
    https.getTicketDetail(ticketId).then((res) => {
      this.ticketInfo = mapperTicketInfo(res.data);
      // 华为分享
      this.instance.pageName = 'CommodityDetail';
      this.instance.goodId = this.ticketInfo.ticketId;
      this.instance.goodName = this.ticketInfo.ticketName;
    });
  }

  aboutToAppear(): void {
    this.vm.pathStack = this.mainPathStack;
    this.context.eventHub.on('makeCall', (phone: string) => {
      SystemUtil.triggerForCall(this.getUIContext(), phone);
    });
    this.context.eventHub.on('cancelCall', () => {
      this.isShowCall = false;
    });
  }

  aboutToDisappear(): void {
    this.context.eventHub.off('makeCall');
    this.context.eventHub.off('cancelCall');
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium);
    }.onClick(() => {
      this.tabsController.changeIndex(index);
    });
  }

  @Builder
  TicketInfo() {
    Column({ space: 8 }) {
      Column({ space: 8 }) {
        Text(this.ticketInfo.ticketName)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));
        Row({ space: 8 }) {
          ForEach(this.ticketInfo.labels, (item: string) => {
            Text(item)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .border({ width: 1, radius: 4, color: $r('sys.color.comp_divider') })
              .height(16)
              .padding({
                top: 1,
                bottom: 1,
                left: 4,
                right: 4,
              });
          }, (item: string) => item);
        };
      }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);

      Divider();

      Row() {
        Text('实名制购票请携带身份证方便入园')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
        SymbolGlyph($r('sys.symbol.phone'))
          .width(40)
          .height(40)
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(1000)
          .padding(8)
          .bindSheet($$this.isShowCall,
            CustomServiceDialog(this.getUIContext().getHostContext()!, this.ticketInfo.phone),
            { title: { title: '购票咨询' }, preferType: SheetType.CENTER, height: 320 })
          .onClick(() => {
            this.isShowCall = true;
          });
      }.justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
    }.padding(12).borderRadius(16).backgroundColor($r('sys.color.font_on_primary'));
  }

  @Builder
  TicketBrief() {
    Text(this.ticketInfo.toKnow)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_primary'))
      .margin({ left: 16, right: 16 })
      .width(Constant.FULL_PERCENT)
      .constraintSize({ maxWidth: Constant.FULL_PERCENT });
  }

  @Builder
  TicketTypes() {
    List({ space: 12 }) {
      ForEach(this.ticketInfo.ticketType, (item: TicketType, index: number) => {
        ListItem() {
          Column({ space: 12 }) {
            Row() {
              Column({ space: 4 }) {
                Text(`${item.ticketTypeName}`)
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text('预付 | 未核销随时退').fontColor($r('sys.color.multi_color_04')).fontSize($r('sys.float.Body_S'));
                Text('可随时预订').fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_S'));
              }.alignItems(HorizontalAlign.Start);

              Row() {
                Text(`￥${item.originalPrice}`)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_tertiary'))
                  .decoration({ type: TextDecorationType.LineThrough });
                Text() {
                  Span('￥').fontSize($r('sys.float.Body_S'));
                  Span(`${item.discountPrice}`).fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Medium);
                  Span('起').fontSize($r('sys.float.Body_S'));
                }.fontColor($r('sys.color.warning'));
              };
            }.alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);

            Row() {
              Row({ space: 4 }) {
                Text('预订须知')
                  .fontColor($r('sys.color.multi_color_04'))
                  .fontSize($r('sys.float.Body_M'))
                  .onClick(() => {
                    this.isShow = true;
                    this.showIndex = index;
                  });
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(24)
                  .width(12)
                  .height(24)
                  .fontColor([$r('sys.color.multi_color_04')]);
              };

              Button('预订', { controlSize: ControlSize.SMALL })
                .backgroundColor($r('sys.color.multi_color_04'))
                .fontColor($r('sys.color.font_on_primary'))
                .width(72)
                .onClick(() => {
                  if (this.userInfo.isLink) {
                    this.mainPathStack.pushPathByName('TicketReserve', item);
                  } else {
                    this.index = index;
                    this.dialogController?.open();
                  }
                });
            }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
          }.width(Constant.FULL_PERCENT);
        };
      }, (item: TicketType, index: number) => index + '__' + JSON.stringify(item));
    }
    .bindSheet($$this.isShow, this.TicketBrief(),
      {
        title: { title: '预订须知' },
        preferType: SheetType.CENTER,
        height: 320,
        detents: [320, 321],
        backgroundColor: 'rgba(255, 255, 255, 0.9)'
      })
    .alignListItem(ListItemAlign.Start)
    .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '景区门票', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll() {
          Column({ space: 12 }) {
            Image(this.ticketInfo.banner)
              .width(Constant.FULL_PERCENT)
              .height(200)
              .id(this.options.snapshotId(this.ticketInfo.banner, 0))
              .onClick(() => {
                this.options
                  .setImageList([new SourceImageModel(
                    { imageUrl: this.ticketInfo.banner })])
                  .setInitIndex(0);
                ImagePreview.open(this.getUIContext(), this.options);
              });
            Column({ space: 12 }) {
              this.TicketInfo();
              Column({ space: 12 }) {
                Row({ space: 16 }) {
                  this.tabBuilder(0, '产品预订');
                  this.tabBuilder(1, '简介须知');
                }.padding({ top: 8, bottom: 8 }).width(Constant.FULL_PERCENT);

                Tabs({ controller: this.tabsController }) {
                  TabContent() {
                    this.TicketTypes();
                  };

                  TabContent() {
                    this.TicketBrief();
                  };
                }.height('auto').barHeight(0).backgroundColor($r('sys.color.font_on_primary'))
                .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
                  if (index === targetIndex) {
                    return;
                  }
                  this.selectedIndex = targetIndex;
                });
              }.padding(12).borderRadius(16).backgroundColor($r('sys.color.comp_background_primary'));
            }
            .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
            .width(Constant.FULL_PERCENT);
          };
        }
        .align(Alignment.TopStart)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor($r('sys.color.background_secondary'));
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.getTicketById(context.pathInfo.param as number);
    });
  }
}