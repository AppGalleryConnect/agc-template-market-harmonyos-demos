import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { Constant, SystemUtil } from 'common';
import { TitleBar } from 'uicomponents';
import { https } from 'network';
import { UserInfo } from 'types';
import { CustomShareParams, LoginConfirmDialogComponent } from 'module_base';
import { mapperTicketInfo } from '../mapper/Index';
import { TicketInfo, TicketType } from '../model/TicketInfo';
import { TicketVM } from '../viewmodel/TicketVM';
import { CustomServiceDialog } from '../components/CustomServiceDialog';

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
  @Local index: number = 0
  @Local instance: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LoginConfirmDialogComponent({
      confirm: () => {
        this.userInfo.mockLink()
        this.getUIContext().getPromptAction().showToast({ message: '成功关联账号' });
        this.mainPathStack.pushPathByName('TicketReserve', this.ticketInfo.ticketType[this.index]);
      },
    }),
    customStyle: false,
    autoCancel: true,
  });

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
        .opacity(this.selectedIndex === index ? 1 : 0.4)
        .fontSize(14);
    }.margin({ left: 16 }).onClick(() => {
      this.tabsController.changeIndex(index);
    });
  }

  @Builder
  TicketInfo() {
    Column({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.ticketInfo.ticketName).fontSize(16).fontWeight(500);
        Row({ space: 8 }) {
          ForEach(this.ticketInfo.labels, (item: string) => {
            Text(item)
              .fontSize(10)
              .border({ width: 1, radius: 4, color: '#F6933B' })
              .padding(4);
          }, (item: string) => item);
        };
      }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);

      Divider();

      Row() {
        Text('实名制购票请携带身份证方便入园').fontSize(12).opacity(0.6);
        Image($r('app.media.phone'))
          .size({ width: 24, height: 24 })
          .bindSheet($$this.isShowCall,
            CustomServiceDialog(this.getUIContext().getHostContext()!, this.ticketInfo.phone),
            { title: { title: '购票咨询' }, height: 280 })
          .onClick(() => {
            this.isShowCall = true;
          });
      }.justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
    }.padding(16).backgroundColor($r('sys.color.font_on_primary'));
  }

  @Builder
  TicketBrief() {
    Text(this.ticketInfo.toKnow)
      .fontSize(14)
      .lineHeight(20)
      .width(Constant.FULL_PERCENT)
      .height(Constant.FULL_PERCENT)
      .align(Alignment.Top)
      .backgroundColor($r('sys.color.font_on_primary'))
      .padding(16);
  }

  @Builder
  TicketTypes() {
    List() {
      ForEach(this.ticketInfo.ticketType, (item: TicketType, index: number) => {
        ListItem() {
          Column({ space: 14 }) {
            Row() {
              Column({ space: 2 }) {
                Text(`${item.ticketTypeName}`)
                  .fontSize(16)
                  .fontWeight(500)
                  .width(200)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text('预付 | 未核销随时退').fontColor('#64BB5C').fontSize(12);
                Text('可随时预订').opacity(0.6).fontSize(12);
                Text('预订须知 >')
                  .fontColor('#64BB5C')
                  .fontSize(14)
                  .margin({ top: 4 })
                  .onClick(() => {
                    this.isShow = true;
                    this.showIndex = index;
                  });
              }.alignItems(HorizontalAlign.Start);

              Column() {
                Row() {
                  Text(`￥${item.originalPrice}`)
                    .fontSize(10)
                    .decoration({ type: TextDecorationType.LineThrough })
                    .opacity(0.4);
                  Text() {
                    Span('￥').fontSize(12).fontColor('#E84026');
                    Span(`${item.discountPrice}`).fontSize(18).fontWeight(500).fontColor('#E84026');
                    Span('起').fontSize(12).opacity(0.4);
                  };
                }.alignItems(VerticalAlign.Bottom).margin({ bottom: 12 });

                Button('预订')
                  .width(60)
                  .backgroundColor('#64BB5C')
                  .fontColor($r('sys.color.font_on_primary'))
                  .width(64)
                  .height(28)
                  .onClick(() => {
                    if (this.userInfo.isLink) {
                      this.mainPathStack.pushPathByName('TicketReserve', item);
                    } else {
                      this.index = index
                      this.dialogController?.open()
                    }
                  })
              };
            }.justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);

            Divider();
          }.padding(16);
        };
      }, (item: TicketType, index: number) => index + '__' + JSON.stringify(item));
    }
    .bindSheet($$this.isShow, this.TicketBrief(),
      { title: { title: '预订须知' }, height: '40%' })
    .alignListItem(ListItemAlign.Start)
    .height(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.font_on_primary'));
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '门票详情', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll() {
          Column({ space: 8 }) {
            Column() {
              Image(this.ticketInfo.banner).width(Constant.FULL_PERCENT).height(240);

              this.TicketInfo();
            };

            Column() {
              Flex({ direction: FlexDirection.Row }) {
                this.tabBuilder(0, '产品预订');
                this.tabBuilder(1, '简介须知');
              }.padding({ top: 12, bottom: 12 }).backgroundColor($r('sys.color.font_on_primary'));

              Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
                TabContent() {
                  this.TicketTypes();
                };

                TabContent() {
                  this.TicketBrief();
                };
              }.backgroundColor($r('sys.color.font_on_primary')).onChange((index: number) => {
                this.selectedIndex = index;
              });
            };
          };
        }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).backgroundColor('#F1F3F5');
      };
    }.hideTitleBar(true).title(this.ticketInfo.ticketName).onReady((context: NavDestinationContext) => {
      this.getTicketById(context.pathInfo.param as number);
    });
  }
}