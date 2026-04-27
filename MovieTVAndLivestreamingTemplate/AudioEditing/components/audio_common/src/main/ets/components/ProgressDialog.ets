import { ProgressDialogInfo } from '../model/ProgressDialogModel';
import { ProgressDialogVM } from '../viewModel/ProgressDialogVM';
import { FileUtil } from '../../../../Index';
import { common } from '@kit.AbilityKit';


@Builder
export function ProgressDialog(info: ProgressDialogInfo) {
  customProgressDialog({ info })
}

@ComponentV2
struct customProgressDialog {
  @Param @Require info: ProgressDialogInfo;
  uiContext = this.getUIContext();
  vm: ProgressDialogVM = new ProgressDialogVM(this.uiContext);

  @Monitor('vm.exportStateInfo.completeValue')
  infoPropertyChange() {

    this.vm.dialogState.completeValue = this.vm.exportStateInfo.completeValue
    ProgressDialogVM.contentNode?.update(this.vm.dialogState);


  }

  aboutToAppear(): void {
    ProgressDialogVM.completeState = false
    this.vm.uIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.vm.dialogState = this.info as ProgressDialogInfo;
    this.vm.getCompleteValue(this.vm.dialogState.fileTime)


  }

  onCancel() {
    clearInterval(this.vm.timer)
    new FileUtil(this.vm.uIAbilityContext!).deleteFileByPath(this.vm.dialogState.logoFilePath)
    this.vm.closeDialog()
    this.vm.dialogState.cancel()
  }

  build() {
    Column() {
      Column() {
        Text(this.vm.dialogState.progressTitle)
          .fontSize(20)
          .fontColor($r('sys.color.font_on_primary'))

        Column() {
          Text(this.vm.dialogState.completeValue + '%')
            .fontColor('#01FCEA')
            .fontSize(24)
        }
        .margin({
          top: 43,
          bottom: 15,
        })

        Stack() {
          Column() {

          }
          .width('100%')
          .height(8)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(12)

          Column() {

          }
          .height(8)
          .width(this.vm.dialogState.completeValue + '%')
          .borderRadius(12)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#C707FF', 0.0], ['#01FCEA', 1]]
          })

        }

        .alignContent(Alignment.Start)
        .width('100%')
        .margin({
          bottom: 41
        })

        Column() {
          Text('取消')
            .fontSize(16)
            .fontColor('#01FCEA')
            .borderRadius(20)
            .textAlign(TextAlign.Center)
            .width(156)
            .height(40)
            .border({
              width: 1,
              color: '#01FCEA'
            })
            .backgroundColor('#00000000')
            .onClick(() => {
              this.onCancel()
            })
        }.width('100%')
        .justifyContent(FlexAlign.Center)

      }
      .padding({
        top: 23,
        bottom: 24,
        left: 24,
        right: 24
      })

      .borderRadius(32)
      .backgroundColor('#202E3E')
    }

    .padding({
      left: 20,
      right: 20
    })
    .width('100%')
  }
}
