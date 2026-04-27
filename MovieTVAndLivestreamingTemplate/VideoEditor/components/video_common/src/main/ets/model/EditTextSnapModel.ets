//@ObservedV2
export class EditTextSnapModel {
  textVal: string = ''
  colorVal: string | Color = Color.White
  scaleVal: number = 1
  x: number = 0
  y: number = 0
  angle: number = 0
  width: number = 130
  height: number = 40
  imgScale: number = 1 //图标缩放比例
  public scroller: Scroller | undefined = undefined
  public snapScroller: Scroller | undefined = undefined
  //下面轨道处的文字控件属性
  prompterX: number = 0
  prompterZIndex: number = 0
  prompterWidth: number = 50
  startTime: number = 0 //单位(秒)
  endTime: number = 0 //单位(秒)
  urlList: string[] = []
}
