import { HotCourse } from 'course';
import { RouterMap, RouterUtils, DateUtil, CommonConstants, Course1, COURSE_DATA1,
  COURSE_CONTENT, CourseContent,
  BreakpointNameEnum,
  BreakpointModel , CourseDataModel} from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AppStorageV2, display } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

class Plan {
  coursePlan: Course1[] = []
}

interface GridSettingInfo {
  template: string;
  colGap: number;
  rowGap: number;
}

@Builder
export function PlanPageBuilder() {
  PlanPage()
}

@ComponentV2
export struct PlanPage {
  scroller: Scroller = new Scroller()
  private weekNameList: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  @Local context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Local dateList: Date[] = [];
  @Local dateSelectIndex: number = 0;
  @Local planList: string[] = [];
  @Local coursePlan: Course1[] = []
  @Local courseContent: CourseContent[] = []
  @Local loss: number = 0
  @Local target: number = 0
  @Local days: number = 0
  @Local energy: number = 0
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local courseDataModel: CourseDataModel = AppStorageV2.connect(CourseDataModel, () => new CourseDataModel())!;
  private listScroller: ListScroller = new ListScroller();
  private month: number = new Date().getMonth();

  aboutToAppear() {
    this.dateList = this.buildDateList();
    this.getUIContext().getHostContext()?.eventHub.on('calculateData', (courseList: string[][]) => {
      this.days = 0
      this.energy = 0
      this.calculateData(courseList)
    })
    this.coursePlan = this.buildPlanList();
    this.calculateData([])
  }

  onPageShow(): void {
    this.dateSelectIndex = 0
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()?.eventHub.off('calculateData')
  }

  calculateData(coursePlan: string[][]) {
    this.getPlanList(this.dateList[this.dateSelectIndex].getDate())
    this.dateList.forEach((date: Date, index) => {
      let courseList: string[] = (coursePlan[index] ?? []) as string[]
      if (courseList.length !== 0) {
        this.days++
      }
      courseList.forEach((courseId: string) => {
        let index: number = Number(courseId) - 1
        this.energy += Number(COURSE_CONTENT[index].energy)
      })
    })
    const pref = preferences.getPreferencesSync(this.context, { name: 'prefData' });
    this.loss = Number((this.energy / 7700).toFixed(2))
    this.target = Number(pref.getSync('userWeight', '')) - this.loss
  }

  private buildPlanList(): Course1[] {
    let coursePlan: Course1[] = []
    let courseContent: CourseContent[] = []
    this.planList.forEach((courseId: string) => {
      let index: number = Number(courseId) - 1
      coursePlan.push(COURSE_DATA1[index])
      courseContent.push(COURSE_CONTENT[index])
    })
    this.courseContent = courseContent
    return coursePlan
  }

  private buildDateList(): Date[] {
    let dateSelectList: Date[] = [];
    const today = new Date();
    // 获取当前星期几 (0 = 周日, 1 = 周一, ..., 6 = 周六)
    const dayOfWeek = today.getDay();
    // 计算距离本周一的天数差
    // 如果是周日(0), 需要回退6天; 如果是周一(1), 不需要回退; 其他情况回退(dayOfWeek - 1)天
    const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    // 创建本周一的日期对象
    const monday = new Date(today);
    monday.setDate(today.getDate() - daysToMonday);
    // 从周一开始生成连续7天的日期
    for (let i = 0; i < 7; i++) {
      const nextDate = new Date(monday);
      nextDate.setDate(monday.getDate() + i);
      dateSelectList.push(nextDate);
    }
    return dateSelectList;
  }

  getPlanList(date: number) {
    this.planList = (AppStorage.get(String(date)) ?? []) as string[]
    this.coursePlan = this.buildPlanList()
  }

  isPassedDay(selectDay: Date): boolean{
    let today: Date = new Date()
    if(selectDay.getMonth() < today.getMonth() || selectDay.getDate() < today.getDate()){
      return true
    }
    return false
  }

