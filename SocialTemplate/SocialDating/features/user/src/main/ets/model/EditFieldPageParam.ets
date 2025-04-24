
export class EditFieldPageParam{
  title:string = '';
  currentValue:string = '';
  textMaxLength: number = 16;
  inputType:InputType = InputType.Normal;
  inputCheckFunc?: (input: string) => string;

  constructor(title: string, currentValue: string, textMaxLength: number, inputTypeParam?:InputType,
    inputCheckFunc?: (input: string) => string) {
    this.title = title;
    this.currentValue = currentValue;
    this.textMaxLength = textMaxLength;
    if(inputTypeParam !== undefined) {
      this.inputType = inputTypeParam;
    }
    this.inputCheckFunc = inputCheckFunc;
  }
}