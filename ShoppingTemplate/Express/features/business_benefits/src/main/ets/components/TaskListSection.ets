import { PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { productViewManager } from '@kit.AppGalleryKit';
import { AdvertisementComponent, RewardAdStatusHandler } from 'module_advertisement';
import { HttpApi, Logger, Task, ToastLoading, UserInfoModel } from 'lib_foundation';
import { TaskModel } from '../models/Models';

@Extend(Text)
function textFancy() {
  .fontSize(14)
  .fontWeight(400)
  .lineHeight(19)
}

@Extend(Text)
function subTextFancy() {
  .fontSize(12)
  .fontWeight(400)
  .lineHeight(16)
}


@ComponentV2
export struct TaskListSection {
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local taskList: TaskModel[] = [];
  @Local showAdView: boolean = false;
  @Local rewardAdImpl: RewardAdStatusHandler = RewardAdStatusHandler.instance;
  @Local watchAdForTask: TaskModel | undefined = undefined;

  @Monitor('rewardAdImpl.status')
  onRewardAdStatusChange() {
    if (this.rewardAdImpl.status === 'onAdReward' && this.watchAdForTask) {
      this.executeTask(this.watchAdForTask)
    } else if (this.rewardAdImpl.status === 'onAdClose') {
      this.showAdView = false;
      this.watchAdForTask = undefined;
    }
  }

  aboutToAppear(): void {
    ToastLoading.open();
    HttpApi.queryDailyTasks(this.userInfoModel.id).then((resp) => {
      if (resp.length > 0) {
        this.taskList = resp.map((item) => new TaskModel(item));
      }
    }).finally(() => {
      ToastLoading.close();
    })
  }

  // 按钮文案
  getBtnText(task: TaskModel) {
    if (task.actionText === '领取' && task.isReceived) {
      return '已领取'
    }
    if (task.currentCount >= task.targetCount) {
      return '已完成'
    }
    return task.actionText;
  }

  // 完成任务领取积分
  executeTask(taskInfo: TaskModel) {
    const data = {
      id: taskInfo.id,
      title: taskInfo.title,
      isFinished: taskInfo.isFinished,
      isReceived: taskInfo.isReceived,
      currentCount: taskInfo.currentCount + 1,
      targetCount: taskInfo.targetCount,
      rewardValue: taskInfo.rewardValue,
    } as Task;
    HttpApi.claimTaskReward(this.userInfoModel.id, data).then((resp) => {
      if (resp > 0) {
        this.userInfoModel.points += taskInfo.rewardValue;
        taskInfo.currentCount += 1;
        if (taskInfo.currentCount === taskInfo.targetCount) {
          taskInfo.isReceived = true;
          taskInfo.isFinished = true;
        }
        this.showAdView = false;
        this.watchAdForTask = undefined
      }
    })
  }

  // 观看广告
  watchAd(taskInfo: TaskModel) {
    this.showAdView = true;
    this.watchAdForTask = taskInfo;
  }

  // 下载 xx APP
  downloadApp(taskInfo: TaskModel) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    try {
      productViewManager.loadProduct(context, {
        parameters: {
          // 必填，此处填入要加载的应用包名，例如： bundleName: 'com.huawei.xxx.xxx'
          bundleName: 'com.huawei.hmsapp.books',
        }
      }, {
        onAppear: () => {
          this.executeTask(taskInfo)
        },
      });
    } catch (err) {
      Logger.error('[TaskListSection]', `loadProduct failed. error: ${JSON.stringify(err)}`);
    }
  }

  build() {
    Stack() {
      Column() {
        Text('做任务，赚积分')
          .width('100%')
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(21)
          .textAlign(TextAlign.Start)

        List({ space: 12 }) {
          Repeat(this.taskList)
            .each((taskInfo: RepeatItem<TaskModel>) => {
              ListItem() {
                this.taskItemCard(taskInfo)
              }
            })
            .key((item) => JSON.stringify(item))
        }
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .contentStartOffset(12)
        .contentEndOffset(12)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
      }
      .width('100%')
      .padding(12)
      .borderRadius(16)
      .backgroundColor(Color.White)

      if (this.showAdView) {
        AdvertisementComponent({
          testAd: 'testx9dtjwj8hp',
          adType: 7,
        })
      }
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
  }

  @Builder
  taskItemCard(taskInfo: RepeatItem<TaskModel>) {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(taskInfo.item.title)
            .fontColor($r('sys.color.font_primary'))
            .textFancy()
          Text(`+${taskInfo.item.rewardValue}`)
            .fontColor($r('sys.color.multi_color_10'))
            .textFancy()

          if (taskInfo.item.targetCount > 1) {
            Text(`(${taskInfo.item.currentCount}/${taskInfo.item.targetCount})`)
              .fontColor($r('sys.color.font_secondary'))
              .subTextFancy()
          }
        }
        Text(taskInfo.item.description)
          .fontColor($r('sys.color.font_tertiary'))
          .subTextFancy()
      }
      .alignItems(HorizontalAlign.Start)

      Button(this.getBtnText(taskInfo.item))
        .type(ButtonType.Normal)
        .width(75)
        .height(28)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(500)
        .borderRadius(8)
        .enabled(!taskInfo.item.isReceived)
        .onClick(() => {
          const taskItem = taskInfo.item
          if (taskItem.currentCount < taskItem.targetCount) {
            // 执行领取操作
            if (taskItem.actionText === '领取') {
              this.executeTask(taskInfo.item)
            } else if (taskItem.actionText === '去观看') {
              this.watchAd(taskInfo.item)
            } else if (taskItem.actionText === '去下载') {
              this.downloadApp(taskInfo.item)
            }
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}