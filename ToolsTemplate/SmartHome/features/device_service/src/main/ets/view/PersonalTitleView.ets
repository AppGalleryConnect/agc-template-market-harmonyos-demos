import { PersonalTitleViewModel } from '../viewmodel/PersonalTitleViewModel';

@ComponentV2
export struct PersonalTitleView {
  personalProfileViewModel: PersonalTitleViewModel = new PersonalTitleViewModel();

  @Computed
  get getTitle() {
    if (this.personalProfileViewModel.nickName === '') {
      return '智慧家';
    } else {
      return this.personalProfileViewModel.nickName + '的智慧家';
    }
  }

  build() {
    Row() {
      Text(this.getTitle)
        .fontSize(20)
        .fontWeight(FontWeight.Medium);
    }
  }
}