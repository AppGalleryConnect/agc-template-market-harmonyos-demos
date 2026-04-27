import { InputItem } from './InputItem';

const inputTextList: string[] = ['1', '2', '3', 'Del', '4', '5', '6', '确定', '7', '8', '9', '-', '0', '.']

class KeyboardParams {
  handleInput = (value: string) => {
  }
  handleOk = () => {
  }
  isSmallHeight:boolean = true
}

@Builder
export function NumberKeyboardBuilder(params: KeyboardParams) {
  Column({ space: 5 }) {
    Grid() {
      ForEach(inputTextList, (content: string) => {
        if (content === '确定') {
          GridItem() {
            InputItem({ value: content, type: 'primary' })
          }
          .rowStart(1)
          .rowEnd(4)
          .onClick(() => {
            params.handleOk();
          })
        } else {
          GridItem() {
            InputItem({ value: content })
          }.onClick(() => {
            params.handleInput(content)
          })
        }
      }, (content: string) => content)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .width('100%')
    .height(params.isSmallHeight ? 180 : 300)
  }.width('100%')
  .padding({
    top: 10,
    left: 10,
    right: 10,
    bottom: 20,
  }).borderRadius(0)
  .backgroundColor('#ebebeb')
}