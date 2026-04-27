import { ExpressPageVM } from '../viewModels/ExpressPageVM'
import { CustomContentDialog } from '@kit.ArkUI'
import { ITime } from '../types'
import { CommonButton, CommonCoupon, CommonTitle, RouterModule } from 'lib_foundation'
import { Coupon, IBuilderType, ISetting, payMethodList, RouterMap, toastUtil } from 'module_base'

@ComponentV2
export struct HomeVisit {
  vm: ExpressPageVM = ExpressPageVM.instance
  expressDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.expressBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })
  couponDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.couponBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })
  timeDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.timeBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })
  priceDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.priceBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })

  build() {
    Column() {
      Column() {
        this.contentBuilder({
          label: '物品信息',
          placeholder: '请选择物品信息',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.goodsName,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: true,
          isTime: false,
          isIcon: true,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            this.vm.isFresh = false
            RouterModule.push({ url: RouterMap.GOODS_PAGE, param: true })
          },
        })
        this.contentBuilder({
          label: '选择快递',
          placeholder: 'x1，x2等14家快递公司可供选择',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.selectedCompany,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: true,
          isTime: false,
          isIcon: true,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            const value = this.vm.companyPickerList[0]
            this.vm.tempCompany = value
            this.expressDialogController.open()
          },
        })
        this.contentBuilder({
          label: '期望上门时间',
          placeholder: '请选择时间',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.selectedDayText + this.vm.selectedTime,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: true,
          isTime: false,
          isIcon: true,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            this.vm.tempDay = this.vm.dayList[0].text
            this.vm.tempTime = this.vm.timePickerList[0]
            this.timeDialogController.open()
          },
        })
        this.contentBuilder({
          label: '付款方式',
          placeholder: '请选择付款方式',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.selectedPayMethod,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: true,
          isTime: false,
          isIcon: true,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            const value = payMethodList[0].text
            this.vm.tempPayMethod = value
            this.priceDialogController.open()
          },
        })
        this.contentBuilder({
          label: '优惠券',
          placeholder: '请选择优惠券',
          placeholderColor: '#0A59F7',
          text: this.vm.couponName,
          textColor: '#0A59F7',
          isDivider: this.vm.userInfoModel.isVip ? true : false,
          isTime: false,
          isIcon: true,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            if (this.vm.price === '--') {
              toastUtil.showToast('请先填写基础信息')
              return
            }
            this.vm.getCouponList()
            this.couponDialogController.open()
          },
        })

        if (this.vm.userInfoModel.isVip) {
          this.contentBuilder({
            label: '会员折扣',
            placeholder: '会员折扣',
            placeholderColor: '#0A59F7',
            text: '9折',
            textColor: '#0A59F7',
            isDivider: false,
            isTime: false,
            isIcon: false,
            func: () => {
            },
          })
        }
      }
      .padding({ top: 12, left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(8)
    }
    .width('100%')
  }

  @Builder
  contentBuilder($$: IBuilderType) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text($$.label)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          if ($$.isTime) {
            Image($r('app.media.ic_warning'))
              .width(10)
              .height(10)
            Text('08:00至20:00')
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_tertiary'))
          }
        }

        Row() {
          Text($$.text ? $$.text : $$.placeholder)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($$.text ? $$.placeholderColor : $$.textColor)
            .margin({ right: 4 })
          if ($$.isIcon) {
            Image($r('app.media.ic_arrow_right'))
              .width(12)
              .height(12)
          }
        }
      }
      .margin({ bottom: 12 })

      if ($$.isDivider) {
        Divider().strokeWidth('1px').color($r('sys.color.comp_divider'))
          .margin({ bottom: 12 })
      }
    }
    .onClick(() => {
      $$.func()
    })
  }

  // 自定义弹出框的内容区
  @Builder
  expressBuilder(): void {
    Column() {
      Column() {
        Scroll() {
          Column() {
            this.titleBuilder('选择快递', () => {
              this.expressDialogController.close()
            })
            TextPicker({ range: this.vm.companyPickerList, selected: this.vm.selectedCompanyIndex })
              .onChange((value) => {
                this.vm.tempCompany = value as string
              })

            this.buttonBuilder(
              () => {
                this.expressDialogController.close()
              },
              () => {
                this.vm.selectedCompany = this.vm.tempCompany
                this.vm.getEstimatedPrice()
                this.vm.selectedCompanyIndex = this.vm.getSelectedIndex(this.vm.tempCompany, this.vm.companyPickerList)
                this.expressDialogController.close()
              },
            )
          }
          .width('100%')
          .padding({ bottom: 28 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
    }
  }

  // 自定义弹出框的内容区
  @Builder
  timeBuilder(): void {
    Column() {
      Scroll() {
        Column() {
          this.titleBuilder('时间选择', () => {
            this.timeDialogController.close()
          })

          Row() {
            Column() {
              ForEach(this.vm.dayList, (day: ITime, index: number) => {
                Row() {
                  Text(day.text)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.vm.selectedDayIndex === index ? '#0A59F7' : $r('sys.color.font_primary'))
                }
                .width('100%')
                .height(60)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.vm.selectedDayIndex === index ? Color.White : '')
                .onClick(() => {
                  this.vm.tempDay = day.text
                  this.vm.selectedDayIndex = index
                  this.vm.timePickerList = this.vm.dayList[index].timeList
                })
              }, (item: ISetting[]) => JSON.stringify(item))
            }
            .width(100)

            TextPicker({ range: this.vm.timePickerList, selected: this.vm.selectedTimeIndex })
              .width(200)
              .onChange((value) => {
                this.vm.tempTime = value as string
              })
          }
          .width('100%')

          this.buttonBuilder(
            () => {
              this.timeDialogController.close()
            }, () => {
            this.vm.selectedDay = this.vm.dayList.find((item) => {
              return item.text === this.vm.tempDay
            })!!
            this.vm.selectedDayText = this.vm.tempDay
            this.vm.selectedTime = this.vm.tempTime
            this.vm.selectedTimeIndex = this.vm.getSelectedIndex(this.vm.tempTime, this.vm.timePickerList)
            this.vm.selectedDayIndex = this.vm.getSelectedSettingIndex(this.vm.tempDay, this.vm.dayList)
            this.vm.getEstimatedPrice()
            this.timeDialogController.close()
          },
          )
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  @Builder
  priceBuilder(): void {
    Column() {
      Scroll() {
        Column() {
          this.titleBuilder('付款方式', () => {
            this.priceDialogController.close()
          })
          List() {
            LazyForEach(this.vm.payMethodListDataSource, (data: ISetting, index: number) => {
              ListItem() {
                Row() {
                  Text(data.text)
                    .fontColor(this.vm.selectedPayMethodIndex === index ? '#0A59F7' : $r('sys.color.font_primary'))
                }
                .width('100%')
                .height(40)
                .borderRadius(20)
                .onClick(() => {
                  this.vm.tempPayMethod = data.text
                  this.vm.selectedPayMethod = this.vm.tempPayMethod
                  this.vm.selectedPayMethodIndex = this.vm.getSelectedSettingIndex(this.vm.tempPayMethod, payMethodList)
                  this.priceDialogController.close()
                  this.vm.getEstimatedPrice()
                })
              }
            }, (v: ISetting) => v.text)
          }
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  // 自定义弹出框的内容区
  @Builder
  couponBuilder(): void {
    Column() {
      this.titleBuilder('优惠券', () => {
        this.couponDialogController.close()
      })

      if (this.vm.couponList.length === 0) {
        Column() {
          Text('暂无优惠券')
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.vm.couponList, (coupon: Coupon) => {
            ListItem() {
              CommonCoupon({
                isVip: false,
                coupon: coupon,
                couponDialogController: this.couponDialogController,
                onChange: (coupon: Coupon) => {
                  this.vm.selectedCoupon = coupon
                  this.vm.getCouponPrice(this.vm.originPrice)
                  this.vm.couponName = coupon?.name!!
                },
              })
            }
            .margin({ bottom: 14 })
          }, (item: Coupon[]) => JSON.stringify(item))
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
    }
    .width('100%')
    .padding({ bottom: 28 })
  }

  @Builder
  titleBuilder(title: string, func: Function) {
    CommonTitle({ title: title, func: func })
  }

  @Builder
  buttonBuilder(cancelFunc: Function, saveButton: Function) {
    CommonButton({ cancelFunc: cancelFunc, saveButton: saveButton })
  }
}