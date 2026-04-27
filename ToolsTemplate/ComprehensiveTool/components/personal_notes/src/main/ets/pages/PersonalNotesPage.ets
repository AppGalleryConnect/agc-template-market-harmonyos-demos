import { TOOL_BAR_LIST, NOTE_SHOW_TYPE_LIST, NOTE_SORT_TYPE_LIST } from '../commons/Constant';
import { ShowMethod, SortEnum } from '../commons/Enum';
import { ToolBar } from '../commons/Interface';
import { EmptyNotes } from '../components/EmptyNotes';
import { NoteCategoryVew } from '../components/NoteCategoryVew';
import { NoteItemCard } from '../components/NoteItemCard';
import { SearchNoResult } from '../components/SearchNoResult';
import { SortSheetCard } from '../components/SortSheetCard';
import { Category } from '../models/Category';
import { Note } from '../models/Note';
import { WindowUtil } from '../utils/WindowUtil';
import { PersonalNotesVM } from '../viewmodel/PersonalNotesVM';

@Builder
export function PersonalNotesPageBuilder() {
  PersonalNotesPage();
}

@ComponentV2
export struct PersonalNotesPage {
  vm: PersonalNotesVM = new PersonalNotesVM(this.getUIContext());

  aboutToAppear(): void {
    WindowUtil.init(this.getUIContext());
  }

