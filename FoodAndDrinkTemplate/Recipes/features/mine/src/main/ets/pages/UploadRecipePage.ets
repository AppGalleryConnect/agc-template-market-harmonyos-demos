import { UploadRecipeVM } from '../viewModels/UploadRecipeVM';
import { LengthMetrics } from '@kit.ArkUI';
import { buildTitleBar } from 'commonlib';
import { UploadRecipe, UploadRecipeData } from 'upload_recipe';

@Builder
export function UploadRecipeBuilder() {
  UploadRecipePage();
}

@ComponentV2
struct UploadRecipePage {
  vm: UploadRecipeVM = new UploadRecipeVM();

  build() {
    NavDestination() {
      UploadRecipe({
        uploadRecipe: (data: UploadRecipeData) => {
          this.vm.uploadRecipe(data)
        },
      })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ top: 24})
    .title(buildTitleBar('上传菜谱'), { paddingStart: LengthMetrics.vp(16) });
  }

}
