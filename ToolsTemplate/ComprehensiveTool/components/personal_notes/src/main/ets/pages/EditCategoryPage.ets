import { ComponentContent } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { SelectedController } from '../controller/SelectedController';
import { CategoryUtil } from '../utils/CategotyUtil';
import { NoteUtil } from '../utils/NoteUtil';
import { Category } from '../models/Category';
import { Note } from '../models/Note';
import { DialogUtil } from '../utils/DialogUtil';
import { StringUtil } from '../utils/StringUtil';

@Builder
export function EditCategoryPageBuilder() {
  EditCategoryPage();
}


@ComponentV2
export struct EditCategoryPage {
  private scroller: ListScroller = new ListScroller();
  pathStack: NavPathStack = new NavPathStack();
  categoryUtil: CategoryUtil = CategoryUtil.instance;
  noteUtil: NoteUtil = NoteUtil.instance;
  private selectedController: SelectedController = SelectedController.instance;
  @Local categoryList: Array<Category> = [];
  @Local categoryId: string = '';
  @Local isEditCategoryName: boolean = true;
  @Local isEditCategory: boolean = true;
  @Local currentCategory: Category = this.categoryUtil.getFirstCategory();;
  @Local noteList: Note[] = [];

  selectFontColor(item: Category): ResourceStr {
   if (this.isEditCategory) {
       return this.currentCategory.id === item.id ? $r('sys.color.font_primary') : $r('sys.color.font_secondary');
   }

   return this.noteList.find(note => note.categoryId === item.id) ?
      $r('sys.color.font_tertiary') : $r('sys.color.font_secondary');
  }

  selectFontWeight(item: Category): FontWeight {
    if (this.isEditCategory) {
      return this.currentCategory.id === item.id ? FontWeight.Medium : FontWeight.Regular;
    }
    return this.noteList.find(note => note.categoryId === item.id) ? FontWeight.Medium : FontWeight.Regular;
  }

  partOfNoteList(categoryId: string): boolean {
    let noteItem = this.noteList.find(item => item.categoryId === categoryId);
    return Boolean(noteItem);
  }

  handleItemClick(item: Category) {
    if (item.id === '-1' || item.id === this.currentCategory.id) {
      return
    }
    // 非编辑模式
    if (!this.isEditCategory && this.noteList.length) {
      // 移动分类
      this.noteList.forEach(note => {
        this.categoryUtil.moveCategory(note.categoryId, item.id);
        note.categoryId = item.id;
        note.isSelected = false;
      })
      this.noteList.forEach(note => {
        this.noteUtil.updateNote(note);
      })
      this.selectedController.recoverInitState()
      this.pathStack.pop();
    }
  }

