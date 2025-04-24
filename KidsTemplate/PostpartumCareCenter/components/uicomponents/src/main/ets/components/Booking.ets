import { promptAction } from '@kit.ArkUI';
import { BookingUtil, Logger, ServiceItem } from '@ohos_agcit/postpartum_care_center_utils';
import { StoreBookingRecordItem } from '../../../../Index';
import { MainEntryVM } from '../viewmodel/MainEntryVM';

@Builder
export function BookingBuilder() {
  Booking();
}

const TAG: string = '[testTagBooking]';
const COMFORT: number = 0;
const SIGHTSEEING: number = 1;

@Entry
@Preview
@ComponentV2
struct Booking {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local selectedDate: string = '';
  @Local selectedStore: ResourceStr = '';
  @Local name: string = '';
  @Local options: Array<SelectOption> = [];
  @Local optionsSelected: number = 0;
  @Local currentProjectIndex: number = SIGHTSEEING;

  aboutToAppear(): void {
    Logger.debug(TAG, 'aboutToAppear');
    this.currentProjectIndex = SIGHTSEEING;
    this.options = [
      { value: '南京涵江楼' },
      { value: '南京卓美悦' },
      { value: '苏州华轩苑' },
      { value: '南京华轩府' },
      { value: '无锡雅辉阁' },
      { value: '杭州科技城' },
      { value: '北京卓美悦' },
      { value: '深圳海月楼' },
      { value: '东莞华轩苑' },
      { value: '广州银月楼' },
      { value: '汕头卓美悦' },
      { value: '常州银月楼' },
      { value: '上海银月楼' },
      { value: '上海云顶轩' },
      { value: '北京云顶轩' },
      { value: '常州星辉阁' },
      { value: '深圳华轩苑' },
      { value: '广州卓美拉' },
      { value: '上海雅阁楼' },
      { value: '上海华轩府' },
      { value: '杭州涵江楼' },
      { value: '杭州卓美悦' },
      { value: '无锡卓美悦' },
    ];

    if (this.vm.storeList.storeList.every(store => store.distance !== null)) {
      this.options.forEach((value: SelectOption) => {
        value.value =
          value.value + ` ${this.vm.storeList.storeList.find(store => store.name === value.value)?.distance}km`;
      });
      this.options.sort((a, b) => {
        return parseFloat((a.value as String).replace(/[^0-9.]/g, '')) -
        parseFloat((b.value as String).replace(/[^0-9.]/g, ''));
      });
    }
    this.options.forEach(option => {
      Logger.debug(TAG, `aboutToAppear options: ${option.value as string}`);
    });
  }

