import { PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import dayjs from 'dayjs';
import { TEXT_PICKER_DATA } from '../commons/Constant';
import { Diary, DiaryExtraInfo } from '../models/Diary';
import { DiaryUtil } from '../utils/DiaryUtil';
import { PopViewUtils } from '../utils/PopViewUtils';
import { PageMode, TEXT_PICKER_LABEL } from '../commons/Enum';
import { textPickerBuilder, TextPickerBuilderParams } from '../components/CommonTextPicker';
import { dateTimePickerBuilderParams, DateTimePickerResult, IconTextItem, MoreFunction } from '../commons/Interface';
import { dateTimePickerBuilder, DateTimePickerBuilderParams } from '../components/DateTimePickerSheet';
import { DateUtil } from '../utils/DateUtil';
import { baseTimePickerBuilder } from '../components/BaseTimePicker';
import { baseDatePickerBuilder } from '../components/BaseDatePicker';
import { DiaryDB } from '../database/DiaryDB';
import { ImageUtils } from '../utils/ImageUtils';
import { handleTaskPoolDelete } from '../utils/TaskPoolHandle';
import { EditorController } from '../controller/EditorController';
import { SnapShotWebController } from '../controller/SnapShotWebController';
import { WindowUtil } from '../utils/WindowUtil';
import { Logger } from '../utils/Logger';


@ObservedV2
export class DiaryEditorPageVM {
  diaryUtil: DiaryUtil = DiaryUtil.instance;
  editorController: EditorController = new EditorController();
  snapShotWebController: SnapShotWebController = new SnapShotWebController(this.editorController.webviewController);
  @Trace diaryExtraInfo: DiaryExtraInfo = PersistenceV2.connect(DiaryExtraInfo, () => new DiaryExtraInfo())!;

  @Trace currentDiary: Diary = new Diary();
  @Trace isEdit: boolean = false;
  @Trace date: string = dayjs().format();
  @Trace dateTime: string = dayjs().format('HH:mm');
  @Trace pageMode: PageMode = PageMode.CREATE
  @Trace timer: number | null = null;
  @Trace weatherText: string = '';
  @Trace weatherIcon: string = 'sys.symbol.cloud_and_sun_filled';
  @Trace moodText: string = '';
  @Trace moodIcon: string = 'sys.symbol.face_smiling';
  @Trace createDiaryId: number = -1;
  @Trace moreMenuList: MoreFunction[] = [
    {
      name: '设为私密',
      onClick: () => {
        this.handleDiaryPrivacy()
      }
    },
    {
      name: '编辑',
      onClick: () => {
        this.pushToEditPage()
      }
    },
  ]

  uiContext?: UIContext;
  pathStack: NavPathStack = new NavPathStack();

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  @Computed
  get dateLabel() {
    return dayjs(this.date).format('YYYY年MM月DD日');
  }

  async initData(params: Record<string, Object>) {
    this.pageMode = params.pageMode as PageMode;
    let id = params.diaryId as string;
    if (id) {
      await this.getDiary(id)
    }
    // 处理天气和心情
    this.handleMoodAndWeather()
    // 设置自动保存
    this.setAutoSaveDiary();
    this.moreMenuList[0].name = this.currentDiary.isPrivacy ? '取消私密' : '设为私密';
  }

  async getDiary(id: string) {
    let data = await DiaryDB.queryDiaryById(id);
    if (data) {
      let diary = new Diary(data);
      this.currentDiary = diary;
      this.editorController.richTextContent = data.htmlContent;
    }
  }

  handleMoodAndWeather() {
    this.weatherText = this.currentDiary.weatherText;
    this.weatherIcon = this.currentDiary.weatherIcon;
    this.moodText = this.currentDiary.moodText;
    this.moodIcon = this.currentDiary.moodIcon;
  }

  setAutoSaveDiary() {
    let showAutoSaveTip: boolean = this.diaryExtraInfo.showAutoSaveTip;
    let time: number = this.diaryExtraInfo.autoSaveTime;
    // 编辑页，且开启自动保存
    if (this.pageMode !== PageMode.VIEW) {
      this.timer = setTimeout(async () => {
        if (this.checkSaveDiary()) {
          // 处理日记数据
          this.handleSaveDiary();
          if (this.pageMode === PageMode.EDIT) {
            await DiaryDB.updateDiary(this.currentDiary);
          } else {
            // 新建日记，首次自动保存时，插入一条数据。再次保存时会更新
            if (this.createDiaryId === -1) {
              this.createDiaryId = await DiaryDB.insertDiary(this.currentDiary);
            } else {
              this.currentDiary.id = this.createDiaryId.toString();
              await DiaryDB.updateDiary(this.currentDiary);
            }
          }
          if (showAutoSaveTip) {
            this.showToast('已自动保存');
          }
        }
        this.setAutoSaveDiary();
      }, time * 1000)
    }
  }

  stopAutoSave() {
    if (this.timer !== null) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    this.editorController.isSave = false;
  }

  // 跳转到编辑页
  pushToEditPage() {
    const params: Record<string, Object> = {
      'diaryId': this.currentDiary.id,
      'pageMode': PageMode.EDIT,
    };
    this.pathStack.pushPathByName('DiaryEditorPage', params, async () => {
      // 从编辑页返回详情页，刷新页面
      await this.getDiary(this.currentDiary.id);
      this.editorController.webviewController.refresh();
    });
  }

  // 返回事件
  onBack() {
    // 按返回键弹出弹窗
    this.showConfirmDialog()
    return true;
  }

  // 页面销毁事件
  handleDisappear() {
  }

  showConfirmDialog() {
    this.uiContext?.getPromptAction().showDialog({
      title: '退出编辑',
      message: '确认要退出日记编写并丢弃当前内容吗？',
      alignment: 	DialogAlignment.Center,
      buttons: [
        {
          text: '取消',
          color: $r('sys.color.icon_emphasize')
        },
        {
          text: '确定',
          color: $r('sys.color.icon_emphasize')
        }
      ]
    }, (err, data) => {
      if (err) {
        return;
      }
      if (data.index === 1) {
        if (this.pageMode === PageMode.EDIT) {
          this.pathStack.pop(this.pageMode);
        } else {
          this.pathStack.pop();
        }
        this.stopAutoSave()
      }
    });
  }

  // 处理隐私开关
  handleDiaryPrivacy() {
    let pwd = this.diaryExtraInfo.password;
    let isOn = !this.currentDiary.isPrivacy;
    // 打开开关
    if (isOn) {
      // 已经设置隐私密码
      if (pwd) {
        // 需要输入隐私密码
        this.diaryUtil.openPrivacyPwdInputDialog(async () => {
          this.currentDiary.isPrivacy = isOn;
          await DiaryDB.updateDiary(this.currentDiary);
          this.moreMenuList[0].name = isOn ? '取消私密' : '设为私密';
        })
      } else {
        // 需要设置隐私密码
        this.diaryUtil.openPrivacyPasswordDialog(async (password: string) => {
          this.currentDiary.isPrivacy = isOn;
          this.diaryExtraInfo.password = password;
          await DiaryDB.updateDiary(this.currentDiary);
          this.moreMenuList[0].name = '取消私密';
        })
      }
    } else {
      // 需要输入隐私密码
      this.diaryUtil.openPrivacyPwdInputDialog(async () => {
        this.currentDiary.isPrivacy = isOn;
        await DiaryDB.updateDiary(this.currentDiary);
        this.moreMenuList[0].name = isOn ? '取消私密' : '设为私密';
      })
    }
  }

  // 日期选择
  handleDatePicker() {
    this.openDateTimePickerSheet(this.date, '选择日期', wrapBuilder(baseDatePickerBuilder),
      (value: DateTimePickerResult) => {
        this.date = value as string;
      }
    )
  }

  // 时间选择
  handleTimePicker() {
    let dateTime = dayjs(this.date).format('YYYY-MM-DD') + 'T' + this.dateTime;
    this.openDateTimePickerSheet(dateTime, '选择时间', wrapBuilder(baseTimePickerBuilder),
      (value: DateTimePickerResult) => {
        if (value) {
          let time = value as TimePickerResult
          if (time.hour >= 0) {
            this.dateTime = DateUtil.dateTimeFormat(time)
          }
        }
      }
    )
  }

  // 日期、时间选择弹框
  openDateTimePickerSheet(
    date: string,
    title: string,
    contentBuilder: WrappedBuilder<[dateTimePickerBuilderParams]>,
    callback: (value: DateTimePickerResult) => void
  ) {
    let builderParams: DateTimePickerBuilderParams = {
      date: date,
      title: title,
      contentBuilder: contentBuilder,
      confirm: (value: DateTimePickerResult) => {
        callback?.(value)
        PopViewUtils.closeSheet()
      },
      cancel: () => {
        PopViewUtils.closeSheet()
      }
    }
    PopViewUtils.showSheet(wrapBuilder(dateTimePickerBuilder), {
      height: 400,
      preferType: SheetType.BOTTOM,
      showClose: false,
    }, builderParams);
  }

  // 天气、心情选择弹框
  openTextPickerSheet(type: string) {
    let textList: IconTextItem[] = TEXT_PICKER_DATA[type];
    let builderParams: TextPickerBuilderParams = {
      textList: textList,
      type: type,
      confirm: (data: IconTextItem) => {
        if (type === 'weather'){
          this.weatherText = data.text;
          this.weatherIcon = data.icon;
        } else if (type === 'mood') {
          this.moodText = data.text;
          this.moodIcon = data.icon;
        }
        PopViewUtils.closeSheet()
      },
    }
    PopViewUtils.showSheet(wrapBuilder(textPickerBuilder), {
      height: 360,
      preferType: SheetType.BOTTOM,
      title: { title: TEXT_PICKER_LABEL[type] },
    }, builderParams);
  }

  // 保存日记
 async save() {
    if (!this.checkSaveDiary()) {
      return
    }
    // 处理日记数据
    this.handleSaveDiary();

    // 保存到本地数据库
   if (this.pageMode === PageMode.EDIT) {
     await DiaryDB.updateDiary(this.currentDiary);
   } else {
     // 新建日记，如果已经自动保存过，在点击保存按钮时，更新数据
     if (this.createDiaryId === -1) {
       this.createDiaryId = await DiaryDB.insertDiary(this.currentDiary);
     } else {
       this.currentDiary.id = this.createDiaryId.toString();
       await DiaryDB.updateDiary(this.currentDiary);
     }
   }

   // 通知列表刷新
   try {
     emitter.emit('refreshDiaryListEvent');
   } catch (e) {
     Logger.error('[DiaryPage]', `emit refreshDiaryListEvent failed. error: ${JSON.stringify(e)}`)
   }

    this.stopAutoSave();
    if (this.pageMode === PageMode.EDIT) {
      this.pathStack.pop(this.pageMode);
    } else {
      this.pathStack.pop();
    }
  }

  checkSaveDiary(): boolean {
    const htmlContent = this.editorController.richTextContent;
    return htmlContent.length > 0;
  }

  handleSaveDiary() {
    const htmlContent = this.editorController.richTextContent;
    let dateTimeStr = dayjs(this.date).format('YYYY-MM-DD') + 'T' + this.dateTime;
    let timeStr = new Date(dateTimeStr).getTime().toString();
    this.currentDiary.textContent = this.editorController.parseHtmlContent(htmlContent)
    this.currentDiary.weatherText = this.weatherText;
    this.currentDiary.weatherIcon = this.weatherIcon;
    this.currentDiary.moodText = this.moodText;
    this.currentDiary.moodIcon = this.moodIcon;
    if (this.pageMode === PageMode.CREATE) {
      this.currentDiary.createTime = timeStr;
    }
    this.currentDiary.updateTime = timeStr;
    this.editorController.isSave = true;

    this.handleHtmlImgSrc();
  }

  handleHtmlImgSrc() {
    const htmlContent = this.editorController.richTextContent;
    // 处理图片 找出富文本中的图片
    const newImgSrcList: string[] = ImageUtils.findImgSrcList(htmlContent);
    const firstImg = newImgSrcList[0];
    // 保存第一张图片
    this.currentDiary.firstImage = firstImg ?? '';
    // 替换html中的所有img的src
    const newHtmlContent = this.replaceImgSrc(htmlContent, newImgSrcList);
    if (this.pageMode === PageMode.EDIT) {
      // 需要将富文本中已经删除的图片从沙箱中删除
      const oldImgSrcList: string[] = ImageUtils.findImgSrcList(this.currentDiary.htmlContent);
      handleTaskPoolDelete(oldImgSrcList, newImgSrcList)
    }
    this.currentDiary.htmlContent = newHtmlContent;
  }

  // 替换html中img的地址
  replaceImgSrc(html: string, newSrcList: string[]): string {
    let index = 0;
    return html.replace(/(<img[^>]+src=["'])\s*([^"']+)\s*(["'])/g, (match, p1: string, oldSrc: string, p3: string) => {
      const newSrc: string = newSrcList[index++] || oldSrc;
      return `${p1}${newSrc}${p3}`;
    });
  }

  showToast(message: string) {
    WindowUtil.uiContext.getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
      duration: 1500
    })
  }
}