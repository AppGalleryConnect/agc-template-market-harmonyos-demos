import { Constants, NavPathName } from 'constant';
import { CounterComponent, CounterType, promptAction } from '@kit.ArkUI';
import { SelectKeys } from '../model/Index';
import { Commodity } from 'type';
import { mapCommodityParam } from '../mapper/CommodityInfoMapper';
import { Logger } from 'util';
import { Basic } from '../components/Basic';
import { TitleBar } from 'component';
import { AccountUtil } from 'account';

@Builder
export function CommodityDetailBuilder() {
  CommodityDetail();
}

@Component
export struct CommodityDetail {
  @StorageLink('currentUser') currentUser: string | undefined = AccountUtil.getCurrentUser();
  @State commodity: Commodity = new Commodity();
  @State @Watch('onSelectKeysChange') selectKeys: SelectKeys = {
    index: 0,
    isSelected: false,
  };
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  private tabIndexArr: Array<number> = [0, 1];
  @State isShow: boolean = false;
  @State value: number = 1;
  @State selectedSfc: string = '';
  @State activeIndex: number = 0;
  @State detailIndex: number = 0;
  @State amount: number = 0;
  scroller = new Scroller();
  detailScroller = new Scroller();

  onSelectKeysChange() {
    Logger.info('specification has changed' + this.selectedSfc);
  }

  @Builder
  TabBuilder(index: number) {
    Column() {
      Text(Constants.commodityFeatureTab[index].title)
        .fontColor(this.activeIndex === index ? $r('app.color.keyword_type_font_color') :
        Color.Black)
        .fontSize(14)
        .fontWeight(this.activeIndex === index ? 600 : 400)
        .enableDataDetector(this.activeIndex === index ? true : false);

      Divider()
        .vertical(false)
        .width(16)
        .margin({ top: 4 })
        .strokeWidth(2)
        .color(this.activeIndex === index ? $r('app.color.keyword_type_font_color') : $r('sys.color.white'));
    }.justifyContent(FlexAlign.Start).onClick(() => {
      this.goToCommodityInfo(index);
    });
  }

  @Builder
  SpecificationBuilder() {
    Column() {
      Column() {
        Row() {
          Text(this.commodity.goodsName).fontSize(16).maxLines(2).fontWeight(500).width('80%');
        }.height(80).alignItems(VerticalAlign.Center).width(Constants.FULL_SCREEN).padding({ left: 16, right: 16 });

        Divider().vertical(false);

        Column() {
          Text('规格').fontSize(12).margin({ top: 12 });
          ForEach(this.commodity.specification.split(','), (sfc: string, index: number) => {
            Text(`${sfc}`)
              .fontColor(this.selectKeys.index === index ? '#FFFFFF' :
                '#000000')
              .border({ width: 1, color: '#D6D6D6', radius: 4 })
              .padding(6)
              .fontSize(12)
              .margin({ top: 12 })
              .backgroundColor(this.selectKeys.index === index ? '#007DFF' :
                '#FFFFFF')
              .onClick(() => {
                if (this.selectKeys.index !== index) {
                  // 选择切换，规格变化
                  this.selectKeys.index = index;
                  this.selectedSfc = sfc;
                  this.amount = this.commodity.retailPrice[this.selectKeys.index] * this.value;
                }
              });
          }, (sfc: string) => sfc);
        }.alignItems(HorizontalAlign.Start).padding({ left: 16, right: 16 }).width(Constants.FULL_SCREEN);

        Divider().vertical(false).margin({ top: 24 });

        Row() {
          Text('数量').fontSize(12);

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
          });
        }.padding({ left: 16, right: 16 });
      };