  @Computed
  get dateWidth() {
    if ([BreakpointNameEnum.SM, BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 0;
    }
    return 32;
  }

  @Computed
  get gridSetting() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 8,
      rowGap: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr'
      if(this.coursePlan.length < 2){
        gridSettingInfo.template = '1fr'
      }
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        gridSettingInfo.template = '1fr 1fr 1fr'
        if(this.coursePlan.length < 2){
          gridSettingInfo.template = '1fr'
        }else if(this.coursePlan.length < 3){
          gridSettingInfo.template = '1fr 1fr'
        }
        gridSettingInfo.colGap = 24
        gridSettingInfo.rowGap = 11
      }
    }
    return gridSettingInfo
  }

  @Builder
  planBuilder() {
    // 日期选择
    Column() {
      Row() {
        Column() {
          Text((this.month + 1 < 10 ? '0' + (this.month + 1) : this.month + 1 + ''))
            .fontSize($r('sys.float.Body_M'))
            .width(17)
            .height(19)
            .margin({ bottom: 2 })

          Text('月')
            .fontSize(10)
            .width(10)
            .height(14)
        }
        .padding(4)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .margin({ right: 8 })
        .borderRadius(12)
        .height(43)
        .width(24)

        Row() {
          ForEach(this.dateList, (item: Date, index: number) => {
            Column() {
              Text(this.weekNameList[item.getDay()])
                .fontSize($r('sys.float.Body_M'))
                .fontColor(index === this.dateSelectIndex ? '#FFFFFF' :
                  '#333333')
              Text((item.getMonth() + 1 < 10 ? '0' + (item.getMonth() + 1) :
                item.getMonth() + 1 + '') + '.' +
                (item.getDate() < 10 ? '0' + item.getDate() : item.getDate() + ''))
                .fontSize(10)
                .fontColor(index === this.dateSelectIndex ? '#FFFFFF' :
                  '#333333')
            }
            .backgroundColor(index === this.dateSelectIndex ? $r('app.color.app_theme') :
              '#FFFFFF')
            .height(43)
            .width(36)
            .padding(4)
            .justifyContent(FlexAlign.SpaceAround)
            .borderRadius(8)
            .onClick(() => {
              this.dateSelectIndex = index;
              this.getPlanList(item.getDate())
            })
          }, (item: Date) => DateUtil.formatDate(item))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: 16, top: 12, right: 16, bottom: 12 })
    }
    .width(`calc(100% - ${2 * this.dateWidth}vp)`)
    .height(67)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 8, bottom: 12 })
  }

  @Computed
  get buttonWidth() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 304;
    }
    return 448;
  }

  @Computed
  get borderPadding() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 16;
    }
    if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 24;
    }
    return 32;
  }

  @Builder
  courseBuilder(plan: Plan) {
    Column() {
      Grid() {
        ForEach(plan.coursePlan, (course: Course1, index: number) => {
          GridItem() {
            Column() {
              // 完成标签
              Row() {
                Image(
                  this.dateList[this.dateSelectIndex].getDate() === new Date().getDate() &&
                    (this.courseDataModel.courseProgress.get(course.id) ?? 0) > 15 ?
                    $r('app.media.ic_finish') :$r('app.media.ic_unfinish')
                )
                  .margin({ right: 4 })
                  .width(16)
                  .height(16)
                Text(
                  this.dateList[this.dateSelectIndex].getDate() === new Date().getDate() &&
                    (this.courseDataModel.courseProgress.get(course.id) ?? 0) > 15 ?
                    '课程已完成' : '课程未完成')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor('rgba(0, 0, 0, 0.4)')
              }
              .width('100%')
              .justifyContent(FlexAlign.End)

              // 左图右文核心内容
              Row(){
                Image(course.cover)
                  .width(80)
                  .height(80)
                  .borderRadius(8)
                  .margin({ right: 12 })

                Column({ space: 8 }) {
                  Text(course.courseTitle)
                    .fontSize($r('sys.float.Body_L'))
                    .margin({ top: 4 })
                    .fontWeight(FontWeight.Medium)
                  Row() {
                    Text(`难度：${this.courseContent[index].difficulty}`)
                      .fontSize($r('sys.float.Body_S'))
                      .fontColor('rgba(0, 0, 0, 0.6)')
                      .fontWeight(FontWeight.Regular)
                      .margin({ right: 12 })
                    Image($r('app.media.ic_time'))
                      .margin({ right: 4 })
                      .width(12)
                      .height(12)
                    Text(`${this.courseContent[index].duration}分钟`)
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_S'))
                      .fontColor('rgba(0, 0, 0, 0.6)')
                  }
                  Text(`预计消耗热量：${this.courseContent[index].energy}kcal`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor('rgba(0, 0, 0, 0.6)')
                    .fontWeight(FontWeight.Regular)
                }
                .width('70%')
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .margin({ bottom: 12 })
            .onClick(() => RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, course.id))
          }
        })
      }
      .columnsTemplate(this.gridSetting.template)
      .columnsGap(this.gridSetting.colGap)
      .rowsGap(this.gridSetting.rowGap)

      if (this.isPassedDay(this.dateList[this.dateSelectIndex])) {
        Button(){
          Row() {
            SymbolGlyph($r('sys.symbol.plus_circle_fill'))
              .width(16)
              .height(16)
              .margin({ top: 4, bottom: 4, right: 8 })
              .fontColor([$r('sys.color.icon_on_primary')])
            Text('添加计划')
              .width(64)
              .height(21)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_on_primary'))
              .margin({ top: 1.5, bottom: 1.5 })
          }
          .justifyContent(FlexAlign.Center)
        }
        .width(this.buttonWidth)
        .height(40)
        .borderRadius(24)
        .backgroundColor($r('app.color.app_theme'))
        .padding({ top: 8, left: 24, right: 24, bottom: 8 })
        .opacity(0.4)
      } else {
        Button(){
          Row() {
            SymbolGlyph($r('sys.symbol.plus_circle_fill'))
              .width(16)
              .height(16)
              .margin({ top: 4, bottom: 4, right: 8 })
              .fontColor([$r('sys.color.icon_on_primary')])
            Text('添加计划')
              .fontSize($r('sys.float.Body_L'))
              .width(64)
              .height(21)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_on_primary'))
              .margin({ top: 1.5, bottom: 1.5 })
          }
          .justifyContent(FlexAlign.Center)
        }
        .onClick(() => RouterUtils.pushPathByName(RouterMap.COURSE_PAGE_PLAN))
        .backgroundColor($r('app.color.app_theme'))
        .padding({ top: 8, left: 24, right: 24, bottom: 8 })
        .width(this.buttonWidth)
        .height(40)
        .borderRadius(24)
      }
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.font_on_primary'))
  }

  @Builder
  noCoursebuild() {
    Column() {
      if (this.isPassedDay(this.dateList[this.dateSelectIndex])) {
        Image($r('app.media.plandateout'))
          .width(120)
          .height(120)

        Text('当前日期已过期, 不可添加')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .margin({ top: 16, bottom: 8 })

      } else {
        Image($r('app.media.noplan'))
          .width(120)
          .height(120)

        Text('暂无计划，赶快去添加吧~')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .margin({ top: 8, bottom: 8 })

        Button(){
          Row() {
            SymbolGlyph($r('sys.symbol.plus_circle_fill'))
              .width(16)
              .height(16)
              .margin({ top: 4, bottom: 4, right: 8 })
              .fontColor([$r('sys.color.icon_on_primary')])
            Text('添加计划')
              .fontSize($r('sys.float.Body_L'))
              .width(64)
              .height(21)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_on_primary'))
              .margin({ top: 1.5, bottom: 1.5 })
          }
          .justifyContent(FlexAlign.Center)
        }
        .onClick(() => RouterUtils.pushPathByName(RouterMap.COURSE_PAGE_PLAN))
        .backgroundColor($r('app.color.app_theme'))
        .padding({ top: 8, left: 24, right: 24, bottom: 8 })
        .width(this.buttonWidth)
        .height(40)
        .borderRadius(24)
      }
    }
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(16)
    .padding(12)
    .width('100%')
    .height(219)
  }

  @Builder
  async purposeBuild() {
    Column() {
      Row() {
        Image($r('app.media.purpose'))
          .width(16)
          .height(16)
          .margin({ right: 8 })
        Text('本周目标')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0, 0, 0, 0.9)')
        Blank()
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Column() {
          Row() {
            Text(String(this.loss))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(0,0,0,0.9)')
            Text('（kg）')
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.6)')
          }
          .height(24)
          .margin({ bottom: 8 })

          Text('预计减重')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.6)')
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height(48)

        Column() {
          Row() {
            Text(this.target > 0 ? String(this.target) : '---')
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(0,0,0,0.9)')
              .fontSize(18)
            Text('（kg）')
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.6)')
          }
          .height(24)
          .margin({ bottom: 8 })

          Text('目标体重')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.6)')
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height(48)

        Column() {
          Row() {
            Text(String(this.days))
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(0,0,0,0.9)')
              .fontSize(18)
          }
          .height(24)
          .margin({ bottom: 8 })

          Text('训练天数')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.6)')
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height(48)

        Column() {
          Row() {
            Text(String(this.energy))
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(0,0,0,0.9)')
              .fontSize(18)
            Text('（kcal）')
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.6)')
          }
          .height(24)
          .margin({ bottom: 8 })

          Text('消耗热量')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.6)')
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height(48)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
    .padding(12)
    .margin({ top: 12 })
    .borderRadius(16)
    .width('100%')
  }

  @Builder
  recommendCourseListBuilder() {
    Column() {
      Row() {
        Text('推荐课程')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
        Image($r('app.media.ic_right'))
          .width(12)
          .height(24)
          .opacity(0.4)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.RECOMMENDATION_COURSE_PAGE)
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
    .width('100%')
    .padding({ top: 24, bottom: 8 })

    Column() {
      HotCourse({ isShowTop: true })
    }
    .margin({ bottom: 20 })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '计划',
          isSubTitle: false,
        })
        // 日期
        this.planBuilder()
        Scroll(this.scroller) {
          Column() {
            // 计划
            if (this.coursePlan.length !== 0) {
              this.courseBuilder({ coursePlan: this.coursePlan })
            } else {
              this.noCoursebuild()
            }
            // 本周目标
            this.purposeBuild()
            // 推荐课程
            this.recommendCourseListBuilder()
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .padding({ left: this.borderPadding, right: this.borderPadding })
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.plan_background'))
    }
    .onShown(() => {
      this.dateSelectIndex = 0
    })
    .onWillShow(() => {
      this.dateSelectIndex = 0
    })
  }
}

