import { Sex } from '../common/Constant';

@ObservedV2
export class ShipPageVM {
  private static _instance: ShipPageVM
  @Trace sex: Sex = Sex.MAN
  @Trace inputText: string = ''
  @Trace inputPlaceholder: string = '点击按钮输入关系'
  @Trace outputText: string = ''
  @Trace outputPlaceholder: string = '点击按钮计算结果'
  @Trace reverse: boolean = false
  @Trace lastText: string = ''
  @Trace count: number = 0
  @Trace showManButton: boolean = false
  @Trace showWomanButton: boolean = false

  public static get instance() {
    if (!ShipPageVM._instance) {
      ShipPageVM._instance = new ShipPageVM();
    }
    return ShipPageVM._instance;
  }

  changeSex(sex: Sex) {
    this.sex = sex
    this.clear()
  }

  handleInput(text: string, uiContext: UIContext) {
    if (this.count > 7) {
      uiContext.getPromptAction().showToast({ message: '超出计算范围' })
      return
    }
    this.count += 1
    switch (text) {
      case '夫':
        this.input('老公')
        break
      case '父':
        this.input('爸爸')
        break
      case '兄':
        this.input('哥哥')
        break
      case '子':
        this.input('儿子')
        break
      case '妻':
        this.input('老婆')
        break
      case '母':
        this.input('妈妈')
        break
      case '姐':
        this.input('姐姐')
        break
      case '女':
        this.input('女儿')
        break
      case '弟':
        this.input('弟弟')
        break
      case '妹':
        this.input('妹妹')
        break
    }
    this.lastText = text
    this.disableButton()
  }

  input(first: string) {
    if (this.inputText === '') {
      this.inputText += first
    } else {
      this.inputText += `的${first}`
    }
  }

  clear() {
    this.inputText = ''
    this.outputText = ''
    this.lastText = ''
    this.reverse = false
    this.count = 0
    this.disableButton()
  }

  init() {
    this.inputText = ''
    this.outputText = ''
    this.lastText = ''
    this.reverse = false
    this.sex = Sex.MAN
    this.count = 0
    this.disableButton()
  }

  disableButton() {
    if (this.lastText === '') {
      if (this.sex === Sex.MAN) {
        this.showManButton = false
        this.showWomanButton = true
      } else {
        this.showManButton = true
        this.showWomanButton = false
      }
    }
    if (this.lastText === '夫' || this.lastText === '父' || this.lastText === '兄' || this.lastText === '子' ||
      this.lastText === '弟') {
      this.showManButton = false
      this.showWomanButton = true
    }
    if (this.lastText === '妻' || this.lastText === '母' || this.lastText === '姐' || this.lastText === '女' ||
      this.lastText === '妹') {
      this.showManButton = true
      this.showWomanButton = false
    }
  }
}
