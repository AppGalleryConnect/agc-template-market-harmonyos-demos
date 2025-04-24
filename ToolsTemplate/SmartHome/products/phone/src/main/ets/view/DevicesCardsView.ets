import { DeviceCardAddView, DeviceCardView, DeviceCardViewModel, DevicesCardsViewModel } from 'device_mng';
import { AddFormMenuItem } from '@kit.ArkUI';
import { formBindingData, formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { StorageUtil } from 'utils'

const tag = 'AddFormMenuItem';

@ComponentV2
export struct DevicesCardsView {
  @Require @Param pathStack: NavPathStack = new NavPathStack();
  deviceCardsViewModel: DevicesCardsViewModel = new DevicesCardsViewModel();

  @Builder
  BuildAddDevice() {
    Column({space: 16}) {
      this.BuildTitle('添加智能设备')
      Text('打造全场景体验，创建智慧互联家庭')
        .width('100%')
        .fontSize(14)
        .fontColor('#666666')
      Image($r('app.media.devices'))
        .size({width: 200})
        .padding({top: 40})
      this.BuildAddButton()
    }
  }

  @Builder
  BuildAddButton() {
    Column() {
      Row() {
        Image($r('app.media.plus_white'))
          .size({ height: 16, width: 16 });

        Text(' 添加设备')
          .fontColor(Color.White)
          .fontSize(16)
      }
    }
    .justifyContent(FlexAlign.Center)
    .borderRadius(8)
    .backgroundColor('#0A59F7')
    .width(220)
    .height(40)
    .margin({ top: 30 })
    .onClick(() => {
      if (StorageUtil.exists('isLogin')) {
        this.pathStack.pushPathByName('AddDevicePage', null);
      } else {
        this.pathStack.pushPathByName('QuickLoginPage', null);
      }
    });
  }

  @Builder
  BuildTitle(title: string) {
    Row() {
      Text(title)
        .fontColor('#333333')
        .fontSize(20);
    }
    .width('100%')
  }


  @Builder
  BuildGridCards() {
    Grid() {
      ForEach(this.deviceCardsViewModel.addedDevicesId, (item: string, index: number) => {
        GridItem() {
          DeviceCardViewWrapper({ deviceId: item, pathStack: this.pathStack });
        };
      }, (item: Object, index: number) => index + '__' + JSON.stringify(item));
      DeviceCardAddView({ pathStack: this.pathStack });
    }
    .height('100%')
    .editMode(true)
    .columnsTemplate('1fr 1fr')
    .columnsGap(15)
    .rowsGap(15)
    .scrollBar(BarState.Off);
  }

  @Builder
  BuildMyDevice() {
    Column({space: 16}) {
      this.BuildTitle('我的设备')
      this.BuildGridCards()
    }
  }

  build() {
    Column() {
      if (this.deviceCardsViewModel.addedDevicesId.length === 0) {
        this.BuildAddDevice();
      } else {
        this.BuildMyDevice();
      }
    };
  }
}

@ComponentV2
struct DeviceCardViewWrapper {
  @Require @Param deviceId: string = '';
  @Require @Param pathStack: NavPathStack = new NavPathStack();
  deviceCardViewModel: DeviceCardViewModel = new DeviceCardViewModel(this.deviceId);
  @Local message: string = 'Long press show menu';
  formId: string = '';
  private compId: string = 'addforms@d46313145';

  getFormBindingData(): formBindingData.FormBindingData {
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData({
      deviceId: this.deviceCardViewModel.deviceId,
      deviceImage: this.deviceCardViewModel.deviceImage,
      deviceName: this.deviceCardViewModel.deviceName,
      isDeleted: this.deviceCardViewModel.isDeleted,
    });
    return formMsg;
  }

  @Monitor('deviceCardViewModel.deviceName', 'deviceCardViewModel.isDeleted')
  deviceNameChange(monitor: IMonitor) {
    formProvider.updateForm(this.formId, this.getFormBindingData());
  }

  @Monitor('deviceCardViewModel.deviceLatestBriefStateText')
  deviceLatestBriefStateTextChange(monitor: IMonitor) {
    formProvider.updateForm(this.formId, this.getFormBindingData());
  }

  @Builder
  MyMenu() {
    Menu() {
      AddFormMenuItem(
        {
          bundleName: 'XXX.XXX.XXX', // 包名
          abilityName: 'PhoneFormAbility', // 模块ability名称
          parameters: {
            'ohos.extra.param.key.form_dimension': 2,
            'ohos.extra.param.key.form_name': 'widget',
            'ohos.extra.param.key.module_name': 'phone',
          },
        },
        this.compId,
        {
          formBindingData: this.getFormBindingData(),
          callback: (error, formId) => {
            this.formId = formId;

            hilog.info(0x3900, tag, `callback info：error = ${JSON.stringify(error)}, formId = ${formId}`);
            if (error?.code === 0) {
              hilog.info(0x3900, tag, '添加至桌面成功');
            } else {
              hilog.info(0x3900, tag, '添加至桌面失败，请尝试其它添加方式');
            }
          },
        },
      );
    };
  }

  build() {
    DeviceCardView({ deviceId: this.deviceId, pathStack: this.pathStack })
      // .bindContextMenu(this.MyMenu, ResponseType.LongPress, {
      //   placement: Placement.BottomLeft,
      // })
      .id(this.compId);
  }
}
