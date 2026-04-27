import { common } from '@kit.AbilityKit';
import { JSON, util } from '@kit.ArkTS';
import { VideoEditDetailVM } from '../viewmodel/VideoEditDetailVM';
import { BottomNavigationModel, FUNCTION_BUTTON_INFO, FUNCTION_BUTTON_TOAST_INFO } from '../model/BottomTabModel';
import ConstantsUtil, { ActionWithAppBean } from '../utils/ConstantsUtil';
import { DisplayUtil } from '../utils/DisplayUtil';
import { curves, display, EllipseShape, promptAction, RectShape, AlertDialog } from '@kit.ArkUI';
import { EditTextComponent } from '../components/EditTextComponent';
import { PrompterListVM } from '../viewmodel/PrompterListVM';
import { EditTextVM } from '../viewmodel/EditTextVM';
import { TelePrompterDialog } from '../components/PrompterDialog';
import { PrompterTextComponent } from '../components/PrompterTextComponent';
import { CommonSize, getMultiData, hasAnyOverlap, sort } from '../utils/EditTextUtil';
import { ColorSelectDialog } from '../components/ColorSelectDialog';
import { EditTextSnap } from '../components/EditTextSnap';
import { PipComponent } from '../components/PipComponent';
import { deleteFolderRecursively, formatTime, savePixelMapToAlbum, saveScreenshot } from '../utils/CommonUtils';
import { SelectWithWhiteArrow } from '../components/SelectWithWhiteArrow';
import { BarVM, BasicVideoData, EditTextSnapModel, exportVideo, frameListData, TValueType } from 'video_common';
import { MultiImage } from '../components/MultiImage';
import { failSaveWork } from '../utils/ExportVideoUtil';
import { emitter, systemDateTime } from '@kit.BasicServicesKit';
import { SubtitlesSingleModel } from '../model/SubtitlesSingleModel';
import { VELoading } from '../components/VELoading';

@Builder
export function VideoEditDetailPageBuilder() {
  VideoEditDetailPage();
}

/**
 * @usage: 用于视频编辑详情页面，提供视频剪辑、画中画、提词器、字幕等编辑功能。
 * 支持视频帧预览、拖动排序、分割、缩放等操作。
 * 关键数据结构：BasicVideoData视频数据模型，EditTextVM提词器文本模型，isShrinked缩放模式状态，
 * dragParentIndex拖动索引。包含if逻辑：根据editStatus显示提词器编辑弹窗，根据colorSelectStatus显示颜色选择弹窗。
 * @layout: 页面整体采用垂直布局（Column）。顶部为标题栏（横向排列），中间为视频预览区域（Stack布局），
 * 下方为视频帧编辑区域（横向滚动列表），底部为功能按钮导航栏（横向排列）。
 * @constraints:
 * @zhName: 视频编辑详情页
 * @fileType: page
 * @isGen: true
 * @subPage: ExportVideoPage
 * @component: EditTextComponent,TeleTextComponent,TelePrompterDialog,ColorSelectDialog,TransformLoading
 */
