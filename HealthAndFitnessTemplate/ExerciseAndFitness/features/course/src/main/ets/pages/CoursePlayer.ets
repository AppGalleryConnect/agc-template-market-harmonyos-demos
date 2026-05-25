import { AppStorageV2, window } from '@kit.ArkUI';
import {
  Course1,
  COURSE_DATA1,
  MyCourseParam,
  RouterMap,
  RouterModule,
  UserInfo,
  WindowSize,
  CourseDataModel,
  ExerciseRecord,
  ExerciseDays,
  COURSE_CONTENT
} from 'lib_common';
import { MovieItem, PlayerComponent, PlayerVM } from 'module_player';
import { CommentModel, CourseCatalogModel, CourseModel, ConvertTool } from 'lib_common';

@Builder
export function CoursePlayerBuilder() {
  CoursePlayer();
}

@ComponentV2
export struct CoursePlayer {
  @Local courseId: string = ''
  @Local arr: number[] = [50, 40, 30, 20, 10]
  @Local isShow: boolean = false
  @Local keyboardHeight: number = 0;
  // 窗口状态
  @Local windowStatusType: number = 0;
  @Local isLayoutFullScreen: boolean = false;
  @Local courseDetail: CourseModel = new CourseModel()
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  // 课程目录
  @Local isShowCatalog: boolean = false
  @Local selectSelection: string = '';
  // 课程目录当前选中
  @Local indexNumber: number = 0;
  @Local comments: CommentModel[] = [];
  @Local playerVM: PlayerVM = PlayerVM.instance;
  @Local learnProgress: number = 0;
  @Local param: MyCourseParam = MyCourseParam.instance()
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
  @Local courseDataModel: CourseDataModel = AppStorageV2.connect(CourseDataModel, () => new CourseDataModel())!;
  private scroller: ListScroller = new ListScroller();
  private movieItems: MovieItem[] = [];

