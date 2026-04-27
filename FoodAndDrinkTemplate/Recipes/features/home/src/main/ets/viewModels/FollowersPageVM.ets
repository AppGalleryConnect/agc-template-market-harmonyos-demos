import { BreakpointModel, BreakpointType, RouterMap, RouterModule } from 'commonlib';
import { getBloggerFollowers } from 'network';
import { BloggerFollowerClz } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';

const TAG = '[FollowersPageVM]';

@ObservedV2
export class FollowersPageVM {
  @Trace followerList: BloggerFollowerClz[] = []
  @Trace authorName: string = ''
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  init() {
    let params = RouterModule.getNavParam<Record<string, number | string>>(RouterMap.FOLLOWERS_PAGE)
    let authorId = params?.id || 0
    this.authorName = params?.name?.toString() || ''
    getBloggerFollowers(Number(authorId)).then(res => {
      if (res.status === 200) {
        this.followerList =
          res.data.map(item => new BloggerFollowerClz(item.id, item.authorId, item.author, item.authorAvatar,
           authorId === 0 ? !item.isFollower : item.isFollower))
      }
    })
  }

  @Computed
  get getLanes() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}
