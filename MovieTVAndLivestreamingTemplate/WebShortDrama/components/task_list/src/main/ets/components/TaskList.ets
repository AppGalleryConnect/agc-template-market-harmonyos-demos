import { TYCard } from '../common/TYCard'
import { TaskCard } from '../common/TaskCard'
import { OnlineCheckIn } from './OnlineCheckIn'
import StrConstants from '../constants/StrConstants'
import { TaskModel } from '../model/TaskModel'

@ComponentV2
export struct TaskList {
  @Provider('balance') balance: number = 0
  @Event onTaskSuccess: (balance: number) => void
  @Param button: () => void = () => {
  }
  @Param taskmsg: Array<TaskModel> = [
    new TaskModel(StrConstants.LOTTERY_EVENT, 'app.media.award_lottery_event'),
    new TaskModel(StrConstants.TREASURE_BOX, 'app.media.award_treasure_box'),
    new TaskModel(StrConstants.SHARE_SHOW, 'app.media.award_share_short_dramas')
  ]
  @Param isLogin: boolean = true
  @Event loginFunc: () => void = () => {
  }

  build() {
    TYCard({
      liftTitle: $r('app.string.daily_tasks'),
      rightTitle: $r('app.string.daily_task_update'),
      topPadding: 18,
      bottomPadding: 20,
      bottomMargin: 23
    }) {
      TaskCard({
        coinIcon: 'app.media.award_coin888',
        isWatchShows: true,
        button: () => {
          if (this.isLogin) {
            this.button()
            return true
          }else {
            this.loginFunc()
            return false
          }
        },
        topMargin: 33,
        bottomMargin: 0
      })
      OnlineCheckIn({
        addAward: () => this.onTaskSuccess(this.balance)
      })
      ForEach(this.taskmsg, (item: TaskModel, index: number) => {
        TaskCard({
          leftIcon: item.titleIcon,
          title: item.title,
          dailyPointLimit: item.subTitle,
          addAward: () => this.onTaskSuccess(this.balance),
          button: () => {
            if (this.isLogin) {
              this.button()
              return true
            }else {
              this.loginFunc()
              return false
            }
          },
          topMargin: 32,
          bottomMargin: 0
        })
      }, (item: TaskModel) => item.title)
    }
  }
}
