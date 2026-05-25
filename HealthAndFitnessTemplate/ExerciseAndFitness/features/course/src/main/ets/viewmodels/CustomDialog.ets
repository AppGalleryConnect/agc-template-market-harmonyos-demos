import { CalendarItem, CalendarUtils } from './Calendar';
import { VIDEO_URL } from 'lib_common'

@CustomDialog
export struct addDialog {
  controller?: CustomDialogController;

  build() {
    Column() {
      Text('添加日历成功！')
        .fontSize(20)
        .height(56)
        .width(244)
        .textAlign(TextAlign.Center)
      Image($r('app.media.ic_date_success'))
        .width(244)
        .height(192)
        .margin({ bottom: 20 })
      Text('好的，我知道了')
        .width(216)
        .height(40)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .borderRadius(24)
        .backgroundColor($r('app.color.app_theme'))
        .padding({ top: 8, bottom: 8, left: 24, right: 24 })
        .onClick(() => {
          if (this.controller !== undefined) {
            this.controller.close();
          }
        })
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 42, right: 42, bottom: 24 })
    .borderRadius(32)
    .width(328)
    .height(332)
  }
}

@CustomDialog
export struct addPlanDialog {
  controller?: CustomDialogController;

  build() {
    Column() {
      Text('添加计划成功！')
        .fontSize(20)
        .height(56)
        .width(244)
        .textAlign(TextAlign.Center)
      Image($r('app.media.icon_plan_on'))
        .width(244)
        .height(192)
        .margin({ bottom: 20 })
      Text('好的，我知道了')
        .width(216)
        .height(40)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .borderRadius(24)
        .backgroundColor($r('app.color.app_theme'))
        .padding({ top: 8, bottom: 8, left: 24, right: 24 })
        .onClick(() => {
          if (this.controller !== undefined) {
            this.controller.close();
          }
        })
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 42, right: 42, bottom: 24 })
    .borderRadius(32)
    .width(328)
    .height(332)
  }
}

@CustomDialog
export struct cancelDialog {
  controller?: CustomDialogController;

  build() {
    Column() {
      Text('是否取消计划？')
        .fontSize(20)
        .height(56)
        .width(244)
        .textAlign(TextAlign.Center)
      Image($r('app.media.icon_plan_off'))
        .width(244)
        .height(192)
        .margin({ bottom: 20 })
      Row({ space: 16 }) {
        Button('确认取消')
          .width(140)
          .height(40)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close();
            }
          })

        Button('我再想想')
          .width(140)
          .height(40)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close();
            }
          })
      }
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 16, right: 16, bottom: 24 })
    .borderRadius(32)
    .width(328)
    .height(332)
  }
}

@ComponentV2
export struct CustomButton {
  @Local isOn: boolean = false  // 独立状态存储
  @Param label: string = ''    // 按钮文本
  @Param isCurrent: boolean = false
  @Param dateList: string[] = [];
  @Param private themeColor: Resource = $r('app.color.app_theme')  // 主题色
  @Param private darkColor: string = 'rgba(0, 0, 0, 0.4)'
  @Param private foreColor: string = 'rgba(0, 0, 0, 0.9)'

  build() {
    if (this.isCurrent) {
      Text(this.label)
        .fontSize($r('sys.float.Body_M'))
        .height(40)
        .width(40)
        .borderRadius(12)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isOn ? Color.White : this.foreColor)
        .backgroundColor(this.isOn ? this.themeColor : Color.White)
        .onClick(() => {
          this.isOn = !this.isOn  // 状态自动切换
          this.dateList.push(this.label);
        })
    } else{
      Text(this.label)
        .fontSize($r('sys.float.Body_M'))
        .height(40)
        .width(40)
        .borderRadius(12)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.darkColor)
        .backgroundColor(Color.White)
    }
  }
}

