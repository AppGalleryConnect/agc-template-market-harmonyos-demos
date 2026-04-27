import { BarVM } from 'video_common';
import ConstantsUtil from '../utils/ConstantsUtil';
import {
  CommonSize, convertWorldTranslateToLocal, getAngle,
} from '../utils/EditTextUtil';
import { EditTextVM } from '../viewmodel/EditTextVM'
import { VideoEditDetailVM } from '../viewmodel/VideoEditDetailVM';

@ComponentV2
export struct EditTextComponent {
  @Param @Require vm: VideoEditDetailVM
  @Param @Require editTextVM: EditTextVM
  @Param @Require index: number
  @Param @Require activeIndex: number //当前活动的对象
  @Param @Require editStatus: boolean //当前对象是否处于编辑状态
  @Param @Require currentTime: number //视频已播放时长
  @Param @Require isPlaying: boolean //视频播放状态

  @Monitor('currentTime')
  onNameChange(monitor: IMonitor) {
    if (!this.isPlaying) { //视频处于未播放状态时，scroll滚动，需要处理视频开始播放的时间以及文本框滚动的位置
      this.lastTime = monitor.value()?.now as number / 1000
      if (this.lastTime < this.editTextVM.startTime ||
        this.lastTime > (this.editTextVM.startTime + this.editTextVM.prompterWidth / CommonSize.ONE_SECOND_WIDTH)) {
        this.yStart = 0 //时间线不在文本框区间内则滚动起始位置重置归0
      } else { //时间线处于文本框区间内，计算文本框滚动的起点
        this.yStart = (this.lastTime - this.editTextVM.startTime) / CommonSize.ONE_LINE_TIME *
        CommonSize.EDIT_TEXT_LINE_HEIGHT + CommonSize.EDIT_TEXT_LINE_HEIGHT / 10
        this.editTextVM.scroller?.scrollTo({
          xOffset: 0,
          yOffset: this.yStart,
          animation: { duration: 100 }
        })
      }
    }
  }

  @Monitor('vm.oldWidth')
  windowSizeChangeMonitor(_monitor: IMonitor) {
    this.offsetX = this.editTextVM.x;
    this.offsetY = this.editTextVM.y;
  }

  offsetX: number = 0;
  offsetY: number = 0;
  routateVal: number = 0
  dScalVal: number = 1
  widthVal: number = 0
  heightVal: number = 0
  lastTime: number = 0
  scroller: Scroller = new Scroller()
  timer: number = 0
  yStart: number = 0 //文本框滚动的位置
  @Event deleteEditText: () => void = () => {
  };
  @Event selectEditText: (index: number) => void = () => {
  };
  @Event addEditText: () => void = () => {
  };

  aboutToAppear(): void {
    this.offsetX = this.editTextVM.x
    this.offsetY = this.editTextVM.y
    this.routateVal = this.editTextVM.angle
    this.dScalVal = this.editTextVM.scaleVal
    this.widthVal = this.editTextVM.width
    this.heightVal = this.editTextVM.height
    this.editTextVM.scroller = this.scroller
  }

  //处理编辑框图标点击事件
  iconOperator(index: number) {
    switch (index) {
      case 0: //关闭弹窗
        this.deleteEditText()
        break;
      case 1: //编辑
        this.selectEditText(this.index)
        break;

      case 3: //复制增加
        this.addEditText()
        break;
      default:
        return
        break;
    }
  }

