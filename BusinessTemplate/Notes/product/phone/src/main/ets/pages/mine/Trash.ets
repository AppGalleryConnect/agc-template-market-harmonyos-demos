import { NoteService, SortEnum } from '@ohos_agcit/notes_datasource';
import { BreakpointType, DateConstants, DateUtil, GlobalInfoModel } from '@ohos_agcit/notes_utils';
import { NoteSearchController } from '../../controller/NoteSearchController';
import { EmptyTrash } from '../../components/EmptyTrash';
import { Note } from 'richeditor';
import { AppStorageV2 } from '@kit.ArkUI';
import { KVStore, SerializeUtil } from 'serializer';

@Builder
export function TrashBuilder() {
  Trash();
}

@ComponentV2
export struct Trash {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Consumer() kvStore: KVStore | undefined = undefined;
  noteService: NoteService = NoteService.instance;
  @Local noteList: Note[] = this.noteService.getDumpstersData();
  uiContext: UIContext = this.getUIContext() as UIContext;
  private currentNote: Note | undefined = undefined;
  private searchCtrl: NoteSearchController = NoteSearchController.instance;
  private scroller: ListScroller = new ListScroller();
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  // 排序相关状态
  @Local openSortSheet: boolean = false;
  @Local sortBy: SortEnum = SortEnum.CREATE_TIME_ASC;

  onSearch(keyword: string) {
    this.noteList = this.searchCtrl.onDumpsterSearch(keyword);
    this.noteList = this.sortDumpsterList(this.noteList);
  }

  // 获取排序后的回收站列表
  getSortedDumpsterList(): Note[] {
    const list = this.searchCtrl.getSortedDumpsterList();
    return this.sortDumpsterList(list);
  }

  // 排序方法
  sortDumpsterList(list: Note[]): Note[] {
    switch (this.sortBy) {
      case SortEnum.CREATE_TIME_ASC:
        return list.sort((a, b) => parseInt(a.createTime) - parseInt(b.createTime));
      case SortEnum.CREATE_TIME_DESC:
        return list.sort((a, b) => parseInt(b.createTime) - parseInt(a.createTime));
      default:
        return list;
    }
  }

  // 排序确认方法
  onSortConfirm(sortBy: SortEnum) {
    this.sortBy = sortBy;
    this.noteList = this.getSortedDumpsterList();
    this.openSortSheet = false;
  }

  @Builder
  swipeEnd(item: Note) {
    Row() {
      // 恢复按钮
      Column() {
        Image($r('app.media.icon_recover'))
          .width(40)
          .onClick(() => {
            this.currentNote = item;
            const params: Record<string, Note | undefined> = { 'note': this.currentNote };
            this.appPathStack.pushPathByName('RecoveryNoteDialog', params);
            this.scroller.closeAllSwipeActions();
          });
      }
      .width(60)
      .height(105)
      .justifyContent(FlexAlign.Center)

      // 删除按钮
      Column() {
        Image($r('app.media.delete_category'))
          .width(40)
          .onClick(() => {
            this.currentNote = item;
            const params: Record<string, Note | undefined> = { 'note': this.currentNote };
            this.appPathStack.pushPathByName('CompleteDeleteNoteDialog', params);
            this.scroller.closeAllSwipeActions();
          });
      }
      .width(60)
      .height(105)
      .justifyContent(FlexAlign.Center)
    }
    .height(105)
  }

  // 排序弹窗
  @Builder
  sortSheet() {
    Column() {
      Text($r('app.string.sort_order'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 24, bottom: 24, left: 24 });

      Column({ space: 10 }) {
        // 最早进入回收站
        Row() {
          Text('按时间升序')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
          Blank();
          Radio({ value: SortEnum.CREATE_TIME_ASC, group: 'sortGroup' })
            .checked(this.sortBy === SortEnum.CREATE_TIME_ASC)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.onSortConfirm(SortEnum.CREATE_TIME_ASC);
              }
            });
        }
        .width('100%')
        .padding({ top: 10, left: 12, right: 14 })
        .onClick(() => this.onSortConfirm(SortEnum.CREATE_TIME_ASC))

        Divider()
          .width('95%');

        // 最晚进入回收站
        Row() {
          Text('按时间倒序')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
          Blank();
          Radio({ value: SortEnum.CREATE_TIME_DESC, group: 'sortGroup' })
            .checked(this.sortBy === SortEnum.CREATE_TIME_DESC)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.onSortConfirm(SortEnum.CREATE_TIME_DESC);
              }
            });
        }
        .width('100%')
        .padding({ left: 12, right: 14, bottom: 10 })
        .onClick(() => this.onSortConfirm(SortEnum.CREATE_TIME_DESC))
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .margin({
        left: 16,
        right: 16,
        bottom: 50,
      })
      .borderRadius(8);
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%');
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          // 搜索框
          Search({
            placeholder: $r('app.string.searchtrash_note'),
            controller: this.searchCtrl.controller
          })
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .placeholderColor($r('sys.color.font_secondary'))
            .onSubmit((value: string) => this.onSearch(value))
            .onChange((value: string) => {
              if (!value){
                this.onSearch('');
              }
            })
            .width('100%')
            .margin({ bottom: 12 });

          if (this.noteList.length > 0) {
            Row() {
              Image($r('app.media.icon_more'))
                .width(24)
                .height(24)
                .onClick(() => {
                  this.openSortSheet = true;
                })
                .bindSheet($$this.openSortSheet, this.sortSheet(), {
                  width: '100%',
                  height: 200,
                  showClose: false,
                  preferType: 0,
                  enableOutsideInteractive: false,
                });
            }
            .justifyContent(FlexAlign.End)
            .width('100%')
            .margin({ bottom: 12 })
          }

          if (this.noteList.length === 0) {
            EmptyTrash()
          } else {
            this.showNoteList();
          }
        }
        .width('100%')
        .height('100%')
      }
      .padding(new BreakpointType<Padding>({
        sm: {
          top: 10,
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        },
        md: {
          top: 10,
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        },
        lg: {
          top: 10,
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        },
      }).getValue(this.globalInfo.currentBreakpoint))
      .width('100%')
      .height('100%');
    }
    .title('回收站')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  showNoteList() {
    if (this.searchCtrl.isDumpsterSearching && this.noteList.length === 0) {
      Column() {
        Text('没有找到匹配的笔记')
          .fontSize(16)
          .fontColor($r('sys.color.font_tertiary'));
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 12, scroller: this.scroller }) {
        ForEach(this.noteList, (item: Note) => {
          ListItem() {
            Column({ space: 12 }) {
              Text(item.title)
                .fontSize(18)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .padding({ top: 12 });

              Text(item.description)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(14)
                .fontWeight(FontWeight.Regular);

              Row() {
                Text(DateUtil.getFormatDateStr(item.createTime, DateConstants.DATE_FORMAT4))
                  .fontSize(12)
                  .fontColor($r('sys.color.font_tertiary'));
                Blank();
              }
              .width('100%');
            }
            .height(105)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
          }
          .swipeAction({
            end: {
              builder: () => this.swipeEnd(item)
            }
          })
        }, (item: Note) => item.id);
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ bottom: 16 })
      .scrollBar(BarState.Off);
    }
  }
}