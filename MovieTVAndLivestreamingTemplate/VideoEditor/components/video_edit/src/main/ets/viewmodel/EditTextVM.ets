import { CommonSize } from '../utils/EditTextUtil'

@ObservedV2
export class EditTextVM {
  id: number = 0
  //上面编辑框的属性
  @Trace textVal: string = ''
  @Trace colorVal: string | Color = Color.White
  @Trace scaleVal: number = 1
  @Trace x: number = 0
  @Trace y: number = 0
  @Trace angle: number = 0
  @Trace width: number = CommonSize.EDIT_TEXT_DEFAULT_WIDTH
  @Trace height: number = CommonSize.EDIT_TEXT_DEFAULT_HEIGHT
  @Trace textAreaHeight: number = CommonSize.EDIT_TEXT_DEFAULT_HEIGHT
  @Trace imgScale: number = 1 //图标缩放比例
  public scroller: Scroller | undefined = undefined
  public snapScroller: Scroller | undefined = undefined
  //下面轨道处的文字控件属性
  @Trace prompterX: number = 0
  @Trace prompterZIndex: number = 0
  @Trace prompterWidth: number = CommonSize.PROMPTER_DEFAULT_WIDTH
  @Trace startTime: number = 0 //单位(秒)
  @Trace endTime: number = this.prompterWidth / CommonSize.PROMPTER_DEFAULT_WIDTH//单位(秒)

  setProps(tempObj: EditTextVM) {
    this.id = tempObj.id
    this.textVal = tempObj.textVal
    this.colorVal = tempObj.colorVal
    this.scaleVal = tempObj.scaleVal
    this.x = tempObj.x
    this.y = tempObj.y
    this.angle = tempObj.angle
    this.width = tempObj.width
    this.height = tempObj.height
    this.imgScale = tempObj.imgScale

    this.prompterWidth = tempObj.prompterWidth
  }

  setId(id: number) {
    this.id = id
  }

  setX(x: number) {
    this.x = x
  }

  setY(y: number) {
    this.y = y
  }

  setColor(color: string | Color) {
    this.colorVal = color
  }

  setPrompterX(val: number) {
    this.prompterX = val
  }

  resetPrompterZIndex() {
    this.prompterZIndex = 0
  }

  activePrompterZIndex() {
    this.prompterZIndex = 1
  }

  setPrompterWidth(val: number) {
    this.prompterWidth = val
  }

  setPrompterStartTIme(time: number) {
    this.startTime = time
  }

  setPrompterEndTIme(time: number) {
    this.endTime = time
  }

  setTextAreaHeight(textAreaHeight: number) {
    this.textAreaHeight = textAreaHeight
  }
}