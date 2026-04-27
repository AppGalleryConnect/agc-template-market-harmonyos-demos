import {
  AccountUtil,
  RouterMap,
  RouterModule,
  UserInfo,
  RdbManager,
  recipesData,
  CommonConstants,
  BreakpointType,
  BreakpointModel,
  GlobalContextUtils
} from 'commonlib';
import {
  deleteMyRecipe,
  getBloggerInfo,
  getMyNoticeList,
  Notice,
  queryCollectionList,
  queryMyRecipeList,
} from 'network';
import { recipeListMapper } from '../mapper/Index';
import { LazyDataSource, RecipeBriefInfo } from 'featured_recipes';
import { TabIndexEnum } from 'base_ui';
import { BloggerInfo } from 'personal_homepage';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ApiHandler, GenderType, PersonalInfo, SwitchInfo } from 'collect_personal_info';

const TAG = '[MinePageVM]';

@ObservedV2
export class MinePageVM {
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace bloggerInfo: BloggerInfo = new BloggerInfo()
  @Trace recipeList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Trace authCode: string = '';
  @Trace showService: boolean = false;
  @Trace currentIndex: number = 1;
  @Trace noticeList: Notice[] = [];
  @Trace isToDelete: boolean = false;
  @Trace selectIds: number[] = [];
  private static _instance: MinePageVM;
  private context: common.UIAbilityContext = GlobalContextUtils.globalUIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);
  @Trace recipes: Array<recipesData> = [];
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 4,
    xl: 4,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace switchInfo: SwitchInfo = {
    showAvatar: true,
    showNickName: true,
    showFullName: true,
    showGender: true,
    showBirthDate: true,
    showPhoneNumber: true,
    showIntroDesc: true,
  };
  @Trace personalInfo: PersonalInfo = {
    avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_12.jpg',
    nickName: '华为用户',
    gender: GenderType.MALE,
    birthDate: new Date('1990-10-01'),
    fullName: '张三',
    phoneNumber: '10000001111',
    introDesc: '在自己的小世界里，做一个快乐的普通人，把节奏放慢，享受生活！十六岁的青春张扬 十八岁的未来可期，携零零碎碎的美好奔赴未知的将来！',
  };
  @Trace apiInfo: ApiHandler = {
    updateAvatar: (param: Object) => new Promise((resolve) => resolve()),
    updateNickName: (param: Object) => new Promise((resolve) => resolve()),
    updateGender: (param: Object) => new Promise((resolve) => resolve()),
    updateBirth: (param: Object) => new Promise((resolve) => {
      resolve()
    }),
    updateFullName: (param: Object) => new Promise((resolve) => resolve()),
    updateIntro: (param: Object) => new Promise((resolve) => resolve()),
    updatePhoneInfo: {
      codeLength: 6,
      sendCode: (phone: string) => {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            resolve()
          }, 1000)
        })
      },
      verifyCode: (phone: string, code: string) => {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            resolve()
          }, 1000)
        })
      },
    },
  };

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  @Monitor('userInfo.nickname', 'userInfo.avatar', 'userInfo.isMembership')
  changeUserInfo(monitor: IMonitor) {
    this.bloggerInfo.name = this.userInfo.isLogin ? this.userInfo.nickname : '去登录';
    this.bloggerInfo.isMembership = this.userInfo.isLogin ? this.userInfo.isMembership : false;
    if (typeof this.userInfo.avatar === 'string') {
      this.bloggerInfo.avatar = this.formatAvatar(this.userInfo.avatar)
    }
  }

  formatAvatar(avatar: string) {
    let newAvatar: ResourceStr
    if (avatar) {
      if ((typeof avatar === 'string') && avatar.startsWith('file://')) {
        newAvatar = avatar
      } else {
        newAvatar = $r(`app.media.${avatar}`)
      }
    } else {
      newAvatar = $r('app.media.ic_avatar')
    }
    return newAvatar
  }

  init() {
    this.queryUserInfo()
    this.getMyNoticeList()
    // 根据当前 tab 加载对应数据
    if (this.currentIndex === TabIndexEnum.FIRST) {
      this.queryMyRecipeList()
    } else {
      this.queryCollection()
    }
  }

  refreshMinePage() {
    this.getMyNoticeList()
    // 根据当前 tab 刷新对应数据
    if (this.currentIndex === TabIndexEnum.FIRST) {
      this.queryMyRecipeList()
    } else {
      this.queryCollection()
    }
  }

  getMyNoticeList() {
    if (!AccountUtil.getUserInfo().isLogin) {
      return
    }
    getMyNoticeList().then(res => {
      if (res.status === 200) {
        this.noticeList = res.data;
      }
    })
  }

  async queryMyRecipeList() {
    if (!AccountUtil.getUserInfo().isLogin) {
      return
    }
    this.recipeList.clear()
    const res = await queryMyRecipeList();
    if (this.currentIndex === TabIndexEnum.FIRST) {
      this.recipeList.pushArrayData(recipeListMapper(res.data));
    }
  }

  async queryCollection() {
    if (!AccountUtil.getUserInfo().isLogin) {
      return
    }
    this.recipeList.clear()

    // 接口查询或者rdb查询
    if (CommonConstants.RDB_FLAG) {
      // rdb 初始化rdb数据库
      await this.rdbManager.initDatabase(this.context);
      let result: recipesData[] = await this.rdbManager.query('', true);
      // 过滤收藏的
      result = result.filter(item => Boolean(item.isCollected))
      if (this.currentIndex === TabIndexEnum.SECOND) {
        this.recipeList.pushArrayData(recipeListMapper(result));
      }
    } else {
      //如果有接口，走接口查数据
      const res = await queryCollectionList();
      if (this.currentIndex === TabIndexEnum.SECOND) {
        this.recipeList.pushArrayData(recipeListMapper(res.data));
      }
    }
  }

  queryUserInfo() {
    if (!AccountUtil.getUserInfo().isLogin) {
      this.bloggerInfo.name = '去登录'
      this.bloggerInfo.avatar = $r('app.media.ic_avatar')
      return
    }
    getBloggerInfo(this.userInfo.id).then(res => {
      if (res.status === 200) {
        this.bloggerInfo.updateData(res.data.id, res.data.name, res.data.avatar, res.data.profile, res.data.sex,
          res.data.createdAccount, res.data.ipLocation, res.data.bloggerType, res.data.followers, res.data.fans,
          res.data.beFavorite, res.data.beFollowed, res.data.myRecipeList, res.data.collectRecipeList)
        if (this.userInfo.isLogin) {
          this.bloggerInfo.name = this.userInfo.nickname
          this.bloggerInfo.avatar = this.formatAvatar(this.userInfo.avatar)
          this.bloggerInfo.isMembership = this.userInfo.isMembership;
        }
      }
    })
  }

  changeSideBar(flag: boolean) {
    RouterModule.push(RouterMap.SIDE_BAR_PAGE)
  }

  changeTabs(index: number) {
    this.currentIndex = index
    if (this.isToDelete) {
      this.isToDelete = false
    }
    if (index === TabIndexEnum.FIRST) {
      this.queryMyRecipeList()
    } else {
      this.queryCollection()
    }
  }

  login() {
    if (AccountUtil.getUserInfo().isLogin) {
      RouterModule.push(RouterMap.PERSON_INFO_PAGE);
    } else {
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }

  changeLogin() {
    if (this.userInfo.isLogin) {
      this.init()
    } else {
      this.recipeList.clear()
      this.bloggerInfo.updateData(0, this.bloggerInfo.name, this.bloggerInfo.avatar)
      this.noticeList = this.noticeList.filter(() => false)
    }
  }

  async deleteMyRecipe(ids: number[]) {
    const res = await deleteMyRecipe(ids);
    if (res.status === 200) {
      this.queryMyRecipeList().then(() => {
        GlobalContextUtils.showToast({ message: '删除成功！' });
        this.exitDeleteMode()
      });
    }
  }

  // 选中/取消选中菜谱
  toggleSelect(id: number, selected: boolean) {
    if (selected) {
      this.selectIds.push(id)
    } else {
      this.selectIds = this.selectIds.filter(item => item !== id)
    }
  }

  // 进入删除模式
  enterDeleteMode() {
    this.isToDelete = true
  }

  // 退出删除模式
  exitDeleteMode() {
    this.isToDelete = false
    this.selectIds = []
  }

  // 删除选中的菜谱
  deleteSelectedRecipes() {
    if (this.selectIds.length > 0) {
      this.deleteMyRecipe(this.selectIds)
    }
  }


  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}