  @Builder
  buildDetail1() {
    Stack() {
      Scroll(this.scroller) {
        Text(this.editTextVM.textVal || '输入文字...')
          .width('100%')
          .fontColor(this.editTextVM.colorVal)
          .fontSize(16)
          .lineHeight(CommonSize.EDIT_TEXT_LINE_HEIGHT)
          .padding({
            left: 12,
            right: 12,
            top: 0,
            bottom: 0
          })
          .borderRadius(0)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .border({ width: this.activeIndex === this.index ? 1 : 0, color: Color.White })

      Row().width('100%').height('100%')
    }.width('100%')
    .height('100%')
  }

  @Builder
  buildDetail2() {
    Image($r('app.media.icon_edit_text1'))
      .width(24)
      .height(24)
      .position({ left: -12, top: -12 })
      .scale({ x: this.editTextVM.imgScale, y: this.editTextVM.imgScale, z: 1 })
      .visibility(this.activeIndex === this.index ? Visibility.Visible : Visibility.Hidden)
      .onClick(() => {
        this.iconOperator(0)
      })
    Image($r('app.media.icon_edit_text5'))
      .width(24)
      .height(24)
      .draggable(false)
      .position({ right: -12, top: -12 })
      .scale({ x: this.editTextVM.imgScale, y: this.editTextVM.imgScale, z: 1 })
      .visibility((this.activeIndex === this.index) ? Visibility.Visible : Visibility.Hidden)
      .gesture(
        PanGesture()
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) {
              //处理旋转
              let degree = getAngle((this.offsetX + this.widthVal / 2), (this.offsetY + this.heightVal),
                (this.offsetX + this.widthVal + event.offsetX), (this.offsetY + this.heightVal + event.offsetY))
              this.editTextVM.angle = this.routateVal + degree
            }
          })
          .onActionEnd(() => {
            this.routateVal = this.editTextVM.angle
          })
      )

  }

  @Builder
  buildDetail3() {
    Image($r('app.media.icon_edit_text3'))
      .width(24)
      .height(24)
      .position({ right: -12, bottom: -12 })
      .scale({ x: this.editTextVM.imgScale, y: this.editTextVM.imgScale, z: 1 })
      .visibility(this.activeIndex === this.index ? Visibility.Visible : Visibility.Hidden)
      .draggable(false)
      .gesture(
        PanGesture()
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) {
              //拉长宽
              let tempWidth = this.widthVal + event.offsetX
              let tempHeight = this.heightVal + event.offsetY
              if (tempWidth < CommonSize.EDIT_TEXT_MIN_WIDTH) {
                this.editTextVM.width = CommonSize.EDIT_TEXT_MIN_WIDTH
              } else {
                this.editTextVM.width = this.widthVal + event.offsetX
              }
              if (tempHeight < CommonSize.EDIT_TEXT_MIN_HEIGHT) {
                this.editTextVM.height = CommonSize.EDIT_TEXT_MIN_HEIGHT
              } else {
                this.editTextVM.height = this.heightVal + event.offsetY
              }
            }
          })
          .onActionEnd(() => {
            this.widthVal = this.editTextVM.width
            this.heightVal = this.editTextVM.height
          })
      )
  }

  getTextLineCount() {
    let count = 0;
    let str = this.editTextVM.textVal;
    for (let i = 0; i < str.length; i++) {
      if (str[i] === '\n') {
        count++;
      }
    }
    count += Math.round((str.length + 0.5) / CommonSize.EDIT_TEXT_LINE_HEIGHT)
    return count;
  }

  onVisibleAreaChangeAction(isVisible: boolean) {

    this.lastTime = this.currentTime / 1000
    if (isVisible) {
      this.timer = setInterval(() => {
        if (this.isPlaying) {
          this.lastTime = this.currentTime / 1000
          this.yStart += CommonSize.EDIT_TEXT_LINE_HEIGHT / 18
          this.editTextVM.scroller?.scrollTo({
            xOffset: 0,
            yOffset: this.yStart,
            animation: { duration: 100 }
          })
        }
        // }
      }, 100)
    } else {
      clearInterval(this.timer)
      this.lastTime = 0
    }
  }

  onActionUpdateAction(event: GestureEvent | undefined) {
    if (event) {
      // 提词器能移动区域的宽高
      const displayWidth = px2vp(ConstantsUtil.currentDisplayWidth);
      let displayHeight = px2vp(ConstantsUtil.currentDisplayHeight) * 0.515;
      // 提词器移动到底部区域，设置安全间距
      let bottomArea = 0;
      if (ConstantsUtil.isFullScreen) {
        displayHeight = px2vp(ConstantsUtil.currentDisplayHeight);
        bottomArea = BarVM.instance.aiBarH;
      }
      let distance = convertWorldTranslateToLocal(event.offsetX, event.offsetY, this.routateVal)
      // 移动后的位置
      const positionX = this.offsetX + distance[0];
      const positionY = this.offsetY + distance[1];
      if (positionX > (displayWidth - this.vm.clipWidth) / 2 &&
        positionX + this.editTextVM.width < (displayWidth + this.vm.clipWidth) / 2) {
        this.editTextVM.x = positionX;
      }
      if (positionY > (displayHeight - this.vm.clipHeight) / 2 &&
        positionY + this.editTextVM.height < (displayHeight + this.vm.clipHeight - bottomArea) / 2) {
        this.editTextVM.y = positionY;
      }
    }
  }

  build() {
    Row() {
      this.buildDetail1()
      this.buildDetail2()
      this.buildDetail3()
    }
    .constraintSize({ minWidth: CommonSize.EDIT_TEXT_MIN_WIDTH, minHeight: CommonSize.EDIT_TEXT_MIN_HEIGHT })
    .width(this.editTextVM.width)
    .height(this.editTextVM.height)
    .visibility((this.editTextVM.startTime > this.vm.currentScrollX ||
      (this.editTextVM.startTime + this.editTextVM.prompterWidth / CommonSize.ONE_SECOND_WIDTH) <
      this.vm.currentScrollX) ?
    Visibility.Hidden : Visibility.Visible)
    .onVisibleAreaChange([0.0], (isVisible: boolean, _currentRatio: number) => {
      this.onVisibleAreaChangeAction(isVisible)
    })
    .scale({ x: this.editTextVM.scaleVal, y: this.editTextVM.scaleVal, z: 0 })
    .rotate({
      x: 0,
      y: 0,
      z: 1,
      angle: this.editTextVM.angle
    })
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent | undefined) => {
          this.onActionUpdateAction(event)
        })
        .onActionEnd(() => {
          this.offsetX = this.editTextVM.x
          this.offsetY = this.editTextVM.y
        })
    )
    .onClick(() => {
      this.selectEditText(this.index)
    })
  }
}