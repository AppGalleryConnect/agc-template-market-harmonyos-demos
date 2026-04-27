import { exportPipVideo, frameListData } from 'video_common';
import { DisplayUtil } from '../utils/DisplayUtil';
import { CommonSize } from '../utils/EditTextUtil';
import { VideoEditDetailVM } from '../viewmodel/VideoEditDetailVM';
import ConstantsUtil from '../utils/ConstantsUtil';
import { MultiImage } from './MultiImage';

/**
 * @usage: 画中画组件，用于在视频编辑中添加和调整画中画视频轨道，支持时间轴拖拽和裁剪
 * @layout: 横向布局，左侧占位区+左手柄+画中画帧列表+右手柄+右侧占位区
 * @isGen: true
 * @fileType: component
 * @zhName: 画中画组件
 * @domain: 视频
 * @component: MultiImage
 */
@ComponentV2
export struct PipComponent {
  uiContext: UIContext = this.getUIContext();
  @Param @Require exportPipVideos: exportPipVideo[];
  @Param @Require vm: VideoEditDetailVM
  @Param @Require length: number
  @Param @Require isSelected: boolean
  @Local leftOffsetX: number = 0
  @Local offsetWidth: number = 0
  @Local rightOffsetX: number = 0
  @Local pipScroller: Scroller = new Scroller()
  @Local leftSide: number = 0
  @Local leftFlag: boolean = false
  @Local downMarginLeft: number = 0;
  @Local startX: number = 0;
  @Local longPress: boolean = false
  @Event changeLength: (x: number) => void = (x: number) => {}
  @Event changeSelect: (x: boolean) => void = (x: boolean) => {}
  @Event changeXOffset: () => void = () => {}
  private disPlayWidth = this.uiContext.px2vp(DisplayUtil.getWidth())
  private disPlayHeight = this.uiContext.px2vp(DisplayUtil.getHeight())

  aboutToAppear(): void {}

  @Builder
  TextBuilder(i: number) {
    Row() {
      Divider().color('rgba(0,0,0,0.2)').strokeWidth(2).height(12).vertical(true)
    }
    .width(CommonSize.PROMPTER_TEXT_HEADER_WIDTH)
    .height(30)
    .offset({ x: i === 0 ? this.leftFlag ? 0 : this.leftOffsetX : this.rightOffsetX })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .visibility(this.showHandler())
    .zIndex(10)
    .priorityGesture(
      PanGesture({ fingers: 1, distance: 5 })
        .onActionStart(async event => {
        })
        .onActionUpdate(async event => {
          let distance = this.length - this.leftSide
          if (i === 0) { //左手柄
            if (distance - event.offsetX > CommonSize.EDIT_TEXT_MIN_WIDTH &&
              distance - event.offsetX <
                this.exportPipVideos[0]?.pipFrameList.length * CommonSize.EDIT_TEXT_MIN_WIDTH) {
              if (event.offsetX < 0) {
                this.leftFlag = true
              }
              this.leftOffsetX = event.offsetX
              this.leftSide = event.offsetX
            }
          } else { //右手柄
            if (distance + event.offsetX > CommonSize.EDIT_TEXT_MIN_WIDTH &&
              distance + event.offsetX <
                this.exportPipVideos[0]?.pipFrameList.length * CommonSize.EDIT_TEXT_MIN_WIDTH) {
              this.rightOffsetX = event.offsetX
            }
          }
        })

        .onActionEnd(() => {
          if (i === 0) {
            this.exportPipVideos[0].startTime =
              this.exportPipVideos[0].startTime + Math.round(1000 * this.leftOffsetX / CommonSize.EDIT_TEXT_MIN_WIDTH)
            this.leftOffsetX = 0
            this.changeLength((this.length - this.leftSide) / CommonSize.EDIT_TEXT_MIN_WIDTH)
            this.leftSide = 0
            this.leftFlag = false
            setTimeout(() => {
              this.pipScroller.scrollToIndex(this.exportPipVideos[0]?.pipFrameList.length - 1);
            }, 100);
          } else {
            this.exportPipVideos[0].endTime =
              this.exportPipVideos[0].endTime + Math.round(1000 * this.rightOffsetX / CommonSize.EDIT_TEXT_MIN_WIDTH)
            this.changeLength((this.length + this.rightOffsetX) / CommonSize.EDIT_TEXT_MIN_WIDTH)
            this.rightOffsetX = 0
          }
          this.exportPipVideos[0].duration = this.exportPipVideos[0].endTime - this.exportPipVideos[0].startTime
        })
    )
  }

