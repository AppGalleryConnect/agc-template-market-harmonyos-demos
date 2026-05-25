import { NavHeaderBar } from 'lib_widget';
import { CoursePageVM } from '../viewmodels/CoursePageVM';
import { CollectionModel } from 'mine'
import { CourseItemComponent } from 'mine'
import { MineServiceApi } from 'lib_api';
import { COURSE_DATA } from 'lib_common';
import dayjs from 'dayjs';

@Builder
export function FilterPageBuilder() {
  FilterPage()
}

@ComponentV2
struct FilterPage {
  vm: CoursePageVM = new CoursePageVM();
  @Local filter: string[] = AppStorage.get('FilterList') as string[]
  @Local filterList: CollectionModel[] = []
  scroller: Scroller = new Scroller()

  async aboutToAppear() {
    this.filter = AppStorage.get('FilterList') as string[]
    this.filterList = []
    // 我的收藏数据初始化
    this.initFilterData()
  }

  async aboutToDisappear() {
    AppStorage.setOrCreate<String[]>('FilterList', [])
    this.filter = []
    this.filterList = []
  }

  /**
   * 课程筛选结果初始化
   */
  initFilterData() {
    if (this.filter.includes('零基础')) {
      let courseModel: CollectionModel = new CollectionModel()
      let courseModel1: CollectionModel = new CollectionModel()
      let courseModel2: CollectionModel = new CollectionModel()
      courseModel.id = COURSE_DATA[10].id
      courseModel.time = dayjs(COURSE_DATA[10].time).format('YYYY-MM-DD')
      courseModel.isDelete = false
      courseModel.courseTitle = COURSE_DATA[10].courseTitle
      courseModel.courseDuration = COURSE_DATA[10].courseDuration
      courseModel.learnProgress = COURSE_DATA[10].learnProgress
      courseModel.cover = COURSE_DATA[10].cover
      this.filterList.push(courseModel)
      courseModel1.id = COURSE_DATA[12].id
      courseModel1.time = dayjs(COURSE_DATA[12].time).format('YYYY-MM-DD')
      courseModel1.isDelete = false
      courseModel1.courseTitle = COURSE_DATA[12].courseTitle
      courseModel1.courseDuration = COURSE_DATA[12].courseDuration
      courseModel1.learnProgress = COURSE_DATA[12].learnProgress
      courseModel1.cover = COURSE_DATA[12].cover
      this.filterList.push(courseModel1)
      courseModel2.id = COURSE_DATA[13].id
      courseModel2.time = dayjs(COURSE_DATA[13].time).format('YYYY-MM-DD')
      courseModel2.isDelete = false
      courseModel2.courseTitle = COURSE_DATA[13].courseTitle
      courseModel2.courseDuration = COURSE_DATA[13].courseDuration
      courseModel2.learnProgress = COURSE_DATA[13].learnProgress
      courseModel2.cover = COURSE_DATA[13].cover
      this.filterList.push(courseModel2)
    }
    if (this.filter.includes('免费')) {
      let courseModel: CollectionModel = new CollectionModel()
      let courseModel1: CollectionModel = new CollectionModel()
      let courseModel2: CollectionModel = new CollectionModel()
      let courseModel3: CollectionModel = new CollectionModel()
      let courseModel4: CollectionModel = new CollectionModel()
      courseModel.id = COURSE_DATA[10].id
      courseModel.time = dayjs(COURSE_DATA[10].time).format('YYYY-MM-DD')
      courseModel.isDelete = false
      courseModel.courseTitle = COURSE_DATA[10].courseTitle
      courseModel.courseDuration = COURSE_DATA[10].courseDuration
      courseModel.learnProgress = COURSE_DATA[10].learnProgress
      courseModel.cover = COURSE_DATA[10].cover
      this.filterList.push(courseModel)
      courseModel1.id = COURSE_DATA[9].id
      courseModel1.time = dayjs(COURSE_DATA[9].time).format('YYYY-MM-DD')
      courseModel1.isDelete = false
      courseModel1.courseTitle = COURSE_DATA[9].courseTitle
      courseModel1.courseDuration = COURSE_DATA[9].courseDuration
      courseModel1.learnProgress = COURSE_DATA[9].learnProgress
      courseModel1.cover = COURSE_DATA[9].cover
      this.filterList.push(courseModel1)
      courseModel2.id = COURSE_DATA[8].id
      courseModel2.time = dayjs(COURSE_DATA[8].time).format('YYYY-MM-DD')
      courseModel2.isDelete = false
      courseModel2.courseTitle = COURSE_DATA[8].courseTitle
      courseModel2.courseDuration = COURSE_DATA[8].courseDuration
      courseModel2.learnProgress = COURSE_DATA[8].learnProgress
      courseModel2.cover = COURSE_DATA[8].cover
      this.filterList.push(courseModel2)
      courseModel3.id = COURSE_DATA[7].id
      courseModel3.time = dayjs(COURSE_DATA[7].time).format('YYYY-MM-DD')
      courseModel3.isDelete = false
      courseModel3.courseTitle = COURSE_DATA[7].courseTitle
      courseModel3.courseDuration = COURSE_DATA[7].courseDuration
      courseModel3.learnProgress = COURSE_DATA[7].learnProgress
      courseModel3.cover = COURSE_DATA[7].cover
      this.filterList.push(courseModel3)
      courseModel4.id = COURSE_DATA[6].id
      courseModel4.time = dayjs(COURSE_DATA[6].time).format('YYYY-MM-DD')
      courseModel4.isDelete = false
      courseModel4.courseTitle = COURSE_DATA[6].courseTitle
      courseModel4.courseDuration = COURSE_DATA[6].courseDuration
      courseModel4.learnProgress = COURSE_DATA[6].learnProgress
      courseModel4.cover = COURSE_DATA[6].cover
      this.filterList.push(courseModel4)
    }
  }

  @Builder
  FilterCourse() {
    Column() {
      // 有数据时显示收藏列表
      List() {
        ForEach(this.filterList, ((item: CollectionModel, index: number) => {
          ListItem() {
            Row() {
              // 课程列表子项
              CourseItemComponent({
                courseId: item.id,
                courseTitle: item.courseTitle,
                courseDuration: item.courseDuration,
                learnProgress: item.learnProgress,
                cover: item.cover,
                time: item.time,
              })
            }
            .width('100%')
            .onClick(() => {

            })
          }
          .padding({ left: 16, right: 16 })
        }), (item: CollectionModel, index: number) => item.id + index)
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      // 无数据时显示
      Text('课程筛选结果为空。')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.icon_secondary'))
        .height('100%')
        .visibility(this.filterList.length === 0 ? Visibility.Visible : Visibility.None)
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '筛选课程',
        })

        Scroll(this.scroller){
          Column() {
            this.FilterCourse()
          }
          .height('100%')
          .margin({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .margin({ bottom: 30 })
        .width('100%')
      }
      .height('100%')
      .backgroundColor($r('app.color.course_background'))
    }
    .hideTitleBar(true)
  }
}
