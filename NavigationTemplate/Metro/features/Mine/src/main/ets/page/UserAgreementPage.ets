import { PrivacyAgreementPage } from './PrivacyAgreementPage'

@Builder
export function UserAgreementPageBuilder(name: string, param: Object){
  UserAgreementPage()
}

@Component
export struct UserAgreementPage{
  build() {
    PrivacyAgreementPage({title1:'用户协议',title2:'XX地铁官方APP用户协议'})
  }
}