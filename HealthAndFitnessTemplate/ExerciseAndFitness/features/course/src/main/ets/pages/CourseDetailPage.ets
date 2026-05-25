import {
  BreakpointModel,
  BreakpointNameEnum,
  UserInfoModel,
  Course1, CourseContent, COURSE_CONTENT, COURSE_DATA1, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { CoursePageVM } from '../viewmodels/CoursePageVM';
import { addDialog, addPlanDialog, cancelDialog, DateDialog, explain,
  explainVIP, PlanDialog } from '../viewmodels/CustomDialog';
import { emitter } from '@kit.BasicServicesKit';
import { calendarManager } from '@kit.CalendarKit';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction , PersistenceV2 } from '@kit.ArkUI';
import { LoginSheetUtils } from 'lib_account';

@Builder
export function CourseDetailPageBuilder() {
  CourseDetailPage()
}

interface GridSettingInfo {
  template: string;
  colGap: number;
  rowGap: number;
}

@ComponentV2
struct CourseDetailPage {
  @Local courseId: string = '';
  vm: CoursePageVM = new CoursePageVM();
  scroller: Scroller = new Scroller()
  @Local isShowAddPlanDialog: boolean = false;
  @Local isShowAddDateDialog: boolean = false;
  @Local isShowExplain: boolean[] = [];
  @Local isShowExplain1: boolean = false;
  @Local isShowExplain2: boolean = false;
  @Local isShowExplain3: boolean = false;
  @Local isShowExplain4: boolean = false;
  @Local isShowExplain5: boolean = false;
  @Local sheetHeight: number = 470;
  @Local clickedStates: boolean[] = [false, false, false, false, false, false, false]
  @Local label: string = '';
  @Local planList: number[] = [];
  @Local courseDateList: string[] = [];
  @Local dateList: string[] = [];
  @Local course: Course1 = COURSE_DATA1[0]
  @Local courseContent: CourseContent = COURSE_CONTENT[0]
  @Local isStar: boolean = AppStorage.get(this.courseId) as boolean
  @Local calendar: calendarManager.Calendar | undefined = undefined;
  @Local calendarMgr: calendarManager.CalendarManager | null = null;
  @Local titleList: string[] = []
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  buildDateList(): string[] {
    let planDateList: string[] = [];
    const today = new Date();
    const dayOfWeek = today.getDay();
    const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    const monday = new Date(today);
    monday.setDate(today.getDate() - daysToMonday);
    for (let i = 0; i < 7; i++) {
      const nextDate = new Date(monday);
      nextDate.setDate(monday.getDate() + i);
      planDateList.push(String(nextDate.getDate()));
    }
    return planDateList;
  }

  aboutToAppear() {
    this.isStar = AppStorage.get(this.courseId) as boolean
    this.titleList = this.courseContent.contentCategory
    this.vm.addHistory(this.label)
    this.courseDateList = this.buildDateList()
    this.courseDateList.forEach((date: string , index: number) => {
      let coursePlan: string[] = (AppStorage.get(date) ?? []) as string[]
      if(coursePlan.includes(this.courseId)){
        this.clickedStates[index] = true
        this.planList.push(Number(date))
      }
    })

    // 3.创建日历账户
    this.calendarMgr?.createCalendar(this.calendarAccount).then((data: calendarManager.Calendar) => {
      console.info(`Succeeded in creating calendar data->${JSON.stringify(data)}`);
      this.calendar = data;
      // 设置日历配置信息
      this.calendar.setConfig(this.calendarConfig).then(() => {
        console.info(`Succeeded in setting config, data->${JSON.stringify(this.calendarConfig)}`);
      }).catch((err: BusinessError) => {
        console.error(`Failed to set config. Code: ${err.code}, message: ${err.message}`);
      });
    }).catch((error: BusinessError) => {
      console.error(`Failed to create calendar. Code: ${error.code}, message: ${error.message}`);
    });
  }

