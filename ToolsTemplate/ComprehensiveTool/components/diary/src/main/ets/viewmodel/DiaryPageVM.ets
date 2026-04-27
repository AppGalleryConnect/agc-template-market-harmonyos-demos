import { common } from '@kit.AbilityKit';
import { PersistenceV2, window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import dayjs from 'dayjs';
import { PageMode } from '../commons/Enum';
import { DiaryUtil } from '../utils/DiaryUtil';
import { Diary, DiaryExtraInfo } from '../models/Diary';
import { diaryDateFilterBuilder } from '../components/BaseDateFilter';
import { PopViewUtils } from '../utils/PopViewUtils';
import { DateTimePickerResult, MoreFunction } from '../commons/Interface';
import { dateTimePickerBuilder, DateTimePickerBuilderParams } from '../components/DateTimePickerSheet';
import { DiaryDB } from '../database/DiaryDB';
import { ImageUtils } from '../utils/ImageUtils';
import { handleTaskPoolDelete } from '../utils/TaskPoolHandle';
import { Logger } from '../utils/Logger';

@ObservedV2
export class DiaryPageVM {
  diaryUtil: DiaryUtil = DiaryUtil.instance;
  uiContext?: UIContext;
  pathStack: NavPathStack = new NavPathStack();
  listScroller: ListScroller = new ListScroller();
  @Trace diaryList: Diary[] = [];
  @Trace date: string = '';
  @Trace diaryExtraInfo: DiaryExtraInfo = PersistenceV2.connect(DiaryExtraInfo, () => new DiaryExtraInfo())!;

  moreMenuList: MoreFunction[] = [
    {
      name: '隐私日记密码设置',
      onClick: () => {
        this.pathStack.pushPathByName('PrivacyDiaryPassword', '')
      }
    },
    {
      name: '自动保存设置',
      onClick: () => {
        this.pathStack.pushPathByName('AutoSaveSetting', '')
      }
    }
  ]

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.initWindowSize()
  }

  @Computed
  get dateLabel() {
    if (this.date) {
      return dayjs(new Date(this.date)).format('YYYY年MM月');
    }
    return '全部'
  }

  initWindowSize() {
    // 获取屏幕宽高
    let context = this.uiContext!.getHostContext() as common.UIAbilityContext;
    let windowClass: window.Window = context.windowStage.getMainWindowSync();
    let size = windowClass.getWindowProperties().windowRect;
    AppStorage.setOrCreate('screenHeight', this.uiContext!.px2vp(size.height));
    AppStorage.setOrCreate('screenWidth', this.uiContext!.px2vp(size.width));
  }

  async initData() {
    const context = this.uiContext!.getHostContext() as Context
    await DiaryDB.initDB(context);
    let resList = await DiaryDB.queryDiaryList(this.date);
    let tempList: Diary[] = [];
    if (resList.length > 0) {
      for (const item of resList) {
        let data = new Diary(item);
        tempList.push(data)
      }
    }
    this.diaryList = tempList;
  }

  pageDestroy() {
    try {
      emitter.off('refreshDiaryListEvent');
    } catch (e) {
      Logger.error('[DiaryPage]', `emitter off refreshDiaryListEvent failed. error: ${JSON.stringify(e)}`)
    }
  }

  // 点击卡片事件
  clickItemCard(item: Diary) {
    // 查看隐私日记需要输入密码
    if (item.isPrivacy) {
      this.diaryUtil.openPrivacyPwdInputDialog(() => {
        this.pushToDiaryDetailPage(item)
      })
    } else {
      this.pushToDiaryDetailPage(item)
    }
  }

  // 跳转到详情页
  pushToDiaryDetailPage(item: Diary) {
    const params: Record<string, Object> = {
      'diaryId': item.id,
      'pageMode': PageMode.VIEW,
    };
    this.pathStack.pushPathByName('DiaryEditorPage', params);
  }

  openDiaryFilterSheet() {
    let builderParams: DateTimePickerBuilderParams = {
      date: this.date,
      title: '筛选',
      contentBuilder: wrapBuilder(diaryDateFilterBuilder),
      confirm: (value: DateTimePickerResult) => {
        this.date = value as string;
        this.initData();
        PopViewUtils.closeSheet()
      },
      cancel: () => {
        PopViewUtils.closeSheet()
      }
    }
    PopViewUtils.showSheet(wrapBuilder(dateTimePickerBuilder), {
      height: 450,
      preferType: SheetType.BOTTOM,
      showClose: false,
    }, builderParams);
  }

  // createDiary
  createDiary() {
    const params: Record<string, Object> = {
      'diaryId': '',
      'pageMode': PageMode.CREATE,
    };
    this.pathStack.pushPathByName('DiaryEditorPage', params);
  }

  // 处理隐私日记
  handlePrivacyDiary(diary: Diary) {
    let pwd = this.diaryExtraInfo.password;
    if (!pwd) {
      this.diaryUtil.openPrivacyPasswordDialog(async (password: string) => {
        this.diaryExtraInfo.password = password;
        diary.isPrivacy = true;
        await DiaryDB.updateDiary(diary);
        this.listScroller.closeAllSwipeActions();
      })
      return;
    }

    this.diaryUtil.openPrivacyPwdInputDialog(async () => {
      diary.isPrivacy = !diary.isPrivacy;
      await DiaryDB.updateDiary(diary);
      this.listScroller.closeAllSwipeActions();
    })
  }

  // 删除日记操作
  deleteDiary(diary: Diary) {
    if (diary.isPrivacy) {
      this.diaryUtil.openDeleteDiaryDialog(this.uiContext, () => {
        this.diaryUtil.openPrivacyPwdInputDialog(async () => {
          await DiaryDB.deleteDiary(diary.id)
          this.initData();
          this.handleRemoveSandboxImg(diary);
        })
      })
    } else {
      this.diaryUtil.openDeleteDiaryDialog(this.uiContext, async () => {
        await DiaryDB.deleteDiary(diary.id)
        this.initData();
        this.handleRemoveSandboxImg(diary);
      })
    }
  }

  // 同步删除沙箱的图片
  handleRemoveSandboxImg(diary: Diary) {
    let imgSrcList = ImageUtils.findImgSrcList(diary.htmlContent);
    handleTaskPoolDelete(imgSrcList)
  }
}