@ComponentV2
export struct explain {
  @Param title: string = '';
  @Param isVideo: boolean = false;
  @Local isPaused: boolean = true;
  @Local durationTime: string = '';
  controller: VideoController = new VideoController();

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
          .margin({ right: 8 })
        Text('10分钟')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
      }
      .width('100%')
      .height(24)
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.Start)

      if (this.isVideo) {
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Video({
              src: VIDEO_URL,
              controller: this.controller,
              posterOptions: {
                showFirstFrame: true  // 首帧送显
              }
            })
              .controls(false)  // 隐藏状态栏
              .loop(true)
              .onPrepared((e) => {
                this.durationTime = this.formatTime(e.duration); // 格式化为"00:00"
              })

            Image($r('app.media.ic_paused'))
              .visibility(this.isPaused ? Visibility.Visible : Visibility.None)
              .width(48)
              .height(48)

            RelativeContainer() {
              Text(this.durationTime)
                .width(34)
                .fontSize(10)
                .fontColor($r('sys.color.font_on_primary'))
                .padding(4)
                .borderRadius(4)
                .backgroundColor('rgba(0, 0, 0, 0.4)')
                .offset({ bottom: 8, right: 12 })
                .alignRules({
                  bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                  right: { anchor: '__container__', align: HorizontalAlign.End },
                })
            }
          }
          .width('100%')
          .onClick(() => {
            this.isPaused = !this.isPaused;
            if (this.isPaused) {
              this.controller.pause();
            } else {
              this.controller.start();
            }
          })
        }
        .borderRadius(16)
        .width('100%')
        .height(184)
        .clip(true)
      } else {
        Scroll() {
          Row({ space: 12 }) {
            Image($r('app.media.explain1'))
              .width(90)
              .height(184)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
            Image($r('app.media.explain2'))
              .width(90)
              .height(184)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
            Image($r('app.media.explain3'))
              .width(90)
              .height(184)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
            Image($r('app.media.explain4'))
              .width(90)
              .height(184)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
          }
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')  // 设置滚动区域宽度
      }

      Column() {
        Text('动作讲解')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
      }
      .width('100%')
      .height(24)
      .margin({ top: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('·保持头部中立位，目视前方，避免低头或仰头造成颈椎压力。')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)

        Text('·收紧核心肌群，肩胛骨微收，手臂自然屈曲90°前后摆动，减少躯干晃动。')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)

        Text('·全脚掌滚动式着地（脚跟→前掌），步频建议保持180步/分钟以减少关节冲击。')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('训练要点')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
      }
      .height(24)
      .width('100%')
      .margin({ top: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('·在使用跑步机前，充分活动关节，如踝关节、膝关节、髋关节等，拉伸腿部、腰部肌肉，高抬腿过程中避免激烈跳动，以热身为主，能减少运动损伤。')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('常见错误')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
      }
      .height(24)
      .width('100%')
      .margin({ top: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('·心率上升速度太快导致呼吸紊乱；')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)
        Text('·落地脚踝不稳导致受伤风险提高；')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)
        Text('·开合跳没有收紧腹部导致肠胃不适；')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)
        Text('·快跑阶段没有控制时速。')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .margin({ top: 50 })
    .padding({ left: 16, right: 16 })
    .width('100%')
  }

  private formatTime(total: number): string {
    const minutes = Math.floor(total / 60).toString().padStart(2, '0');
    const seconds = Math.floor(total % 60).toString().padStart(2, '0');
    return `${minutes}:${seconds}`;
  }
}