  // 1.配置日历账户信息
  private calendarAccount: calendarManager.CalendarAccount = {
    // 日历账户名称（面向开发者）
    name: '运动健康',
    // 日历账户类型（LOCAL，本地账号；EMAIL，邮箱账号；BIRTHDAY，生日账号；BIRTHDAY，支持CalDAV协议账户；SUBSCRIBED，订阅账户）
    type: calendarManager.CalendarType.LOCAL,
    // 日历账户显示名称，该字段如果不填，创建的日历账户在界面显示为空字符串。
    displayName: '运动健康'
  };

  // 2.配置日历配置信息
  private calendarConfig: calendarManager.CalendarConfig = {
    // 是否打开Calendar下所有Event提醒能力
    enableReminder: true,
    // 设置日历账户颜色
    color: '#aabbcc'
  };

  public getCalendarPermission(): Promise<string> {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;

    const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    let atManager = abilityAccessCtrl.createAtManager();
    return new Promise((resolve, reject) => {
      atManager.requestPermissionsFromUser(context, permissions).then((result: PermissionRequestResult) => {
        if (result.authResults[0] === -1 && result.authResults[1] === -1) {
          resolve('failed')
        } else {
          resolve('success')
        }
      }).catch((error: BusinessError) => {
        reject('failed')
        console.error(`get Permission error, error. Code: ${error.code}, message: ${error.message}`);
      })
    })
  }

  addPlanDialogController: CustomDialogController = new CustomDialogController({
    builder: addPlanDialog({
    }),
    alignment: DialogAlignment.Center
  })

  cancelDialogController: CustomDialogController = new CustomDialogController({
    builder: cancelDialog({

    }),
    alignment: DialogAlignment.Center,
    autoCancel: true  // 允许点击蒙层关闭
  })

  addDialogController: CustomDialogController = new CustomDialogController({
    builder: addDialog({
    }),
    alignment: DialogAlignment.Center
  })

  isVIPCourse(): boolean {
    if ((this.courseId === '0006' || this.courseId === '0007' || this.courseId === '0008' ||
      this.courseId === '0009' || this.courseId === '0010' || this.courseId === '0011') && !this.vm.isVIP()) {
      return true
    }
    return false
  }

