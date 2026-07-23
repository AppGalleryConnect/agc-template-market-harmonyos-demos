import { ExamService, ROUTE_PARAM, EXAM_MANAGER_TYPE, WRONG_COLLECT } from '@ohos_agcit/driver_license_exam_datasource';
import { Exam, ExamController, ExamManager, showSettingSheet } from 'exam';
import { CommonConstants, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';


@Builder
export function PracticeViewBuilder() {
  PracticeView();
}

@ComponentV2
export struct PracticeView {
  vm: CommonModel = CommonModel.instance;
  private examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  private examController: ExamController = ExamController.instance;
  @Local title: string | Resource = '顺序练习';
  @Local type: EXAM_MANAGER_TYPE = EXAM_MANAGER_TYPE.sequence;
  @Local currentQuestionId: string = '';
  @Local examManager: ExamManager = new ExamManager(this.title, []);
  @Local wrongOrCollect?: WRONG_COLLECT;
  @Local keyword?: string = '';
  // 点击设置是否展示设置视图
  @Local isShowSetting: boolean = false;

  getExamManger() {
    this.examManager = this.examService.getManagerByName(this.title, this.type, 0, this.keyword, this.wrongOrCollect);
  }

  build() {
    NavDestination() {
      Column() {
        Exam({
          appPathStack: this.vm.navStack,
          examManager: this.examManager,
          mockExamCall: (score: number) => {
            this.examService.addMockExamCount(score);
            this.examService.syncMockExamToGlobal(this.examManager);
          },
          syncExamData: () => {
            if (this.type === EXAM_MANAGER_TYPE.mock_exam) {
              this.examService.syncMockExamToGlobal(this.examManager);
            }
          },
        });
      }
      .width('100%')
      .height('100%')
    }
    .title(this.navTitle)
    .menus(this.toolBar())
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: this.getUIContext().px2vp(AppStorage.get('topRectHeight') || 0),
    })
    .onReady((ctx: NavDestinationContext) => {
      const index = this.vm.navStack.size();
      const param: ROUTE_PARAM = this.vm.navStack.getParamByIndex(index - 1) as ROUTE_PARAM;
      this.title = param.title;
      this.type = param.type;
      if (param.examManager) {
        this.examManager = param.examManager;
        return;
      }
      if (param.questionId) {
        this.currentQuestionId = param.questionId;
      }
      if (param.wrongOrCollect !== undefined) {
        this.wrongOrCollect = param.wrongOrCollect;
      }
      if (param.keyword) {
        this.keyword = param.keyword;
      }
      this.getExamManger();
    })
    .onBackPressed(() => {
      if (this.type === EXAM_MANAGER_TYPE.mock_exam) {
        // 打开模拟考试结束弹窗
        this.examController.isShowMockExamDialog = true;
        return true;
      }
      this.vm.navStack.pop();
      return true;
    })
  }

  @Builder
  navTitle() {
    Text(this.title)
      .fontColor($r('sys.color.font_primary'))
      .fontSize(this.getUIContext().px2fp(64))
      .fontWeight(FontWeight.Bold)
      .height(CommonConstants.FULL_HEIGHT)
      .margin({
        left: 10,
      })
  }

  @Builder
  toolBar() {
    Row() {
      Image($r('app.media.setting'))
        .width(40)
        .height(40);
    }
    .width(50)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .margin({
      top: 10,
      right: '4%',
    })
    .onClick(() => {
      this.isShowSetting = !this.isShowSetting;
    })
    .bindSheet($$this.isShowSetting, showSettingSheet(), {
      height: 200,
      width: this.vm.isLargeDevice ? '61%' : '100%',
      title: { title: '设置' },
      backgroundColor: $r('sys.color.comp_background_primary'),
    });
  }
}
