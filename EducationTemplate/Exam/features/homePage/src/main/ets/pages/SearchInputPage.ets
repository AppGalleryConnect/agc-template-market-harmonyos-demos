import { RouterMap, RouterModule } from 'commonlib';
import { SearchQuestionPage } from '../components/SearchQuestionPage';

@ComponentV2
export struct SearchInputPage {
  build() {
    Column() {
      SearchQuestionPage({
        search: (data) => {
        },
        back: () => {
          RouterModule.pop()
        },
      })
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function SearchInputBuilder() {
  SearchInputPage();
}