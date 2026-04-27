import { DividerTmp, menuList } from '../common/Constants';
import { getInstance } from '../common/CommonRoute';
import { CalTaxInput, TaxParam, Menu, IncomeType } from '../model/CalTaxInput';
import { check } from '../utils/Check';

@ComponentV2
export struct IncomeCalculator {
  @Local curIndex: number = 0;
  @Local selectedString: string = '工资、薪金所得（综合所得）';
  @Local egDivider: DividerTmp = new DividerTmp(1, 0, 0, '#ffe9f0f0');
  @Local routePath: string = 'PersonalTaxPage';
  @Local calTaxInput: CalTaxInput = {};
  @Local isShow: boolean = false;
  @Local incomeType: Menu = menuList[0];

  aboutToDisappear(): void {
    menuList.forEach((item) => {
      item.isChecked = false;
    });
    menuList[0].isChecked = true;
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            List() {
              this.incomeTypeBuilder();
              // 判断收入类型
              if (this.incomeType.type === IncomeType.SALARY) {
                this.listItemBuilder('税前工资（月）', '50%', '50%');
                this.listItemBuilder('专项扣除（社保公积金个人部分）');
                this.listItemBuilder('专项附加扣除（子女教育等）');
                this.freeTaxBuilder();
              } else if (this.incomeType.type === IncomeType.LABOUR) {
                this.listItemBuilder('劳务报酬', '50%', '50%');
              } else if (this.incomeType.type === IncomeType.ROYALTIES) {
                this.listItemBuilder('特许权使用费', '50%', '50%');
              }

              ListItem() {
                Divider().color($r('sys.color.comp_divider')).width(1);
              }
              .width('100%')
              .padding({ bottom: 17 });
            }
            .width('100%')
            .backgroundColor(Color.White)
            .divider(this.egDivider)
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
            .alignListItem(ListItemAlign.Center);
          }
          .width('100%')
          .margin({ bottom: 24 })
          .padding(16);


          Button($r('app.string.calculation'))
            .onClick(() => {
              const param: TaxParam = {
                incomeType: this.incomeType.type,
                texInput: this.calTaxInput,
              };
              const isPassed = check(this.incomeType.type, this.calTaxInput);
              if (isPassed) {
                getInstance().pushPathByName(this.routePath, param);
              }
            })
            .width(264)
            .height(40);
        };
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
    }
    .layoutWeight(1);
  }

  @Builder
  incomeTypeBuilder() {
    ListItem() {
      Row() {
        this.titleBuilder($r('app.string.Revenue_type'));
        Row() {
          Text(this.incomeType ? this.incomeType.content : '请选择类型')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ right: 6 });

          Image($r('app.media.arrow_right'))
            .width(6)
            .height(14);
        }
        .onClick(() => {
          this.isShow = !this.isShow;
        })
        .bindSheet(this.isShow, this.mySheet(), {
          title: {
            title: '选择收入类型',
          },
          height: 560,
          dragBar: false,
          onDisappear: () => {
            this.isShow = !this.isShow;
          },
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .height(48);
  }

  @Builder
  listItemBuilder(name: string, percentLeft: string = '80%', percentRight: string = '20%') {
    ListItem() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          this.titleBuilder(name);
        }
        .width(percentLeft)
        .flexBasis('auto');

        TextInput({ placeholder: '0' })
          .width(percentRight)
          .textAlign(TextAlign.End)
          .flexBasis('auto')
          .padding({ right: 8 })
          .backgroundColor($r('app.color.list_background'))
          .type(InputType.Number)
          .onChange((value: string) => {
            switch (name) {
              case '税前工资（月）':
                this.calTaxInput.income = Number(value);
                break;
              case '专项扣除（社保公积金个人部分）':
                this.calTaxInput.insurance = Number(value);
                break;
              case '专项附加扣除（子女教育等）':
                this.calTaxInput.deduction = Number(value);
                break;
              case '基本减除费用（起征点）':
                this.calTaxInput.threshold = Number(value);
                break;
              case '劳务报酬':
                this.calTaxInput.income = Number(value);
              case '特许权使用费':
                this.calTaxInput.income = Number(value);
            }
          });
        Text('元')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'));
      };
    }
    .width('100%')
    .height(48);
  }

  @Builder
  freeTaxBuilder() {
    ListItem() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
      }) {
        this.titleBuilder('基本减除费用（起征点）');
        Text('5000  元')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .flexBasis('auto');
      };
    }
    .height(48)
    .width('100%');
  }

  @Builder
  titleBuilder(value: ResourceStr) {
    Text(value)
      .fontSize($r('sys.float.Subtitle_M'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'));
  }

  @Builder
  mySheet() {
    Column() {
      List() {
        ForEach(menuList, (menu: Menu) => {
          ListItem() {
            Row() {
              Text(menu.content)
                .fontSize(14)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'));
              Radio({ value: 'Radio', group: 'radioGroup' })
                .checked(menu.isChecked)
                .height(20)
                .width(20)
                .onChange((value) => {
                  if (value) {
                    this.incomeType = menu;
                  }
                  this.calTaxInput = {}
                  menu.isChecked = value;
                });
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween);
          }
          .width('100%')
          .height(48);
        }, (menu: Menu) => JSON.stringify(menu));
        ListItem() {
          Divider().color($r('sys.color.comp_divider')).width(1);
        }
        .width('100%');
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .divider(this.egDivider)
      .borderRadius({ topLeft: 16, topRight: 16 });
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 });
  }
}