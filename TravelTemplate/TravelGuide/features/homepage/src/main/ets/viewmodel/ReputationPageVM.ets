import { reputationList, ReputationItem } from '../common/mock/ReputationMockData'

@ObservedV2
export class ReputationPageVM {
  @Trace reputationList: ReputationItem[] = reputationList
}




