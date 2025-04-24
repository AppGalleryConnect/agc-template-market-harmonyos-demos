import { Constants } from 'utils';
import { CustomContentDialog } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function HelpCenterPageBuilder(name: string, param: Object) {
  HelpCenterPage();
}

@ComponentV2
export struct HelpCenterPage {
  pathStack: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.BuildCallDialog();
      },
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    cancel: () => {
      console.info('Closed callbacks');
    },
    backgroundColor: Constants.CUSTOM_DIALOG_BACKGROUND_COLOR,
  });

  callCustomerService() {
    call.makeCall('11111111111', (err: BusinessError) => {
      if (!err) {
        console.log('make call success.');
      } else {
        console.log('make call fail, err is:' + JSON.stringify(err));
      }
    });
  }

  @Builder
  BuildCallDialog() {
    List() {
      ListItem() {
        Text('呼叫客服')
          .onClick(() => {
            this.callCustomerService();
          })
          .fontSize(18)
          .fontColor('#0A59F7');
      };
    }
    .alignListItem(ListItemAlign.Center)
    .divider({
      strokeWidth: 1,
      color: '#F1F3F5',
      startMargin: 10,
      endMargin: 10,
    });
  }

  @Builder
  BuildHelper() {
    Row() {
      Image($r('app.media.helper'))
        .size({ width: 35, height: 35 });
    }
    .width('15%')
    .height('100%')
    .onClick(() => {
      this.dialogController.open();
    });
  }

  @Builder
  ShowText(question: string, answer: string) {
    Column() {
      Text(question)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 25, bottom: 20 })
      Text(answer)
        .fontSize(16)
        .fontColor('#ff696868')
        .lineHeight(25)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.ShowText('智慧家居APP有什么功能？','智慧家居APP是一款可以控制智能设备的多功能智能软件，可以控制设备开关等。')
        this.ShowText('一般智能灯适合多大房间使用？','吸顶灯最佳照明效果是15平方米的房间使用。')
        this.ShowText('Pura智能灯有什么功能？','Pura智能灯是一款智能冷暖色吸顶灯，可以通过智慧家居APP进行智能控制。')
        this.ShowText('如何查看产品说明书？','建议与产品制造商沟通，取得产品说明书。')
        this.ShowText('为何控制不了绑定的设备？','建议先检查家中网络情况与设备联网情况。')
      }
      .height('100%')
      .width('90%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('帮助中心')
    .menus(this.BuildHelper)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR);
  }
}