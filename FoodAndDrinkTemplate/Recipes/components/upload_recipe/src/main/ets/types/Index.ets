import { media } from '@kit.MediaKit';

@ObservedV2
export class RecipeItem {
  @Trace id: number = 0;
  @Trace banner: ResourceStr = '';
  @Trace title: string = '';
  @Trace label?: string[] = [];
  @Trace used?: number = 0;
  @Trace star: number = 0;
  @Trace avatar: ResourceStr = '';
  @Trace nickname: string = '';
}


@ObservedV2
export class Step {
  @Trace description: string;
  @Trace stepImg: string;

  constructor(description: string, stepImg: string) {
    this.description = description;
    this.stepImg = stepImg;
  }
}

// 菜谱用料
export interface RecipeIngredient {
  name: string;
  quantity: string;
  unit: string;
}

// 需要上传的数据
export interface UploadRecipeData {
  title: string;
  mainImg: string;
  description: string;
  ingredients: RecipeIngredient[];
  steps: Step[];
  video?: string;
  coverUrl?: string;
}

export class VideoSizeData {
  public photoSize: media.PixelMapParams = {
    width: 0,
    height: 0,
  };
  public totalTime: number = 0;
}