@Builder
export function explainVIP(title: string) {
  Column() {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ right: 8 })
      Text('10分钟')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
    }
    .height(24)
    .width('100%')
    .margin({ bottom: 12 })
    .justifyContent(FlexAlign.Start)

    Scroll() {
      Row({ space: 12 }) {
        Image($r('app.media.explain1'))
          .width(90)
          .height(184)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        Image($r('app.media.explain2'))
          .width(90)
          .height(184)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        Image($r('app.media.explain3'))
          .width(90)
          .height(184)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
        Image($r('app.media.explain4'))
          .width(90)
          .height(184)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')  // 设置滚动区域宽度

    Column() {
      Text('动作讲解')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .height(24)
    .margin({ top: 12, bottom: 12 })

    Column() {
      Text('·保持头部中立位，目视前方，避免低头或仰头造成颈椎压力。')
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
        .fontWeight(FontWeight.Medium)

      Text('·收紧核心肌群，肩胛骨微收，手臂自然屈曲90°前后摆动，减少躯干晃动。')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')

      Text('·全脚掌滚动式着地（脚跟→前掌），步频建议保持180步/分钟以减少关节冲击。')
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
        .fontWeight(FontWeight.Medium)
    }
    .height(114)
    .width('100%')
    .justifyContent(FlexAlign.Start)

    Column() {
      Text('训练要点')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
    }
    .height(24)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 12, bottom: 12 })

    Column() {
      Text('·在使用跑步机前，充分活动关节，如踝关节、膝关节、髋关节等，拉伸腿部、腰部肌肉，高抬腿过程中避免激烈跳动，以热身为主，能减少运动损伤。')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
    }
    .width('100%')
    .height(57)
    .justifyContent(FlexAlign.Start)

    Column() {
      Text('常见错误')
        .fontWeight(FontWeight.Medium)
        .fontSize(18)
    }
    .width('100%')
    .height(24)
    .margin({ top: 12, bottom: 12 })
    .alignItems(HorizontalAlign.Start)

    Column() {
      Text('·心率上升速度太快导致呼吸紊乱；')
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
        .fontWeight(FontWeight.Medium)
      Text('·落地脚踝不稳导致受伤风险提高；')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
      Text('·开合跳没有收紧腹部导致肠胃不适；')
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
        .fontWeight(FontWeight.Medium)
      Text('·快跑阶段没有控制时速。')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor('rgba(0, 0, 0, 0.6)')
    }
    .width('100%')
    .height(76)
    .alignItems(HorizontalAlign.Start)
  }
  .width('100%')
  .margin({ top: 50 })
  .padding({ left: 16, right: 16 })
  .blur(10)
}

@ComponentV2
export struct CustomFilterButton {
  @Param label: string = ''    // 按钮文本
  @Param filter: String[] = []
  @Local isOn: boolean = this.filter.includes(this.label)  // 独立状态存储
  @Param private backColor: Resource = $r('sys.color.comp_background_tertiary')
  @Param private foreColor: string = 'rgba(0, 0, 0, 0.9)'
  @Param private themeColor: Resource = $r('app.color.app_theme')  // 主题色

  build() {
    Button(this.label)
      .width(80)
      .height(28)
      .margin({ right: 4, bottom: 12 })
      .borderRadius(14)
      .fontSize($r('sys.float.Body_S'))
      .fontColor(this.isOn ? Color.White : this.foreColor)
      .backgroundColor(this.isOn ? this.themeColor : this.backColor)
      .onClick(() => {
        this.isOn = !this.isOn  // 状态自动切换
        if (this.filter.includes(this.label)) {
          const index = this.filter.findIndex(item => item === this.label);
          this.filter.splice(index, 1);
        } else {
          this.filter.push(this.label);
        }
      })
  }
}

