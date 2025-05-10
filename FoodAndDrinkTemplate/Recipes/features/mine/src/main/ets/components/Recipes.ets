import { RouterMap, RouterModule } from 'commonlib';
import { RecipeItem } from '../types/Index';

@ComponentV2
export struct Recipes {
  @Param @Require recipeList: RecipeItem[];

  build() {
    Scroll() {
      if (this.recipeList.length) {
        Column({ space: 8 }) {
          ForEach(this.recipeList, (item: RecipeItem) => {
            Row({ space: 8 }) {
              Image($r(`app.media.${item.banner}`)).width(120).borderRadius(8);
              Column() {
                Text(item.title).maxLines(1).width(120).textOverflow({ overflow: TextOverflow.Ellipsis });
                Row({ space: 8 }) {
                  ForEach(item.label, (item: string) => {
                    Text(item).fontSize(10).backgroundColor('rgba(241,243,245,1.00)').padding(4).borderRadius(4);
                  }, (item: string) => item);
                };

                Column({ space: 6 }) {
                  Text(`${item.star}收藏`).fontSize(12).width(120).textAlign(TextAlign.Start);
                  Text(`${item.used}看过`).fontSize(12).width(120).textAlign(TextAlign.Start);
                };

                Row({ space: 4 }) {
                  Image($r(`app.media.${item.avatar}`)).size({ width: 20, height: 20 });
                  Text(item.nickname).fontSize(12).opacity(0.6);
                };
              }.height('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Start);
            }.height(120).width('100%').justifyContent(FlexAlign.Start).onClick(() => {
              RouterModule.push({ url: RouterMap.DISHES, param: { id: item.id } })
            });
          }, (item: RecipeItem) => item.title);
          Text('~~我已经到底了~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
        };
      } else {
        Column() {
          Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
          Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
        }.margin({ top: 72 });
      }
    }
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .padding({
      top: 12,
      left: 16,
      right: 16,
      bottom: 12,
    });
  }
}