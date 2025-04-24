import { StoreModel } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { ActivityModel } from '@ohos_agcit/postpartum_care_center_utils';
import { ActivityEntryVM } from '../viewmodel/ActivityEntryVM';
import { ActivityCard } from './ActivityCard';

@Preview
@ComponentV2
export struct ActivityList {
  vm: ActivityEntryVM = ActivityEntryVM.instance;

  build(){

    Column(){
      List(/*{space: 10}*/){
        ForEach(this.vm.activityList, (item: ActivityModel) =>{
          if(this.vm.cityName === '全部' && this.vm.type === '全部'){
            ListItem(){
              ActivityCard({activity: item});
            }
          } else if(this.vm.cityName === '全部'){
            if (this.vm.type === item.type){
              ListItem(){
                ActivityCard({activity: item});
              }
            }
          } else if(this.vm.type === '全部'){
            if (this.vm.cityName === item.city){
              ListItem(){
                ActivityCard({activity: item});
              }
            }
          } else {
            if(this.vm.cityName === item.city && this.vm.type === item.type){
              ListItem(){
                ActivityCard({activity: item});
              }
            }
          }
        }, (item: StoreModel) => JSON.stringify(item));
      }
      .height('auto')
      .lanes(2)
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollBarWidth('app.string.border_radius_16')
      .padding({left: $r('app.string.margin_ms')})
    }
    .width('100%')
    .height('100%')

  }


}