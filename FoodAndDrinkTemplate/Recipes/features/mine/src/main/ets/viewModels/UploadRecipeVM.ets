import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { Logger, RouterModule } from 'commonlib';
import { RecipeIngredient, RecipeStep, uploadMyRecipe, UploadRecipeBody } from 'network';
import { Step } from '../types/Index';
import { promptAction } from '@kit.ArkUI';

const TAG = '[UploadRecipeVM]';

@ObservedV2
export class UploadRecipeVM {
  // 主图
  @Trace mainImg: string = '';
  // 标题
  @Trace title: string = ''
  // 最大长度
  @Trace maxLength: number = 200
  // 当前长度
  @Trace curLength: number = 0
  // 描述
  @Trace description: string = ''
  // 用料
  @Trace ingredients: RecipeIngredient[] = [{ name: '', quantity: '', unit: '' }]
  // 步骤
  @Trace steps: Step[] = [new Step('', '')]
  // 记录当前步骤
  @Trace curStep: number = 1
  private static _instance: UploadRecipeVM;

  public static get instance() {
    if (!UploadRecipeVM._instance) {
      UploadRecipeVM._instance = new UploadRecipeVM();
    }
    return UploadRecipeVM._instance;
  }

  public clearData() {
    this.title = ''
    this.curLength = 0
    this.description = ''
    this.mainImg = ''
    this.curStep = 1
    this.ingredients = [{ name: '', quantity: '', unit: '' }]
    this.steps = [new Step('', '')]
  }

  isStepsEmpty(): boolean {
    let isEmpty: boolean = false
    this.steps.forEach((val) => {
      if (!val.description || !val.stepImg) {
        isEmpty = true
      }
    })
    return isEmpty
  }

  isIngredientsEmpty(): boolean {
    let isEmpty: boolean = false
    this.ingredients.forEach((val) => {
      if (!val.name || !val.quantity) {
        isEmpty = true
      }
    })
    return isEmpty
  }

  isUploadValid(): boolean {
    if (!this.title) {
      promptAction.showToast({ message: '请填写标题！' });
      return false
    }

    if (!this.mainImg) {
      promptAction.showToast({ message: '请上传主图！' });
      return false
    }
    if (!this.description) {
      promptAction.showToast({ message: '请补充描述！' });
      return false
    }
    if (this.isIngredientsEmpty()) {
      promptAction.showToast({ message: '请补充用料名称、数量！' });
      return false
    }
    if (this.isStepsEmpty()) {
      promptAction.showToast({ message: '请完善步骤！' });
      return false
    }

    return true
  }

  public async uploadRecipe() {
    const data: UploadRecipeBody = {
      description: this.description,
      title: this.title,
      ingredients: this.ingredients,
      steps: this.steps.map((item: Step, index) => {
        const val: RecipeStep = {
          description: item.description,
          stepNumber: index + 1,
        };
        return val;
      }),
    };
    try {
      const res = await uploadMyRecipe(data)
      if (res.status === 200) {
        promptAction.showToast({ message: '上传成功！' });
        RouterModule.pop()
      }

    } catch (err) {
      promptAction.showToast({ message: '上传失败！' });
      Logger.error(TAG, err)
    }
  }

  // 获取图片
  public async selectImage(): Promise<string> {
    return new Promise((resolve, reject) => {
      try {
        let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
        PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
        PhotoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new photoAccessHelper.PhotoViewPicker();
        photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          let imgFile: fs.File | null = null;
          try {
            imgFile = fs.openSync(PhotoSelectResult.photoUris[0]!, fs.OpenMode.READ_ONLY);
            let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
            fs.copyFileSync(imgFile.fd, newPath);
            resolve('file://' + newPath);
          } catch (err) {
            Logger.error(TAG, 'get photo error:' + err);
            reject(err);
          } finally {
            if (imgFile) {
              fs.closeSync(imgFile);
            }
          }
        }).catch((err: BusinessError) => {
          Logger.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
          reject(err);
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        Logger.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
        reject(err);
      }
    });
  }
}