  @Builder
  addPlanDialogBuilder() {
    Column() {
      PlanDialog({ planList: this.planList, clickedStates: this.clickedStates , courseId: this.courseId })

      Row() {
        Text('保存计划')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .margin({ top: 10})
      .width(328)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('app.color.app_theme'))
      .onClick(() => {
        let courseList: string[][] = []
        this.courseDateList.forEach((date: string) => {
          let coursePlan: string[] = (AppStorage.get(date) ?? []) as string[]
          if (this.planList.includes(Number(date))) {
            if (!coursePlan.includes(this.courseId)) {
              coursePlan = [...coursePlan, this.courseId]; // 添加课程ID
            }
          } else {
            const courseIndex = coursePlan.indexOf(this.courseId);
            if (courseIndex !== -1) {
              coursePlan.splice(courseIndex, 1); // 从数组中移除课程ID
            }
          }
          AppStorage.setOrCreate<string[]>(date, coursePlan)
          courseList.push(coursePlan)
        })
        this.getUIContext().getHostContext()?.eventHub.emit('calculateData', courseList);
        this.isShowAddPlanDialog = false;
        if(this.planList.length !== 0) {
          this.addPlanDialogController.open();
        }
      })
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16, top: 9, bottom: 9 })
    }
    .backgroundColor('rgba(255, 255, 255, 0.9)')
    .width('100%')
  }

  @Builder
  addDateDialogBuilder() {
    Column() {
      DateDialog({ dateList: this.dateList })

      Row() {
        Text('保存日程')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16, top: 9, bottom: 9 })
      .width(328)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('app.color.app_theme'))
      .onClick(async () => {
        this.isShowAddDateDialog = false;
        if(this.dateList.length !== 0) {
          // 加日程
          let permission = await this.getCalendarPermission()

          if (permission === 'success') {
            this.calendarMgr =
              calendarManager.getCalendarManager(this.getUIContext().getHostContext() as common.UIAbilityContext);

            for (let i = 0; i < this.dateList.length; i++) {
              if (this.dateList[i]) {
                const date = new Date();
                date.setDate(Number.parseInt(this.dateList[i]));

                // 日历提醒信息，可根据需要自定义配置
                const event: calendarManager.Event = {
                  // 日程标题
                  title: this.course.courseTitle,
                  // 日程类型，不推荐三方开发者使用calendarManager.EventType.IMPORTANT，重要日程类型不支持一键服务跳转功能及无法自定义提醒时间
                  type: calendarManager.EventType.NORMAL,
                  // 是否为全天日程
                  isAllDay: true,
                  // 日程开始时间
                  startTime: date.getTime(),
                  // 日程结束时间
                  endTime: date.getTime() + 60 * 60 * 1000,
                };

                let calendar: calendarManager.Calendar | undefined = undefined;

                try {
                  this.calendarMgr?.getCalendar((err: BusinessError, data:calendarManager.Calendar) => {
                    if (err) {
                      console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
                    } else {
                      console.info(`Succeeded in getting calendar, data -> ${JSON.stringify(data)}`);
                      calendar = data;
                      calendar.addEvent(event).then((data: number) => {
                        console.info(`Succeeded in adding event, id -> ${data}`);
                      }).catch((err: BusinessError) => {
                        console.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
                      });
                    }
                  });
                } catch (e) {
                  console.error('getCalendar failed')
                }
              }
            }

            this.addDialogController.open();
          }else {
            this.getUIContext().getPromptAction().showToast({message: '没有日历权限，请去设置页面授权'});
          }
        }
      })
    }
    .width('100%')
    .margin({bottom: 10})
    .backgroundColor('rgba(255, 255, 255, 0.9)')
  }

  @Builder
  explainBuilder(index: number, titleList: string[]) {
    Column() {
      Scroll() {
        explain({
          title: titleList[index],
          isVideo: this.courseContent.isVideos[index],
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1) // 占据剩余空间，让底部按钮固定

      Row({ space: 16 }) {
        Image(index === 0 ? $r('app.media.explain_left') : $r('app.media.ic_left_on'))
          .width(40)
          .onClick(() => {
            this.isShowExplain[index] = false;
            this.isShowExplain[index-1] = true;
          })
        Text('我已了解')
          .width(216)
          .height(40)
          .fontColor(Color.White)
          .borderRadius(24)
          .textAlign(TextAlign.Center)
          .padding({ left: 24, right: 24, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.app_theme'))
          .onClick(() => {
            this.isShowExplain[index] = false;
          })
        Image(index !== titleList.length - 1 ? $r('app.media.explain_right') : $r('app.media.ic_right_off'))
          .width(40)
          .onClick(() => {
            this.isShowExplain[index] = false;
            this.isShowExplain[index+1] = true;
          })
      }
      .margin({ bottom: 28 })
      .width('100%')
      .height(64)
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor('rgba(255, 255, 255, 0.9)')
    .width('100%')
    .height('100%')
  }

  @Builder
  explainVIPBuilder(index: number, titleList: string[]) {
    Column() {
      Scroll() {
        explainVIP(titleList[index])
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1) // 占据剩余空间，让底部按钮固定

      Column() {
        Row() {
          Image($r('app.media.ic_vip'))
            .width(24)
            .height(24)
            .margin({ right: 4 })
          Text('开通会员解锁课程？')
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
        }
      }
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 16, right: 16, top: 9, bottom: 9 })
      .margin({ left: 16, right: 16 , bottom: 28 })
      .backgroundColor($r('app.color.app_theme'))
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .width('90%')
      .height(40)
      .onClick(() => {
        this.isShowExplain[index] = false;
        RouterUtils.pushPathByName(RouterMap.VIP_PAGE);
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder courseIntroduction() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(this.course.cover)
          .width('100%')
          .aspectRatio(1.8)
          .objectFit(ImageFit.Cover)
          .borderRadius(16)

        Image(this.isStar ? $r('app.media.star') : $r('app.media.no_star'))
          .width(40)
          .height(40)
          .margin({ right: 12, bottom: 12 })
          .onClick(() => {
            if (!this.isStar) {
              if (this.vm.saveAction(this.label)) {
                this.isStar = true;
                AppStorage.setOrCreate<boolean>(this.courseId, true)
              }
            } else {
              if (this.vm.deleteAction(this.label)) {
                this.isStar = false;
                AppStorage.setOrCreate<boolean>(this.courseId, false)
              }
            }
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        Text(this.course.courseTitle)
          .fontWeight(FontWeight.Bold)
          .fontSize(18)
        Text(`难度：${this.courseContent.difficulty}`)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .margin({ top: 12, bottom: 12 })
        Text(`预计时长：${this.courseContent.duration}分钟`)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .margin({ bottom: 12 })
        Text(`预计消耗热量：${this.courseContent.energy} (kcal)`)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
        Text('练习建议')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .margin({ top: 25, bottom: 4 })
        Text(this.course.description)
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontSize($r('sys.float.Body_M'))
        Text('注意事项')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .margin({ top: 25, bottom: 4 })
        Column() {
          ForEach(this.courseContent.careAbout, (item: string) => {
            Text(item)
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontSize($r('sys.float.Body_M'))
              .margin({ bottom: 8 })
              .width('100%')
              .textAlign(TextAlign.Start)
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(12)
      .borderRadius(16)
      .backgroundColor(Color.White)
    }
  }

  @Computed
  get buttonWidth() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 223;
    }
    return 448;
  }

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 16,
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr'
    }
    return gridSettingInfo
  }

  @Builder courseContentDetail() {
    Column() {
      Column() {
        Text('课程内容')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
      }
      .width('100%')
      .height(24)
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 8 })

      Column() {
        ForEach(this.courseContent.contentCategory, (item: string, index) => {
          Row() {
            Row() {
              Text(item)
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'))
                .margin({ right: 8 })
              Text(this.courseContent.contentDuration[index])
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_M'))
            }

            Row({ space: 4 }){
              Image(this.courseContent.isVideos[index] ? $r('app.media.video_fill'): $r('app.media.picture_fill'))
                .width(16)
                .height(16)
              Text('学习')
                .fontColor(Color.White)
                .textAlign(TextAlign.End)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.app_theme'))
            .width(80)
            .height(28)
            .borderRadius(14)
            .onClick(() => {
              this.isShowExplain[index] = true;
            })
            .bindSheet(this.isShowExplain[index], (!this.vm.isVIP() && this.isVIPCourse()) ?
              this.explainVIPBuilder(index, this.titleList) : this.explainBuilder(index, this.titleList), {
              height: '90%',
              dragBar: false,
              showClose: true,
              preferType: SheetType.CENTER,
              backgroundColor: '#fff',
              onDisappear: () => {
                this.isShowExplain[index] = false;
              }
            })
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .justifyContent(FlexAlign.SpaceBetween)
        })
      }
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding({ left: 12, right: 12 })
      .width('100%')
    }

  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '课程详情',
        })

        Scroll(this.scroller) {
          Column() {
            Grid() {
              GridItem() {
                this.courseIntroduction()
              }
              GridItem() {
                this.courseContentDetail()
              }
            }
            .columnsTemplate(this.gridSetting.template)
            .columnsGap(this.gridSetting.colGap)
            .rowsGap(this.gridSetting.rowGap)
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          bottom: 24
        })
        .width('100%')

        Column() {
          if (this.isVIPCourse()) {
              Row() {
                Image($r('app.media.ic_vip'))
                  .width(24)
                  .height(24)
                  .margin({ right: 4 })
                Text('开通会员解锁课程？')
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_L'))
              }
              .padding({ left: 16, right: 16, top: 9, bottom: 9 })
              .margin({ top: 4 })
              .justifyContent(FlexAlign.Center)
              .width(328)
              .height(40)
              .backgroundColor($r('app.color.app_theme'))
              .borderRadius(20)
              .onClick(() => {
                RouterUtils.pushPathByName(RouterMap.VIP_PAGE);
              })
          } else {
            Row() {
              Row() {
                Column() {
                  Image(this.planList.length > 0 ? $r('app.media.ic_plan_on')
                    : $r('app.media.ic_plan_off'))
                    .width(24)
                    .height(24)
                    .margin({ bottom: 2 })
                  Text(this.planList.length > 0 ? '已加计划' : '加计划')
                    .width(54)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(10)
                    .textAlign(TextAlign.Center)
                }
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width(54)
                .height(48)
                .padding({ top: 4, left: 12, right: 12, bottom: 4 })
                .onClick(() => {
                  if(!this.userInfoModel.isLogin){
                    LoginSheetUtils.open()
                  }else{
                    this.isShowAddPlanDialog = true;
                  }
                })
                .bindSheet($$this.isShowAddPlanDialog, this.addPlanDialogBuilder(), {
                  height: '40%',
                  dragBar: false,
                  showClose: true,
                  title: { title: '添加计划' },
                  backgroundColor: '#fff',
                  preferType: SheetType.CENTER,
                  onDisappear: () => {
                    this.isShowAddPlanDialog = false;
                  }
                })

                Column() {
                  Image(this.dateList.includes(String(new Date().getDate())) ? $r('app.media.ic_date_on')
                    : $r('app.media.ic_date_off'))
                    .width(24)
                    .height(24)
                    .margin({ bottom: 2 })
                  Text(this.dateList.includes(String(new Date().getDate())) ? '已加日程' : '加日程')
                    .width(50)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(10)
                    .textAlign(TextAlign.Center)
                }
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width(50)
                .height(48)
                .padding({ top: 4, left: 8, right: 12, bottom: 4 })
                .onClick(() => {
                  if(!this.userInfoModel.isLogin){
                    LoginSheetUtils.open()
                  }else{
                    this.isShowAddDateDialog = true;
                  }
                })
                .bindSheet($$this.isShowAddDateDialog, this.addDateDialogBuilder(), {
                  height: '70%',
                  dragBar: false,
                  showClose: true,
                  preferType: SheetType.CENTER,
                  title: { title: '添加日历' },
                  backgroundColor: '#fff',
                  onDisappear: () => {
                    this.isShowAddDateDialog = false;
                  }
                })
              }
              Row() {
                Text('开始训练')
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_L'))
                  .margin({ right: 4 })
              }
              .justifyContent(FlexAlign.Center)
              .padding({ left: 16, right: 16, top: 9, bottom: 9 })
              .width(this.buttonWidth)
              .height(40)
              .borderRadius(20)
              .backgroundColor($r('app.color.app_theme'))
              .onClick(() => RouterUtils.pushPathByName(RouterMap.COURSE_VIDEO, this.courseId))
            }
            .width('100%')
            .padding({
              left: this.vm.breakPointModel.pagePadding,
              right: this.vm.breakPointModel.pagePadding,
            })
            .justifyContent(FlexAlign.SpaceBetween)
          }
        }
        .width('100%')
        .backgroundColor(Color.White)
        .height(80)
        .padding({ top: 4, bottom: 20 }) // 安全区域处理
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .backgroundColor($r('app.color.course_background'))
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.courseId = context.pathInfo?.param as string
      let index: number = Number(this.courseId) - 1
      this.course = COURSE_DATA1[index]
      this.courseContent = COURSE_CONTENT[index]
      this.label = this.course.courseTitle
      this.aboutToAppear()
    })
  }
}
