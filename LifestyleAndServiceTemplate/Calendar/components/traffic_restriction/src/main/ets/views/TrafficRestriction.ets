import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { UtilLog } from '@hw-agconnect/util-log';
import { ToastUtils } from 'base_apis';
import { cityListMap } from '../constants/Constants'
import { LimitsList } from '../model/Model'
import { openPermissionsInSystemSettings, PermissionRequestUtils } from '../utils/LocationPermission'
import { getCityLimits } from '../utils/Utils'

const TAG = '[TrafficRestriction]'

@ComponentV2
export struct TrafficRestriction {
  @Local isShowSheet: boolean = false
  @Local cityList: string[] = []
  @Local select: number = 0
  @Local location: string = ''
  @Local limitsList: LimitsList[] = []
  @Param selectDate: Date = new Date()
  @Local locationPermission: string = ''
  permissionRequestUtils: PermissionRequestUtils = new PermissionRequestUtils()

  @Monitor('location selectDate')
  getLimits() {
    this.limitsList = getCityLimits(this.location, this.selectDate)
  }

  aboutToAppear(): void {
    ToastUtils.setUIContext(this.getUIContext())
    this.permissionRequestUtils.setContext(this.getUIContext())
    this.cityList = cityListMap.map(item => {
      return item.city
    })
  }

  getCurrentLocation() {
    this.permissionRequestUtils.locationPermissionRequest().then(async (res) => {
      if (res === 'success') {
        this.locationPermission = res
        this.permissionRequestUtils.getCurrentLocation().then((res: string) => {
          this.location = res
        }).catch((err: BusinessError) => {
          this.location = '北京'
        })
      } else {
        this.dealError()
      }
    }).catch(() => {
      this.dealError()
    })
  }

  dealError() {
    ToastUtils.showToast({ message: '定位权限未开启，如需开启请前往系统设置！' })
  }

  @Builder
  cityLimits() {
    Column() {
      Column() {
        Image($r('app.media.no_location')).width('80').width(80)
        Row() {
          Row({ space: 5 }) {
            Text('暂无城市限行数据')
              .fontSize(14)
          }
        }
      }
      .visibility(this.limitsList.length ? Visibility.None : Visibility.Visible)

      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12,
          xl: 12,
        },
        gutter: {
          x: {
            sm: 16,
            md: 18,
            lg: 20,
            xl: 24,
          },
          y: {
            sm: 8,
            md: 8,
            lg: 8,
            xl: 8,
          },
        },
      }) {
        ForEach(this.limitsList, (item: LimitsList, index: number) => {
          GridCol({
            span: {
              sm: 4,
              md: 4,
              lg: 6,
              xl: 6,
            },
          }) {
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Column() {
                Text(index ? '明天' : '今天')
                  .fontWeight(FontWeight.Bold)
                Text(item.date)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize(14)
              }
              .width(120)

              Column() {
                Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                  Text('车牌尾号')
                    .fontWeight(FontWeight.Medium)
                  Row({ space: 16 }) {
                    ForEach(item.limits, (value: number) => {
                      Stack() {
                        Image($r('app.media.path')).width(40).height(40)
                        Text(value.toString())
                          .fontSize(24)
                          .fontWeight(FontWeight.Bold)
                      }
                    }, (value: number) => value.toString())
                  }
                }
                .padding({ left: 16, right: 16 })
                .width('100%')
                .height('100%')
                .backgroundColor($r('sys.color.background_secondary'))
                .borderRadius(16)
              }
              .padding(3)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(16)
              .flexGrow(1)
              .border({
                width: 1,
                color: $r('sys.color.background_secondary'),
              })
              .height(64)
            }
          }

        }, (item: LimitsList) => JSON.stringify(item))
      }
      .visibility((this.location && this.limitsList.length) ? Visibility.Visible :
        Visibility.None)
      .layoutWeight(1)
    }.visibility(this.locationPermission ? Visibility.Visible :
      Visibility.None)
  }

  @Builder
  SheetBuilder() {
    Column() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Row({ space: 8 }) {
            Row() {
              Image($r('app.media.city_close')).width(18).height(18)
            }
            .justifyContent(FlexAlign.Center)
            .width(40)
            .height(40)
            .backgroundColor('#E6E8E9')
            .borderRadius('50%')
            .onClick(() => {
              this.isShowSheet = false
            })

            Text('城市选择')
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
          }

          Row() {
            Image($r('app.media.city_confirm')).width(40).height(40)
          }
          .onClick(() => {
            this.isShowSheet = false
            this.location = this.cityList[this.select]
          })
        }

        TextPicker({ range: this.cityList, selected: this.select })
          .onChange((value: string | string[], index: number | number[]) => {
            this.select = index as number
            UtilLog.info(TAG, 'Picker item changed, value: ' + value + ', index: ' + index);
          })
          .onScrollStop((value: string | string[], index: number | number[]) => {
            UtilLog.info(TAG, 'Picker scroll stopped, value: ' + value + ', index: ' + index);
          })
          .canLoop(false)
          .height(200)
          .disappearTextStyle({ color: Color.Black, font: { size: 14, weight: FontWeight.Lighter } })
          .textStyle({ color: Color.Black, font: { size: 18, weight: FontWeight.Normal } })
          .selectedTextStyle({ color: '#C4272B', font: { size: 20, weight: FontWeight.Medium } })
      }.margin({ top: 16, left: 16, right: 16 })
    }
    .backgroundColor('#F1F3F5')

  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 12 }) {
          Text('城市限行')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Row({ space: 5 }) {
            Image($r('app.media.location')).width(16).height(16)
            Text(this.location)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
          }
          .padding({
            left: 8,
            right: 8,
            top: 5,
            bottom: 5,
          })
          .borderRadius(14)
          .backgroundColor($r('sys.color.background_secondary'))
        }

        Row({ space: 5 }) {
          Text('设置')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
          Image($r('app.media.chevron_right')).width(12).height(24)
        }
        .onClick(() => {
          this.isShowSheet = !this.isShowSheet
        })
      }

      Column() {
        Column({ space: 12 }) {
          this.cityLimits()
          Column() {
            Image($r('app.media.no_location')).width('80').width(80)
            Row() {
              Row({ space: 5 }) {
                Text('点击开启位置权限')
                  .fontSize(14)
                Image($r('app.media.chevron_right')).width(8).height(16)
              }
              .onClick(() => {
                this.permissionRequestUtils.locationPermissionRequest().then(res => {
                  if (res === 'success') {
                    this.locationPermission = res
                    this.permissionRequestUtils.getCurrentLocation().then((res: string) => {
                      this.location = res
                    })
                  } else {
                    openPermissionsInSystemSettings(this.getUIContext().getHostContext() as common.UIAbilityContext)
                  }
                })
              })
            }
          }
          .visibility(this.locationPermission === 'success' ? Visibility.None : Visibility.Visible)
        }
        .padding({ top: 16 })
      }
      .onAppear(() => {
        this.getCurrentLocation()
      })
      .justifyContent(FlexAlign.Center)
    }
    .bindSheet(this.isShowSheet, this.SheetBuilder(), {
      height: 280,
      showClose: false,
      preferType: SheetType.CENTER,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .padding(12)
    .borderRadius(16)
    .height(200)
  }
}