@ComponentV2
export struct CourseFilterDialog {
  @Param filter: String[] = []
  targetList: string[] = ['增肌塑形', '减重瘦身', '强化心肺', '保持健康', '力量训练', '马甲线', '增加柔韧', '随便练练']
  bodyPartsList: string[] = ['手臂', '大腿', '腹部', '臀部', '胸肌', '背部', '肩部', '随便练练']
  difficultLevel: string[] = ['零基础', '初级', '中级', '高级']
  sportTypeList: string[] = ['燃脂', '普拉提', '瑜伽', '力量训练']
  courseType: string[] = ['免费', '会员']
  durationList: string[] = ['30以下', '31-50', '51-100', '100以上']
  build() {
    Column() {
      Column() {
        Text('目标')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .height(45)
          .padding({
            top: 16,
            bottom: 8,
          })

        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.targetList, (item: string) => {
              CustomFilterButton({label: item, filter: this.filter})
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column() {
        Text('身体部位')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .height(45)
          .padding({
            top: 16,
            bottom: 8,
          })

        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.bodyPartsList, (item: string) => {
              CustomFilterButton({label: item, filter: this.filter})
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column() {
        Text('难度')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .height(45)
          .padding({
            top: 16,
            bottom: 8,
          })

        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.difficultLevel, (item: string) => {
              CustomFilterButton({label: item, filter: this.filter})
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column() {
        Text('种类')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .height(45)
          .padding({
            top: 16,
            bottom: 8,
          })

        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.sportTypeList, (item: string) => {
              CustomFilterButton({label: item, filter: this.filter})
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column() {
        Text('课程性质')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .height(45)
          .padding({
            top: 16,
            bottom: 8,
          })

        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.courseType, (item: string) => {
              CustomFilterButton({label: item, filter: this.filter})
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Column() {
        Text('课程时长（分钟）')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .height(45)
          .padding({
            top: 16,
            bottom: 8,
          })

        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.durationList, (item: string) => {
              CustomFilterButton({label: item, filter: this.filter})
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
  }
}


@ComponentV2
export struct PlanDialog {
  private weekNameList: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  private month: number = new Date().getMonth();
  private year: number = new Date().getFullYear();
  @Local dateList: Date[] = [];
  @Local today: number = new Date().getDate()
  @Param planList: number[] = [];
  @Param clickedStates: boolean[] = [false, false, false, false, false, false, false];
  @Param courseId: string = '';

  buildDateList(): Date[] {
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

  isPassedDay(selectDay: Date): boolean{
    let today: Date = new Date()
    if(selectDay.getMonth() < today.getMonth() || selectDay.getDate() < today.getDate()){
      return true
    }
    return false
  }

  aboutToAppear(): void {
    this.dateList = this.buildDateList();
  }

  build() {
    Column() {
      Column() {
        Text((this.year + '年 ') + (this.month + 1 + '月'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .width('90%')
          .height(21)
          .margin({ left: 12, bottom: 12 })
          .textAlign(TextAlign.Start)

        Row({ space: 8 }) {
          ForEach([0, 1, 2, 3, 4], (index: number) => {
            Column() {
              Text(this.weekNameList[this.dateList[index].getDay()])
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'))
                .fontColor(
                  this.isPassedDay(this.dateList[index])
                    ? 'rgba(0,0,0,0.4)'
                    : this.clickedStates[index] ? Color.White : 'rgba(0,0,0,0.9)'
                )
                .margin({ top: 4, bottom: 2 })

              Text(
                (this.dateList[index].getMonth() + 1 < 10
                  ? '0' + (this.dateList[index].getMonth() + 1)
                  : this.dateList[index].getMonth() + 1 + '') + '.' +
                  (this.dateList[index].getDate() < 10
                    ? '0' + this.dateList[index].getDate()
                    : this.dateList[index].getDate() + '')
              )
                .fontColor(
                  this.isPassedDay(this.dateList[index])
                    ? 'rgba(0,0,0,0.4)'
                    : this.clickedStates[index] ? Color.White : 'rgba(0,0,0,0.9)'
                )
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_S'))
            }
            .width('18%')
            .height(47)
            .borderRadius(8)
            .backgroundColor(
              this.isPassedDay(this.dateList[index])
                ? Color.White
                : this.clickedStates[index] ? $r('app.color.app_theme') : Color.White
            )
            .onClick(() => {
              if (!this.isPassedDay(this.dateList[index])) {
                this.clickedStates[index] = !this.clickedStates[index]
                const dateValue = this.dateList[index].getDate()
                const planIndex = this.planList.findIndex(item => item === dateValue)
                if (this.clickedStates[index]) {  // true: 添加
                  if (!this.planList.includes(dateValue)) {
                    this.planList.push(dateValue);
                  }
                } else {  // false: 删除
                  if (planIndex !== -1) {
                    this.planList.splice(planIndex, 1);
                  }
                }
              }
            })
          })
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 12 })

        Row({ space: 8 }) {
          ForEach([5, 6], (index: number) => {
            Column() {
              Text(this.weekNameList[this.dateList[index].getDay()])
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'))
                .fontColor(
                  this.isPassedDay(this.dateList[index])
                    ? 'rgba(0,0,0,0.4)'
                    : this.clickedStates[index] ? Color.White : 'rgba(0,0,0,0.9)'
                )
                .margin({ top: 4, bottom: 2 })

              Text(
                (this.dateList[index].getMonth() + 1 < 10
                  ? '0' + (this.dateList[index].getMonth() + 1)
                  : this.dateList[index].getMonth() + 1 + '') + '.' +
                  (this.dateList[index].getDate() < 10
                    ? '0' + this.dateList[index].getDate()
                    : this.dateList[index].getDate() + '')
              )
                .fontColor(
                  this.isPassedDay(this.dateList[index])
                    ? 'rgba(0,0,0,0.4)'
                    : this.clickedStates[index] ? Color.White : 'rgba(0,0,0,0.9)'
                )
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_S'))
            }
            .width('18%')
            .height(47)
            .borderRadius(8)
            .backgroundColor(
              this.isPassedDay(this.dateList[index])
                ? Color.White
                : this.clickedStates[index] ? $r('app.color.app_theme') : Color.White
            )
            .onClick(() => {
              if (!this.isPassedDay(this.dateList[index])) {
                this.clickedStates[index] = !this.clickedStates[index]
                const dateValue = this.dateList[index].getDate()
                const planIndex = this.planList.findIndex(item => item === dateValue)
                if (this.clickedStates[index]) {  // true: 添加
                  if (!this.planList.includes(dateValue)) {
                    this.planList.push(dateValue);
                  }
                } else {  // false: 删除
                  if (planIndex !== -1) {
                    this.planList.splice(planIndex, 1);
                  }
                }
              }
            })
          })
        }
        .justifyContent(FlexAlign.Center)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor(Color.White)
    .padding({ top: 8, right: 16 })
    .width('100%')
    .height(139)
  }
}

@ComponentV2
export struct DateDialog {
  @Param dateList: string[] = [];
  @Local currentCalendar: CalendarItem[] = [];
  @Local weekHeaders: string[] = [];
  @Local groupedWeeks: CalendarItem[][] = [];

  loadCalendar() {
    this.currentCalendar = CalendarUtils.getCurrentMonthCalendar();
    this.groupedWeeks = CalendarUtils.groupByWeek(this.currentCalendar);
    this.weekHeaders = CalendarUtils.getWeekHeaders();
  }

  async aboutToAppear() {
    this.loadCalendar()
  }

  build() {
    Column() {
      Row() {
        Text((new Date().getFullYear() + '年 ') + (new Date().getMonth() + 1 + '月'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .width('100%')
      .height(36)
      .justifyContent(FlexAlign.Start)

      Column() {
        Row({ space: 14 }) {
          ForEach(CalendarUtils.getWeekHeaders(), (header: string) => {
            Text(header)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Body_M'))
              .width(42)
              .height(18)
          })
        }
        .width('95%')
        .height(19)
        .margin({ top: 4, bottom: 3 })
        .justifyContent(FlexAlign.SpaceBetween)

        Column({ space: 2 }) {
          // 日历内容
          Column({ space: 2 }) {
            ForEach(this.groupedWeeks, (week: CalendarItem[], weekIndex: number) => {
              Row({ space: 2 }) {
                ForEach(week, (day: CalendarItem, dayIndex: number) => {
                  if (day.isPastDate) {
                    CustomButton({ label: String(day.day) })
                  } else {
                    if (day.isCurrentMonth) {
                      CustomButton({ label: String(day.day), isCurrent: true, dateList: this.dateList })
                    } else {
                      CustomButton({ label: String(day.day) })
                    }
                  }
                })
              }
              .height(42)
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            })
          }
          .width('100%')
          .padding(10)
        }
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('rgb(255, 255, 255, 0.4)')
        .borderRadius(12)
        .width('100%')
        .height(334)
      }
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgb(255, 255, 255, 0.4)')
    .borderRadius(12)
    .width('100%')
    .padding({ left: 24 })
    .height(334)
  }
}