@ComponentV2
export struct VideoEditDetailPage {
  @Local isJump2LoginPage: boolean = false;
  vm: VideoEditDetailVM = VideoEditDetailVM.instance
  barVm: BarVM = BarVM.instance
  stack: NavPathStack | null = null;
  @Local pageParam: TValueType = null
  @Local editSelectedIndex: number = 0;
  @Local leftWidthOrigin: number = 0
  @Local currentTime: number = 0;
  @Local currentPageIndex: number = 0;
  @Local offsetX: number = 0;
  @Local offsetY: number = 0;
  @Local startX: number = 0;
  @Local startY: number = 0;
  xComponentController1: XComponentController = new XComponentController();
  xComponentController2: XComponentController = new XComponentController();
  proFreshTimer: number = 0;
  uiContext: UIContext = this.getUIContext(); // 获取UI上下文
  ctx: common.Context = this.uiContext.getHostContext() as common.Context;
  scrollerMain: Scroller = new Scroller();
  @Local selectedIndex: number = -1; // 记录当前选中的图片索引（-1表示未选中）
  @Local voiceState: boolean = true
  @Local teleprompterListVM: PrompterListVM = PrompterListVM.instance
  @Local editTextSnapList: EditTextSnapModel[] = []
  // 父级拖动排序状态（拖动父ListItem）
  @Local isShrink: boolean = false; // 是否所有父项缩成50px
  @Local dragParentIndex: number = -1; // 当前拖动的父ListItem索引
  @Local scaleParentIndex: number = -1; // 当前缩放的父ListItem索引
  @Local neighborParentIndex: number = -1; // 相邻父ListItem索引
  @Local neighborScale: number = 1;
  @Local isDragging: boolean = false;
  @Local dragRefOffset: number = 0;
  // 尺寸配置
  private PARENT_SPACING: number = 10; // 父项间距
  private SCALE_MAX: number = 1.1; // 拖动项缩放
  private SCALE_NEIGHBOR: number = 0.9; // 相邻项缩放
  @Local dropTargetIndex: number = -1; // -1 表示未指向任何空隙
  @Local isDropping: boolean = false; // 手指抬起时正在“落位”
  @Local jumpDirection: number = 0; // 1 向右跳，-1 向左跳
  @Local dropFingerIndex: number = 0; //手指按下的位置坐标
  @Local baseOffset: number = 0
  @Local handlerLeftStart: boolean = false
  @Local handlerRightStart: boolean = false
  @Local timer: number = -1
  @Local startOffset: number = 0; // fling 瞬间的基准
  @Local movedOffset: number = 0; // 本次 fling 已移动的距离
  private disPlayWidth = this.uiContext.px2vp(DisplayUtil.getWidth())
  private disPlayHeight = this.uiContext.px2vp(DisplayUtil.getHeight())
  @Local isJump2Vip: boolean = false
  @Local isExpanded: boolean =
    display.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED;
  @Local isButtonClickable: boolean = true
  exitControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '提示',
      content: '要保存到草稿吗？',
      primaryButton: {
        value: '取消',
        action: () => {
          if (!this.isButtonClickable) {
            return;
          }
          this.isButtonClickable = false
          this.vm.resultCode = 1
          this.stack?.pop()
          this.exitControllerConfirm.close()
        },
      },
      secondaryButton: {
        value: '保存',
        role: ButtonRole.ERROR,
        action: async () => {
          if (!this.isButtonClickable) {
            return;
          }
          this.isButtonClickable = false
          this.vm.loadingText = '草稿保存中...'
          this.vm.isComposeLoading = true
          await this.prompterSnapAction()
          await this.saveSubtitles()
          this.stack?.pop()
          this.exitControllerConfirm.close()
        }
      },
    }),
  })

  isExporting = false; //正在导出

  getPaddingH() {
    if (this.isExpanded) {
      return 24
    } else {
      return 16
    }
  }

  @Monitor('vm.totalDuration')
  getNumberLength() {
    const count =
      Number((Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000) / 1000).toFixed(3));
    this.vm.durationLength = Array.from<undefined, number>({ length: count + 1 }, (_, i) => i)
  }

  @Monitor('vm.srcHeight')
  changeWidthAndHeight() {
    const currentWindowSize =
      { width: ConstantsUtil.currentDisplayWidth, height: ConstantsUtil.currentDisplayHeight } as Size
    this.vm.setClipSize(currentWindowSize);

    // 重新设置提词器容器内容
    this.resetTeleprompterList();
  }

  // 重新设置提词器容器内容
  resetTeleprompterList() {
    if (this.vm.exportTextSnapList.length > 0) {
      this.editTextSnapList = this.vm.exportTextSnapList
      this.teleprompterListVM.editTexts = [];
      this.vm.exportTextSnapList.forEach((item) => {
        let editTextVM: EditTextVM = new EditTextVM()
        editTextVM.textVal = item.textVal
        editTextVM.x = item.x / this.vm.srcWidth * this.vm.clipWidth +
          (this.uiContext.px2vp(ConstantsUtil.BASIC_VIDEO_WIDTH) - this.vm.clipWidth) / 2
        editTextVM.y = item.y / this.vm.srcHeight * this.vm.clipHeight +
          (this.uiContext.px2vp(ConstantsUtil.BASIC_VIDEO_HEIGHT) - this.vm.clipHeight) / 2
        editTextVM.width = item.width / this.vm.srcWidth * this.vm.clipWidth
        editTextVM.height = item.height / this.vm.srcHeight * this.vm.clipHeight
        editTextVM.angle = item.angle
        editTextVM.colorVal = item.colorVal
        editTextVM.scaleVal = item.scaleVal
        editTextVM.scroller = new Scroller()
        editTextVM.snapScroller = new Scroller()
        editTextVM.prompterX = item.prompterX
        editTextVM.prompterZIndex = item.prompterZIndex
        editTextVM.prompterWidth = item.prompterWidth
        editTextVM.startTime = item.startTime
        editTextVM.endTime = item.endTime
        this.teleprompterListVM.editTexts.push(editTextVM)
      })
    }
  }

  @Monitor('vm.srcPipHeight')
  changePipWidthAndHeight() {
    if (this.vm.srcPipWidth > this.vm.srcPipHeight) {
      this.vm.clipPipWidth = this.vm.clipWidth / 2
      this.vm.clipPipHeight = this.vm.clipPipWidth * (this.vm.srcPipHeight / this.vm.srcPipWidth)
    } else {
      this.vm.clipPipHeight = this.vm.clipHeight / 2
      this.vm.clipPipWidth = this.vm.clipPipHeight * (this.vm.srcPipWidth / this.vm.srcPipHeight)
    }
    this.vm.clipPipWidthT = this.vm.clipPipWidth
    this.vm.clipPipHeightT = this.vm.clipPipHeight
  }

  @Monitor('vm.surfaceId')
  onChangeSurfaceId() {
    if (!this.vm.videoPlayer && this.vm.surfaceId !== '') {
      this.vm.initBasicPlayer()
    }
  }

  @Monitor('vm.isPlaying')
  stopScroller() {
    if (this.vm.isPlaying) {
      this.scrollerPlaying()
    } else {
      clearInterval(this.timer)
      this.timer = -1
      this.movedOffset = 0
    }
  }

  scrollerPlaying(){
    const distance = Number((this.vm.basicThumbnailWidth * this.disPlayHeight / this.disPlayWidth).toFixed(3))
    this.timer = setInterval(() => {
      const now = this.scrollerMain.currentOffset().xOffset
      if (this.vm.isFullScreen) {
        this.vm.currentTime = Number((now / distance).toFixed(3)) * 1000
        this.vm.currentScrollX = now / distance
      } else {
        this.vm.currentTime = Number((now / this.vm.basicThumbnailWidth).toFixed(3)) * 1000
        this.vm.currentScrollX = now / this.vm.basicThumbnailWidth
      }
      if (this.vm.currentTime ===
        Number((Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000) /
          1000).toFixed(3)) * 1000) {
        this.vm.isPlaying = false
      }
      this.movedOffset = now - this.startOffset // 实时移动量
      if (this.vm.isFullScreen) {
        this.fullScreenPlaying(distance)
      } else {
        this.halfScreenPlaying()
      }
    }, 10)
  }

  fullScreenPlaying(distance: number){ //全屏播放状态
    if (this.movedOffset / distance * 1000 > this.vm.pipXDistance &&
      this.movedOffset / distance * 1000 < this.vm.exportPipVideos[0]?.duration + this.vm.pipXDistance * 1000) {
      if (this.vm.avPlayerPip && ['prepared', 'paused'].includes(this.vm.avPlayerPip.state)) {
        this.vm.playPip()
      }
      this.vm.showPip = true
    } else {
      this.vm.avPlayerPip?.pause()
      this.vm.showPip = false
    }
    if (this.movedOffset / distance * 1000 > this.vm.basicDuration) {
      this.vm.showBasic = false
    } else {
      this.vm.showBasic = true
    }
  }

  halfScreenPlaying(){ //半屏播放状态
    if (this.movedOffset / this.vm.basicThumbnailWidth * 1000 > this.vm.pipXDistance * 1000 &&
      this.movedOffset / this.vm.basicThumbnailWidth * 1000 <
        this.vm.exportPipVideos[0]?.duration + this.vm.pipXDistance * 1000) {
      if (this.vm.avPlayerPip && ['prepared', 'paused'].includes(this.vm.avPlayerPip.state)) {
        this.vm.playPip()
      }
      this.vm.showPip = true
    } else {
      this.vm.avPlayerPip?.pause()
      this.vm.showPip = false
    }
    if (this.movedOffset / this.vm.basicThumbnailWidth * 1000 > this.vm.basicDuration) {
      this.vm.showBasic = false
    } else {
      this.vm.showBasic = true
    }
  }

  judgeChildListWidth(currentIndex: number, childList: frameListData[]): number {
    if (this.handlerLeftStart) {
      if (this.vm.basicParentSelectIndex === currentIndex) {
        return childList.length * this.vm.basicThumbnailWidth
      } else {
        return this.vm.listRightHandlerPosition[currentIndex]
      }
    }

    if (this.handlerRightStart) {
      if (this.vm.basicParentSelectIndex === currentIndex) {
        return this.vm.listRightHandlerPosition[currentIndex] + this.vm.handlerOffsetX
      } else {
        return this.vm.listRightHandlerPosition[currentIndex]
      }
    } else {
      return this.vm.listRightHandlerPosition[currentIndex]
    }
  }

  judgeChildListOffset(currentIndex: number): number {
    if(currentIndex !== 0){
      let splitOffset = this.vm.allBasicListDisplay[currentIndex].splitLeft * this.vm.basicThumbnailWidth
      setTimeout(() => {
        this.vm.allBasicListDisplay[currentIndex].scroller?.scrollTo({xOffset:splitOffset,yOffset: 0})
      }, 10);
    }
    if (this.handlerLeftStart) {
      if (this.vm.basicParentSelectIndex <= currentIndex) {
        return 0
      } else {
        return this.vm.childListLeftWidth
      }
    } else {
      return 0
    }
  }

  getTranslateX(parentIndex: number) {
    return (this.dragParentIndex === parentIndex) ? this.offsetX :
      // ① 手指拖动量
      (this.isShrink && this.jumpDirection > 0 && parentIndex > this.dragParentIndex &&
        parentIndex <= this.dropTargetIndex) ? -(this.vm.basicThumbnailWidth + this.PARENT_SPACING) :
        // ② 向右拖：后面向左让
        (this.isShrink && this.jumpDirection < 0 && parentIndex < this.dragParentIndex &&
          parentIndex >= this.dropTargetIndex) ? (this.vm.basicThumbnailWidth + this.PARENT_SPACING) :
          // ③ 向左拖：前面向右让
          0 // ④ 不动
  }

  // 父项缩放比例
  getParentScale(currentIndex: number): number {
    if (this.scaleParentIndex === currentIndex) {
      return this.SCALE_MAX;
    } else if (this.neighborParentIndex === currentIndex) {
      return this.neighborScale;
    }
    return 1;
  }

  // 计算父项总宽度（子项总宽+间距）
  getParentWidth(currentIndex: number, childList: frameListData[]): number {
    return this.isShrink
      ? this.vm.basicThumbnailWidth  // 缩小时：固定50px（单帧宽度）
      : this.vm.isFullScreen
        ? this.judgeChildListWidth(currentIndex, childList) * this.disPlayHeight / this.disPlayWidth
        : this.judgeChildListWidth(currentIndex, childList)
  }

  // 交换父ListItem位置
  parentItemMove(fromParentIdx: number, toParentIdx: number): void {
    if (fromParentIdx === toParentIdx) {
      return;
    }
    const temp = this.vm.listRightHandlerPosition.splice(fromParentIdx, 1)[0];
    this.vm.listRightHandlerPosition.splice(toParentIdx, 0, temp);
    // 交换父列表项
    const newArr = [...this.vm.allBasicListDisplay]
    const item = newArr.splice(fromParentIdx, 1)[0]
    newArr.splice(toParentIdx, 0, item)
    //遍历新数组，更新每个元素的index为当前所在位置（新位置）
    for (let index = 0; index < newArr.length; index++) {
      const element = newArr[index];
      element.keyId = systemDateTime.getTime(true).toString();
    }

    this.vm.allBasicListDisplay = newArr
    this.vm.updateCoverData()
    //更新视频片段源
    this.vm.updateVideoSegments(this.vm.allBasicListDisplay)
    // 两个视频长按左右切换后，切换播放机、更换视频fd、seek到对应位置（时间戳）
    this.vm.videoPlayer?.parentItemMoveSeek(this.vm.currentTime, this.vm.allBasicListDisplay);
  }

  // 长按进入缩放模式（所有父项缩成50px）
  enterShrinkMode(currentIndex: number): void {
    animateTo({ curve: Curve.EaseInOut, duration: 300 }, () => {
      this.isShrink = true; // 触发全局缩放
      this.scaleParentIndex = currentIndex; // 高亮当前长按项
    });
  }

  // 退出缩放模式
  exitShrinkMode(): void {
    animateTo({ curve: Curve.EaseInOut, duration: 300 }, () => {
      this.isShrink = false;
      this.scaleParentIndex = -1;
      this.dragParentIndex = -1;
      this.neighborParentIndex = -1;
      this.isDragging = false;
      this.offsetX = 0;
    });
  }

  // 复位所有拖动相关状态
  reset(): void {
    animateTo({ curve: Curve.EaseInOut, duration: 200 }, () => {
      this.isShrink = false;
      this.isDragging = false;
      this.dragParentIndex = -1;
      this.scaleParentIndex = -1;
      this.neighborParentIndex = -1;
      this.dropTargetIndex = -1; // 插入提示条复位
      this.offsetX = 0;
      this.dragRefOffset = 0;
      this.neighborScale = 1;
    });
  }

  dealWithDidScroll(scrollOffset: number, scrollState: ScrollState) {
    if (this.vm.touchScroll && !this.vm.touchVoice) {
      this.vm.currentScrollX =
        Number((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth).toFixed(3))
      let frameIndex = Math.floor((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth))
      this.vm.currentTime = this.vm.currentScrollX * 1000
      // 记录当前白线对应的item索引
      this.vm.currentWhiteLineIndex = frameIndex
      if (this.vm.currentScrollX >= 0) {
        if (this.vm.currentScrollX * 1000 >= this.vm.pipXDistance * 1000 &&
          this.vm.currentScrollX * 1000 <= this.vm.exportPipVideos[0]?.duration + this.vm.pipXDistance * 1000) {
          this.vm.showPip = true
        } else {
          this.vm.showPip = false
        }
        if (this.vm.currentScrollX * 1000 <= this.vm.basicDuration) {
          this.vm.showBasic = true
        } else {
          this.vm.showBasic = false
        }
        this.vm.currentBasicFrame = this.vm.pixelMapBasicList[frameIndex]
        this.vm.currentWhiteLineParentIndex =
          this.vm.findTargetInParent(this.vm.allBasicListDisplay, this.vm.currentWhiteLineIndex)
        let beforeLength = 0
        let beforeTime = 0
        for (let i = 0; i < this.vm.currentWhiteLineParentIndex; i++) {
          beforeLength += Number(((this.vm.listRightHandlerPosition[i] / ConstantsUtil.IMAGE_WIDTH)).toFixed(3))
          beforeTime += this.vm.allBasicListDisplay[i].duration
        }
        this.vm.basicVideoCover = this.vm.allBasicListDisplay[this.vm.currentWhiteLineParentIndex]?.
        frameList[Math.ceil(this.vm.currentWhiteLineIndex - beforeLength +
          this.vm.allBasicListDisplay[this.vm.currentWhiteLineParentIndex]?.leftShort)]
        this.vm.currentPipFrame = this.vm.pixelMapPipList[frameIndex]

        if (this.vm.isPlaying) {
          this.vm.pauseTogether()
        }
        this.vm.showCover = false
        this.vm.isPlaying = false
        let time =
          Number((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth * 1000).toFixed(3)) -
            beforeTime
        this.vm.seekToTime(time, this.vm.currentWhiteLineParentIndex, scrollOffset)
      }
    }
  }

  dealScrollStop(){
    this.vm.showCover = true
    let frameIndex = 0
    if (this.vm.isFullScreen) {
      let distance = Number((this.vm.basicThumbnailWidth * this.disPlayHeight / this.disPlayWidth).toFixed(3))
      this.scrollerMain.scrollTo({ xOffset: this.vm.currentTime / 1000 * distance, yOffset: 0 })
    } else {
      if (this.vm.zoomInFlag) {
        setTimeout(() => {
          this.scrollerMain.scrollTo({
            xOffset: this.vm.currentTime / 1000 * this.vm.basicThumbnailWidth,
            yOffset: 0
          })
        }, 100)
        this.vm.zoomInFlag = false
      } else {
        this.vm.currentScrollX = this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth
        let frameIndex =
          Number((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth).toFixed(3))
        this.vm.currentTime = frameIndex * 1000
        this.vm.currentWhiteLineIndex = frameIndex
        this.vm.currentWhiteLineParentIndex =
          this.vm.findTargetInParent(this.vm.allBasicListDisplay, this.vm.currentWhiteLineIndex)
        if (this.vm.currentScrollX * 1000 >= this.vm.pipXDistance * 1000 &&
          this.vm.currentScrollX * 1000 <= this.vm.exportPipVideos[0]?.duration + this.vm.pipXDistance * 1000) {
          this.vm.showPip = true
        } else {
          this.vm.showPip = false
        }
        if (this.vm.currentScrollX * 1000 <= this.vm.basicDuration) {
          this.vm.showBasic = true
        } else {
          this.vm.showBasic = false
        }
        let beforeTime = 0
        for (let i = 0; i < this.vm.currentWhiteLineParentIndex; i++) {
          beforeTime += this.vm.allBasicListDisplay[i].duration
        }
        let time =
          Number((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth * 1000).toFixed(3)) -
            beforeTime
        this.vm.seekToTime(time, this.vm.currentWhiteLineParentIndex, 1)
      }
    }
  }

  dealWithOnActionUpdate(event: GestureEvent, parentIndex: number) {
    if (!this.isDragging || !this.isShrink) {
      return;
    }
    this.offsetX = event.offsetX - this.dragRefOffset;
    const total = this.vm.basicThumbnailWidth + this.PARENT_SPACING;
    const maxX = (this.vm.allBasicListDisplay.length - 1 - parentIndex) * total;
    const minX = -parentIndex * total;
    this.offsetX = Math.max(Math.min(this.offsetX, maxX), minX);

    /* 相邻缩放逻辑 */
    const curveValue = curves.initCurve(Curve.Sharp);
    let value = 0;
    if (this.offsetX < 0 && parentIndex > 0) {
      value = curveValue.interpolate(-this.offsetX / total);
      this.neighborParentIndex = parentIndex - 1;
      this.neighborScale = this.SCALE_NEIGHBOR + (1 - this.SCALE_NEIGHBOR) * (1 - value);
    } else if (this.offsetX > 0 && parentIndex < this.vm.allBasicListDisplay.length - 1) {
      value = curveValue.interpolate(this.offsetX / total);
      this.neighborParentIndex = parentIndex + 1;
      this.neighborScale = this.SCALE_NEIGHBOR + (1 - this.SCALE_NEIGHBOR) * (1 - value);
    }
    const step = Math.round(this.offsetX / total); // +2 向右跨 2 格
    const finalIdx =
      Math.max(0, Math.min(parentIndex + step, this.vm.allBasicListDisplay.length - 1));
    this.jumpDirection = step > 0 ? 1 : (step < 0 ? -1 : 0);
    this.dropTargetIndex = finalIdx; // 抬手时插入位置
  }

  dealWithOnTouch(event: TouchEvent, parentIndex: number) {
    if (event.type === TouchType.Down) {
      if (parentIndex === 0) {
        this.dropFingerIndex =
          event.touches[0].x - this.vm.basicThumbnailWidth * parentIndex - this.vm.basicThumbnailWidth / 2
      } else {
        let totalWidth = 0
        for (let i = 0; i < parentIndex; i++) {
          totalWidth = totalWidth + this.vm.listRightHandlerPosition[i]
        }
        this.dropFingerIndex =
          totalWidth + event.touches[0].x - this.vm.basicThumbnailWidth * parentIndex - this.vm.basicThumbnailWidth / 2
      }
    }
  }

  jump2VipPageWithLogin(appAction: ActionWithAppBean) {
    if (appAction.action === 'getLoginStatusRes') {
      let isLogin = appAction.data as boolean
      if (!isLogin) {
        if (this.isJump2LoginPage) {
          return
        }
        this.isJump2LoginPage = true
        this.doActionWithApp('jump2LoginPage')
      } else {
        // 登录成功后会检查是否vip并跳转vip页
        // 点击画中画直接跳转vip，返回后不会检查跳转vip页
        if (!this.isJump2LoginPage) {
          return
        }
        if (!this.vm.isVip) {
          this.isJump2LoginPage = false
          this.doActionWithApp('jump2VipPage')
        }
      }
      return
    } else if (appAction.action === 'getVipStatusRes') {
      //vip页面
      this.isJump2Vip = false
      let isVip = appAction.data as boolean
      if (!!isVip) {
        this.vm.isVip = true
      }
    }
  }

  doActionWithApp(key: string, data: TValueType = null) {
    let action = new ActionWithAppBean()
    action.action = key
    action.data = data;
    try {
      emitter.emit({ eventId: ActionWithAppBean.ACTION_WITH_APP }, {
        data: {
          data: action
        }
      })
    }catch (error) {
    }
  }

  aboutToAppear(): void {
    VELoading.uiContext = this.getUIContext();
    try {
      display.on('foldStatusChange', (type: number) => {
        this.isExpanded = display.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED;
      })
    } catch (error) {}
    this.vm.resultCode = 0
    this.vm.clipPipWidth = this.uiContext.px2vp(ConstantsUtil.PIP_WIDTH)
    this.vm.clipPipHeight = ConstantsUtil.PIP_HEIGHT
    this.vm.pipWidth = this.uiContext.px2vp(ConstantsUtil.PIP_WIDTH)
    this.vm.pipHeight = ConstantsUtil.PIP_HEIGHT
    this.vm.pipTempW = this.uiContext.px2vp(ConstantsUtil.PIP_WIDTH)
    this.vm.pipTempH = ConstantsUtil.PIP_HEIGHT
    this.vm.init(this.uiContext.getHostContext() as common.UIAbilityContext)
    try {
      emitter.on({ eventId: ActionWithAppBean.ACTION_WITH_APP }, this.cbActionWithApp)
    }catch (error) {}
  }

  cbActionWithApp: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    if (!eventData || !eventData.data || !eventData.data.data) {
      return;
    }

    let appAction = eventData.data.data as ActionWithAppBean
    // 获取登录状态
    if (appAction.action === 'getLoginStatusRes') {
      this.vm.isLogin = appAction.data as boolean;
    }

    // 获取vip状态
    if (appAction.action === 'getVipStatusRes') {
      this.vm.isVip = appAction.data as boolean;
    }

    if (!this.isJump2Vip) {
      return;
    }
    try {
      this.jump2VipPageWithLogin(appAction)
    } catch (e) {
    }
  }

  async aboutToDisappear(): Promise<void> {
    if (this.vm.resultCode === 0) {
      let exportVideoParam = await this.makeData()
      failSaveWork(exportVideoParam, this.vm.allBasicListDisplay[0].frameList[0].url)
    }
    try {
      display.off('foldStatusChange')
      emitter.off(ActionWithAppBean.ACTION_WITH_APP, this.cbActionWithApp)
    } catch (error) {
    }
    await this.vm.clearAll()
    this.teleprompterListVM.clearAll()
    this.editTextSnapList = []
    this.vm.isComposeLoading = false
  }

  @Builder
  titleBar() {
    Row() {
      Image($r('app.media.cancel_icon'))
        .draggable(false)
        .width(24)
        .onClick(async () => {
          this.vm.pauseTogether()
          this.scrollerMain.fling(1)
          if(this.vm.isLoading){
            this.vm.isAbortFetch = true;
            this.vm.resultCode = 1
            this.stack?.pop()
          }else {
            await this.exitControllerConfirm.open()
          }
        })

      Row() {
        SelectWithWhiteArrow({
          options: [{ value: '1080' }, { value: '720' }, { value: '480' }],
          selectedIndex: this.vm.videoResolutionIndex,
          value: this.vm.videoResolution,
          onSelect: (index: number, value: string) => {
            this.vm.videoResolution = value;
            this.vm.videoResolutionIndex = index;
          },
          selectWidth: 64,
          selectHeight: 28,
          fontSizeRes: 14,
          textColor: '#D9FFFFFF',
          cornerRes: 8,
          bgColor: '#FF333333',
          selectedBgColor: '#FF505050',
          itemWidth: 70,
          itemHeight: 32,
        })
          .margin({ right: 10 })

        SelectWithWhiteArrow({
          options: [{ value: 'mp4' }, { value: 'mkv' }, { value: 'mov' }, { value: 'avi' }, { value: 'flv' }],
          selectedIndex: this.vm.videoFormatIndex,
          value: this.vm.videoFormat,
          onSelect: (index: number, value: string) => {
            this.vm.videoFormat = value;
            this.vm.videoFormatIndex = index;
          },
          selectWidth: 64,
          selectHeight: 28,
          fontSizeRes: 14,
          textColor: '#D9FFFFFF',
          cornerRes: 8,
          bgColor: '#FF333333',
          selectedBgColor: '#FF505050',
          itemWidth: 70,
          itemHeight: 32,
        })
          .margin({ right: 10 })

        Button($r('app.string.save'))
          .type(ButtonType.Normal)
          .fontColor($r('sys.color.font_primary'))
          .width(64)
          .fontSize($r('sys.float.Body_M'))
          .height(28)
          .borderRadius($r('sys.float.corner_radius_level4'))
          .onClick(async () => {
            if(this.vm.isLoading){
              this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
              return
            }
            if (this.isExporting) {
              return
            }
            try {
              this.vm.pauseTogether()
              this.scrollerMain.fling(1)
              this.isExporting = true;
              this.vm.loadingText = '视频合成素材准备中...'
              this.vm.isComposeLoading = true
              await this.prompterSnapAction()
              await this.saveSubtitles()
              let exportVideoParam: exportVideo = await this.makeData()
              this.vm.isComposeLoading = false
              this.stack?.pushPathByName('ExportVideoPage', exportVideoParam, (popInfo: PopInfo) => {
                /**
                 * popInfo.result
                 * 1 导出页跳转到作品列表
                 * finish 导出成功,返回到视频编辑页面
                 * unFinish 导出失败,返回到视频编辑页面
                 */
                if (popInfo.result === 1) {
                  // 导出成功，修改code状态
                  this.vm.resultCode = 1;
                  this.stack?.pop();
                }
              }, false);
            } finally {
              this.isExporting = false;
            }
          })
          .linearGradient(this.vm.btnGradientColor)
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

    }
    .padding({
      top: this.barVm.staBarH,
      left: this.getPaddingH(),
      right: this.getPaddingH(),
    })
    .width('100%')
    .height(56 + this.barVm.staBarH)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#0D0C11')
    .visibility(this.vm.isFullScreen ? Visibility.None : Visibility.Visible)
  }

  @Builder
  basicVideoShow() {
    XComponent({
      type: XComponentType.SURFACE,
      controller: this.xComponentController1
    })
      .zIndex(1)
      .onLoad(async () => {
        this.vm.surfaceId = this.xComponentController1.getXComponentSurfaceId();
      })
      .renderFit(this.vm.isFullScreen ? RenderFit.RESIZE_CONTAIN : RenderFit.RESIZE_FILL)
      .width(this.vm.clipWidth)
      .height(this.vm.clipHeight)
      .visibility(this.vm.showBasic ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  pipVideoShow() {
    Stack({ alignContent: Alignment.Center }) {
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.xComponentController2
      })
        .alignSelf(ItemAlign.Center)
        .zIndex(3)
        .onLoad(() => {
          this.vm.surfacePipId = this.xComponentController2.getXComponentSurfaceId();
        })
        .width(this.vm.clipPipWidth)
        .height(this.vm.clipPipHeight)

      if(this.vm.isShape){
        // 羽化过渡遮罩
        Column()
          .zIndex(4)
          .width(this.vm.clipPipWidth)
          .height(this.vm.clipPipHeight)
          .radialGradient({
            center: ['50%', '50%'],
            radius: '50%',
            colors: [
              ['rgba(0,0,0,1)', 0.70], // 中心：完全不透明中性灰
              ['rgba(0,0,0,0)', 0.95]  // 边缘：完全透明中性灰
            ]
          })
          .blendMode(BlendMode.DST_IN) //反转
      }

    }
    .width(this.vm.clipPipWidth)
    .height(this.vm.clipPipHeight)
    .enabled(this.vm.isFullScreen ? false : true)
    .clipShape(this.vm.isShape
      ? new EllipseShape({ width: this.vm.clipPipWidth, height: this.vm.clipPipHeight })
      : new RectShape({ width: this.vm.clipPipWidth, height: this.vm.clipPipHeight }))
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            this.startX = this.vm.offsetPipX;
            this.startY = this.vm.offsetPipY;
          })
          .onActionUpdate((event: GestureEvent) => {
            // 根据偏移量更新组件位置
            this.vm.offsetPipX = this.startX + event.offsetX;
            this.vm.offsetPipY = this.startY + event.offsetY;
            // 判断坐标是否超出区域限定，超出后重新赋值
            if (this.vm.offsetPipX <= -(this.vm.clipWidth - this.vm.clipPipWidth) / 2) {
              this.vm.offsetPipX = -(this.vm.clipWidth - this.vm.clipPipWidth) / 2
            }
            if (this.vm.offsetPipX >= (this.vm.clipWidth - this.vm.clipPipWidth) / 2) {
              this.vm.offsetPipX = (this.vm.clipWidth - this.vm.clipPipWidth) / 2
            }
            if (this.vm.offsetPipY <= -(this.vm.clipHeight - this.vm.clipPipHeight) / 2) {
              this.vm.offsetPipY = -(this.vm.clipHeight - this.vm.clipPipHeight) / 2
            }
            if (this.vm.offsetPipY >= (this.vm.clipHeight - this.vm.clipPipHeight) / 2) {
              this.vm.offsetPipY = (this.vm.clipHeight - this.vm.clipPipHeight) / 2
            }
          }),
      )
    )
  }

  @Builder
  pipVideoEditShow() {
    Image($r('app.media.icon_pip_top'))
      .width(24)
      .height(24)
      .position({ top: -30, left: (this.vm.clipPipWidth / 2 - 12) })
      .zIndex(5)
      .draggable(false)
      .enabled(this.vm.isFullScreen ? false : true)
      .gesture(
        PanGesture()
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) { //拉高
              if (this.vm.clipPipHeightT - event.offsetY < this.vm.clipHeight &&
                this.vm.clipPipHeightT - event.offsetY > 50) {
                this.vm.clipPipHeight = this.vm.clipPipHeightT - event.offsetY
              }
            }
          })
          .onActionEnd(() => {
            this.vm.clipPipHeightT = this.vm.clipPipHeight
          })
      )
    Image($r('app.media.icon_pip_right'))
      .width(24)
      .height(24)
      .position({ right: -30, top: (this.vm.clipPipHeight / 2 - 12) })
      .zIndex(5)
      .draggable(false)
      .enabled(this.vm.isFullScreen ? false : true)
      .gesture(
        PanGesture()
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) { //拉宽
              if (this.vm.clipPipWidthT + event.offsetX < this.vm.clipWidth &&
                this.vm.clipPipWidthT + event.offsetX > 50) {
                this.vm.clipPipWidth = this.vm.clipPipWidthT + event.offsetX
              }
            }
          })
          .onActionEnd(() => {
            this.vm.clipPipWidthT = this.vm.clipPipWidth
          }))

    Image($r('app.media.ic_feathering'))
      .width(24)
      .height(24)
      .position({ bottom: -30, left: (this.vm.clipPipWidth / 2 - 12) })
      .zIndex(5)
      .draggable(false)
      .enabled(this.vm.isFullScreen ? false : true)
      .onClick(() => {
        this.vm.isShape = !this.vm.isShape
        if(this.vm.isShape){
          this.vm.clipPipWidth += 0.01
        }
      })
      .gesture(
        PanGesture()
          .onActionUpdate((event: GestureEvent | undefined) => {
            if (event) { //拉高
              this.vm.pipWidth = this.vm.pipTempW + event.offsetX
            }
          })
          .onActionEnd(() => {
            this.vm.pipTempW = this.vm.pipWidth
          })
      )
  }

  @Builder
  subtitlesShow() {
    Column() {
      Text(this.vm.subtitlesValue)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height('auto')
        .fontSize(20)
        .fontColor('#ffffffff')
        .enabled(false)
        .backgroundColor(Color.Transparent)
        .id('textSubTitle')
        .onAreaChange((oldValue, newValue) => {
          this.vm.subTitleWidth =
            Math.round(newValue.width as number / this.vm.clipWidth * this.vm.srcWidth * 1000) / 1000
          this.vm.subTitleHeight =
            Math.round(newValue.height as number / this.vm.clipHeight * this.vm.srcHeight * 1000) / 1000
          this.vm.subTitleX =
            Math.round(newValue.position.x as number / this.vm.clipWidth * this.vm.srcWidth * 1000) / 1000
          this.vm.subTitleY =
            Math.round(newValue.position.y as number / this.vm.clipHeight * this.vm.srcHeight * 1000) / 1000
        })
    }
    .width(this.vm.clipWidth)
    .height(this.vm.clipHeight)
    .enabled(false)
    .justifyContent(FlexAlign.End)
    .zIndex(6)
  }

  @Builder
  prompterShow() {
    //提词器上面编辑组件
    ForEach(this.teleprompterListVM.editTexts, (item: EditTextVM, index: number) => {
      EditTextComponent({
        vm: this.vm,
        currentTime: this.vm.currentTime,
        isPlaying: this.vm.isPlaying,
        editTextVM: item,
        index: index,
        editStatus: this.teleprompterListVM.editStatus,
        activeIndex: this.teleprompterListVM.activeIndex,
        deleteEditText: () => {
          this.teleprompterListVM.editTexts.splice(this.teleprompterListVM.editTexts.indexOf(item), 1)
          this.teleprompterListVM.editStatus = false
        },
        addEditText: () => {
          let res = this.teleprompterListVM.addEditText(this.vm, item)
          if (res.code === 0) {
            this.teleprompterListVM.editStatus = true //设置当前对象处于编辑状态
          } else {
            promptAction.showToast({ message: res.msg })
          }
        },
        selectEditText: (index: number) => {
          if (this.teleprompterListVM.activeIndex === index) {
            this.teleprompterListVM.editStatus = true
          } else {
            this.teleprompterListVM.activeIndex = index
          }
        }
      })
        .position({ x: item.x, y: item.y })
        .zIndex(7)
    }, (item: EditTextVM) => item.id.toString())
  }

  @Builder
  videoShow() {
    Stack({ alignContent: Alignment.Center }) {
      this.basicVideoShow()

      Column() {
        this.pipVideoShow()
        this.pipVideoEditShow()
      }
      .width(this.vm.clipPipWidth)
      .height(this.vm.clipPipHeight)
      .translate({ x: this.vm.offsetPipX, y: this.vm.offsetPipY })
      .zIndex(3)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .visibility(this.vm.showPip ? Visibility.Visible : Visibility.Hidden)

      this.subtitlesShow()
      this.prompterShow()
    }
    .width('100%')
    .height(this.vm.isFullScreen ? '100%' : '51.5%')
    .margin({ top: this.vm.isFullScreen ? 0 : 0 })
    .clip(true)
    .backgroundColor('#1C1C1C')
  }

  @Builder
  playBar() {
    RelativeContainer() {
      this.timeShow()
      this.playButton()
      this.zoomButton()
    }
    .height('5%')
    .width('100%')
    .margin({ top: this.vm.isFullScreen ? -16 - this.barVm.aiBarH : 0 })
    .alignSelf(ItemAlign.Center)
    .backgroundColor(this.vm.isFullScreen ? Color.Transparent : '#0D0C11')
  }

  @Builder
  timeShow(){
    Text() {
      Span(formatTime(this.vm.currentTime)).fontColor('#D9FFFFFF')
      Span(util.format(' %s %s', '/',
        formatTime(Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000))))
        .fontColor('#D9FFFFFF')
    }
    .fontSize(12)
    .fontColor('#FFFFFF')
    .alignRules({
      'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
      'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
    }).margin({ left: this.getPaddingH() })
  }

  // 播放/暂停按钮
  @Builder
  playButton(){
    Image(this.vm.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
      .draggable(false)
      .height(24)
      .width(24)
      .onClick(async () => {
        if(this.vm.isLoading){
          this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
          return
        }
        if (this.vm.isFullScreen) {
          let distance = Number((this.vm.basicThumbnailWidth * this.disPlayHeight / this.disPlayWidth).toFixed(3))
          // 记录当前白线对应的item索引
          this.vm.currentWhiteLineIndex =
            Number((this.scrollerMain.currentOffset().xOffset / distance).toFixed(3))
        } else {
          this.vm.currentWhiteLineIndex =
            Number((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth).toFixed(3))
        }
        if (this.vm.currentWhiteLineIndex ===
        Number((Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000) /
          1000).toFixed(3))) {
          this.vm.currentWhiteLineIndex = 0
        }
        this.vm.currentWhiteLineParentIndex =
          this.vm.findTargetInParent(this.vm.allBasicListDisplay, this.vm.currentWhiteLineIndex)
        if (this.vm.allBasicListDisplay.length > 1 && this.vm.currentWhiteLineIndex ===
        Number((this.vm.allBasicListDisplay[this.vm.currentWhiteLineParentIndex].duration / 1000).toFixed(3))) {
          this.vm.currentWhiteLineParentIndex = this.vm.currentWhiteLineParentIndex + 1
        }
        if (this.vm.isPlaying) {
          this.scrollerMain.fling(1);
          this.vm.isPlaying = false;
          this.vm.pauseTogether();
        } else {
          this.vm.showBottomViewFlag = false
          if (this.vm.isFullScreen) {
            let distance = Number((this.vm.basicThumbnailWidth * this.disPlayHeight / this.disPlayWidth).toFixed(3))
            if (Math.round(this.scrollerMain.currentOffset().xOffset / distance) ===
            Number((Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000) /
              1000).toFixed(3))) {
              await this.scrollerMain.scrollTo({ xOffset: 0, yOffset: 0 })
            }
            this.scrollerMain.scrollEdge(Edge.End, { velocity: distance });
          } else {
            if (Number((this.scrollerMain.currentOffset().xOffset / this.vm.basicThumbnailWidth).toFixed(3)) ===
            Number((Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000) /
              1000).toFixed(3))) {
              this.vm.currentWhiteLineIndex = 0
              this.vm.currentWhiteLineParentIndex = 0
              await this.scrollerMain.scrollTo({ xOffset: 0, yOffset: 0 })
            }
            this.scrollerMain.scrollEdge(Edge.End, { velocity: this.vm.basicThumbnailWidth });
          }
          this.vm.isPlaying = true;
          this.vm.showCover = false;

          let beforeLength = 0
          for (let i = 0; i < this.vm.currentWhiteLineParentIndex; i++) {
            beforeLength += Number(((this.vm.listRightHandlerPosition[i] / ConstantsUtil.IMAGE_WIDTH)).toFixed(3))
          }
          this.vm.playBasic(this.vm.currentWhiteLineParentIndex,
            (this.vm.currentWhiteLineIndex - beforeLength) * 1000 +
            this.vm.allBasicListDisplay[this.vm.currentWhiteLineParentIndex].startTime);

          if (this.vm.currentWhiteLineIndex >= this.vm.pipXDistance) {
            this.vm.playPip()
          }
        }
      })
      .alignRules({
        'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center },
        'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
      })

  }

  @Builder
  zoomButton(){
    Image(this.vm.isFullScreen ? $r('app.media.ic_zoom_in') : $r('app.media.ic_zoom_out'))
      .draggable(false)
      .height(24)
      .height(24)
      .onClick(async () => {
        if(this.vm.isLoading){
          this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
          return
        }
        this.vm.isPlaying = false
        this.vm.pauseTogether()
        this.scrollerMain.fling(1)
        if (this.vm.isFullScreen) {
          this.vm.zoomInFlag = true
          this.vm.zoomVideo('zoomIn', this.uiContext)
        } else {
          this.vm.zoomInFlag = false
          this.vm.zoomVideo('zoomOut', this.uiContext)
        }
      })
      .alignRules({
        'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
        'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
      })
      .margin({ right: this.getPaddingH() })
  }

  @Builder
  editShow() {
    Column() {
      this.imageSwiper()
    }
    .layoutWeight(1)
    .width('100%')
    .visibility(this.vm.isFullScreen ? Visibility.Hidden : Visibility.Visible)
  }

  @Builder
  timeListBuilder() {
    Row() {
      List() {
        ListItem() {
        }.width(this.vm.isFullScreen
          ? this.disPlayHeight / 2 - 25
          : this.disPlayWidth / 2 - 25)

        ForEach(this.vm.durationLength, (index: number) => {
          ListItem() {
            Column() {
              Text((index % 2 === 0) ? formatTime(index * 1000) : '·')
                .fontSize(10).fontColor('#99ffffff')
                .textAlign(TextAlign.Center)
                .alignSelf(ItemAlign.Center)
            }
            .width(50)
            .alignItems(HorizontalAlign.Center)
          }
        })
        ListItem() {
        }.width(this.vm.isFullScreen
          ? this.disPlayHeight / 2
          : this.disPlayWidth / 2)
      }
      .listDirection(Axis.Horizontal)
      .alignListItem(ListItemAlign.Start)
      .enableScrollInteraction(false)
      .scrollBar(BarState.Off)
      .height(40)
      .margin({ top: 6 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
  }

  @Builder
  basicListBuilder(){
    Stack() {
      List() {
        ListItem()
          .width(this.vm.isFullScreen
            ? this.disPlayHeight
            : this.disPlayWidth)
          .height(51)
          .backgroundColor('#1C1C1C')
          .margin({
            left: this.vm.isFullScreen
              ? -this.disPlayHeight
              : -this.disPlayWidth
          })
          .offset({ x: this.vm.leftWidthOrigin, y: 0 })
          .zIndex(100)

        ListItem() {
          Row() {
            Column() {
              Image(this.voiceState ? $r('app.media.loud_speaker_icon') : $r('app.media.ic_close_voice'))
                .width(24)
              Text(this.voiceState ? $r('app.string.turn_off_sound') : $r('app.string.turn_on_sound'))
                .fontSize(10).fontColor('#D9FFFFFF')
            }
            .width(48)
            .height(48)
            .justifyContent(FlexAlign.SpaceEvenly)
            .onTouch((event: TouchEvent) => {
              switch (event.type) {
                case TouchType.Down:
                  this.vm.touchVoice = true
                  break
                case TouchType.Up:
                  this.vm.touchVoice = false
                  break
              }
            })
            .onClick(() => {
              if(this.vm.isLoading){
                this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
                return
              }
              this.voiceState = !this.voiceState
              this.vm.openOrClose(this.voiceState)
            })

            Stack() {
              MultiImage({
                imageData: this.vm.videoCover,
                imageWidth: 48,
                imageHeight: 48,
                flag: true
              })

              Column() {
                Text($r('app.string.set_cover'))
                  .fontSize(10).fontColor('#99FFFFFF')
                  .width(20)
                  .maxLines(2)
              }
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .height('100%')
              .borderRadius('8')
              .backgroundColor('#99000000')
            }
            .width(48)
            .height(48)
            .alignContent(Alignment.Center)
            .onClick(() => {
              if(this.vm.isLoading){
                this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
                return
              }
              this.scrollerMain.fling(1);
              this.vm.showBottomViewFlag = true
              this.currentPageIndex = 2
            })
          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width(this.vm.isFullScreen
          ? this.disPlayHeight / 2
          : this.disPlayWidth / 2 - CommonSize.PROMPTER_TEXT_HEADER_WIDTH)
        .height('51')
        .offset({ x: this.vm.leftWidthOrigin, y: 0 }) // 用position直接控制x坐标
        .zIndex(100) // 提升层级，确保覆盖下方组件
        .backgroundColor('#1C1C1C')

        ListItem() {
          this.controlBuilder()
        }.width('100%')

        ListItem() {
        }.width(this.vm.isFullScreen
          ? this.disPlayHeight / 2
          : this.disPlayWidth / 2)

      }
      .listDirection(Axis.Horizontal)
      .alignListItem(ListItemAlign.Start)
      .scrollBar(BarState.Off)
      .enableScrollInteraction(false)
      .height(51)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .alignContent(Alignment.Start)
    .width('100%')
  }

  @Builder
  imageSwiper() {
    Stack({ alignContent: Alignment.TopStart }) {
      List({ scroller: this.scrollerMain }) {
        ListItem() {
          Column() {
            this.timeListBuilder()
            this.basicListBuilder()
            PipComponent({
              vm: this.vm,
              exportPipVideos: this.vm.exportPipVideos,
              length: this.vm.pixelMapPipListLength * this.vm.basicThumbnailWidth,
              isSelected: this.vm.isSelectPip,
              changeLength: (lengthL: number) => {
                this.vm.pixelMapPipListLength = lengthL
                this.vm.updateMaxWidth(this.uiContext, Number((this.vm.basicDuration / 1000).toFixed(3)),
                  this.vm.pixelMapPipListLength + this.vm.pipXDistance, this.vm.pixelMapPipListLength)
              },
              changeSelect: (flag: boolean) => {
                this.vm.isSelectPip = flag
                this.vm.showBottomViewFlag = true
                this.currentPageIndex = 1
                this.scrollerMain.fling(1);
              },
              changeXOffset: () => {
                this.vm.totalDuration =
                  Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000)
                this.vm.updateMaxWidth(this.uiContext, Number((this.vm.basicDuration / 1000).toFixed(3)),
                  this.vm.pixelMapPipListLength + this.vm.pipXDistance, this.vm.pixelMapPipListLength)
              }
            })
              .width('100%')
              .visibility(this.vm.exportPipVideos[0]?.pipFrameList.length > 0 ? Visibility.Visible : Visibility.None)
            //提词器文本
            this.prompterBuilder()
          }
          .justifyContent(FlexAlign.Start)
          .width(this.vm.maxWidth === -1 ? 'max_content' :
            this.vm.isFullScreen ? this.vm.maxWidth * this.disPlayHeight / this.disPlayWidth : this.vm.maxWidth)
        }
        .offset({ x: 0 })
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.None, { alwaysEnabled: false })
      .onWillScroll(() => {
        this.vm.showCover = false
      })
      .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
        this.dealWithDidScroll(scrollOffset, scrollState)
      })
      .onScrollStop(() => {
        this.dealScrollStop()
      })
      .onTouch((event: TouchEvent) => {
        switch (event.type) {
          case TouchType.Down:
            this.vm.touchScroll = true
            break
          case TouchType.Up:
            this.vm.touchScroll = false
            break
        }
      })
      .offset({ x: 0 })
      .width('100%')
      .height('100%')

      Image($r('app.media.icon_add_video'))
        .width(30)
        .height(30)
        .position({ x: '87.5%', y: 55 })
        .margin({ right: 30 })
        .onClick(() => { //添加新的视频
          if(this.vm.isLoading){
            this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
            return
          }
          // 过滤掉index为undefined/null的情况，再去重统计
          const uniqueIndexCount = new Set(
            this.vm.allBasicListDisplay
              .filter(item => item.index !== undefined && item.index !== null) // 过滤无效index
              .map(item => item.index)
          ).size
          const maxIndex = uniqueIndexCount || 0;
          if(maxIndex > 1){
            this.uiContext.getPromptAction().showToast({message:'暂时只支持添加两个不同的视频'})
          }else {
            this.vm.selectBasicOrPip = true
            this.vm.photoPick(this.uiContext, this.vm.selectBasicOrPip,0)
          }
        })

      Text('')
        .width(2)
        .height(130)
        .margin({
          left: this.vm.isFullScreen
            ? this.disPlayHeight / 2
            : this.disPlayWidth / 2, top: 24
        })
        .backgroundColor(Color.White)
        .borderRadius(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1C1C1C')
    .onClick(() => {
      this.vm.basicParentSelectIndex = -1
      this.vm.showBottomViewFlag = false
      this.vm.isSelectPip = false
      this.scrollerMain.fling(1);
    })
  }

  @Builder
  renderLeftImage(childList: BasicVideoData, parentIndex: number) {
    ListItem() { //左手柄
      this.HandleLeftImage(parentIndex)
    }
    .zIndex(100)
    .visibility(this.isShrink ? Visibility.Hidden :
      this.vm.basicParentSelectIndex === parentIndex ? Visibility.Visible :
        (parentIndex === 0 ? Visibility.Hidden : Visibility.None))
  }

  @Builder
  controlBuilder() {
    Scroll() {
      Row({space: 0.5}) {
        ForEach(this.vm.allBasicListDisplay,
          (childList: BasicVideoData, parentIndex: number) => {
          this.renderLeftImage(childList, parentIndex)

          ListItem() {
            Stack({ alignContent: Alignment.Start }){
              Stack({ alignContent: Alignment.Start }) {
                List({ scroller: childList.scroller }) {
                  ForEach(childList.frameList, (item: frameListData, childIndex: number) => {
                    ListItem() {
                      Stack() {
                        MultiImage({
                          imageData: item,
                          imageWidth: 50,
                          imageHeight: 50,
                          flag: false,
                          onClickEvent: () => {
                            this.vm.basicParentSelectIndex = parentIndex
                            this.handlerLeftStart = false
                            this.vm.showBottomViewFlag = true
                            this.vm.isSelectPip = false
                            this.currentPageIndex = 0
                            this.scrollerMain.fling(1);
                          }
                        })
                          .zIndex(0)
                      }
                      .width(50)
                      .height(50)
                      .alignContent(Alignment.Center)
                      .clip(false) // 允许容器内内容溢出
                      .padding(0)
                    }
                    .clip(true)
                  }, (item: frameListData, childIndex: number) => `${parentIndex}_${childIndex}`)
                }
                .clip(true)
                .listDirection(Axis.Horizontal)
                .alignListItem(ListItemAlign.Start)
                .scrollBar(BarState.Off)
                .height(50)
                .enableScrollInteraction(false)
                .translate({ x: this.judgeChildListOffset(parentIndex) })
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
              }
              .width('100%')
              .height('100%')

              // 右边分割图标显示
              Image($r('app.media.ic_split_item'))
                .width(20)
                .height(20)
                .borderRadius(3)
                .position({ x: this.getParentWidth(parentIndex, childList.frameList) - 10, y: 15 })
                .zIndex(2)
              .visibility(this.isShrink ? Visibility.None :
                parentIndex !== this.vm.allBasicListDisplay.length - 1 ? Visibility.Visible : Visibility.None)
            }
            .width(this.getParentWidth(parentIndex, childList.frameList))
            .height(50)
            .scale({
              x: this.scaleParentIndex === parentIndex ? this.SCALE_MAX :
                (this.neighborParentIndex === parentIndex ? this.SCALE_NEIGHBOR : 1),
              y: this.scaleParentIndex === parentIndex ? this.SCALE_MAX :
                (this.neighborParentIndex === parentIndex ? this.SCALE_NEIGHBOR : 1)
            })
            .translate({
              x: this.getTranslateX(parentIndex)
            })
            .animation({ duration: 150, curve: Curve.EaseInOut })

          }
          .onTouch((event) => {
            this.dealWithOnTouch(event, parentIndex)
          })
          .translate({ x: this.isShrink ? this.dropFingerIndex : 0 })
          .zIndex(this.vm.allBasicListDisplay.length - parentIndex)
          .border({
            width: this.vm.isSelectPip ? 0 : this.vm.basicParentSelectIndex === parentIndex ? 1 : 0,
            color: Color.White
          })
          .priorityGesture(
            GestureGroup(GestureMode.Sequence,
              // 长按触发全局缩放（所有父项缩成50px）
              LongPressGesture({ repeat: true, duration: 300 })
                .onAction((event) => {
                  if (!this.isShrink && !this.isDragging) {
                    this.scrollerMain.fling(1);
                    this.enterShrinkMode(parentIndex);
                  }
                })
                .onActionEnd(() => {
                  if (!this.isDragging && this.dragParentIndex === -1) {
                    this.exitShrinkMode();
                  }
                }),
              // 拖动排序（仅在缩小时生效）
              PanGesture({ fingers: 1, direction: null, distance: 0 })
                .onActionStart((event: GestureEvent) => {
                  if (this.isShrink) { // 仅缩小时允许拖动
                    this.dragParentIndex = parentIndex;
                    this.dragRefOffset = event.offsetX;
                    this.isDragging = true;
                    this.scaleParentIndex = parentIndex; // 拖动时保持高亮
                    this.dropTargetIndex = -1;
                  }
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.dealWithOnActionUpdate(event, parentIndex)
                })
                .onActionEnd(() => {
                  if (!this.isShrink) {
                    return;
                  }
                  const currentIdx = this.dragParentIndex;
                  const finalTarget = this.dropTargetIndex;
                  if (finalTarget !== -1 && finalTarget !== currentIdx) {
                    animateTo({ curve: curves.interpolatingSpring(0, 1, 300, 30) }, () => {
                      this.parentItemMove(currentIdx, finalTarget);
                    });
                  }
                  // 复位视觉跳动
                  this.jumpDirection = 0;
                  this.reset();
                })
            )
              .onCancel(() => {
                this.exitShrinkMode();
              })
          )

          ListItem() { //右手柄
            this.HandleRightImage(parentIndex)
          }
          .zIndex(100)
          .visibility(this.isShrink ? Visibility.None :
            this.vm.basicParentSelectIndex === parentIndex ? Visibility.Visible : Visibility.None)

        },
          (childList: BasicVideoData) => childList.keyId)
      }
      .clip(true)
      .width('100%')
      .height('51')
    }
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  prompterBuilder() {
    Row() {
      ForEach(this.teleprompterListVM.editTexts, (item: EditTextVM, index: number) => {
        PrompterTextComponent({
          vm: this.vm,
          editTextVM: item,
          index: index,
          activeIndex: this.teleprompterListVM.activeIndex,
          selectEditText: (index: number) => {
            if (this.teleprompterListVM.activeIndex === index) {
              this.teleprompterListVM.activeIndex = -1
            } else {
              this.teleprompterListVM.activeIndex = index
              if (index > -1) {
                this.scrollerMain.scrollTo({
                  //scroll滚动到提词器文本位置
                  xOffset: this.teleprompterListVM.editTexts[index].prompterX,
                  yOffset: 0
                })
              }
            }
          },
          activeCurrentZIndex: (index: number) => {
            this.teleprompterListVM.editTexts.forEach(item => {
              item.resetPrompterZIndex()
            });
            this.teleprompterListVM.editTexts[index].activePrompterZIndex()
          },
          checkOverLap: (index: number): boolean => { //检测目标文本移动结束时的位置是否与其他文本重叠
            let segment = getMultiData(this.teleprompterListVM.editTexts, index)
            let res = hasAnyOverlap(this.teleprompterListVM.editTexts[index], segment)
            return res
          },
          getEditTexts: (): EditTextVM[] => {
            return this.teleprompterListVM.editTexts
          },
          alterSite: (index: number) => {
            let singleSegment = this.teleprompterListVM.editTexts[index]
            this.teleprompterListVM.editTexts = sort(this.teleprompterListVM.editTexts)
            let newIndex = this.teleprompterListVM.editTexts.indexOf(singleSegment)
          }
        })
      })
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .translate({ x: -CommonSize.PROMPTER_TEXT_HEADER_WIDTH })
    .padding({ left: this.uiContext.px2vp(DisplayUtil.getWidth()) / 2 })
  }

  @Builder
  bottomMenu() {
    Row() {
      this.BottomNavigation(FUNCTION_BUTTON_INFO[0])
      this.BottomNavigation(FUNCTION_BUTTON_INFO[1])
      this.BottomNavigation(FUNCTION_BUTTON_INFO[2])
      this.BottomNavigation(FUNCTION_BUTTON_INFO[3])
    }
    .width('100%')
    .height('100%')
    .padding({ left: this.getPaddingH(), right: this.getPaddingH(), top: 4 })
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Top)
    .backgroundColor('#0D0C11')
    .visibility(this.vm.showBottomViewFlag ? Visibility.Hidden : Visibility.Visible)
  }

  @Builder
  BottomNavigation(button: BottomNavigationModel) {
    Column({ space: 2 }) { //根据index判断导航按钮是否聚焦
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.currentPageIndex === button.index ? button.selectedImage : button.primaryImage)
          .objectFit(ImageFit.Contain)
          .width(24)
          .height(24)
          .margin({ right: 3, top: 3 })
        Image($r('app.media.ic_pic_in_pic_vip'))
          .objectFit(ImageFit.Contain)
          .width(14)
          .height(14)
          .visibility(button.index === 1 && !this.vm.isVip ? Visibility.Visible : Visibility.None)
      }.width(30)

      Text(button.title)
        .fontColor(this.currentPageIndex === button.index ? '#ffffffff' : '#D9FFFFFF')
        .fontWeight(500)
        .opacity(0.6)
        .textAlign(TextAlign.Center)
        .fontSize(10)
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if(this.vm.isLoading){
        this.uiContext.getPromptAction().showToast({message: '视频正在抽帧中，请稍后重试！'})
        return
      }
      if (this.vm.isPlaying) {
        this.uiContext.getPromptAction().showToast({ message: '请先暂停' })
        return
      }
      switch (button.index) {
        case 0:
        case 1:
        case 2: // 0: 剪辑 1: 画中画 2: 视频抽帧
          if (!this.vm.isLogin && button.index === 1) {
            this.isJump2Vip = true;
            this.isJump2LoginPage = true;
            this.doActionWithApp('jump2LoginPage');
            return;
          }
          if (!this.vm.isVip && button.index === 1) {
            this.uiContext.getPromptAction().showToast({ message: '请先升级为VIP，才能使用该功能' })
            this.isJump2Vip = true;
            this.isJump2LoginPage = false;
            this.doActionWithApp('jump2VipPage')
            return
          }
          this.vm.showBottomViewFlag = true
          this.currentPageIndex = button.index
          break
        case 3: //跳转提词器
          let res = this.teleprompterListVM.addEditText(this.vm)
          if (res.code === 0) {
            this.teleprompterListVM.editStatus = true //设置当前对象处于编辑状态
          } else {
            promptAction.showToast({ message: res.msg })
          }
          this.currentPageIndex = button.index
          break
        case 4:
          try {
            this.stack?.pushPathByName('CreateSubtitlesPage', [...this.vm.subtitlesList], (popInfo: PopInfo) => {
              this.vm.subtitlesList = popInfo.result as SubtitlesSingleModel[];
            }, true);
          } catch (err) {
          }
      }
    })
  }

  @Builder
  BottomToastView() {
    RelativeContainer() {
      Image($r('app.media.left_arrow'))
        .rotate({
          centerZ: 0.5,
          angle: 180,
        })
        .alignRules({
          'start': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
          'center': { 'anchor': '__container__', 'align': VerticalAlign.Top }
        })
        .onClick(() => {
          this.vm.showBottomViewFlag = false
        })
        .margin({ top: 43 })
        .width(20)
        .height(20)

      Row() {
        Column({ space: 2 }) { //根据index判断导航按钮是否聚焦
          Image(FUNCTION_BUTTON_TOAST_INFO[this.currentPageIndex].primaryImage)
            .objectFit(ImageFit.Contain)
            .width(24)
            .height(24)
          Text(FUNCTION_BUTTON_TOAST_INFO[this.currentPageIndex].title)
            .fontColor('#D9FFFFFF')
            .fontWeight(500)
            .opacity(0.6)
            .textAlign(TextAlign.Center)
            .fontSize(10)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(async () => {
          switch (this.currentPageIndex) {
            case 0: //分割
              if (this.vm.currentWhiteLineIndex < 1) {
                this.uiContext.getPromptAction().showToast({ message: '不支持1秒以内裁剪' })
                return
              }
              this.vm.allBasicListDisplay =
                this.vm.splitChildAndUpdate(this.vm.allBasicListDisplay,
                  Math.round(this.vm.currentWhiteLineParentIndex),
                  this.vm.currentWhiteLineIndex)
              break
            case 1: //画中画
              if (this.vm.pipFileUriList.length === 0) {
                this.vm.selectBasicOrPip = false
                this.vm.pipXOffset = this.vm.currentScrollX * this.vm.basicThumbnailWidth
                this.vm.pipXDistance = this.vm.currentScrollX
                await this.vm.photoPick(this.uiContext, this.vm.selectBasicOrPip, this.vm.currentScrollX * 1000)
              } else {
                this.uiContext.getPromptAction().showToast({ message: '仅支持一条画中画视频' })
              }
              break
            case 2: //设置为封面
              if (this.vm.basicVideoCover !== undefined) {
                this.vm.videoCover = this.vm.basicVideoCover
                this.uiContext.getPromptAction().showToast({ message: '已设置当前帧为封面' })
                // 延迟1秒执行隐藏底部视图的操作
                setTimeout(() => {
                  this.vm.showBottomViewFlag = false;
                }, 1000);
              } else {
                this.uiContext.getPromptAction().showToast({ message: '设置为封面失败' })
              }
              break
          }
        })

        Column({ space: 2 }) {
          Image(this.currentPageIndex === 2 ? FUNCTION_BUTTON_TOAST_INFO[this.currentPageIndex + 1].primaryImage :
          $r('app.media.ic_delete'))
            .objectFit(ImageFit.Contain)
            .width(24)
            .height(24)

          Text(this.currentPageIndex === 2 ? FUNCTION_BUTTON_TOAST_INFO[this.currentPageIndex + 1].title :
          $r('app.string.delete'))
            .fontColor('#D9FFFFFF')
            .fontWeight(500)
            .opacity(0.6)
            .textAlign(TextAlign.Center)
            .fontSize(10)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(async () => {
          switch (this.currentPageIndex) {
            case 0: //删除Basic视频
              if (this.vm.basicParentSelectIndex === -1) {
                this.uiContext.getPromptAction().showToast({ message: '请先选择要删除的视频片段' })
                return
              }
              if (this.vm.allBasicListDisplay.length === 1) {
                this.uiContext.getPromptAction().showToast({ message: '至少要保留一个视频' })
                return
              }
              if (this.vm.basicParentSelectIndex === this.vm.currentWhiteLineParentIndex &&
                this.vm.basicParentSelectIndex >= 1) {
                this.vm.seekToTime(this.vm.allBasicListDisplay[this.vm.basicParentSelectIndex -1].duration,
                  this.vm.basicParentSelectIndex - 1, 1)
              }
              this.vm.allBasicListDisplay.splice(this.vm.basicParentSelectIndex, 1)
              let changedDuration = 0
              this.vm.allBasicListDisplay.forEach((item) => {
                changedDuration += item.duration
              })
              this.vm.updateCoverData()
              this.vm.updateVideoSegments(this.vm.allBasicListDisplay)

              this.vm.basicDuration = changedDuration
              this.vm.totalDuration = Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000)
              this.vm.listRightHandlerPosition.splice(this.vm.basicParentSelectIndex, 1)
              let afterSplitLength = 0
              this.vm.listRightHandlerPosition.forEach((length) => {
                afterSplitLength += length
              })
              this.vm.updateMaxWidth(this.uiContext, afterSplitLength / this.vm.basicThumbnailWidth,
                Number(((this.vm.exportPipVideos[0]?.duration ?? 0) / 1000).toFixed(3)) + this.vm.pipXDistance,
                Number(((this.vm.exportPipVideos[0]?.duration ?? 0) / 1000).toFixed(3)))
              if (this.vm.basicParentSelectIndex === 0 && this.vm.currentWhiteLineParentIndex === 0) {
                this.vm.videoPlayer!.currentIndex = -1
                this.vm.videoPlayer!.seekSegmentIndex = -1
                await this.vm.seekToTime(
                  Math.min(this.vm.allBasicListDisplay[0].duration, this.vm.currentWhiteLineIndex * 1000), 0, 1)
              }
              this.vm.basicParentSelectIndex = -1
              break
            case 1: //删除画中画视频
              this.vm.clearPlayer(1)
              this.vm.showPip = false
              this.vm.isShape = false
              this.vm.pixelMapPipList = []
              this.vm.pipFileUriList = []
              this.vm.exportPipVideos = []
              this.vm.pipDuration = 0
              this.vm.pipXOffset = 0
              this.vm.pipXDistance = 0
              this.vm.totalDuration = Math.max(this.vm.basicDuration, 0)
              this.vm.updateMaxWidth(this.uiContext, Number((this.vm.basicDuration / 1000).toFixed(3)), 0, 0)
              break
            case 2: //保存当前帧到相册
              if (this.vm.basicVideoCover !== undefined) {
                savePixelMapToAlbum(this.uiContext, this.vm.basicVideoCover)
                // 延迟1秒执行隐藏底部视图的操作
                setTimeout(() => {
                  this.vm.showBottomViewFlag = false;
                }, 1000);
              }
              break
          }
        })
      }
      .width('150')
      .height('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignRules({
        'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center },
        'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24, top: 4 })
    .backgroundColor('#2B2B2B')
    .visibility(this.vm.showBottomViewFlag ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  HandleLeftImage(indexId: number) {
    Row() {
      Divider().color('rgba(0,0,0,0.2)').strokeWidth(2).height(12).vertical(true)
    }
    .borderRadius({ topLeft: 3, bottomLeft: 3 })
    .height(51)
    .width(14)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .offset({ x: this.vm.leftWidthOrigin })
    .draggable(false)
    .enabled(false)
    .priorityGesture(PanGesture({ fingers: 1, distance: 5 })
      .onActionStart(() => {
        this.handlerLeftStart = true
      })
      .onActionUpdate(async event => {
        if (this.vm.listRightHandlerPosition[indexId] - event.offsetX > this.vm.basicThumbnailWidth &&
          this.vm.listRightHandlerPosition[indexId] - event.offsetX <=
            this.vm.allBasicListDisplay[indexId].frameList.length * this.vm.basicThumbnailWidth) {
          this.vm.childListLeftWidth = event.offsetX
          this.vm.leftWidthOrigin = event.offsetX
        } else {
          this.vm.childListLeftWidth = 0
          this.vm.leftWidthOrigin = 0
        }
      })
      .onActionEnd(() => {
        this.vm.leftWidthOrigin = this.vm.childListLeftWidth;
        this.vm.allBasicListLeftXMap.set(indexId, this.vm.childListLeftWidth)
        this.vm.listRightHandlerPosition[indexId] =
          this.vm.listRightHandlerPosition[indexId] - this.vm.leftWidthOrigin
        this.vm.leftWidthOrigin = 0
        this.handlerLeftStart = false
        this.vm.allBasicListDisplay[indexId].startTime = this.vm.allBasicListDisplay[indexId].startTime +
          Number((this.vm.childListLeftWidth / this.vm.basicThumbnailWidth).toFixed(3)) * 1000
        this.vm.allBasicListDisplay[indexId].duration =
          this.vm.listRightHandlerPosition[indexId] / this.vm.basicThumbnailWidth * 1000
        this.vm.allBasicListDisplay[indexId].leftShort = this.vm.allBasicListDisplay[indexId].leftShort +
        Number((this.vm.childListLeftWidth / this.vm.basicThumbnailWidth).toFixed(3))
        this.vm.basicDuration = 0
        this.vm.allBasicListDisplay.forEach((item) => {
          this.vm.basicDuration += item.duration
        })
        this.vm.totalDuration = Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000)
        this.vm.updateMaxWidth(this.uiContext, Number((this.vm.basicDuration / 1000).toFixed(3)),
          Number(((this.vm.exportPipVideos[0]?.duration ?? 0) / 1000).toFixed(3)) + this.vm.pipXDistance,
          Number(((this.vm.exportPipVideos[0]?.duration ?? 0) / 1000).toFixed(3)))
        if (this.vm.allBasicListDisplay[this.vm.basicParentSelectIndex].scroller) {
          setTimeout(() => {
            this.vm.allBasicListDisplay[this.vm.basicParentSelectIndex].scroller?.scrollToIndex(
              this.vm.allBasicListDisplay[this.vm.basicParentSelectIndex].frameList.length - 1);
          }, 100);
        }
        this.vm.updateVideoSegments(this.vm.allBasicListDisplay)
      })
      .onActionCancel(() => {
        this.vm.leftWidthOrigin = this.vm.childListLeftWidth;
      }))
  }

  @Builder
  HandleRightImage(indexId: number) {
    Row() {
      Divider().color('rgba(0,0,0,0.2)').strokeWidth(2).height(12).vertical(true)
    }
    .borderRadius({ topRight: 3, bottomRight: 3 })
    .height(51)
    .width(14)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
    .offset({ x: 0, y: 0 })
    .draggable(false)
    .enabled(false)
    .priorityGesture(PanGesture({ fingers: 1, distance: 5 })
      .onActionStart(() => {
        this.handlerRightStart = true
      })
      .onActionUpdate(async event => {
        if (this.vm.listRightHandlerPosition[indexId] - this.vm.childListLeftWidth > this.vm.basicThumbnailWidth &&
          this.vm.listRightHandlerPosition[indexId] + event.offsetX <=
            this.vm.allBasicListDisplay[indexId].frameList.length * this.vm.basicThumbnailWidth) {
          this.vm.handlerOffsetX = event.offsetX
        }
      })
      .onActionEnd(() => {
        this.handlerRightStart = false
        this.vm.listRightHandlerPosition[indexId] = this.vm.listRightHandlerPosition[indexId] + this.vm.handlerOffsetX
        this.vm.allBasicListDisplay[indexId].endTime =
          Number(((this.vm.listRightHandlerPosition[indexId] - this.vm.childListLeftWidth) /
          this.vm.basicThumbnailWidth).toFixed(3)) * 1000
        this.vm.allBasicListDisplay[indexId].duration =
          this.vm.listRightHandlerPosition[indexId] / this.vm.basicThumbnailWidth * 1000
        this.vm.basicDuration = 0
        this.vm.allBasicListDisplay.forEach((item) => {
          this.vm.basicDuration += item.duration
        })
        this.vm.totalDuration = Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000)
        this.vm.updateMaxWidth(this.uiContext, Number((this.vm.basicDuration / 1000).toFixed(3)),
          Number(((this.vm.exportPipVideos[0]?.duration ?? 0) / 1000).toFixed(3)) + this.vm.pipXDistance,
          Number(((this.vm.exportPipVideos[0]?.duration ?? 0) / 1000).toFixed(3)))
        this.vm.handlerOffsetX = 0;
        if (this.vm.allBasicListDisplay[this.vm.basicParentSelectIndex].scroller) {
          setTimeout(() => {
            this.vm.allBasicListDisplay[this.vm.basicParentSelectIndex].scroller?.scrollToIndex(0);
          }, 100);
        }
        this.vm.updateVideoSegments(this.vm.allBasicListDisplay)
      })
      .onActionCancel(() => {
        this.vm.handlerOffsetX = this.vm.childListRightWidth;
      })
    )
    .zIndex(100)
  }

  build() {
    NavDestination() {
      Stack() { //提词器隐藏文本框组件，截图使用
        Row() {
          ForEach(this.teleprompterListVM.editTexts, (item: EditTextVM) => {
            EditTextSnap({
              editTextVM: item,
            })
          })
        }.zIndex(-99)

        Column() {
          this.titleBar()
          this.videoShow()
          this.playBar()
          this.editShow()
          Stack() {
            this.BottomToastView()
            this.bottomMenu()
          }.alignContent(Alignment.Bottom)
          .height('9.6%')
          .visibility(this.vm.isFullScreen ? Visibility.Hidden : Visibility.Visible)

          if (this.teleprompterListVM.editStatus) {
            TelePrompterDialog({
              //提词器编辑弹窗
              teleprompterListVM: this.teleprompterListVM
            }).position({ bottom: 0, left: 0 }).zIndex(1)
          }
          if (this.teleprompterListVM.colorSelectStatus) {
            ColorSelectDialog({
              //提词器颜色设置页面
              teleprompterListVM: this.teleprompterListVM
            }).position({ bottom: 0, left: 0 }).zIndex(2)
          }
        }
        .width('100%')
        .height('100%')
        .onClick(() => {
          if (!this.teleprompterListVM.editStatus) {
            this.teleprompterListVM.activeIndex = -1
          }
        })

        Column(){
          LoadingProgress()
            .color($r('sys.color.icon_on_primary'))
            .width(72).height(72)
          Text(this.vm.loadingText).fontColor(Color.White)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
        .backgroundColor('#CC0D0C11')
        .visibility(this.vm.isComposeLoading ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .title('VideoClipPage')
    .backgroundColor('#0D0C11')
    .onShown(() => {
      // 每次回到页面都要获取登录状态和vip状态
      this.doActionWithApp('getLoginStatus');
      this.doActionWithApp('getVipStatus');
    })
    .onReady(async (ctx: NavDestinationContext) => {
      try {
        this.stack = ctx.pathStack;
        if (!!ctx.pathInfo && !!ctx.pathInfo.param) {
          if (!!ctx.pathInfo.param) {
            this.pageParam = JSON.parse(ctx.pathInfo.param as string)
          }
        }
        let jsonStr = ctx.pathInfo.param ?? ''
        await this.vm.initData(this.uiContext, jsonStr as string)
        // 重新设置提词器容器内容
        this.resetTeleprompterList();
        // 设置播放机宽高
        const currentWindowSize =
          { width: ConstantsUtil.currentDisplayWidth, height: ConstantsUtil.currentDisplayHeight } as Size
        this.vm.setClipSize(currentWindowSize);
      } catch (e) {
      }
    })
    .onBackPressed(() => {
      if (this.vm.isFullScreen) {
        this.vm.zoomInFlag = true
        this.vm.zoomVideo('zoomIn', this.uiContext)
        return true
      } else {
        this.vm.pauseTogether()
        this.scrollerMain.fling(1)
        if(this.vm.isLoading){
          this.vm.isAbortFetch = true;
          this.vm.resultCode = 1
          return false
        }else {
          this.exitControllerConfirm.open()
          return true
        }
      }
    })
    .onHidden(() => {
      this.vm.pauseTogether()
      this.scrollerMain.fling(1)
    })
  }

  async prompterSnap(editTextVM: EditTextVM) {
    let editTextSnap = new EditTextSnapModel()
    //计算提词器时长支持的滚动次数
    let durationTime = editTextVM.endTime - editTextVM.startTime
    let maxNum = durationTime * 10
    let haveNum = 0 //已经滚动的次数
    let isAtEnd = false //定义滚动条是否滚动到底
    let fileName = ''
    while (!(haveNum > maxNum)) { //没超过视频可滚动次数，也没滚动到底
      fileName = haveNum.toString().padStart(4, '0')
      if (haveNum >= 1 && haveNum <= (maxNum - 1)) {
        editTextVM.snapScroller?.scrollBy(0, (editTextVM.textAreaHeight - editTextVM.height) / (maxNum - 2))
      }

      const id = `EditTextSnapId${editTextVM.id}`
      const pixelMap = await this.getUIContext().getComponentSnapshot().get(id, {})
      const url = await saveScreenshot(this.uiContext, pixelMap, 3, fileName)
      editTextSnap.urlList.push(url)
      editTextSnap.x =
        Math.round((editTextVM.x - (this.uiContext.px2vp(ConstantsUtil.BASIC_VIDEO_WIDTH) - this.vm.clipWidth) / 2) /
        this.vm.clipWidth * this.vm.srcWidth * 1000) / 1000
      editTextSnap.y =
        Math.round((editTextVM.y - (this.uiContext.px2vp(ConstantsUtil.BASIC_VIDEO_HEIGHT) - this.vm.clipHeight) / 2) /
        this.vm.clipHeight * this.vm.srcHeight * 1000) / 1000
      editTextSnap.width = Math.round(editTextVM.width / this.vm.clipWidth * this.vm.srcWidth * 1000) / 1000
      editTextSnap.height = Math.round(editTextVM.height / this.vm.clipHeight * this.vm.srcHeight * 1000) / 1000
      editTextSnap.angle = editTextVM.angle
      editTextSnap.textVal = editTextVM.textVal
      editTextSnap.colorVal = editTextVM.colorVal
      editTextSnap.scaleVal = editTextVM.scaleVal
      editTextSnap.imgScale = editTextVM.imgScale
      editTextSnap.prompterX = editTextVM.prompterX
      editTextSnap.prompterZIndex = editTextVM.prompterZIndex
      editTextSnap.prompterWidth = editTextVM.prompterWidth
      editTextSnap.startTime = editTextVM.startTime
      editTextSnap.endTime = editTextVM.endTime
      haveNum++
      isAtEnd = editTextVM.snapScroller?.isAtEnd() as boolean
    }
    return editTextSnap
  }

  async prompterSnapAction() {
    this.editTextSnapList = []
    let autoCueDir = this.uiContext.getHostContext()?.cacheDir + ConstantsUtil.VIDEO_AUTOCUE_URL
    await deleteFolderRecursively(autoCueDir)
    for (let item of this.teleprompterListVM.editTexts) {
      let editTextSnap: EditTextSnapModel = await this.prompterSnap(item)
      this.editTextSnapList.push(editTextSnap)
    }
  }

  async saveSubtitles() {
    if (this.vm.subtitlesValue && this.vm.subtitlesValue.toString().length > 0) {
      //根据字幕组件ID获取对应的 image.PixelMap
      const pixelMap = await this.getUIContext().getComponentSnapshot().get('textSubTitle', {})
      this.vm.exportSubTitle.url = await saveScreenshot(this.uiContext, pixelMap, 2, '')
      this.vm.exportSubTitle.text = this.vm.subtitlesValue
      this.vm.exportSubTitle.offsetX = this.vm.subTitleX
      this.vm.exportSubTitle.offsetY = this.vm.subTitleY
      this.vm.exportSubTitle.width = this.vm.subTitleWidth
      this.vm.exportSubTitle.height = this.vm.subTitleHeight
    }
  }

  async makeData(): Promise<exportVideo> {
    let videoCoverUrl = ''
    if (this.vm.videoCover !== undefined && this.vm.videoCover.mPixelMap !== undefined) {
      videoCoverUrl = await saveScreenshot(this.uiContext, this.vm.videoCover.mPixelMap!, 4, '')
    } else {
      videoCoverUrl = this.vm.videoCover.url
    }
    if (this.vm.exportPipVideos && this.vm.exportPipVideos.length > 0) {
      this.vm.exportPipVideos[0].isShape = this.vm.isShape
      this.vm.exportPipVideos[0].srcWidth = this.vm.clipPipWidth
      this.vm.exportPipVideos[0].srcHeight = this.vm.clipPipHeight
      this.vm.exportPipVideos[0].offsetPipX = this.vm.offsetPipX
      this.vm.exportPipVideos[0].offsetPipY = this.vm.offsetPipY
      this.vm.exportPipVideos[0].width =
        Number((this.vm.clipPipWidth / this.vm.clipWidth * this.vm.srcWidth).toFixed(1))
      this.vm.exportPipVideos[0].height =
        Number((this.vm.clipPipHeight / this.vm.clipHeight * this.vm.srcHeight).toFixed(1))
      this.vm.exportPipVideos[0].offsetX =
        Number((((this.vm.clipWidth - this.vm.clipPipWidth) / 2 + this.vm.offsetPipX) / this.vm.clipWidth)
          .toFixed(1))
      this.vm.exportPipVideos[0].offsetY =
        Number((((this.vm.clipHeight - this.vm.clipPipHeight) / 2 + this.vm.offsetPipY) / this.vm.clipHeight)
          .toFixed(1))
      this.vm.exportPipVideos[0].pipFrameList.forEach((item) => {
        item.mPixelMap = undefined
      })
      this.vm.exportPipVideos[0].xOffsetDistance = this.vm.pipXDistance
    }
    this.vm.totalDuration = Math.max(this.vm.basicDuration, this.vm.pipDuration + this.vm.pipXDistance * 1000)
    this.vm.allBasicListDisplay.forEach((item) => {
      item.frameList.forEach((frames) => {
        frames.mPixelMap = undefined
      })
    })

    const exportVideoParam: exportVideo = {
      videoFormat: this.vm.videoFormat,
      videoFormatIndex: this.vm.videoFormatIndex,
      videoResolution: this.vm.videoResolution,
      videoResolutionIndex: this.vm.videoResolutionIndex,
      totalDuration: this.vm.totalDuration,
      keyFrame: videoCoverUrl,
      basicVideoData: this.vm.allBasicListDisplay,
      exportPipVideo: this.vm.exportPipVideos,
      exportSubTitle: this.vm.exportSubTitle,
      editTextSnapList: this.editTextSnapList,
      isVip: this.vm.isVip
    }
    return exportVideoParam
  }
}


