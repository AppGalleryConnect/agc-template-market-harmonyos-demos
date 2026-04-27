import { HeaderView, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { CurrentDeviceViewModel } from '../viewmodel/CurrentDeviceViewModel';
import { EquipmentPageBuilder, EquipmentPageParam } from './EquipmentPage';
import deviceInfo from '@ohos.deviceInfo';

@Builder
export function EquipmentManagementPageBuilder() {
  EquipmentManagementPage()
}

/**
 * @usage: 用于展示设备管理页面。提供用户登录设备的管理功能，支持查看所有已登录设备列表和删除设备操作。
 * 关键数据结构包括CurrentDeviceViewModel（当前设备视图模型，包含currentDeviceName设备名称、
 * currentDeviceEquipmentSystem设备系统版本、currentDeviceTime验证通过时间、index索引）、marketNameInfo（当前手机名称）、
 * osFullName（当前手机版本号）、marketNamelist（设备列表数组，最多10个设备）。
 * 包含if逻辑：根据设备名称判断是否为当前设备并显示"当前设备"标签，设备列表超过10个时删除最旧设备并添加当前设备。
 * @layout: 页面采用NavDestination布局。顶部是HeaderView导航栏（标题"设备管理"和返回按钮，上边距20vp），
 * 第二行是标题文字"登录设备管理"（字号20、加粗、上边距20vp）和提示文字"最多可同时登录10台设备，超出后将自动移除最早登录的设备"
 * （字号12、灰色、上边距10vp、下边距40vp），主体是List列表（滚动条隐藏、底部边距210vp），
 * 每个ListItem包含设备名称Row（设备名称字号20加粗、当前设备标签字号12蓝色）、设备系统文字、验证通过时间文字、右箭头图标20x20，
 * 每项之间有Divider分割线（上边距10vp）。
 * @constraints: 设备列表最多10个不可修改；当前设备名称和系统版本从deviceInfo获取不可修改；
 * 设备列表数据在aboutToAppear中初始化并自动添加当前设备到列表首位；点击设备项跳转到EQUIPMENT_PAGE设备详情页；
 * 删除设备操作通过cancelEquipmentAction回调执行并更新列表索引。
 * @isGen: true
 * @fileType: page
 * @zhName: 设备管理页面
 * @subPage: EquipmentPage
 * @component: HeaderView
 */


@ComponentV2
struct EquipmentManagementPage {
  //获取手机名称
  @Local marketNameInfo: string = deviceInfo.marketName
  //获取手机版本号
  @Local osFullName: string = deviceInfo.osFullName
  //模拟数据的数组
  @Local marketNamelist: CurrentDeviceViewModel[] = [
    {
      currentDeviceName: 'xiaomi 14',
      currentDeviceEquipmentSystem: 'HarmonyOS 18 . 6 . 2',
      currentDeviceTime: '2020-10-07 15:25:48'
    },
    {
      currentDeviceName: 'vivo R 7',
      currentDeviceEquipmentSystem: 'HarmonyOS 15 . 5 . 1',
      currentDeviceTime: '2018-9-07 13:30:59'
    },
    {
      currentDeviceName: 'oppo R 7',
      currentDeviceEquipmentSystem: 'HarmonyOS 15 . 4 . 2',
      currentDeviceTime: '2018-8-31 09:45:02'
    },
    {
      currentDeviceName: 'REDMAGLC 11 Pro+',
      currentDeviceEquipmentSystem: 'HarmonyOS 20 . 12 . 1',
      currentDeviceTime: '2025-11-4 20:01:58'
    },
    {
      currentDeviceName: 'REDMAGLC 6',
      currentDeviceEquipmentSystem: 'HarmonyOS 17 . 6 . 2',
      currentDeviceTime: '2020-9-07 10:25:33'
    },
    {
      currentDeviceName: 'REDMAGLC 3',
      currentDeviceEquipmentSystem: 'HarmonyOS 16 . 9 . 8',
      currentDeviceTime: '2019-8-07 16:03:50'
    },
    {
      currentDeviceName: 'REDMAGLC 1',
      currentDeviceEquipmentSystem: 'HarmonyOS 12 . 1 . 1',
      currentDeviceTime: '2014-2-28 12:12:12'
    },
    {
      currentDeviceName: 'REDMAGLC 2',
      currentDeviceEquipmentSystem: 'HarmonyOS 13 . 1 . 2',
      currentDeviceTime: '2015-3-07 19:55:37'
    },
    {
      currentDeviceName: 'MAGLOIRE 10',
      currentDeviceEquipmentSystem: 'HarmonyOS 19 . 6 . 2',
      currentDeviceTime: '2023-7-07 08:42:55'
    },
    {
      currentDeviceName: 'REDMAGLC 5',
      currentDeviceEquipmentSystem: 'HarmonyOS 15 . 6 . 2',
      currentDeviceTime: '2018-7-07 08:42:55'
    },
  ]

  aboutToAppear(): void {
    const timestamp: number = new Date().getTime();
    // 转换为可读时间格式
    const currentTime: string = new Date(timestamp).toLocaleString();
    if (this.marketNamelist.length === 0) {
      this.marketNamelist.unshift({
        currentDeviceName: this.marketNameInfo,
        currentDeviceEquipmentSystem: this.osFullName,
        currentDeviceTime: currentTime,
        index: 0
      })
    } else {
      for (let i = 0; i < this.marketNamelist.length; i++) {
        this.marketNamelist[i].index = i
        if (this.marketNamelist[i].currentDeviceName === this.marketNameInfo &&
          this.marketNamelist[i].currentDeviceName === this.osFullName) {

        } else {
          if (this.marketNamelist.length < 10) {
            this.marketNamelist.unshift({
              currentDeviceName: this.marketNameInfo,
              currentDeviceEquipmentSystem: this.osFullName,
              currentDeviceTime: currentTime,
              index: 0
            })
          } else {
            if (this.marketNamelist[i].currentDeviceName !== this.marketNameInfo &&
              this.marketNamelist[i].currentDeviceName !== this.osFullName) {
              this.marketNamelist.splice(0, 1)
              this.marketNamelist.unshift({
                currentDeviceName: this.marketNameInfo,
                currentDeviceEquipmentSystem: this.osFullName,
                currentDeviceTime: currentTime,
                index: 0
              })
            }
          }
        }
      }
    }
  }

  build() {
    NavDestination() {
      //头部展示
      HeaderView({
        title: $r('app.string.device_manage'),
        clickBackBtn: () => {
          phoneRouterControl.popPage();
        }
      })
        .margin({ top: 20 })
      //设备登陆限制提示
      Column() {
        Text($r('app.string.login_device_management'))
          .fontColor($r('app.color.black_color'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({ top: 20 })
        Text($r('app.string.login_quantity_prompt'))
          .fontColor($r('app.color.dark_color_9DA3AA'))
          .fontSize(12)
          .margin({ top: 10, bottom: 40 })
        //设备展示列表
        List() {
          this.MarketNamelistView()
        }
        .width('100%')
        .scrollBar(BarState.Off)
        .margin({ bottom: 210 })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      .height('100%')
    }
    .hideTitleBar(true)
  }

  //设备UX展示
  @Builder
  MarketNamelistView() {
    ForEach(this.marketNamelist, (item: CurrentDeviceViewModel) => {
      ListItem() {
        Row() {
          Column() {
            Row() {
              Text(item.currentDeviceName)
                .fontColor($r('app.color.dark_color_B2000000'))
                .fontSize(20)
                .textAlign(TextAlign.Start)
                .fontWeight(FontWeight.Bold)
                .margin({ right: 10 })
              if (this.marketNameInfo === item.currentDeviceName) {
                Text($r('app.string.current_device'))
                  .fontColor($r('app.color.blue_color_2FAFFF'))
                  .fontSize(12)
              } else {

              }
            }
            .justifyContent(FlexAlign.Start)

            Text('设备系统： ' + item.currentDeviceEquipmentSystem)
              .fontSize(12)
              .fontColor($r('app.color.dark_color_9DA3AA'))
              .margin({ top: 10 })
              .textAlign(TextAlign.Start)
            Text('验证通过时间： ' + item.currentDeviceTime)
              .fontSize(12)
              .fontColor($r('app.color.dark_color_9DA3AA'))
              .margin({ top: 10 })
              .textAlign(TextAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
          Image($r('app.media.iconRight'))
            .size({ width: 20, height: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .margin({ top: 10 })
      .width('100%')
      .onClick(() => {
        //跳转详情方法
        const param: EquipmentPageParam = {
          paramData: item,
          cancelEquipmentAction: () => {
            if (item.index) {
              this.marketNamelist.splice(item.index, 1)
              for (let i = 0; i < this.marketNamelist.length; i++) {
                this.marketNamelist[i].index = i
              }
            }
          }
        }
        phoneRouterControl.jumpPage({
          pageName: RouterMap.EQUIPMENT_PAGE,
          builder: wrapBuilder(EquipmentPageBuilder),
          param: param
        })
      })

      Divider().margin({ top: 10 })
    }, (item: CurrentDeviceViewModel, idx: number) => JSON.stringify(item) + idx)
  }
}
