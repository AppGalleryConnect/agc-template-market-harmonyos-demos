import { MyRecipeVM } from '../viewModels/MyRecipeVM';
import { RouterMap, RouterModule } from 'commonlib';
import { RecipeBriefInfo } from 'network';

@Builder
export function MyRecipeBuilder() {
  MyRecipe();
}

@ComponentV2
struct MyRecipe {
  vm: MyRecipeVM = MyRecipeVM.instance;

  aboutToAppear(): void {
    this.vm.getMyRecipeList()
  }

  @Builder
  recipeCardBuilder(recipe: RecipeBriefInfo) {
    Column() {
      Image($r(`app.media.${recipe.thumbnail}`)).size({ width: 160, height: 160 }).borderRadius(8);
      Text(recipe.title)
        .fontSize(14)
        .fontWeight(500)
        .margin({ top: 8, bottom: 4 })
        .width('calc(50% - 20vp)')
        .textAlign(TextAlign.Start);
      Row() {
        Row({ space: 4 }) {
          Image($r(`app.media.${recipe.authorAvatar}`)).size({ width: 20, height: 20 }).borderRadius(10);
          Text(recipe.author).fontSize(12).opacity(0.6);
        };

        Row({ space: 4 }) {
          Image($r('app.media.ic_public_star_plain')).size({ width: 14, height: 14 });
          Text(`${recipe.likes}`).fontSize(12).opacity(0.6);
        };
      }.width('calc(50% - 20vp)').justifyContent(FlexAlign.SpaceBetween);
    }.onClick(() => {
      RouterModule.push({ url: RouterMap.DISHES, param: { id: recipe.id } })
    });
  }

  build() {
    NavDestination() {
      WaterFlow() {
        FlowItem() {
          Column({ space: 12 }) {
            Image($r('app.media.ic_public_add')).width(40).height(40).fillColor('#66000000')
            Text('上传我的菜谱').fontSize(14).fontColor('#66000000')
          }
          .height('100%')
          .width(160)
          .backgroundColor('#F1F3F5')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            // 添加菜谱
            RouterModule.push({ url: RouterMap.UPLOAD_RECIPE })

          });
        }.height(160);

        ForEach(this.vm.recipeList, (item: RecipeBriefInfo) => {
          FlowItem() {
            this.recipeCardBuilder(item);
          };
        });
      }
      .cachedCount(4)
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
      .layoutWeight(1)
      .padding(16);
    }.title('我的菜谱')
    .onShown(() => {
      this.vm.getMyRecipeList()
    })
  }
}

