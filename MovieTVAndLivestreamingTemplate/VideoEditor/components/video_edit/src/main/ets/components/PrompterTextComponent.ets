import { EditTextVM } from '../viewmodel/EditTextVM'
import { CommonSize } from '../utils/EditTextUtil'
import { VideoEditDetailVM } from '../viewmodel/VideoEditDetailVM'

@ComponentV2
export struct PrompterTextComponent {
  @Param @Require vm: VideoEditDetailVM
  @Param @Require editTextVM: EditTextVM
  @Param @Require index: number
  @Param @Require activeIndex: number //当前活动的对象
  @Event selectEditText: (index: number) => void = () => {
  }
  @Event activeCurrentZIndex: (index: number) => void = () => {
  }
  @Event checkOverLap: (index: number) => boolean = () => false
  @Event getEditTexts: () => EditTextVM[] = () => []
  @Local isLongPress: boolean = false //组件是否被长按
  @Event alterSite: (index: number) => void = () => {
  }
  bgColor: string | Color = '#F8AC00'
  fontColor: string | Color = '#000000'
  offsetWidth: number = 0
  offsetX: number = 0
  leftSide: number = 0
  rightSide: number = 0
  maxTime: number = 0

  aboutToAppear(): void {
    this.offsetWidth = this.editTextVM.prompterWidth
    this.offsetX = this.editTextVM.prompterX
  }

  @Builder
  TextBuilder(i: number) {
    Row() {
      Divider().color('rgba(0,0,0,0.2)').strokeWidth(2).height(12).vertical(true)
    }
    .visibility(this.activeIndex === this.index && !this.isLongPress ? Visibility.Visible : Visibility.Hidden)
    .width(CommonSize.PROMPTER_TEXT_HEADER_WIDTH)
    .height(26)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .gesture(
      PanGesture()
        .onActionStart((event: GestureEvent | undefined) => {
          if (event) {
            let editTextLIst = this.getEditTexts()
            let len = editTextLIst.length - 1
            if (this.index === 0 && this.index === len) { //仅有一个元素的情况
              this.leftSide = 0
              this.maxTime = this.vm.basicDuration / 1000 >= 60 ? 60 : this.vm.basicDuration / 1000
              this.rightSide = this.maxTime * CommonSize.ONE_SECOND_WIDTH //限制60秒长度
            } else if (this.index === 0) { //元素在最左边
              this.leftSide = 0
              let temp = editTextLIst[this.index + 1]
              this.rightSide = temp.prompterX - CommonSize.PROMPTER_TEXT_DIS
            } else if (this.index === len) { //元素在最右边
              let temp = editTextLIst[this.index - 1]
              this.leftSide = temp.prompterX + temp.prompterWidth + CommonSize.PROMPTER_TEXT_DIS
              this.rightSide = this.vm.basicDuration / 1000 * CommonSize.ONE_SECOND_WIDTH
            } else { //元素在中间
              let tempLeft = editTextLIst[this.index - 1]
              this.leftSide = tempLeft.prompterX + tempLeft.prompterWidth + CommonSize.PROMPTER_TEXT_DIS
              let tempRight = editTextLIst[this.index + 1]
              this.rightSide = tempRight.prompterX - CommonSize.PROMPTER_TEXT_DIS
            }
          }
        })
        .onActionUpdate((event: GestureEvent | undefined) => {
          if (event) {
            let tempWidth = this.offsetWidth + event.offsetX * i

            if (i < 0) { //i<0为左边拉长，需要处理元素位置
              let tempX = this.offsetX + event.offsetX
              if (tempX < this.leftSide) { //约束左边拉长到左边界或左侧元素
                this.editTextVM.prompterWidth = this.offsetWidth + (this.offsetX - this.leftSide)
                this.editTextVM.prompterX = this.leftSide
              } else if (tempWidth < CommonSize.PROMPTER_MIN_WIDTH) { //约束文本框最小值
                //左边向右拉缩小文本宽度至最小值时
                this.editTextVM.prompterX = (this.offsetX + this.offsetWidth - CommonSize.PROMPTER_MIN_WIDTH)
                this.editTextVM.prompterWidth = CommonSize.PROMPTER_MIN_WIDTH
              } else {
                if(tempWidth > this.rightSide){
                  this.getUIContext().getPromptAction().showToast({message:'提词器最大支持'+this.maxTime+'秒时长'})
                  return
                }
                this.editTextVM.prompterX = this.offsetX + event.offsetX
                this.editTextVM.prompterWidth = tempWidth
              }
            } else { //右边拉长
              let freeMaxWidth = this.rightSide - this.offsetX //最大可拉长度
              if (tempWidth > this.rightSide) { //拉到右边边界或右侧元素
                tempWidth = freeMaxWidth
                this.getUIContext().getPromptAction().showToast({message:'提词器最大支持'+this.maxTime+'秒时长'})
              } else if (tempWidth < CommonSize.PROMPTER_MIN_WIDTH) { //约束文本框最小值
                //左边向右拉缩小文本宽度至最小值时
                this.editTextVM.prompterWidth = CommonSize.PROMPTER_MIN_WIDTH
              } else {
                this.editTextVM.prompterWidth = tempWidth
              }
            }
          }
        })
        .onActionEnd(() => {
          this.offsetWidth = this.editTextVM.prompterWidth
          this.offsetX = this.editTextVM.prompterX
          this.editTextVM.startTime = (this.offsetX / CommonSize.ONE_SECOND_WIDTH)
          this.editTextVM.endTime = (this.editTextVM.prompterWidth + this.offsetX) / CommonSize.ONE_SECOND_WIDTH
        })
    )
  }