  async aboutToAppear() {
    let course: Course1 = COURSE_DATA1[0]
    let index: number = Number(this.courseId) - 1
    course = COURSE_DATA1[index]
    let courseModel = ConvertTool.convertCourseModel(course) as CourseModel
    if (courseModel) {
      this.courseDetail = courseModel
      if (this.courseDetail.isPay || this.courseDetail.isFree) {
        this.playerVM.isSelections = true
      } else {
        this.playerVM.isSelections = false
      }
      this.courseDetail.courseCatalog?.forEach((item: CourseCatalogModel) => {
        this.movieItems.push(new MovieItem(item.id, item.catalogTitle, item.learnProgress, item.videoUrl!))
      })
      this.indexNumber = this.courseDetail.catalogIndex
      this.selectSelection = this.movieItems[this.indexNumber].movieTitle
      this.learnProgress = this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd ? 100 :
        this.courseDetail.courseCatalog[this.indexNumber].learnProgress
      this.comments = this.courseDetail.courseCatalog[this.indexNumber].comments
      this.comments.sort((a, b) => b.time - a.time)
      this.courseDetail.isWatch = true
      this.courseDetail.isStudy = true
      this.courseDetail.studyTime = Date.now()
      this.courseDetail.watchTime = Date.now()
    }

    try {
      let currentWindow = await window.getLastWindow(this.getUIContext().getHostContext()!)
      // 获取窗口属性
      let properties = currentWindow.getWindowProperties();
      let rect = properties.windowRect;
      if (this.getUIContext().px2vp(rect.height) <= 680) {
        this.windowStatusType = 5
      }
      currentWindow.on('windowStatusChange', (windowStatusType) => {
        this.windowStatusType = windowStatusType
      });
      currentWindow.on('avoidAreaChange', data => {
        if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
          if (data.area.bottomRect.height === 0) {
            this.keyboardHeight = 0
          } else {
            this.keyboardHeight = this.windowStatusType === 5 ? 0 : 100;
          }
        }
      })
    } catch (e) {
      console.error(`Failed to get last window. error: ${JSON.stringify(e)}`)
    }
  }

  aboutToDisappear(): void {
    let learnProgress: number = 0
    this.courseDetail.courseCatalog.forEach((item: CourseCatalogModel) => {
      if (item.isStudyEnd) {
        learnProgress += 100
      } else {
        learnProgress += item.learnProgress
      }
    })
    if (learnProgress >= this.courseDetail.courseCatalog.length * 100) {
      this.courseDetail.isStudyEnd = true
    } else {
      // 一个视频播放完进度为: (1 / 6) * 100 向下取整，从COURSE_DATA1获得的课程章节均为6个
      this.courseDetail.learnProgress = Math.floor(learnProgress / (this.courseDetail.courseCatalog.length * 100) * 100)
    }
    this.param.isLearn = true
    this.courseDataModel.courseProgress.set(this.courseId , this.courseDetail.learnProgress)
    if (this.courseDetail.learnProgress >= Math.floor((1/this.courseDetail.courseCatalog.length) * 100)) {
      this.updateExerciseRecord()
    }
  }

  updateExerciseRecord() {
    let index: number = Number(this.courseId) - 1
    let label: string = COURSE_DATA1[index].label
    let courseList: string[] = AppStorage.get(String(new Date().getDate())) ?? []
    if (courseList.includes(this.courseId)) {
      AppStorage.setOrCreate<boolean>(label, true);
    }
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    let exerciseRecord: ExerciseRecord =
      AppStorageV2.connect(ExerciseRecord, String(`${year}-${month}-${day}`), () => new ExerciseRecord())!;
    if (exerciseRecord.duration === 0) {
      let totalDays: ExerciseDays = AppStorageV2.connect(ExerciseDays, 'totalDays', () => new ExerciseDays())!;
      totalDays.totalDays += 1;
    }
    exerciseRecord.duration += Number(COURSE_CONTENT[index].duration);
    exerciseRecord.energy += Number(COURSE_CONTENT[index].energy);
    let totalRecord: ExerciseRecord =
      AppStorageV2.connect(ExerciseRecord, 'totalRecord', () => new ExerciseRecord())!;
    totalRecord.duration += Number(COURSE_CONTENT[index].duration);
    totalRecord.energy += Number(COURSE_CONTENT[index].energy);
  }

  @Builder
  playerBuilder() {
    Row() {
      PlayerComponent({
        courseId: this.courseId,
        movieItems: this.movieItems,
        playerIndex: this.indexNumber,
        fullScreen: (isLayoutFullScreen: boolean) => {
          this.isLayoutFullScreen = isLayoutFullScreen
        },
        selectionEvent: (idx: number) => {
          this.indexNumber = idx
          this.selectSelection = this.movieItems[idx].movieTitle
          this.comments = this.courseDetail.courseCatalog[this.indexNumber].comments
          this.learnProgress = this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd ? 100 :
            this.courseDetail.courseCatalog[this.indexNumber].learnProgress
        },
        callbackTimeUpdate: (vol: number, total: number) => {
          if (this.courseDetail.courseCatalog[this.indexNumber].learnProgress >= 100) {
            this.courseDetail.courseCatalog[this.indexNumber].isStudyEnd = true
          }
          this.courseDetail.courseCatalog[this.indexNumber].learnProgress = Math.floor(vol / total * 100)
        }
      })
        .width('100%')
        .height(this.isLayoutFullScreen ? '100%' :
          (this.getUIContext().px2vp(this.windowSize.screenWidth) - 32) * 9 / 16)
        .borderRadius(this.isLayoutFullScreen ? 0 : 16)
        .clip(true)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
    .padding(this.isLayoutFullScreen ? 0 : {
      top: 10,
      bottom: 10,
      left: 16,
      right: 16
    })
  }

  build() {
    NavDestination() {
      Column() {
          Column() {
            this.playerBuilder()
          }
          .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(this.isLayoutFullScreen ? 'rgba(0,0,0,1)' : Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.courseId = context.pathInfo?.param as string
      this.aboutToAppear()
    })
  }
}