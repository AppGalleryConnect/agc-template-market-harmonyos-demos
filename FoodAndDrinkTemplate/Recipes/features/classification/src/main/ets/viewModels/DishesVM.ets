import {
  AccountUtil,
  AppStorageMap,
  BreakpointModel,
  BreakpointType,
  CommonConstants,
  GlobalContextUtils,
  Logger,
  RdbManager,
  recipesData,
  RouterMap,
  RouterModule,
  SystemBarOperation
} from 'commonlib';
import { addCollection, changeFollowers, queryRecipeDetail, RecipeDetail, removeCollection } from 'network';
import { BasketList } from '../types/Index';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { MovingPhotoViewController, photoAccessHelper } from '@kit.MediaLibraryKit';
import { CommentModel } from '../model/CommentModel';
import { CommentStore } from './CommentStore';

@ObservedV2
export class DishesVM {
  @Trace recipeDetail?: RecipeDetail = undefined
  @Trace basketList: BasketList =
    PersistenceV2.connect(BasketList, AppStorageMap.SHOPPING_BASKET, () => new BasketList())!;
  @Trace collection: boolean = false
  @Trace isFollower: boolean = false
  scroller: Scroller = new Scroller();
  stepScroller: Scroller = new Scroller();
  private context: common.UIAbilityContext = GlobalContextUtils.globalUIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace indexValue: number = -1;
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
  @Trace pageInfos: NavPathStack = RouterModule.getStack();
  @Trace src: photoAccessHelper.MovingPhoto | undefined = undefined;
  @Trace showPip: boolean = false;
  @Trace isFold: boolean = true;
  @Trace isFullScreen: boolean = true;
  @Trace comments: CommentModel[] = [];
  @Trace isStop: boolean = false;
  controller: MovingPhotoViewController = new MovingPhotoViewController();
  videoController: VideoController = new VideoController();
  commentsScroller: ListScroller = new ListScroller();
  sliderHeight: BreakpointType<string> = new BreakpointType<string>({
    sm: '92%',
    md: '97%',
    lg: '92%',
    xl: '92%',
  });
  marginLeft: BreakpointType<number> = new BreakpointType<number>({
    sm: 8,
    md: 20,
    lg: 28,
    xl: 28,
  });

  async init() {
    let recipeRouter = RouterModule.getNavParam<RecipeDetail>(RouterMap.DISHES)
    await this.rdbManager.initDatabase(this.context);
    Logger.info('Dishes detail router params:', JSON.stringify(recipeRouter))
    if (recipeRouter?.id) {
      this.comments = CommentStore.instance().getByRecipeId(recipeRouter?.id);
    }
    queryRecipeDetail(recipeRouter?.id || 0).then(async res => {
      if (res.status === 200) {
        this.recipeDetail = res.data;
        if (!this.recipeDetail?.video || (this.recipeDetail?.video && this.recipeDetail.thumbnail)) {
          this.isFullScreen = false;
        } else {
          SystemBarOperation.setWindowSystemBarProp({
            statusBarContentColor: '#ffffff',
          })
        }
        if (this.recipeDetail?.video && this.recipeDetail.thumbnail) {
          let imageUri = this.recipeDetail.thumbnail;
          let videoUri = this.recipeDetail.video;
          this.src = await photoAccessHelper.MediaAssetManager.loadMovingPhoto(this.context, imageUri, videoUri);
        }
        // 查询rdb数据，判断是insert还是update
        const result: recipesData[] = await this.rdbManager.query(this.recipeDetail.title, false);
        if (!result.length) {
          let recipes: recipesData = {
            id: this.recipeDetail.id,
            title: this.recipeDetail.title,
            description: this.recipeDetail.description,
            category: this.recipeDetail.category,
            cookingTime: this.recipeDetail.cookingTime,
            difficulty: this.recipeDetail.difficulty,
            authorId: this.recipeDetail.authorId,
            author: this.recipeDetail.author,
            authorAvatar: this.recipeDetail.authorAvatar,
            thumbnail: this.recipeDetail.thumbnail,
            views: this.recipeDetail.views,
            likes: this.recipeDetail.likes,
            isCollected: 0,
            video: this.recipeDetail.video,
            heatness: this.recipeDetail.heatness
          }
          await this.rdbManager.insertData(recipes, 0);
        }
        let filterRecipes = result.filter((item) => item.id === res.data.id)[0];
        this.collection = Boolean(filterRecipes.isCollected) || false;
      }
    })
  }

  addComment(comment: string, score: number) {
    if (this.recipeDetail?.id) {
      let authorId = AccountUtil.getUserInfo().id;
      let nickName = AccountUtil.getUserInfo().nickname;
      let icon = AccountUtil.getUserInfo().avatar;
      CommentStore.instance().addComment(this.recipeDetail.id, authorId, nickName, icon, comment, score);
      this.comments = CommentStore.instance().getByRecipeId(this.recipeDetail?.id);
    }
  }

  async addCollection() {
    if (CommonConstants.RDB_FLAG) {
      // rdb 处理
      if (this.recipeDetail) {
        let recipes: recipesData = JSON.parse(JSON.stringify(this.recipeDetail));
        await this.rdbManager.updateData(recipes, 1);
        this.collection = true
      }
    } else {
      //接口处理
      addCollection(this.recipeDetail?.id || 0).then(res => {
        if (res.status === 200) {
          this.collection = true
        }
      })
    }
  }

  async cancelCollection() {
    // rdb 处理
    if (CommonConstants.RDB_FLAG) {
      if (this.recipeDetail) {
        let recipes: recipesData = JSON.parse(JSON.stringify(this.recipeDetail));
        await this.rdbManager.updateData(recipes, 0);
        this.collection = false
      }
    } else {
      // 接口处理
      removeCollection(this.recipeDetail?.id || 0).then(res => {
        if (res.status === 200) {
          this.collection = false
        }
      })
    }
  }

  collectClick() {
    if (AccountUtil.getUserInfo().isLogin) {
      if (!this.collection) {
        this.addCollection();
      } else {
        this.cancelCollection();
      }
    } else {
      GlobalContextUtils.showToast({ message: '未登录，请登录后重试！' });
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }

  addBasket() {
    if (this.basketList.isInBasket(this.recipeDetail?.id ?? -1)) {
      return;
    }
    if (this.recipeDetail) {
      if (AccountUtil.getUserInfo().isLogin) {
        this.basketList.addBasket(this.recipeDetail);
        GlobalContextUtils.showToast({ message: '添加成功~！' });
      } else {
        GlobalContextUtils.showToast({ message: '未登录，请登录后重试！' });
        RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      }
    }
  }

  collectCb() {
    if (AccountUtil.getUserInfo().isLogin) {
      if (!this.collection) {
        this.addCollection();
      } else {
        this.cancelCollection();
      }
    } else {
      GlobalContextUtils.showToast({ message: '未登录，请登录后重试！' });
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
    }
  }

  changeFollower(isFollower: boolean) {
    if (!AccountUtil.getUserInfo().isLogin) {
      RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      return
    }
    if (isFollower) {
      changeFollowers(Number(this.recipeDetail?.authorId), 1)
    } else {
      changeFollowers(Number(this.recipeDetail?.authorId), 2)
    }
    this.isFollower = isFollower
  }

  showFullScreen() {
    this.isFullScreen = true;
  }

  @Computed
  get breakPoint() {
    return this.breakPointModel.currentBreakpoint;
  }

  @Computed
  get heightPercent() {
    return this.sliderHeight.getValue(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get dishMargin() {
    return this.marginLeft.getValue(this.breakPointModel.currentBreakpoint);
  }
}
