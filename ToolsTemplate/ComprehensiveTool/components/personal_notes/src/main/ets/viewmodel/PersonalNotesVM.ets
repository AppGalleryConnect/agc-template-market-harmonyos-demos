import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { ShowMethod, ToolBarName } from '../commons/Enum';
import { CategoryController } from '../controller/CategoryController';
import { NoteSearchController } from '../controller/NoteSearchController';
import { SelectedController } from '../controller/SelectedController';
import { SortController } from '../controller/SortController';
import { Category } from '../models/Category';
import { CommonDataSource } from '../models/CommonDataSource';
import { Note } from '../models/Note';
import { CategoryUtil } from '../utils/CategotyUtil';
import { NoteUtil } from '../utils/NoteUtil';


@ObservedV2
export class PersonalNotesVM {
  noteUtil: NoteUtil = NoteUtil.instance;
  categoryUtil: CategoryUtil = CategoryUtil.instance;
  noteSearchController: NoteSearchController = NoteSearchController.instance;
  sortController: SortController = SortController.instance;
  categoryController: CategoryController = CategoryController.instance;
  selectedController: SelectedController = SelectedController.instance;

  @Trace noteList: Note[] = [];
  @Trace showListType: ShowMethod  = ShowMethod.normalList;
  @Trace currentCategory: Category = this.categoryUtil.getCurrentCategory();
  @Trace dataList: CommonDataSource<Note> = new CommonDataSource();

  uiContext?: UIContext;
  pathStack: NavPathStack = new NavPathStack();

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.initWindowSize()
  }

  initWindowSize() {
    // 获取屏幕宽高
    let context = this.uiContext!.getHostContext() as common.UIAbilityContext;
    let windowClass: window.Window = context.windowStage.getMainWindowSync();
    let size = windowClass.getWindowProperties().windowRect;
    AppStorage.setOrCreate('screenHeight', this.uiContext!.px2vp(size.height));
    AppStorage.setOrCreate('screenWidth', this.uiContext!.px2vp(size.width));
  }

  initNoteData() {
    this.noteSearchController.searchKeyword = '';
    this.noteList = this.noteUtil.getNoteList(
      this.currentCategory.id, this.sortController.sortBy, this.noteSearchController.searchKeyword);

    // 根据分类处理笔记列表数据
    this.handleNoteListByCategory()
    this.updateDataList();
  }

  handleNoteListByCategory() {
    // 当前分类是否存在
    let category = this.categoryUtil.getCategoryById(this.currentCategory.id)
    if (!category) {
      this.selectedController.isCtrl = false;
      this.currentCategory = this.categoryUtil.getFirstCategory();
      this.noteList = this.noteUtil.getNoteList(
        this.currentCategory.id, this.sortController.sortBy, this.noteSearchController.searchKeyword);
    }
  }

  // 搜索
  submit(value: string) {
    this.noteList = this.noteSearchController.onSearch(
      this.currentCategory.id,
      value,
      this.sortController.sortBy
    );
    this.updateDataList();
  }

  // 搜索框文案变化
  searchChange(value: string) {
    if (!value) {
      // 清空搜索时恢复列表
      this.noteList = this.noteSearchController.onSearch(
        this.currentCategory.id,
        '',
        this.sortController.sortBy
      );
      this.updateDataList();
    }
  }

  // 更新瀑布流卡片数据
  updateDataList() {
    this.dataList.clear();
    this.noteList.forEach((item:Note) => {
      this.dataList.pushData(item);
    })
  }

  // 笔记卡片长按事件
  handleLangPress(item: Note) {
    // 非多选状态下生效
    if (!this.selectedController.isCtrl) {
      this.selectedController.isCtrl = true;
      item.isSelected = true;
      this.selectedController.selectedCount = 1;
    }
  }

  // 获取选中的笔记
  getSelectData():Note[] {
    let tempArray: Note[] = [];
    this.noteList.forEach((item) => {
      if (item.isSelected) {
        tempArray.push(item);
      }
    })
    if (tempArray.length === 0) {
      ToastDialog.showToast({
        message: '还未选中任何笔记',
        toastAlignment: DialogAlignment.Center
      })
    }
    return tempArray;
  }

  // 全选
  handleSelectAll() {
    if (this.selectedController.selectedCount === this.noteList.length) {
      this.noteList.forEach(item => item.isSelected = false);
      this.selectedController.selectedCount = 0;
    } else {
      this.noteList.forEach(item => item.isSelected = true);
      this.selectedController.selectedCount = this.noteList.length;
    }
  }

  // 底部工具栏点击事件 分类、删除、全选
  handleToolBarClick(name: ToolBarName) {
    if (name === ToolBarName.select_all) {
      this.handleSelectAll()
      return;
    }

    const selectDataList = this.getSelectData();
    if (selectDataList.length === 0) {
      return;
    }

    if (name === ToolBarName.move_category) {
      const params: Record<string, Object> = {
        'isEditCategory': false,
        'currentCategory': this.currentCategory,
        'noteList': selectDataList
      };
      this.pathStack.pushPathByName('EditCategoryPage', params);
    } else if (name === ToolBarName.delete) {
      this.deleteNotes()
    }
  }

  deleteNotes() {
    this.uiContext?.getPromptAction().showDialog({
      title: '确认删除',
      message: '请确认是否删除所选笔记？',
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
        const selectDataList = this.getSelectData();
        this.noteUtil.deleteNotes(selectDataList);
        this.noteList = this.noteUtil.getNoteList(
          this.currentCategory.id, this.sortController.sortBy, this.noteSearchController.searchKeyword);
        this.selectedController.recoverInitState();
        this.updateDataList();
      }
    });
  }

  // 重置分类
  resetCategory(category: Category) {
    this.currentCategory = category;
    this.categoryUtil.setCurrentCategory(category)
    this.noteSearchController.isSearching = false; // 重置搜索状态
    this.noteSearchController.searchKeyword = '';
    this.noteList = this.noteUtil.getNoteList(
      this.currentCategory.id, this.sortController.sortBy, this.noteSearchController.searchKeyword);
    this.categoryController.openCategorySheet = false;
    this.updateDataList();
  }

  // 编辑分类
  editCategory() {
    this.categoryController.openCategorySheet = false;
    if (this.currentCategory) {
      const params: Record<string, Object | undefined> = {
        'isEditCategory': true,
        'currentCategory': this.currentCategory,
        'noteList': undefined
      };
      this.pathStack.pushPathByName('EditCategoryPage', params);
    }
  }

  // 点击卡片事件
  clickItemCard(item: Note) {
    if (this.selectedController.isCtrl) {
      item.isSelected = !item.isSelected;
      let count: number = 0;
      this.noteList.forEach((data: Note) => {
        if (data.isSelected) {
          count++;
        }
      })
      this.selectedController.selectedCount = count;
    } else {
      const params: Record<string, Object> = {
        'noteId': item.id,
        'currentCategory': this.currentCategory
      };
      this.pathStack.pushPathByName('EditNotePage', params);
    }
  }
}