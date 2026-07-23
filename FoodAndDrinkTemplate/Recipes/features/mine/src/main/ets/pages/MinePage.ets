import { AccountUtil, BaseHeader, CommonConstants, RouterMap, RouterModule } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';
import { PersonalHomepage } from 'personal_homepage';
import { emitter } from '@kit.BasicServicesKit';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { BloggerInfomation } from 'personal_homepage/src/main/ets/components/BloggerInfomation';
import { TabIndexEnum } from 'base_ui';
import { RecipesHeader } from '../components/RecipesHeader';

@Builder
export function MinePageBuilder() {
  MinePage();
}

@Preview
@ComponentV2
struct MinePage {
  // 累计滚动偏移量
  @Local scrollY: number = 0
  // 个人信息区域真实高度，由 onAreaChange 动态回传
  @Local infoAreaHeight: number = 0
  private readonly TITLE_BAR_HEIGHT: number = 56
  private readonly Z_INDEX_TITLE_BAR: number = 1
  private readonly Z_INDEX_GRID_HEADER: number = 2
  private readonly Z_INDEX_DELETE_BTN: number = 3
  vm: MinePageVM = MinePageVM.instance;
  // 保存同一个回调引用，用于正确取消订阅
  private refreshCallback = () => {
    this.vm.refreshMinePage()
  }

  aboutToAppear(): void {
    this.vm.init()
    emitter.on('refreshMinePage', this.refreshCallback);
  }

  aboutToDisappear(): void {
    emitter.off('refreshMinePage', this.refreshCallback);
  }

  @Monitor('vm.userInfo.isLogin')
  changeLogin(monitor: IMonitor) {
    this.vm.changeLogin()
  }

  @Monitor('vm.isToDelete')
  onIsToDeleteChange(monitor: IMonitor) {
    // isToDelete 变化时触发UI刷新
  }

  @Computed
  get showDeleteBtn(): boolean {
    return this.vm.isToDelete && this.vm.currentIndex === TabIndexEnum.FIRST
  }

  private onColumnClicked(indexValue: string, index: number, snapShotComponentId: string): void {
    let param: Record<string, Object> = {};
    let clickedIndex = parseInt(indexValue);
    let recipeItem = this.vm.recipeList.getData(index);
    if (!recipeItem) {
      return;
    }
    let isVip = recipeItem.isVip;
    param.id = clickedIndex;
    param.indexValue = clickedIndex;
    param.snapShotId = snapShotComponentId;

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }

    if (isVip && !this.vm.userInfo.isMembership) {
      if(!this.vm.userInfo.isLogin) {
        RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      } else {
        RouterModule.push(RouterMap.MEMBER_CENTER_PAGE);
      }
    } else {
      RouterModule.push(RouterMap.DISHES, param);
    }
  }

  // Grid 超出个人信息区域的多余滚动量，是后续所有动画计算的基础
  // 阶段一：scrollY < infoAreaHeight 时为 0，标题栏保持不动
  // 阶段二：scrollY >= infoAreaHeight 时从 0 开始增长，触发联动动画
  get excessScroll(): number {
    return Math.max(this.scrollY - this.infoAreaHeight, 0)
  }

  // 标题栏透明度：随 excessScroll 增长从 1 渐变到 0，在滚动40%距离时完全隐藏
  // 这样 BaseHeader 完全消失时，TabHeader 已移动到接近 BaseHeader 的位置，实现无缝过渡
  get titleBarOpacity(): number {
    const fadeDistance = this.TITLE_BAR_HEIGHT * 0.4
    return Math.max(1 - this.excessScroll / fadeDistance, 0)
  }

  // 吸顶层位置：从标题栏底部开始，随 excessScroll 增长移动到 y=0
  // titleBarOffset + stickyHeaderTop 始终等于 TITLE_BAR_HEIGHT，保证两者无缝衔接
  get stickyHeaderTop(): number {
    return Math.max(this.TITLE_BAR_HEIGHT - this.excessScroll, 0)
  }

  // excessScroll > 0 即进入吸顶阶段，显示吸顶层
  get isStickying(): boolean {
    return this.excessScroll > 0
  }

  get isStickyEd(): boolean {
    return this.excessScroll - this.TITLE_BAR_HEIGHT > 0
  }

  build() {
    NavDestination() {
      // Stack 作为根容器，将固定层叠加在滚动层之上
      Stack({ alignContent: Alignment.TopStart }) {
        // 滚动主体，顶部留出标题栏高度避免内容被遮挡
        Scroll() {
          Column() {
            BloggerInfomation({
              bloggerInfo: this.vm.bloggerInfo,
              isSelf: true,
              isLogin: this.vm.userInfo.isLogin,
              login: () => {
                this.vm.login()
              },
              jumpFollowers: () => {
                RouterModule.push(RouterMap.FOLLOWERS_PAGE, { 'id': this.vm.bloggerInfo.id } as Record<string, number>)
              },
              jumpMemberCenter: () => {
                RouterModule.push(RouterMap.MEMBER_CENTER_PAGE);
              }
            }).onAreaChange((_old: Area, newArea: Area) => {
              this.infoAreaHeight = newArea.height as number
            }).padding({ top: 12, left: 16, right: 16 })
              .visibility(this.isStickying ? Visibility.Hidden : Visibility.Visible)
            // 滚动流中的普通态 吸顶后被吸顶层覆盖
            RecipesHeader({
              currentIndex: this.vm.currentIndex,
              gridCount: this.vm.gridCount,
              changeTabs: (index: number) => {
                this.vm.changeTabs(index)
                this.vm.exitDeleteMode()
              },
            })

            PersonalHomepage({
              recipeList: this.vm.recipeList,
              currentIndex: this.vm.currentIndex,
              isToDelete: this.vm.isToDelete,
              uploadBuilderParam: (): void => {
                this.uploadRecipeBuilder()
              },
              onClickCb: (id: number, index: number) => {
                this.onColumnClicked(id.toString(), index, `recipes_flow_${id}_${index}_`)
              },
              jumpBloggerInfo: (id: number) => {
                RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE, { 'id': id } as Record<string, number>)
              },
              deleteRecipes: (ids: number[]) => {
                this.vm.deleteMyRecipe(ids)
              },
              changeDeleteState: (isToDelete: boolean) => {
                if (isToDelete) {
                  this.vm.enterDeleteMode()
                } else {
                  this.vm.exitDeleteMode()
                }
              },
              changeSelect: (id: number, flag: boolean) => {
                this.vm.toggleSelect(id, flag)
              },
            }).onClick(() => {
              if (this.vm.isToDelete) {
                this.vm.exitDeleteMode()
              }
            })
          }
        }
        .scrollBar(BarState.Off)
        .onDidScroll((_xOffset: number, yOffset: number, _scrollState: ScrollState) => {
          this.scrollY += yOffset
          if (this.scrollY < 0) {
            this.scrollY = 0
          }
        })
        .width('100%')
        .height('100%')
        .padding({ top: this.TITLE_BAR_HEIGHT })
        .margin({ top: CommonConstants.STATUS_BAR_HEIGHT })
        // 标题栏固定在顶部，阶段二开始随 excessScroll 改变透明度直至完全隐藏
        Stack({ alignContent: Alignment.Bottom }) {
          Column()
            .width('100%')
            .height(this.TITLE_BAR_HEIGHT)
          BaseHeader({
            showTitle: false,
            showLeftMenu: true,
            showMsg: true,
            noticeNum: this.vm.noticeList.length,
            changeSideBar: (flag: boolean) => {
              this.vm.changeSideBar(flag)
            },
          }).opacity(this.titleBarOpacity)
            .zIndex(this.Z_INDEX_TITLE_BAR)
            .backgroundColor($r('sys.color.comp_background_gray'))
        }.visibility(this.isStickyEd ? Visibility.Hidden : Visibility.Visible)

        // 吸顶层：进入阶段二后出现，zIndex 比标题栏高
        if (this.isStickying) {
          RecipesHeader({
            isStickyEd: true,
            currentIndex: this.vm.currentIndex,
            gridCount: this.vm.gridCount,
            changeTabs: (index: number) => {
              this.vm.changeTabs(index)
            },
          }).position({ x: 0, y: this.stickyHeaderTop })
            .zIndex(this.Z_INDEX_GRID_HEADER)
            .padding({ top: CommonConstants.STATUS_BAR_HEIGHT })
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .backgroundBlurStyle(BlurStyle.Thin)
        }

        // 删除按钮：在删除模式下显示
        if (this.showDeleteBtn) {
          Row({ space: 8 }) {
            Image($r('app.media.ic_public_trash')).fillColor(Color.White).width(19).height(17);
            Text('删除').fontColor(Color.White).fontSize(16).fontWeight(FontWeight.Medium);
          }
          .width(128)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#E84026')
          .justifyContent(FlexAlign.Center)
          .zIndex(this.Z_INDEX_DELETE_BTN)
          .position({ x: '50%', y: '100%' })
          .translate({ x: '-50%', y: '-128' })
          .onClick(() => {
            this.vm.deleteSelectedRecipes()
          });
        }
      }
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .hideTitleBar(true);
  }

  @Builder
  uploadRecipeBuilder() {
    FlowItem() {
      Column({ space: 12 }) {
        Image($r('app.media.ic_public_add')).width(40).height(40).fillColor($r('sys.color.font_tertiary'));
        Text('上传我的菜谱').fontSize(14).fontColor($r('sys.color.font_tertiary'));
      }
      .height(160)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 添加菜谱
        if (AccountUtil.getUserInfo().isLogin) {
          RouterModule.push(RouterMap.UPLOAD_RECIPE_PAGE, undefined, () => {
            this.vm.queryMyRecipeList()
          });
        } else {
          RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
        }
      });
    }
  }
}


