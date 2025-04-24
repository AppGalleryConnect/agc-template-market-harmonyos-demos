import { Constants } from 'utils';
import { AdviceFeedbackViewMode } from '../viewmodel/AdviceFeedbackViewModel';
import { prompt } from '@kit.ArkUI';


@Builder
export function AdviceFeedbackPageBuilder(name: string, param: Object) {
  AdviceFeedbackPage();
}

@ComponentV2
export struct AdviceFeedbackPage {
  pathStack: NavPathStack = new NavPathStack();
  adviceFeedbackViewMode: AdviceFeedbackViewMode = new AdviceFeedbackViewMode();
  @Local issue: string = '';
  @Local contact: string = '';
  issueController: TextInputController = new TextInputController();
  contactController: TextInputController = new TextInputController();

  @Styles
  TextInputStyle() {
    .margin({ top: 14, bottom: 30 })
    .borderRadius(0)
    .backgroundColor(Constants.TEXT_INPUT_BACKGROUND_COLOR);
  }

  @Builder
  BuildIssue() {
    Column() {
      Column() {
        Text('问题描述')
          .fontColor('#333333')
          .fontSize(16)
          .margin({ top: 16 })
          .fontWeight(FontWeight.Regular);
        TextArea({ text: this.issue, controller: this.issueController, placeholder: '请输入您的问题' })
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .height(150)
          .fontSize(15)
          .maxLength(200)
          .showCounter(true)
          .TextInputStyle()
          .onChange((value: string) => {
            this.issue = value;
          });
      }
      .width('90%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('90%')
    .borderRadius(16)
    .margin({ top: 10 })
    .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR);
  }

  @Builder
  BuildContact() {
    Column() {
      Column() {
        Text('联系方式')
          .fontColor('#333333')
          .fontSize(16)
          .margin({ top: 16 })
          .fontWeight(FontWeight.Regular);
        TextInput({ text: this.contact, controller: this.contactController, placeholder: '请留下您的联系方式' })
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .height(50)
          .fontSize(15)
          .TextInputStyle()
          .onChange((value: string) => {
            this.contact = value;
          });
      }
      .width('90%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('90%')
    .borderRadius(16)
    .margin({ top: 25 })
    .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR);
  }

  @Builder
  BuildSubmit() {
    Button('提交')
      .onClick(() => {
        if (this.adviceFeedbackViewMode.submit(this.issue, this.contact)) {
          this.pathStack.pop();
        }
      })
      .margin({ top: 50 })
      .width('90%');
  }

  build() {
    NavDestination() {
      Column() {
        this.BuildIssue();
        this.BuildContact();
        this.BuildSubmit();
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('意见反馈')
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