  @Builder
  personalInfomationFillIn() {
    // 1、填写个人信息
    Text($r('app.string.booking_personal_info'))
      .width('100%')
      .fontSize($r('app.string.font_size_18'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(0,0,0,0.90)')
      .padding({
        left: $r('app.string.padding_16'),
        top: $r('app.string.margin_l'),
        bottom: $r('app.string.margin_xs'),
      })
      .margin({ bottom: $r('app.string.margin_xs') });

    Column() {
      Row() {
        Text($r('app.string.booking_must'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(232,64,38,1.00)')
          .width(6)
          .height(16);
        Text($r('app.string.booking_name'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0,0,0,0.60)');
      }
      .width('100%');

      TextInput({
        placeholder: $r('app.string.booking_name_input'),
      })
        .height(48)
        .fontSize($r('app.string.font_size_16'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor('rgba(0,0,0,0.90)')
        .placeholderColor('rgba(0,0,0,0.40)')
        .placeholderFont({
          size: $r('app.string.font_size_16'),
          family: 'HarmonyHeiTi',
          weight: FontWeight.Regular,
        })
        .backgroundColor(Color.White)
        .padding({
          left: $r('app.string.padding_6'),
          top: $r('app.string.padding_14'),
          bottom: $r('app.string.padding_13'),
        })
        .onChange((value: string) => {
          this.name = value;
        });

      Divider()
        .margin({ bottom: $r('app.string.margin_ms') })
        .padding({ left: $r('app.string.padding_6'), right: $r('app.string.padding_6') })
        .color('rgba(0,0,0,0.20)')
        .strokeWidth(1);

      Row() {
        Text($r('app.string.booking_must'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(232,64,38,1.00)')
          .width(6)
          .height(16);
        Text($r('app.string.booking_telephone'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0,0,0,0.60)');
      }
      .width('100%');

      TextInput({
        text: this.vm.userInfo.phone
      })
        .height(48)
        .fontSize($r('app.string.font_size_16'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor('rgba(0,0,0,0.90)')
        .placeholderColor('rgba(0,0,0,0.40)')
        .placeholderFont({
          size: $r('app.string.font_size_16'),
          family: 'HarmonyHeiTi',
          weight: FontWeight.Regular,
        })
        .backgroundColor(Color.White)
        .padding({
          left: $r('app.string.padding_6'),
          top: $r('app.string.padding_14'),
          bottom: $r('app.string.padding_13'),
        })
        .onChange((value: string) => {
          this.vm.userInfo.phone = value;
        });

      Divider()
        .margin({ bottom: $r('app.string.margin_ms') })
        .padding({ left: $r('app.string.padding_6'), right: $r('app.string.padding_6') })
        .color('rgba(0,0,0,0.20)')
        .strokeWidth(1);

      Row() {
        Text($r('app.string.booking_must'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(232,64,38,1.00)')
          .width(6)
          .height(16);
        Text($r('app.string.booking_store'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0,0,0,0.60)');
      }
      .width('100%');

      Select(this.options)
        .height(48)
        .width('100%')
        .selected(this.optionsSelected)
        .onSelect((value) => {
          this.optionsSelected = value;
          this.selectedStore = (this.options[value].value as string).replace(/\s*\d+(\.\d+)?\s*km\s*/g, '');
        })
        .value((this.selectedStore as string))
        .font({
          family: 'HarmonyHeiTi',
          weight: FontWeight.Regular,
          size: $r('app.string.font_size_16'),
        })
        .fontColor('rgba(0,0,0,0.90)')
        .menuAlign(MenuAlignType.CENTER)
        .arrowPosition(ArrowPosition.END)
        .backgroundColor(Color.White)
        .padding({ top: $r('app.string.padding_14'), bottom: $r('app.string.padding_13') });
      // .padding(0);

      Divider()
        .padding({ left: $r('app.string.padding_6'), right: $r('app.string.padding_6') })
        .color('rgba(0,0,0,0.20)')
        .strokeWidth(1);
    }
    .padding({ left: $r('app.string.padding_10'), right: $r('app.string.padding_10') });
  }

  @Builder
  bookingDateFillIn() {
    // 2、填写到店参观日期
    Text($r('app.string.booking_date'))
      .width('100%')
      .fontSize($r('app.string.font_size_18'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(0,0,0,0.90)')
      .padding({
        left: $r('app.string.padding_16'),
        top: $r('app.string.margin_l'),
        bottom: $r('app.string.margin_xs'),
      });

    Row() {
      Text(this.selectedDate === '' ? $r('app.string.booking_date_input') : this.selectedDate)
        .height(48)
        .fontSize($r('app.string.font_size_16'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor('rgba(0,0,0,0.90)')
        .textAlign(TextAlign.Start)
        .width('100%')
        .padding({
          left: $r('app.string.padding_16'),
          top: $r('app.string.padding_14'),
          bottom: $r('app.string.padding_13'),
        })
        .onClick(() => {
          console.info('CalendarDialog.show');

          CalendarPickerDialog.show({
            selected: new Date,
            // 在单击对话框中的“确定”按钮时调用。
            onAccept: (value) => {
              // 1. 获取当前日期（作为最小允许日期）
              const currentDate = new Date();
              currentDate.setHours(0, 0, 0, 0); // 清除时间部分

              // 4. 验证是否未来日期
              if (value >= currentDate) {
                console.info('选择有效:', value);
                Logger.debug(TAG, 'calendar onAccept: ' + JSON.stringify(value));
                this.selectedDate = JSON.stringify(value).substring(1, 11);
              } else {
                // 5. 提示用户重新选择
                promptAction.showToast({
                  message: '请选择今天或未来的日期',
                  duration: 2000
                });
              }
            },

            // 当在对话框中选择日期时，触发此事件。
            onChange: (value) => {
              Logger.debug(TAG, 'calendar onChange: ' + JSON.stringify(value));
            },
            onCancel: () => {
              this.selectedDate = '';
            },
            acceptButtonStyle: {
              type: ButtonType.Normal,
              style: ButtonStyleMode.TEXTUAL,
              borderRadius: $r('app.string.shadow_radius_8'),
              fontSize: $r('app.string.font_size_16'),
              fontFamily: 'HarmonyHeiTi',
              fontWeight: FontWeight.Medium,
              fontColor: 'rgba(0,0,0,0.90)',
            },
            cancelButtonStyle: {
              type: ButtonType.Normal,
              style: ButtonStyleMode.TEXTUAL,
              borderRadius: $r('app.string.shadow_radius_8'),
              fontSize: $r('app.string.font_size_16'),
              fontFamily: 'HarmonyHeiTi',
              fontWeight: FontWeight.Medium,
              fontColor: 'rgba(0,0,0,0.20)',
            },
          });
        });
    };

    Divider()
      .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
      .color('rgba(0,0,0,0.20)')
      .strokeWidth(1);
  }

  @Builder
  bookingRemarkFillIn() {
    // 填写备注
    Text('备注')
      .width('100%')
      .fontSize($r('app.string.font_size_18'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(0,0,0,0.90)')
      .padding({
        left: $r('app.string.padding_16'),
        top: $r('app.string.margin_l'),
        bottom: $r('app.string.margin_xs'),
      });

    TextInput({
      placeholder: ('例如：参观人数，方便为您准备月子餐'),
    })
      .height(48)
      .fontSize($r('app.string.font_size_16'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontColor('rgba(0,0,0,0.90)')
      .placeholderColor('rgba(0,0,0,0.40)')
      .placeholderFont({
        size: $r('app.string.font_size_16'),
        family: 'HarmonyHeiTi',
        weight: FontWeight.Regular,
      })
      .backgroundColor(Color.White)
      .padding({
        left: $r('app.string.padding_16'),
        // top: $r('app.string.padding_14'),
        bottom: $r('app.string.padding_13'),
      })

    Divider()
      .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
      .color('rgba(0,0,0,0.20)')
      .strokeWidth(1);

  }

  @Builder
  bookingProjectFillIn() {
    // 3、选择服务项目
    Text($r('app.string.booking_project'))
      .width('100%')
      .fontSize($r('app.string.font_size_18'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Bold)
      .fontColor('rgba(0,0,0,0.90)')
      .padding({
        left: $r('app.string.padding_16'),
        top: $r('app.string.margin_l'),
        bottom: $r('app.string.margin_xs'),
      })
      .margin({ bottom: $r('app.string.margin_xs') });

    Row() {
      Column() {
        Text($r('app.string.booking_comfort_experience'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor(this.currentProjectIndex === COMFORT ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)')
          .margin({ bottom: $r('app.string.margin_xxs') });
        Text($r('app.string.booking_price'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor(this.currentProjectIndex === COMFORT ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)');
      }
      .justifyContent(FlexAlign.Center)
      .borderRadius($r('app.string.border_radius_8'))
      .borderColor(this.currentProjectIndex === COMFORT ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)')
      .borderWidth(1)
      .height(64)
      .padding({
        left: $r('app.string.padding_20'),
        right: $r('app.string.padding_20'),
        top: $r('app.string.padding_13'),
        bottom: $r('app.string.padding_15'),
      })
      .onClick(() => {
        this.currentProjectIndex = COMFORT;
      });

      Blank();

      Column() {
        Text($r('app.string.booking_sightseeing_experience'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor(this.currentProjectIndex === SIGHTSEEING ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)')
          .margin({ bottom: $r('app.string.margin_xxs') });
        Text($r('app.string.booking_free'))
          .fontSize($r('app.string.font_size_12'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor(this.currentProjectIndex === SIGHTSEEING ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)');
      }
      .justifyContent(FlexAlign.Center)
      .borderRadius($r('app.string.border_radius_8'))
      .borderColor(this.currentProjectIndex === SIGHTSEEING ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.40)')
      .borderWidth(1)
      .height(64)
      .padding({
        left: $r('app.string.padding_20'),
        right: $r('app.string.padding_20'),
        top: $r('app.string.padding_13'),
        bottom: $r('app.string.padding_15'),
      })
      .onClick(() => {
        this.currentProjectIndex = SIGHTSEEING;
      });

    }
    .width('100%')
    .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
    .margin({ bottom: $r('app.string.margin_xs') });
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {

            Column() {
              this.personalInfomationFillIn();

              this.bookingDateFillIn();

              this.bookingProjectFillIn();


              Text($r('app.string.booking_tips'))
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.40)')
                .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') });


              this.bookingRemarkFillIn();
            };

            Column() {
              Button({ type: ButtonType.Normal, stateEffect: true }) {
                Text($r('app.string.booking_button'))
                  .fontSize($r('app.string.font_size_16'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF');
              }
              .backgroundColor('#333333')
              .padding({
                top: $r('app.string.padding_10'),
                bottom: $r('app.string.padding_9'),
              }) // 设置文字内边距
              .borderRadius($r('app.string.border_radius_20'))
              .width('100%')
              .onClick(() => {
                if (this.selectedStore === '') {
                  promptAction.showToast({ message: '请选择门店', alignment: Alignment.Center });
                  return;
                }
                if (this.name === '') {
                  promptAction.showToast({ message: '请输入姓名', alignment: Alignment.Center });
                  return;
                }
                if (this.vm.userInfo.phone === '') {
                  promptAction.showToast({ message: '请关联或添加手机号', alignment: Alignment.Center });
                  return;
                }
                if (this.selectedDate === '') {
                  promptAction.showToast({ message: '请选择预约日期', alignment: Alignment.Center });
                  return;
                }

                let recordLen = this.vm.storeBookingRecord.length;

                if (recordLen === 0) {
                  this.vm.storeBookingRecord.push(
                    new StoreBookingRecordItem(1, this.name, this.vm.userInfo.phone, this.selectedStore,
                      this.selectedDate as string, this.currentProjectIndex, 1,
                      this.vm.storeList.storeList.find(data => data.name === this.selectedStore)!.address, false),
                  );
                } else {
                  if (this.vm.storeBookingRecord.some(value => value.telephoneNum === this.vm.userInfo.phone &&
                    value.storeName === this.selectedStore && value.status === 1)) {
                    promptAction.showToast({
                      message: `手机号【${this.vm.userInfo.phone}】在该门店已存在预约记录，请重新选择门店或修改信息`,
                      alignment: Alignment.Center,
                    });
                    return;
                  } else {
                    this.vm.storeBookingRecord.push(
                      new StoreBookingRecordItem(this.vm.storeBookingRecord[recordLen - 1].id + 1, this.name,
                        this.vm.userInfo.phone, this.selectedStore, this.selectedDate as string,
                        this.currentProjectIndex, 1,
                        this.vm.storeList.storeList.find(data => data.name === this.selectedStore)!.address, false),
                    );
                  }
                }

                let newStoreBookingRecord: StoreBookingRecordItem =
                  this.vm.storeBookingRecord[this.vm.storeBookingRecord.length - 1];
                Logger.debug(TAG, `Booking ID: ${newStoreBookingRecord.id}`);
                Logger.debug(TAG, `Booking storeName: ${newStoreBookingRecord.storeName}`);
                Logger.debug(TAG, 'Booking userName: ' + newStoreBookingRecord.userName);
                Logger.debug(TAG, `Booking telephoneNum: ${newStoreBookingRecord.telephoneNum}`);
                Logger.debug(TAG, `Booking date: ${newStoreBookingRecord.date}`);
                Logger.debug(TAG, `Booking project: ${newStoreBookingRecord.project}`);
                this.vm.serviceItems[0].linkNextPageDesc = `${this.vm.storeBookingRecord.length}条记录`;

                this.vm.navStack.pushPathByName('BookingSuccess', newStoreBookingRecord);
              });
            }
            .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') });

          }
          .height('105%')
          .padding({ top: $r('app.string.padding_8'), bottom: $r('app.string.padding_8') })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .height('100%');
      }
      .width('100%')
      .height('100%');


    }
    .onReady((context: NavDestinationContext) => {
      this.vm.navStack = context.pathStack;
      this.selectedStore = context.pathInfo.param as string;
      Logger.debug(TAG, `Booking original storeName: ${this.selectedStore}`);
    });
  }
}