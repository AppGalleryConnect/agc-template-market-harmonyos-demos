import { ClubEnvironmentDetail } from '../pages/ClubEnvironmentDetail';
import { CitySelectPage } from '../pages/CitySelect';
import { SportDetail } from '../pages/SportDetail';

@Builder
export function SportDetailBuilder() {
  SportDetail();
}

@Builder
export function ClubEnvironmentDetailBuilder() {
  ClubEnvironmentDetail();
}

@Builder
export function CitySelectBuilder() {
  CitySelectPage();
}

