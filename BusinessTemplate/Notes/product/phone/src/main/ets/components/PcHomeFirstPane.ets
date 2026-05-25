import { Category, CategoryService } from '@ohos_agcit/notes_datasource';
import { NoteSearchController } from '../controller/NoteSearchController';
import { UserInfo } from 'login';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';


@ComponentV2
export struct PcHomeFirstPane {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private userInfo: UserInfo = UserInfo.instance;
  private categoryService: CategoryService = CategoryService.instance;
  private noteSearchController: NoteSearchController = NoteSearchController.instance;
  private hostContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local currentCategory: Category = this.categoryService.getFirstCategory();
  @Local pcCategoryExpanded: boolean = true;
  private lastCategoryTapId: string = '';
  private lastCategoryTapTime: number = 0;
  private lastAllNotesTapTime: number = 0;

  private isPcLayout(): boolean {
    try {
      const type = this.hostContext.resourceManager.getDeviceCapabilitySync().deviceType;
      return type === resourceManager.DeviceType.DEVICE_TYPE_2IN1;
    } catch (_e) {
      return false;
    }
  }

  aboutToAppear(): void {
    this.applySavedCategory();
  }

  private applySavedCategory(): void {
    const saved: string | undefined = AppStorage.get<string>('notes_pc_current_category_id');
    if (saved) {
      const cat: Category | undefined = this.categoryService.getCategoryById(saved);
      if (cat) {
        this.currentCategory = cat;
        return;
      }
    }
    this.currentCategory = this.categoryService.getFirstCategory();
  }

  private resetPaneCategory(category: Category): void {
    AppStorage.setOrCreate('notes_pc_current_category_id', category.id);
    AppStorage.delete('notes_pc_search_keyword');
    this.currentCategory = category;
    this.noteSearchController.isSearching = false;
    this.noteSearchController.searchKeyword = '';
  }

  private onCategoryRowTap(category: Category): void {
    const now: number = Date.now();
    if (category.id === this.lastCategoryTapId && (now - this.lastCategoryTapTime) < 450) {
      this.resetPaneCategory(category);
      this.appPathStack.pop();
      this.lastCategoryTapId = '';
      this.lastCategoryTapTime = 0;
      return;
    }
    this.lastCategoryTapId = category.id;
    this.lastCategoryTapTime = now;
    this.resetPaneCategory(category);
  }

  private onAllNotesTitleRowTap(): void {
    const now: number = Date.now();
    const all: Category | undefined = this.categoryService.getCategoryById('-1');
    const target: Category = all ?? this.categoryService.getFirstCategory();
    if ((now - this.lastAllNotesTapTime) < 450 && this.lastAllNotesTapTime > 0) {
      this.resetPaneCategory(target);
      this.appPathStack.pop();
      this.lastAllNotesTapTime = 0;
      return;
    }
    this.lastAllNotesTapTime = now;
    this.resetPaneCategory(target);
  }

  private popToHomeWithSearch(keyword: string): void {
    AppStorage.setOrCreate('notes_pc_search_keyword', keyword);
    this.noteSearchController.searchKeyword = keyword;
    this.noteSearchController.isSearching = keyword.length > 0;
    this.appPathStack.pop();
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Image(this.userInfo.userAvatar)
          .width(56)
          .height(56)
          .borderRadius(28)
          .margin({ left: 12 });

        Text(this.userInfo.userName)
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 12 });
      }
      .width('100%')
      .height(72)
      .onClick(() => {
        if (this.userInfo.isLogin) {
          this.appPathStack.pushPathByName(this.isPcLayout() ? 'MineViewHost' : 'MineView', undefined);
        } else {
          this.appPathStack.pushPathByName('QuickLoginPage', undefined);
        }
      });

      Scroll() {
        Column({ space: 8 }) {
          Search({
            placeholder: $r('app.string.search_note'),
          })
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .placeholderColor($r('sys.color.font_secondary'))
            .fontColor($r('sys.color.font_primary'))
            .onSubmit((value: string) => {
              this.popToHomeWithSearch(value);
            })
            .onChange((value: string) => {
              if (!value) {
                this.noteSearchController.isSearching = false;
                this.noteSearchController.searchKeyword = '';
              }
            });

          Column() {
            Button() {
              Row() {
                Text($r('app.string.go_note_category'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Medium);
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize(18)
                  .fontColor([Color.White])
                  .padding({ left: 13 });
              };
            }
            .height(40)
            .width('100%')
            .backgroundColor('#FFAA00')
            .margin({ bottom: 8 })
            .onClick(() => {
              const params: Record<string, Object | undefined> = {
                'isEditCategory': true,
                'currentCategory': this.currentCategory,
                'noteList': undefined,
              };
              this.appPathStack.pushPathByName('EditCategory', params);
            });

            Row({ space: 8 }) {
              Text('全部笔记')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .onClick(() => {
                  this.onAllNotesTitleRowTap();
                });
              Blank();
              SymbolGlyph(this.pcCategoryExpanded ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
                .fontSize(18)
                .fontColor([$r('sys.color.font_secondary')])
                .onClick(() => {
                  this.pcCategoryExpanded = !this.pcCategoryExpanded;
                });
            }
            .width('100%')
            .height(44)
            .padding({ left: 12, right: 12 })
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(12);

            if (this.pcCategoryExpanded) {
              List() {
                ForEach(this.categoryService.getCategoryList().filter((c) => c.id !== '-1'),
                  (category: Category, index: number) => {
                    ListItem() {
                      Column() {
                        if (index !== 0) {
                          Divider().color($r('sys.color.comp_divider'));
                        }
                        Row() {
                          Text(category.name)
                            .fontSize(14)
                            .fontColor(this.currentCategory.id === category.id ?
                              $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                            .fontWeight(this.currentCategory.id === category.id ? FontWeight.Medium :
                              FontWeight.Regular);

                          Blank();
                          Text(String(category.totalCount))
                            .fontSize(14)
                            .fontColor($r('sys.color.font_secondary'));
                        }
                        .width('100%')
                        .height(44);
                      };
                    }
                    .padding({ left: 12, right: 12 })
                    .onClick(() => {
                      this.onCategoryRowTap(category);
                    });
                  }, (category: Category) => category.id);
              }
              .scrollBar(BarState.Off)
              .borderRadius(12)
              .margin({ top: 0 });
            }
          }
          .width('100%');
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .justifyContent(FlexAlign.Start);
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .width('100%');
    }
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12,
    })
    .width('100%')
    .height('100%');
  }
}