  build() {
    Row() {
      this.TextBuilder(-1)
      Row() {
        Text(this.editTextVM.textVal)
          .maxLines(1)
          .wordBreak(WordBreak.BREAK_ALL)
          .borderRadius(2)
          .height(24)
          .backgroundColor(this.bgColor)
          .textAlign(TextAlign.Start)
          .align(Alignment.Center)
          .padding({ left: 5, right: 5 })
          .fontSize(11)
          .fontColor(this.fontColor)
          .width(this.editTextVM.prompterWidth)
          .clip(true)
          .opacity(this.isLongPress ? 0.6 : 1)
          .onTouch((event) => { //当长按和拖动顺序组合时，拖动结束不会触发长按结束方法，故此处统一处理取消长按效果
            if (event.type === TouchType.Down) { //手指按下
              this.activeCurrentZIndex(this.index)
            }
            if (event.type === TouchType.Up) { //手指抬起取消长按效果
              this.isLongPress = false
            }
          })
          .gesture(
            GestureGroup(GestureMode.Sequence,
              LongPressGesture({ repeat: true })
                .onAction((event: GestureEvent | undefined) => {
                  if (event) {
                    this.isLongPress = true
                    this.selectEditText(-1)
                  }
                })
                .onActionEnd(() => {
                }),
              PanGesture()//滑动手势
                .onActionUpdate((event: GestureEvent | undefined) => {
                  if (event) {
                    let tempX = this.offsetX + event.offsetX
                    if (tempX < 0) {
                      this.editTextVM.prompterX = 0
                    } else if ((tempX + this.editTextVM.prompterWidth) >
                      (this.vm.basicDuration / 1000 * CommonSize.ONE_SECOND_WIDTH)) {
                      this.editTextVM.prompterX =
                        ((this.vm.basicDuration / 1000 * CommonSize.ONE_SECOND_WIDTH) - this.editTextVM.prompterWidth)
                    } else {
                      this.editTextVM.prompterX = this.offsetX + event.offsetX
                    }

                  }
                })
                .onActionEnd(() => {
                  //检测和其他组件是否重叠
                  if (this.checkOverLap(this.index)) { //有重叠
                    this.editTextVM.prompterX = this.offsetX
                  } else {
                    this.offsetX = this.editTextVM.prompterX
                    this.editTextVM.startTime = (this.offsetX / CommonSize.ONE_SECOND_WIDTH)
                    this.editTextVM.endTime =
                      (this.editTextVM.prompterWidth + this.offsetX) / CommonSize.ONE_SECOND_WIDTH
                    //调整元素在数组中的位置
                    this.alterSite(this.index)
                  }
                })
            )
          )
          .onClick(() => { //长按结束会触发点击，但长按后拖动结束不会触发点击方法
            this.selectEditText(this.index)
          })
      }.height(26).backgroundColor(this.activeIndex === this.index && !this.isLongPress ? '#FFFFFF' : Color.Transparent)

      this.TextBuilder(1)
    }.position({ x: this.editTextVM.prompterX })
    .zIndex(this.editTextVM.prompterZIndex)
  }
}