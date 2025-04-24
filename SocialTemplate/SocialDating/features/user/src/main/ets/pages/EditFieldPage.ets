import { Constants } from 'commons';
import { EditFieldPageParam } from '../model/EditFieldPageParam';

@Builder
export function EditFieldPageBuilder() {
  EditFieldPage()
}

/**
 * 提供一个简单的修改某个数据项的页面，页面中提供一个文本输入框。
 */
@Component
export struct EditFieldPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private pageTitle: string = '';
  @State val: string = '';
  private controller: TextInputController = new TextInputController()
  private textMaxLength: number = Constants.NICK_NAME_MAX_LENGTH;
  private inputCheckFunc?: (input: string) => string;
  private inputType: InputType = InputType.Normal;
  @State errorStr: string = '';

  aboutToAppear(): void {
    let params: EditFieldPageParam[] = this.pageStack.getParamByName('EditFieldPage') as EditFieldPageParam[];
    if (params.length >= 1) {
      this.pageTitle = params[0].title;
      this.val = params[0].currentValue;
      this.textMaxLength = params[0].textMaxLength;
      this.inputCheckFunc = params[0].inputCheckFunc;
      if (params[0].inputType !== undefined) {
        this.inputType = params[0].inputType
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text(this.pageTitle)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Regular)
            .fontFamily(Constants.HARMONY_HEITI)
            .margin({ left: 10, top: 5, bottom: 5 })
            .width('70%')
          Button('完成').backgroundColor($r('app.color.button_background_color'))
            .onClick(() => {
              if (this.checkInput() === '') {
                this.pageStack.pop(this.val, true)
              }
            })
        }.margin({ top: 10 })

        Row() {
          TextInput({ text: this.val, controller: this.controller })
            .caretColor($r('sys.color.font_emphasize'))
            .width('95%')
            .fontSize($r('sys.float.Body_M'))
            .showCounter(true)
            .maxLength(this.textMaxLength)
            .margin(5)
            .type(this.inputType)
            .showError(this.errorStr)
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.val = value;
            })
            .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
              this.checkInput();
              event.keepEditableState();
            })
        }
      }.borderRadius(10)
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
  }

  private checkInput(): string {
    if (this.inputCheckFunc !== undefined) {
      let checkResult = this.inputCheckFunc(this.val);
      if (checkResult !== '') {
        this.errorStr = checkResult;
      } else {
        this.errorStr = '';
      }
      return checkResult;
    }
    return '';
  }
}