  build() {
    NavDestination() {
      Column() {
        if (this.vm.selectedController.isCtrl) {
          this.headerView()
        }
        // 搜索框
        Search({ placeholder: '请输入关键字搜索' })
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .placeholderColor($r('sys.color.font_secondary'))
          .fontColor($r('sys.color.font_primary'))
          .margin({
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
            top: 12,
            bottom: 12,
          })
          .onSubmit((value: string) => {
            this.vm.submit(value);
          })
          .onChange((value: string) => {
            this.vm.searchChange(value)
          })

        this.editorNoteList()
        this.showNoteList()
        this.toolBarBuilder()
        this.addNoteBuilder()
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height('100%')
    }
    .title('隐私笔记')
    .hideTitleBar(this.vm.selectedController.isCtrl)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      this.vm.pathStack = ctx.pathStack;
    })
    .onWillShow(() => {
      this.vm.initNoteData()
    })
    .onBackPressed(() => {
      if (this.vm.selectedController.isCtrl) {
        this.vm.selectedController.isCtrl = false;
        return true
      }
      return false
    })
  }

  @Styles
  cardWrapperStyle() {
    .width('100%')
    .margin({ bottom: 10 })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .layoutWeight(1)
  }

  @Builder
  headerView() {
    Row() {
      Text(`已选${this.vm.selectedController.selectedCount}项`)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Blank();
      Image($r('app.media.exit_ctrl'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.vm.noteList.forEach((item: Note) => item.isSelected = false)
          this.vm.selectedController.recoverInitState();
        });
    }
    .width('100%')
    .padding({
      top: 12,
      bottom: 20,
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  editorNoteList() {
    if (!this.vm.selectedController.isCtrl){
      Row() {
        Row({ space: 4 }) {
          Text(this.vm.currentCategory.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
            .fontColor([$r('sys.color.font_secondary')]);
        }
        .onClick(() => {
          this.vm.categoryController.openCategorySheet = true;
        })
        .bindSheet($$this.vm.categoryController.openCategorySheet, this.showCategoryDialog(), {
          title: { title: '笔记分类' },
          width: '100%',
          height: 400,
          preferType: SheetType.CENTER,
          radius:{
            topLeft:16,
            topRight:16
          }
        })

        Blank();
        Image($r('app.media.icon_more'))
          .height(20)
          .width(20)
          .onClick(() => {
            this.vm.sortController.openSortSheet = true;
          })
          .bindSheet($$this.vm.sortController.openSortSheet, this.sortSheet(), {
            width: '100%',
            showClose: false,
            height: 376,
            preferType: SheetType.CENTER,
            radius:{
              topLeft:16,
              topRight:16
            }
          })
      }
      .width('100%')
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        top: 12,
        bottom: 12
      })
    }
  }

  @Builder
  showCategoryDialog() {
    NoteCategoryVew({
      currentCategory: this.vm.currentCategory,
      resetCategory: (category: Category) => {
        this.vm.resetCategory(category)
      },
      editCategory: () => {
        this.vm.editCategory()
      }
    })
  }

  @Builder
  sortSheet() {
    Column() {
      SortSheetCard({
        title: '展示形式',
        data: NOTE_SHOW_TYPE_LIST,
        type: 'showType',
        showListType: this.vm.showListType,
        handleEvent: (type: ShowMethod | SortEnum) => {
          this.vm.showListType = type as ShowMethod;
          this.vm.sortController.openSortSheet = false;
        }
      })
      SortSheetCard({
        title: '排序方式',
        data: NOTE_SORT_TYPE_LIST,
        type: 'sortGroup',
        handleEvent: (type: ShowMethod | SortEnum) => {
          this.vm.sortController.onSortConfirm(this.vm.currentCategory.id, type as SortEnum,
            this.vm.noteSearchController.searchKeyword);
        }
      })
    }
  }

  @Builder
  showNoteList() {
    if (this.vm.noteSearchController.isSearching && this.vm.noteList.length === 0) {
      SearchNoResult()
    }
    if (!this.vm.noteSearchController.isSearching && this.vm.noteList.length === 0) {
      EmptyNotes()
    } else if (this.vm.showListType === ShowMethod.normalList) {
      this.cardList()
    } else {
      this.waterCardList()
    }
  }

  @Builder
  cardList() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.vm.noteList, (item: Note) => {
          ListItem() {
            NoteItemCard({
              item: item,
              onClickAction: ()=> {
                this.vm.clickItemCard(item)
              }
            })
          }
          .gesture(
            LongPressGesture({ repeat: false, fingers: 1, duration: 500 })
              .onAction((event: GestureEvent|undefined) => {
                if (event) {
                  this.vm.handleLangPress(item)
                }
              })
          )
        }, (item: Note) => item.id);
      }
      .scrollBar(BarState.Off)
    }
    .cardWrapperStyle()
  }

  @Builder
  waterCardList() {
    Column() {
      WaterFlow() {
        LazyForEach(this.vm.dataList, (item: Note) => {
          FlowItem() {
            NoteItemCard({
              item: item,
              maxLines: 9,
              onClickAction: () => {
                this.vm.clickItemCard(item)
              }
            })
          }
          .width('100%')
          .gesture(
            // 绑定可以重复触发的LongPressGesture
            LongPressGesture({ repeat: false, fingers: 1, duration: 500 })
              .onAction((event: GestureEvent|undefined) => {
                if(event){
                  this.vm.handleLangPress(item)
                }
              })
          )
        }, (item: Note) => item.id)
      }
      .cachedCount(1)
      .columnsTemplate('1fr 1fr')
      .columnsGap($r('sys.float.padding_level8'))
      .rowsGap(16)
      .width('100%')
      .height('100%')
    }
    .cardWrapperStyle()
  }

  @Builder
  addNoteBuilder(){
    if (this.vm.selectedController.isCtrl === false){
      Row(){
        SymbolGlyph($r('sys.symbol.plus'))
          .fontColor([Color.White])
          .fontSize(35);
      }
      .justifyContent(FlexAlign.Center)
      .width(50)
      .height(50)
      .borderRadius(44)
      .backgroundColor('#FFAA00')
      .zIndex(10)
      .position({ right: 30, bottom: 100 })
      .onClick(() => {
        const params: Record<string, Object> = {
          'noteId': '',
          'currentCategory': this.vm.currentCategory
        };
        this.vm.pathStack.pushPathByName('EditNotePage', params);
      })
    }
  }

  @Builder
  toolBarBuilder(){
    if (this.vm.selectedController.isCtrl) {
      Row() {
        ForEach(TOOL_BAR_LIST, (item: ToolBar) => {
          Column({ space: 5 }){
            Image(item.icon)
              .width(24)
              .height(24)

            Text(item.name)
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
          }
          .onClick(() => {
            this.vm.handleToolBarClick(item.name)
          })
        }, (item: ToolBar) => JSON.stringify(item))
      }
      .margin({ top: 10 })
      .padding({ top: 12, bottom: 10 })
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }
}