  build() {
    NavDestination() {
      Scroll(){
        Column({space: 15}) {
          List({ space: 12, scroller: this.scroller }) {
            ForEach(this.categoryList, (item: Category, index: number) => {
              ListItem() {
                Row() {
                  Text(item.name)
                    .fontSize(18)
                    .fontColor(this.selectFontColor(item))
                    .fontWeight(this.selectFontWeight(item))
                  Blank();
                  Text(String(item.totalCount))
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }
                .borderRadius(16)
                .backgroundColor(!this.isEditCategory && this.partOfNoteList(item.id) ?
                  $r('sys.color.background_tertiary') : $r('sys.color.comp_background_list_card'))
                .height(48)
                .width('100%')
                .padding({ left: '3%', right: '3%' })
              }
              .swipeAction({
                end: {
                  builder: () => {
                    if (item.name !== '全部笔记') {
                      this.categoryEnd(item)
                    }
                  }
                }
              })
              .onClick(() => {
                this.handleItemClick(item)
              })
            }, (item: Category) => item.id);
          }

          this.newAddCategoryView()
        }
        .width('100%')
        .padding({
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
          top: 10,
          bottom: 50,
        })
      }
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((cxt: NavDestinationContext) => {
      this.pathStack = cxt.pathStack;
      this.categoryList = this.categoryUtil.getCategoryList();
      let params = cxt.pathInfo.param as Record<string, Object>;
      this.isEditCategory = params.isEditCategory as boolean;
      this.currentCategory = params.currentCategory as Category;
      if (!this.isEditCategory) {
        this.noteList = params.noteList as Note[];
      }
    })
    .title('笔记分类')
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }

  /**
   * 右滑样式设置
   * @param item
   */
  @Builder
  categoryEnd(item: Category){
    Row() {
      Image($r('app.media.edit_category'))
        .width(40)
        .height(40)
        .margin({ left: 16, right: 16})
        .onClick(() => {
          this.isEditCategoryName = true;
          this.categoryId = item.id;

          let contentNode: ComponentContent<object> =
            new ComponentContent(this.getUIContext(),wrapBuilder(editCategoryDialog),
              new EditCategoryParam(this.isEditCategoryName,
                this.categoryUtil.getCategoryById(this.categoryId), this.scroller));
          DialogUtil.openDialog(this.getUIContext(), contentNode);
        })

      Image($r('app.media.delete_category'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.categoryId = item.id;
          let contentNode: ComponentContent<object> =
            new ComponentContent(this.getUIContext(),wrapBuilder(deleteCategoryDialog),
              new DeleteCategoryParam(this.categoryId, this.scroller));
          DialogUtil.openDialog(this.getUIContext(), contentNode);
        })
    }
    .width(112)
    .height(48)
  }

  @Builder
  newAddCategoryView() {
    Row({ space: 8 }) {
      Image($r('app.media.create_category'))
        .width(24)
        .height(24)
      Text('新建分类')
        .fontSize(18)
        .fontColor($r('sys.color.font_secondary'))
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .height(48)
    .width('100%')
    .onClick(() => {
      this.isEditCategoryName = false;
      let contentNode: ComponentContent<object> =
        new ComponentContent(this.getUIContext(),wrapBuilder(editCategoryDialog),
          new EditCategoryParam(this.isEditCategoryName,
            this.categoryUtil.getCategoryById(this.categoryId), this.scroller));
      DialogUtil.openDialog(this.getUIContext(), contentNode);
    })
  }

}

class EditCategoryParam{
  isEdit: boolean;
  category: Category | undefined
  scroller: ListScroller

  constructor(isEdit: boolean, category: Category | undefined, scroller: ListScroller) {
    this.isEdit = isEdit;
    this.category = category;
    this.scroller = scroller
  }
}

@Builder
function editCategoryDialog(params: EditCategoryParam) {
  EditCategoryDialog({
    params: params
  })
}

@ComponentV2
struct EditCategoryDialog {
  @Param @Require params: EditCategoryParam;
  @Local newName: string = '';
  categoryUtil: CategoryUtil = CategoryUtil.instance;

  build() {
    Column() {
      Text(this.params.isEdit ? '重命名' : '新建分类')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .padding({
          top: 11,
          bottom: 12,
        });

      TextInput({
        text: this.params.isEdit ? this.params.category?.name : '',
      })
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .borderRadius(16)
        .margin({
          left: '3%',
          right: '3%',
        })
        .onChange((value) => {
          this.newName = value;
        });

      Row() {
        Row() {
          Text('取消')
            .editCategoryButtonStyle();
        }
        .justifyContent(FlexAlign.Center)
        .height(70)
        .width('50%')
        .onClick(() => {
          DialogUtil.closeDialog();
        });

        Row() {
          Text('确定')
            .editCategoryButtonStyle();
        }
        .justifyContent(FlexAlign.Center)
        .height(70)
        .width('50%')
        .onClick(() => {
          if (StringUtil.isBlank(this.newName)) {
            ToastDialog.showToast({
              message: '分类名称为空, 请重新填写 ~',
              duration: 1500,
              toastAlignment: DialogAlignment.Center,
            });
            return;
          }

          this.params.scroller.closeAllSwipeActions()
          if (this.params.isEdit) {
            if (this.params.category) {
              this.params.category.name = this.newName;
            }
            DialogUtil.closeDialog();
            return;
          }
          if (this.categoryUtil.addCategory(new Category(this.newName, 0))) {
            DialogUtil.closeDialog();
          }
        });
      };
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('92%')
    .height(158);
  }
}


class DeleteCategoryParam{
  categoryId: string
  scroller: ListScroller

  constructor(categoryId: string, scroller: ListScroller) {
    this.categoryId = categoryId;
    this.scroller = scroller
  }
}

@Builder
function deleteCategoryDialog(params: DeleteCategoryParam){
  DeleteCategoryDialog({
    params: params
  })
}

@ComponentV2
struct DeleteCategoryDialog {
  @Param @Require params: DeleteCategoryParam;
  noteUtil: NoteUtil = NoteUtil.instance;
  categoryUtil: CategoryUtil = CategoryUtil.instance;

  deleteCategory() {
    this.categoryUtil.deleteCategoryById(this.params.categoryId);
    ToastDialog.showToast({
      message: '删除成功 ~',
      toastAlignment: DialogAlignment.Center,
      duration: 1500,
    });
    this.params.scroller.closeAllSwipeActions();
    DialogUtil.closeDialog();
  }

  build() {
    Column({ space: 30 }) {
      Row() {
        Text('仅删除分类')
          .fontSize(16)
          .onClick(() => {
            this.noteUtil.moveNotesCategory(this.params.categoryId);
            this.deleteCategory()
          });
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(20);

      Row() {
        Text('删除分类和笔记')
          .fontSize(16)
          .fontColor(Color.Red)
          .onClick(() => {
            // 删除笔记
            let notes: Note[] = this.noteUtil.getNoteList(this.params.categoryId);
            notes.forEach((item) => {
              this.noteUtil.deleteNote(item.id);
            });
            // 删除分类
            this.deleteCategory()
          });
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(20);

      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor(Color.Grey)
          .onClick(() => {
            DialogUtil.closeDialog()
          });
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(20);
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('92%')
    .borderRadius(16)
    .padding({
      top: 30,
      bottom: 30,
    });
  }
}



@Extend(Text)
function editCategoryButtonStyle() {
  .fontSize(16)
  .fontColor('#0A59F7')
  .fontWeight(FontWeight.Medium);
}