      Column() {
        Text() {
          Span('需支付：').fontSize(14);
          Span(`￥${this.amount.toFixed(2)}`).fontColor(Color.Red).fontSize(20).fontWeight(600);
        }.alignSelf(ItemAlign.Start);

        Button('立即购买', { type: ButtonType.Normal })
          .width(Constants.FULL_SCREEN)
          .borderRadius(8)
          .backgroundColor($r('app.color.keyword_type_font_color'))
          .height(44)
          .margin({ top: 6 })
          .onClick(() => {
            if (!this.currentUser) {
              this.isShow = false;
              this.mainPathStack.pushPathByName(NavPathName.QUICK_LOGIN_PAGE, null, (popInfo: ESObject) => {
                this.currentUser = popInfo.result;
                Logger.info('quick login success');
              });
            } else {
              if (this.selectedSfc.length === 0) {
                promptAction.showToast({ message: '请先选择产品规格' });
              } else {
                //关闭弹窗
                this.isShow = false;
                this.purchase();
              }
            }
          });
      }.padding(16).alignItems(HorizontalAlign.Center).width(Constants.FULL_SCREEN).margin({ bottom: 10 });
    }.height(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  CommodityFeatureBuilder(index: number) {
    TabContent() {
      List({ scroller: this.scroller }) {
        ListItem() {
          Column() {
            Column() {
              Text('产品详情').fontSize(16).fontWeight(500).margin({ bottom: 6 }).padding({ left: 16 });
              ForEach(this.commodity.imageList, (item: string) => {
                Image(item).width(Constants.FULL_SCREEN).objectFit(ImageFit.Contain);
              }, (item: string) => item);
            }.width(Constants.FULL_SCREEN).alignItems(HorizontalAlign.Start);

            Column() {
              Text('品牌').fontSize(16).fontWeight(600).margin({ top: 20, bottom: 20 });

              Row() {
                Row() {
                  Image(this.commodity.banner).size({ width: 48, height: 48 }).borderRadius(8);
                  Text('莫干山农产').fontSize(16).margin({ left: 8 });
                };
              }
              .width(Constants.FULL_SCREEN)
              .justifyContent(FlexAlign.SpaceBetween);
            }.width(Constants.FULL_SCREEN).alignItems(HorizontalAlign.Start).padding({ left: 16 });
          };
        };

        ListItem() {
          Column() {
            Text('须知').fontSize(16).fontWeight(500).margin({ top: 20, bottom: 6 });
            Text('拍前须知').fontSize(14).margin({ bottom: 6 });
            Text('发货须知').fontSize(14).margin({ bottom: 6 });
            Text('签收须知').fontSize(14);
          }.width(Constants.FULL_SCREEN).alignItems(HorizontalAlign.Start).margin({ bottom: 10 });
        }.padding({ left: 16 });
      }
      .onScrollIndex((start: number, end: number, center: number) => {
        this.activeIndex = end;
      })
      .scrollBar(BarState.Off);
    }.tabBar(this.TabBuilder(index));
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({
            isShowBack: true, title: '商品详情', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          List({ scroller: this.detailScroller }) {
            ListItem() {
              Basic({ commodity: this.commodity });
            };

            ListItem() {
              Tabs() {
                ForEach(this.tabIndexArr, (item: number) => {
                  this.CommodityFeatureBuilder(item);
                }, (item: number) => item.toString());
              }.barWidth(120).scrollable(false).onChange((index: number) => {
                this.goToCommodityInfo(index);
              });
            };
          }.onScrollIndex((index: number) => {
            this.detailIndex = index;
          }).scrollBar(BarState.Off);
        }.height('80%');

        Row() {
          Button('立即购买', { type: ButtonType.Normal })
            .width(Constants.FULL_SCREEN)
            .borderRadius($r('sys.float.corner_radius_level4'))
            .backgroundColor($r('app.color.keyword_type_font_color'))
            .onClick(() => {
              this.isShow = true;
            })
            .bindSheet($$this.isShow, this.SpecificationBuilder(), {
              height: '60%',
              backgroundColor: Color.White,
            });
        }
        .position({ y: '90%' })
        .height('10%')
        .width(Constants.FULL_SCREEN)
        .justifyContent(FlexAlign.End)
        .padding(16);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.commodity = context.pathInfo.param as Commodity;
      this.amount = this.commodity.retailPrice[this.selectKeys.index];
      this.selectedSfc = this.commodity.specification.split(',')[this.selectKeys.index];
    });
  }

  goToCommodityInfo(index: number) {
    this.detailScroller.scrollToIndex(1);
    this.activeIndex = index;
    this.scroller.scrollToIndex(this.activeIndex);
  }

  purchase() {
    this.mainPathStack.pushPathByName(NavPathName.PURCHASE,
      mapCommodityParam(this.commodity, this.value, this.selectKeys.index, this.selectedSfc));
  }
}