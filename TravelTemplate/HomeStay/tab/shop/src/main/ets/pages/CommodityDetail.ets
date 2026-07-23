import { common } from '@kit.AbilityKit';
import { CounterComponent, CounterType } from '@kit.ArkUI';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Constants, NavPathName } from 'constant';
import { Commodity } from 'type';
import { CommonHeader } from 'component';
import { Logger, AccountUtil, formatPriceToNumber } from 'util';
import { SelectKeys } from '../model/Index';
import { mapCommodityParam } from '../mapper/CommodityInfoMapper';
import { Basic } from '../components/Basic';

@Builder
export function CommodityDetailBuilder() {
  CommodityDetail();
}

@ComponentV2
export struct CommodityDetail {
  @Local currentUser: string | undefined = AccountUtil.getUserId();
  @Local commodity: Commodity = new Commodity();
  @Local selectKeys: SelectKeys = new SelectKeys();
  @Local isShow: boolean = false;
  @Local value: number = 1;
  @Local selectedSfc: string = '';
  @Local amount: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Monitor('selectKeys')
  selectKeysChange(monitor: IMonitor) {
    Logger.info('select key is ' + monitor.value());
  }

  aboutToAppear(): void {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.on('reLogin',
      (uid: string) => {
        AccountUtil.setUserId(uid);
        if (!AccountUtil.getAvatar()) {
          AccountUtil.setAvatar($r('app.media.avatar'));
          AccountUtil.setNickName('华为用户');
        }
      });
  }

  aboutToDisappear(): void {
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.off('reLogin');
  }

  @Builder
  SpecificationBuilder() {
    Column() {
      Row() {
        Image(this.commodity.banner)
          .width(112)
          .height(112)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column({ space: 4 }) {
          Text() {
            Span('实付￥').fontSize(12).fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.warning'))
            Span(`${formatPriceToNumber(this.amount)}`).fontSize(24).fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.warning'))
          }

          Text(`￥${formatPriceToNumber(this.commodity.counterPrice[this.selectKeys.index])}`)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .decoration({ type: TextDecorationType.LineThrough })

          Column({ space: 2 }) {
            Text('免运费 | 7天无理由')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
            Text('48小时内发货')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }.alignItems(HorizontalAlign.Start)
        }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).layoutWeight(1)
      }.width(Constants.FULL_SCREEN).padding({ left: 16, right: 16 })

      Column() {
        Text('规格').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.commodity.specification.split(','), (sfc: string, index: number) => {
            Text(`${sfc}`)
              .fontColor(this.selectKeys.index === index ? $r('sys.color.font_emphasize') :
                $r('sys.color.font_primary'))
              .border({
                width: this.selectKeys.index === index ? 1 : 0,
                color: $r('sys.color.brand'),
                radius: 4
              })
              .height(28)
              .fontSize(14)
              .padding({ left: 12, right: 12 })
              .margin({ top: 8, right: 8 })
              .backgroundColor(this.selectKeys.index === index ? '#1A0A59F7' :
                $r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                if (this.selectKeys.index !== index) {
                  this.selectKeys.index = index;
                  this.selectedSfc = sfc;
                  this.amount = this.commodity.retailPrice[this.selectKeys.index] * this.value;
                }
              })
          }, (sfc: string) => sfc)
        }
      }.alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16 })
      .width(Constants.FULL_SCREEN)
      .margin({ top: 12 })

      Row() {
        Text('数量').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'));

        CounterComponent({
          options: {
            type: CounterType.LIST,
            numberOptions: {
              value: this.value,
              min: 1,
              max: 10,
              onChange: (value: number) => {
                this.value = value;
                this.amount = this.commodity.retailPrice[this.selectKeys.index] * this.value;
              },
            },
          },
        }).margin({ right: 16 });
      }.width(Constants.FULL_SCREEN).padding({ left: 16, right: 16 })

      Blank().layoutWeight(1)

      Column() {
        Button('立即购买', { type: ButtonType.Normal })
          .width(Constants.FULL_SCREEN)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            if (!this.currentUser) {
              this.isShow = false;
              this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                this.currentUser = popInfo.result;
                AccountUtil.setUserId(popInfo.result);
                this.getUIContext().getHostContext()?.eventHub.emit('reLogin',
                  popInfo.result);
                Logger.info('quick login success');
              });
            } else {
              if (this.selectedSfc.length === 0) {
                ToastDialog.showToast({ message: '请先选择产品规格' });
              } else {
                this.isShow = false;
                this.purchase();
              }
            }
          });
      }.width(Constants.FULL_SCREEN)
      .padding({ left: 16, right: 16, bottom: 36 });
    }.height(Constants.FULL_SCREEN)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          CommonHeader({ title: '商品详情', showBackButton: true, backButtonClick: () => {
            this.mainPathStack.pop();
          } });

          Scroll() {
            Basic({ commodity: this.commodity, onSpecClick: () => {
              this.isShow = true;
            } }).bindSheet($$this.isShow, this.SpecificationBuilder(), {
              preferType: SheetType.CENTER,
              height: SheetSize.LARGE,
              backgroundColor: $r('sys.color.comp_background_primary'),
              title: {
                title: '商品规格选择'
              }
            });
          }.scrollBar(BarState.Off);
        }.layoutWeight(1);

        Row() {
          Button('立即购买', { type: ButtonType.Normal })
            .width(Constants.FULL_SCREEN)
            .height(40)
            .borderRadius(20)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              UIDialog.open({
                content: '请选择规格后下单商品',
                showConfirmButton: true,
                confirmButton: '我知道了',
              })
            });
        }
        .width(Constants.FULL_SCREEN)
        .justifyContent(FlexAlign.End)
        .padding({ left: 16, right: 16, bottom: 36 });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.commodity = context.pathInfo.param as Commodity;
      this.amount = this.commodity.retailPrice[this.selectKeys.index];
      this.selectedSfc = this.commodity.specification.split(',')[this.selectKeys.index];
    });
  }

  purchase() {
    this.mainPathStack.pushPathByName(NavPathName.PURCHASE,
      mapCommodityParam(this.commodity, this.value, this.selectKeys.index, this.selectedSfc));
  }
}