  build() {
    Row() {
      Row()
        .translate({ x: this.leftOffsetX })
        .width(this.vm.isFullScreen
          ? this.disPlayHeight / 2 - CommonSize.PROMPTER_TEXT_HEADER_WIDTH
          : this.disPlayWidth / 2 - CommonSize.PROMPTER_TEXT_HEADER_WIDTH)
        .backgroundColor('#1C1C1C')
        .height(31)
        .zIndex(1)
      this.TextBuilder(0)
      List({ scroller: this.pipScroller }) {
        ForEach(this.exportPipVideos[0]?.pipFrameList, (item: frameListData) => {
          ListItem() {
            MultiImage({
              imageData: item,
              imageWidth: ConstantsUtil.IMAGE_WIDTH,
              imageHeight: ConstantsUtil.PIP_IMAGE_HEIGHT,
              flag: false,
              onClickEvent: () => {
                this.changeSelect(true)
              }
            })
          }.translate({ x: this.leftFlag ? -this.leftOffsetX : 0 })
        })
      }
      .border({
        width: this.isSelected ? 1 : 0,
        color: Color.White
      })
      .enabled(true)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .enableScrollInteraction(false)
      .alignListItem(ListItemAlign.Center)
      .width(this.length)
      .height(31)
      .zIndex(0)

      this.TextBuilder(1)
      Row()
        .translate({ x: this.rightOffsetX })
        .backgroundColor('#1C1C1C')
        .width(this.vm.isFullScreen
          ? this.uiContext.px2vp(DisplayUtil.getHeight()) / 2
          : this.uiContext.px2vp(DisplayUtil.getWidth()) / 2)
        .height(31)
        .zIndex(2)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height(30)
    .margin({ left: this.vm.pipXOffset })
    .priorityGesture(
      GestureGroup(GestureMode.Sequence,
        LongPressGesture({ repeat: true, duration: 300 })
          .onAction((event) => {
            this.longPress = true
          })
          .onActionEnd(() => {
            this.longPress = false
          }),
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            this.downMarginLeft = this.vm.pipXOffset
          })
          .onActionUpdate((event: GestureEvent) => {
            if(this.longPress ){
              if(this.vm.basicDuration > this.vm.pipDuration){
                if(this.downMarginLeft + event.offsetX <= (this.vm.basicDuration - this.vm.pipDuration)/ 1000 * 50){
                  let tmpMarginLeft = this.downMarginLeft + event.offsetX;
                  if (tmpMarginLeft < 0) {
                    tmpMarginLeft = 0;
                  }
                  this.vm.pipXOffset = tmpMarginLeft
                }
              }else {
                  this.vm.pipXOffset = 0
                }
              }
          })
          .onActionEnd(()=>{
            this.vm.pipXDistance = Math.round(this.vm.pipXOffset / this.vm.basicThumbnailWidth * 1000)/1000
            this.longPress = false
            this.changeXOffset()
          })
          )
        )
  }

  private showHandler(){
    if(this.exportPipVideos[0]?.pipFrameList.length === 0){
      return Visibility.Hidden
    }else {
      if(this.longPress){
        return Visibility.Hidden
      }else {
        if(this.isSelected){
          return Visibility.Visible
        }else {
          return Visibility.Hidden
        }
      }
    }
  }
}