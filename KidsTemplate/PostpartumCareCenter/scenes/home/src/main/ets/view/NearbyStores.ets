import { MainEntryVM, StoreCard, StoreModel } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { Logger } from '@ohos_agcit/postpartum_care_center_utils';

const STORE_SHOWN_NUM: number = 2;

@Preview
@ComponentV2
export struct NearbyStores {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local currentIndex: number = 0;
  @Local panTranslateX: number = 0; // X轴偏移量

  build() {
    Column() {
      Stack() {
        ForEach(this.vm.storeListNearby.storeList, (item: StoreModel, index: number) => {
          StoreCard({ store: item })
            .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
            .width(`${(1.0 - 0.9 * (index - this.currentIndex) * 0.05) * 100}%`)
            .align(Alignment.Center)
            .zIndex(this.vm.storeListNearby.storeList.length - index)
            .position({
              y: item.translateY + (index - this.currentIndex) * 10,
              x: item.translateX + (index - this.currentIndex) * 8,
            })
            .opacity((index <= STORE_SHOWN_NUM) ? 1 : 0)
            .priorityGesture(
              // 绑定拖动手势
              PanGesture()
                .onActionStart(() => {
                  this.panTranslateX = 0;
                  console.info('Pan start');
                  Logger.debug('testTag', 'Pan start');
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.panTranslateX += event.offsetX;
                  Logger.debug('testTag', 'Pan onActionUpdate');
                })
                .onActionEnd(() => {
                  const distanceThreshold = 100; // 设置距离阈值
                  if (this.panTranslateX > distanceThreshold) {
                    // 如果向右拖动的距离超过阈值，设置消失动画
                    animateTo({
                      duration: 200,
                      curve: Curve.EaseOut,
                      onFinish: () => {
                        item.translateX = 0;
                        item.translateY = 0;
                        const storeList: Array<StoreModel> = [];
                        for (let i = 0; i < this.vm.storeListNearby.storeList.length; i++) {
                          storeList.push(this.vm.storeListNearby.storeList[i]);
                        }
                        const firstStore = storeList[0];
                        storeList.push(firstStore);
                        const storeListNew: Array<StoreModel> = [];
                        for (let i = 1; i < storeList.length; i++) {
                          storeListNew.push(storeList[i]);
                        }
                        this.vm.storeListNearby.storeList = storeListNew;
                        this.vm.storeListNearby.needSortStore = false;
                        Logger.debug('testTag', 'onFinish');
                      },
                    }, () => {
                      item.translateX += 400; // 向右滑动距离
                      item.translateY -= 60; // 向上滑动距离
                    });
                  }
                  Logger.debug('testTag', 'Pan end');
                }),
            );
        }, (item: StoreModel) => JSON.stringify(item));
      }
      .height(340);
    };
  }
}